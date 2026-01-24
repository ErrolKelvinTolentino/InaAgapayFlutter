<?php
session_start();
header('Content-Type: application/json; charset=utf-8');
error_reporting(0);

require_once 'db.php';

$data = [];

/* Not logged in */
if (!isset($_SESSION['account_id'])) {
    echo json_encode($data);
    exit;
}

$account_id = $_SESSION['account_id'];

/* Get midwife_id */
$stmt = $conn->prepare(
    "SELECT midwife_id FROM midwives WHERE account_id = ?"
);
$stmt->bind_param('i', $account_id);
$stmt->execute();
$res = $stmt->get_result();

if ($res->num_rows === 0) {
    echo json_encode($data);
    exit;
}

$midwife_id = $res->fetch_assoc()['midwife_id'];

/* Schedules for mothers handled by this midwife */
$sql = "
SELECT
    a.first_name,
    a.last_name,
    cs.scheduled_date,
    cs.status
FROM prenatal_checkups pc
JOIN pregnancies p ON pc.pregnancy_id = p.pregnancy_id
JOIN mothers m ON p.mother_id = m.mother_id
JOIN accounts a ON m.account_id = a.account_id
JOIN checkup_schedule cs ON cs.mother_id = m.mother_id
WHERE pc.midwife_id = ?
ORDER BY cs.scheduled_date ASC
";

$stmt = $conn->prepare($sql);
$stmt->bind_param('i', $midwife_id);
$stmt->execute();
$result = $stmt->get_result();

while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data);
exit;
