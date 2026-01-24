<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

header("Content-Type: application/json");
require_once __DIR__ . '/../db.php';


$filter = $_GET['filter'] ?? 'all';

$dateCondition = "";
if ($filter === "today") {
    $dateCondition = "AND DATE(p.created_at) = CURDATE()";
} elseif ($filter === "week") {
    $dateCondition = "AND YEARWEEK(p.created_at,1) = YEARWEEK(CURDATE(),1)";
} elseif ($filter === "month") {
    $dateCondition = "AND MONTH(p.created_at)=MONTH(CURDATE()) AND YEAR(p.created_at)=YEAR(CURDATE())";
}

/* ================= TRIMESTERS ================= */
$trimesterSql = "
SELECT
COALESCE(SUM(CASE WHEN TIMESTAMPDIFF(WEEK, last_menstrual_period, CURDATE()) <= 12 THEN 1 ELSE 0 END),0) AS first_trimester,
COALESCE(SUM(CASE WHEN TIMESTAMPDIFF(WEEK, last_menstrual_period, CURDATE()) BETWEEN 13 AND 27 THEN 1 ELSE 0 END),0) AS second_trimester,
COALESCE(SUM(CASE WHEN TIMESTAMPDIFF(WEEK, last_menstrual_period, CURDATE()) >= 28 THEN 1 ELSE 0 END),0) AS third_trimester
FROM pregnancies p
WHERE p.status='ongoing'
AND p.last_menstrual_period IS NOT NULL
$dateCondition
";
$trimester = $conn->query($trimesterSql)->fetch_assoc();

/* ================= CHECKUPS ================= */
$checkupSql = "
SELECT
COALESCE(COUNT(DISTINCT m.mother_id),0) AS mothers,
COALESCE(COUNT(DISTINCT c.child_id),0) AS children
FROM checkup_schedule cs
LEFT JOIN mothers m ON cs.mother_id = m.mother_id
LEFT JOIN children c ON c.mother_id = m.mother_id
WHERE cs.status='scheduled'
AND cs.scheduled_date >= CURDATE()
";
$checkups = $conn->query($checkupSql)->fetch_assoc();

/* ================= BIRTH OUTCOMES ================= */
$outcomeSql = "
SELECT
COALESCE(SUM(outcome='live_birth'),0) AS live_births,
COALESCE(SUM(outcome='stillbirth'),0) AS stillbirths
FROM pregnancies p
WHERE p.status='ended'
$dateCondition
";
$outcomes = $conn->query($outcomeSql)->fetch_assoc();

/* ================= PLACE OF DELIVERY ================= */
$deliverySql = "
SELECT
COALESCE(SUM(place_of_delivery LIKE '%hospital%'),0) AS hospital,
COALESCE(SUM(place_of_delivery LIKE '%center%'),0) AS center,
COALESCE(SUM(place_of_delivery LIKE '%home%'),0) AS home
FROM deliveries d
JOIN pregnancies p ON d.pregnancy_id = p.pregnancy_id
$dateCondition
";
$delivery = $conn->query($deliverySql)->fetch_assoc();

/* ================= OUTPUT ================= */
echo json_encode([
    "trimester" => $trimester,
    "checkups" => $checkups,
    "outcomes" => $outcomes,
    "delivery" => $delivery
]);
