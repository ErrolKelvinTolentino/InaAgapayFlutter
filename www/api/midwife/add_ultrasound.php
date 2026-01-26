<?php
require_once __DIR__ . '/../auth/auth_check.php';
header('Content-Type: application/json');

$pregnancyId = $_POST['pregnancy_id'] ?? null;
$date = $_POST['ultrasound_date'] ?? null;
$location = $_POST['ultrasound_location'] ?? null;
$remarks = $_POST['remarks'] ?? null;
$workerName = $_POST['health_worker_name'] ?? null;
$institution = $_POST['health_worker_institution'] ?? null;
$profession = $_POST['health_worker_profession'] ?? null;

if (!$pregnancyId || !$date) {
    echo json_encode([
        'success' => false,
        'message' => 'Required fields missing'
    ]);
    exit;
}

$stmt = $conn->prepare("
    INSERT INTO ultrasounds (
        pregnancy_id,
        ultrasound_date,
        ultrasound_location,
        remarks,
        health_worker_name,
        health_worker_institution,
        health_worker_profession
    ) VALUES (?, ?, ?, ?, ?, ?, ?)
");

$stmt->bind_param(
    "issssss",
    $pregnancyId,
    $date,
    $location,
    $remarks,
    $workerName,
    $institution,
    $profession
);

if ($stmt->execute()) {
    echo json_encode(['success' => true]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Insert failed'
    ]);
}
