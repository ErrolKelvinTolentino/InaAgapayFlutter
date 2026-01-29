<?php
require_once __DIR__ . '/../db.php';

// swallow auth output (safety)
ob_start();
require_once __DIR__ . '/../auth/auth_check.php';
ob_end_clean();

header('Content-Type: application/json');

try {
    $payload = json_decode(file_get_contents('php://input'), true);
    if (!$payload) {
        throw new Exception('Invalid JSON payload');
    }

    $pregnancyId = $payload['pregnancy_id'] ?? null;
    if (empty($pregnancyId)) {
        throw new Exception('pregnancy_id is required');
    }

    // Resolve midwife_id from authenticated account
    $accountId = $AUTH_USER['account_id'];
    $midStmt = $conn->prepare("SELECT midwife_id FROM midwives WHERE account_id = ? LIMIT 1");
    $midStmt->bind_param("i", $accountId);
    $midStmt->execute();
    $midResult = $midStmt->get_result();
    if ($midResult->num_rows !== 1) {
        throw new Exception('Midwife account not found');
    }
    $midwifeId = $midResult->fetch_assoc()['midwife_id'];

    // Resolve mother_id from pregnancy
    $motherStmt = $conn->prepare("SELECT mother_id FROM pregnancies WHERE pregnancy_id = ? LIMIT 1");
    $motherStmt->bind_param("i", $pregnancyId);
    $motherStmt->execute();
    $motherRes = $motherStmt->get_result();
    if ($motherRes->num_rows !== 1) {
        throw new Exception('Pregnancy not found');
    }
    $motherId = $motherRes->fetch_assoc()['mother_id'];

    $conn->begin_transaction();

    $checkupDate = $payload['checkup_date'] ?? date('Y-m-d');
    $ageOfGestation = $payload['age_of_gestation'] ?? null;
    $weight = $payload['checkup_weight'] ?? null;
    $sys = $payload['blood_pressure_systolic'] ?? null;
    $dia = $payload['blood_pressure_diastolic'] ?? null;
    $fetalPos = $payload['fetal_position'] ?? null;
    $fetalHB = $payload['fetal_heart_beat'] ?? null;
    $fetalTone = $payload['fetal_heart_tone'] ?? null;
    $edema = $payload['edema'] ?? 'none';
    $remarks = $payload['remarks'] ?? null;
    $nextSchedule = $payload['next_schedule'] ?? null;

    $stmt = $conn->prepare("INSERT INTO prenatal_checkups (
            pregnancy_id, midwife_id, age_of_gestation, checkup_weight,
            blood_pressure_systolic, blood_pressure_diastolic,
            fetal_position, fetal_heart_beat, fetal_heart_tone,
            edema, remarks, checkup_date, next_schedule
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

    $stmt->bind_param(
        "iiddiisissssss",
        $pregnancyId,
        $midwifeId,
        $ageOfGestation,
        $weight,
        $sys,
        $dia,
        $fetalPos,
        $fetalHB,
        $fetalTone,
        $edema,
        $remarks,
        $checkupDate,
        $nextSchedule
    );
    $stmt->execute();
    $prenatalId = $conn->insert_id;

    // Mother medications (plan)
    if (!empty($payload['medications'])) {
        $medStmt = $conn->prepare("INSERT INTO mother_medications (
                mother_id, mother_medication_name, frequency, quantity,
                start_date, end_date, status
            ) VALUES (?, ?, ?, ?, ?, ?, 'active')");
        foreach ($payload['medications'] as $m) {
            $medStmt->bind_param(
                "ississ",
                $motherId,
                $m['name'],
                $m['frequency'],
                $m['quantity'],
                $m['start_date'],
                $m['end_date']
            );
            $medStmt->execute();
        }
    }

    // Given medications (dispensed)
    if (!empty($payload['given_medications'])) {
        $givenStmt = $conn->prepare("INSERT INTO given_medications (
                mother_id, given_medication_name, quantity, date_given
            ) VALUES (?, ?, ?, ?)");
        foreach ($payload['given_medications'] as $g) {
            $givenDate = $g['date_given'] ?? date('Y-m-d');
            $givenStmt->bind_param(
                "isis",
                $motherId,
                $g['name'],
                $g['quantity'],
                $givenDate
            );
            $givenStmt->execute();
        }
    }

    // Optionally update mother weight with latest checkup weight
    if (!empty($payload['update_mother_weight']) && $weight !== null) {
        $upd = $conn->prepare("UPDATE mothers SET weight = ? WHERE mother_id = ? LIMIT 1");
        $upd->bind_param("di", $weight, $motherId);
        $upd->execute();
    }

    $conn->commit();

    echo json_encode([
        'success' => true,
        'prenatal_checkup_id' => $prenatalId,
    ]);
} catch (Throwable $e) {
    $conn->rollback();
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
    ]);
}
