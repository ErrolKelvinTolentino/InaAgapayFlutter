<?php
header('Content-Type: application/json');
require_once '../db.php';

$sql = "
SELECT
    c.child_id,
    c.first_name,
    c.last_name,
    c.sex,
    bd.birthdate,
    CONCAT(a.first_name, ' ', a.last_name) AS mother_name
FROM children c
JOIN mothers m ON c.mother_id = m.mother_id
JOIN accounts a ON m.account_id = a.account_id
LEFT JOIN birth_details bd ON bd.child_id = c.child_id
ORDER BY bd.birthdate DESC
";

$result = $conn->query($sql);

$children = [];

while ($row = $result->fetch_assoc()) {
    $children[] = $row;
}

echo json_encode([
    'success' => true,
    'data' => $children
]);
