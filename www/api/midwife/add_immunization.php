<?php
require_once __DIR__ . '/../config/db.php';
header('Content-Type: application/json');

$data = json_decode(file_get_contents('php://input'), true);

$child_id = intval($data['child_id'] ?? 0);
$vaccine_id = intval($data['vaccine_id'] ?? 0);
$vaccination_date = $data['vaccination_date'] ?? null;
$remarks = $data['remarks'] ?? null;

if (!$child_id || !$vaccine_id || !$vaccination_date) {
    echo json_encode([
        'success' => false,
        'message' => 'Missing required fields'
    ]);
    exit;
}

/* prevent duplicate vaccine per child */
$check = $conn->prepare("
    SELECT immunization_record_id
    FROM immunization_record
    WHERE child_id = ? AND vaccine_id = ?
");
$check->bind_param("ii", $child_id, $vaccine_id);
$check->execute();

if ($check->get_result()->num_rows > 0) {
    echo json_encode([
        'success' => false,
        'message' => 'Vaccine already recorded for this child'
    ]);
    exit;
}

$stmt = $conn->prepare("
    INSERT INTO immunization_record
        (child_id, vaccine_id, vaccination_date, remarks)
    VALUES (?, ?, ?, ?)
");

$stmt->bind_param(
    "iiss",
    $child_id,
    $vaccine_id,
    $vaccination_date,
    $remarks
);

if ($stmt->execute()) {
    echo json_encode(['success' => true]);
} else {
    echo json_encode([
        'success' => false,
        'message' => $conn->error
    ]);
}
