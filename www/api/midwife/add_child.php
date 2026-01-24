<?php
header('Content-Type: application/json');
require_once '../db.php';

$data = json_decode(file_get_contents("php://input"), true);

$conn->begin_transaction();

try {
    // =========================
    // 1. HANDLE MOTHER
    // =========================

    if (!empty($data['existing_mother_id'])) {
        $mother_id = (int)$data['existing_mother_id'];
    } else {
        // Create account for mother
        $stmt = $conn->prepare("
            INSERT INTO accounts (account_type, first_name, middle_name, last_name, extension_name, is_verified, status)
            VALUES ('mother', ?, ?, ?, ?, 1, 'active')
        ");
        $stmt->bind_param(
            "ssss",
            $data['mother_first_name'],
            $data['mother_middle_name'],
            $data['mother_last_name'],
            $data['mother_extension_name']
        );
        $stmt->execute();

        $account_id = $stmt->insert_id;

        // Create mother profile
        $stmt = $conn->prepare("
            INSERT INTO mothers (account_id, house_number, street, barangay, city_municipality, province)
            VALUES (?, ?, ?, ?, ?, ?)
        ");
        $stmt->bind_param(
            "isssss",
            $account_id,
            $data['house_number'],
            $data['street'],
            $data['barangay'],
            $data['city_municipality'],
            $data['province']
        );
        $stmt->execute();

        $mother_id = $stmt->insert_id;
    }

    // =========================
    // 2. INSERT CHILD
    // =========================
    $stmt = $conn->prepare("
        INSERT INTO children (mother_id, first_name, last_name, middle_name, extension_name, sex)
        VALUES (?, ?, ?, ?, ?, ?)
    ");
    $stmt->bind_param(
        "isssss",
        $mother_id,
        $data['child_first_name'],
        $data['child_last_name'],
        $data['child_middle_name'],
        $data['child_extension_name'],
        $data['sex']
    );
    $stmt->execute();

    $child_id = $stmt->insert_id;

    // =========================
    // 3. INSERT BIRTH DETAILS
    // =========================
    $stmt = $conn->prepare("
        INSERT INTO birth_details (child_id, birthdate, birth_place)
        VALUES (?, ?, ?)
    ");
    $stmt->bind_param(
        "iss",
        $child_id,
        $data['birthdate'],
        $data['birth_place']
    );
    $stmt->execute();

    $conn->commit();

    echo json_encode([
        'success' => true,
        'child_id' => $child_id
    ]);
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
