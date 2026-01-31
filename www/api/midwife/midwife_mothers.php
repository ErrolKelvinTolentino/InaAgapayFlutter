<?php
header('Content-Type: application/json');
require_once '../db.php';

$sql = "
SELECT
    m.mother_id,
    a.first_name,
    a.middle_name,
    a.last_name,
    a.extension_name,
    a.phone_number,
    m.barangay,
    m.city_municipality,
    m.province,
    p.pregnancy_id,
    p.pregnancy_risk_level,
    p.status AS pregnancy_status,
    p.expected_date_of_delivery,
    p.last_menstrual_period
FROM mothers m
JOIN accounts a ON m.account_id = a.account_id
LEFT JOIN pregnancies p 
    ON p.mother_id = m.mother_id AND p.status = 'ongoing'
ORDER BY a.last_name ASC
";

$result = $conn->query($sql);

$mothers = [];

while ($row = $result->fetch_assoc()) {
    $mothers[] = $row;
}

echo json_encode([
    'success' => true,
    'data' => $mothers
]);
