<?php
require_once __DIR__ . '/../auth/auth_check.php';
require_once __DIR__ . '/../db.php';

header('Content-Type: application/json');

if (($AUTH_USER['account_type'] ?? null) !== 'mother') {
    echo json_encode(['success' => false]);
    exit;
}

$accountId = $AUTH_USER['account_id'];

$stmt = $conn->prepare("
    SELECT p.pregnancy_id
    FROM pregnancies p
    JOIN mothers m ON m.mother_id = p.mother_id
    WHERE m.account_id = ?
      AND p.status = 'ongoing'
    LIMIT 1
");
$stmt->bind_param("i", $accountId);
$stmt->execute();
$pregnancy = $stmt->get_result()->fetch_assoc();

$stmt = $conn->prepare("
    SELECT *
    FROM prenatal_checkups
    WHERE pregnancy_id = ?
    ORDER BY checkup_date DESC
");
$stmt->bind_param("i", $pregnancy['pregnancy_id']);
$stmt->execute();

echo json_encode([
    'success' => true,
    'checkups' => $stmt->get_result()->fetch_all(MYSQLI_ASSOC)
]);
