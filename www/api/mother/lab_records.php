<?php
require_once __DIR__ . '/../auth/auth_check.php';
require_once __DIR__ . '/../db.php';

header('Content-Type: application/json');

$accountId = $AUTH_USER['account_id'];

$stmt = $conn->prepare("
    SELECT mother_id FROM mothers WHERE account_id = ?
");
$stmt->bind_param("i", $accountId);
$stmt->execute();
$mother = $stmt->get_result()->fetch_assoc();

$stmt = $conn->prepare("
    SELECT pregnancy_id FROM pregnancies
    WHERE mother_id = ? AND status = 'ongoing'
");
$stmt->bind_param("i", $mother['mother_id']);
$stmt->execute();
$preg = $stmt->get_result()->fetch_assoc();

$stmt = $conn->prepare("
    SELECT
        lab_test_date,
        lab_test_type,
        health_worker_name,
        lab_test_location,
        remarks
    FROM lab_tests
    WHERE pregnancy_id = ?
    ORDER BY lab_test_date DESC
");
$stmt->bind_param("i", $preg['pregnancy_id']);
$stmt->execute();

echo json_encode([
    'success' => true,
    'records' => $stmt->get_result()->fetch_all(MYSQLI_ASSOC)
]);
