<?php
require_once __DIR__ . '/../auth/auth_check.php';
require_once __DIR__ . '/../db.php';

header('Content-Type: application/json');

if (($AUTH_USER['account_type'] ?? null) !== 'mother') {
    echo json_encode(['success' => false]);
    exit;
}

$stmt = $conn->prepare("
    SELECT m.mother_id
    FROM mothers m
    WHERE m.account_id = ?
    LIMIT 1
");
$stmt->bind_param("i", $AUTH_USER['account_id']);
$stmt->execute();
$mother = $stmt->get_result()->fetch_assoc();

$stmt = $conn->prepare("
    SELECT
        pregnancy_id,
        last_menstrual_period,
        expected_date_of_delivery,
        outcome,
        outcome_date,
        gestational_age_at_end
    FROM pregnancies
    WHERE mother_id = ?
    ORDER BY created_at DESC
");
$stmt->bind_param("i", $mother['mother_id']);
$stmt->execute();

echo json_encode([
    'success' => true,
    'history' => $stmt->get_result()->fetch_all(MYSQLI_ASSOC)
]);
