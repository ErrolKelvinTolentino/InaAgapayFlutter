<?php
require_once __DIR__ . '/../db.php';

header('Content-Type: application/json');

$childId = $_POST['child_id'] ?? null;
$height  = $_POST['height'] ?? null;
$weight  = $_POST['weight'] ?? null;

if (!$childId || !$height || !$weight) {
    echo json_encode([
        'success' => false,
        'message' => 'Missing required fields'
    ]);
    exit;
}

$stmt = $conn->prepare("
    INSERT INTO child_details (child_id, child_height, child_weight)
    VALUES (?, ?, ?)
");

$stmt->bind_param("idd", $childId, $height, $weight);

if ($stmt->execute()) {
    echo json_encode(['success' => true]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Database error'
    ]);
}
