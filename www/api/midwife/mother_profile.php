<?php
require_once __DIR__ . '/../auth/auth_check.php';
header('Content-Type: application/json');

$motherId = $_GET['mother_id'] ?? null;

if (!$motherId) {
    echo json_encode([
        'success' => false,
        'message' => 'Mother ID is required'
    ]);
    exit;
}

$stmt = $conn->prepare("
    SELECT
        mo.mother_id,
        a.first_name,
        a.middle_name,
        a.last_name,
        a.extension_name,
        a.email_address,
        a.phone_number,
        a.status,

        mo.house_number,
        mo.street,
        mo.barangay,
        mo.city_municipality,
        mo.province,
        mo.height,
        mo.blood_type,

        p.pregnancy_id,
        p.pregnancy_risk_level,
        p.status AS pregnancy_status,
        p.expected_date_of_delivery,
        p.last_menstrual_period,

        (SELECT COUNT(*) FROM children c WHERE c.mother_id = mo.mother_id) AS children_count

    FROM mothers mo
    JOIN accounts a ON a.account_id = mo.account_id
    LEFT JOIN pregnancies p 
        ON p.mother_id = mo.mother_id 
        AND p.status = 'ongoing'

    WHERE mo.mother_id = ?
    LIMIT 1
");

$stmt->bind_param("i", $motherId);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode([
        'success' => false,
        'message' => 'Mother not found'
    ]);
    exit;
}

echo json_encode([
    'success' => true,
    'mother' => $result->fetch_assoc()
]);
