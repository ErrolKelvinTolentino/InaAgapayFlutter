<?php
require_once __DIR__ . '/../db.php';

// swallow auth output (safety)
ob_start();
require_once __DIR__ . '/../auth/auth_check.php';
ob_end_clean();

header('Content-Type: application/json');

try {
    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input) {
        throw new Exception('Invalid JSON payload');
    }

    $conn->begin_transaction();

    // ===== ACCOUNT =====
    $acc = $input['account'] ?? [];
    if (empty($acc['email_address'])) {
        throw new Exception('Email is required');
    }

    $stmt = $conn->prepare("
        INSERT INTO accounts (
            email_address, account_type,
            first_name, middle_name, last_name, extension_name,
            phone_number, is_verified
        ) VALUES (?, 'mother', ?, ?, ?, ?, ?, 1)
    ");
    $stmt->bind_param(
        "ssssss",
        $acc['email_address'],
        $acc['first_name'],
        $acc['middle_name'],
        $acc['last_name'],
        $acc['extension_name'],
        $acc['phone_number']
    );
    $stmt->execute();

    $accountId = $conn->insert_id;

    // ===== MOTHER =====
    $addr = $input['address'] ?? [];
    $stmt = $conn->prepare("
        INSERT INTO mothers (
            account_id, house_number, street,
            barangay, city_municipality, province
        ) VALUES (?, ?, ?, ?, ?, ?)
    ");
    $stmt->bind_param(
        "isssss",
        $accountId,
        $addr['house_number'],
        $addr['street'],
        $addr['barangay'],
        $addr['city_municipality'],
        $addr['province']
    );
    $stmt->execute();

    $motherId = $conn->insert_id;

    // ===== EMERGENCY CONTACT =====
    if (!empty($input['emergency_contact'])) {
        $ec = $input['emergency_contact'];
        $stmt = $conn->prepare("
            INSERT INTO emergency_contacts (
                mother_id, first_name, middle_name,
                last_name, extension_name,
                phone_number, email_address
            ) VALUES (?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->bind_param(
            "issssss",
            $motherId,
            $ec['first_name'],
            $ec['middle_name'],
            $ec['last_name'],
            $ec['extension_name'],
            $ec['phone_number'],
            $ec['email_address']
        );
        $stmt->execute();
    }

    // ===== MEDICAL CONDITIONS =====
    if (!empty($input['medical_conditions'])) {
        $stmt = $conn->prepare("
            INSERT INTO medical_conditions (mother_id, condition_name)
            VALUES (?, ?)
        ");
        foreach ($input['medical_conditions'] as $c) {
            $stmt->bind_param("is", $motherId, $c);
            $stmt->execute();
        }
    }

    // ===== ALLERGIES =====
    if (!empty($input['allergies'])) {
        $stmt = $conn->prepare("
            INSERT INTO allergies (
                mother_id, allergen, diagnosis_date, treatment
            ) VALUES (?, ?, ?, ?)
        ");
        foreach ($input['allergies'] as $a) {
            $stmt->bind_param(
                "isss",
                $motherId,
                $a['allergen'],
                $a['diagnosis_date'],
                $a['treatment']
            );
            $stmt->execute();
        }
    }

    // ===== PREGNANCY =====
    if (!empty($input['pregnancy'])) {
        $p = $input['pregnancy'];
        $stmt = $conn->prepare("
            INSERT INTO pregnancies (
                mother_id, pregnancy_risk_level,
                last_menstrual_period,
                expected_date_of_delivery,
                status
            ) VALUES (?, ?, ?, ?, 'ongoing')
        ");
        $stmt->bind_param(
            "isss",
            $motherId,
            $p['pregnancy_risk_level'],
            $p['last_menstrual_period'],
            $p['expected_date_of_delivery']
        );
        $stmt->execute();
    }

    $conn->commit();

    echo json_encode([
        'success' => true,
        'mother_id' => $motherId
    ]);

} catch (Throwable $e) {
    $conn->rollback();
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
