<?php
require_once __DIR__ . '/../auth/auth_check.php';

header('Content-Type: application/json');

$childId = $_GET['child_id'] ?? null;

if (!$childId) {
    echo json_encode([
        'success' => false,
        'message' => 'Missing child_id'
    ]);
    exit;
}

/**
 * CHILD BASIC INFO
 */
$stmt = $conn->prepare("
    SELECT
        c.child_id,
        c.first_name,
        c.middle_name,
        c.last_name,
        TIMESTAMPDIFF(YEAR, bd.birthdate, CURDATE()) AS age_years
    FROM children c
    LEFT JOIN birth_details bd ON bd.child_id = c.child_id
    WHERE c.child_id = ?
    LIMIT 1
");
$stmt->bind_param("i", $childId);
$stmt->execute();
$child = $stmt->get_result()->fetch_assoc();

if (!$child) {
    echo json_encode([
        'success' => false,
        'message' => 'Child not found'
    ]);
    exit;
}

/**
 * BIRTH DETAILS
 */
$stmt = $conn->prepare("
    SELECT
        birthdate,
        birth_place
    FROM birth_details
    WHERE child_id = ?
    LIMIT 1
");
$stmt->bind_param("i", $childId);
$stmt->execute();
$birth = $stmt->get_result()->fetch_assoc();

/**
 * LATEST GROWTH RECORD
 */
$stmt = $conn->prepare("
    SELECT
        child_height,
        child_weight,
        ROUND(child_weight / POW(child_height / 100, 2), 1) AS bmi
    FROM child_details
    WHERE child_id = ?
    ORDER BY created_at DESC
    LIMIT 1
");
$stmt->bind_param("i", $childId);
$stmt->execute();
$growth = $stmt->get_result()->fetch_assoc();

/**
 * LATEST IMMUNIZATION
 */
$stmt = $conn->prepare("
    SELECT
        v.vaccine_name,
        ir.vaccination_date
    FROM immunization_record ir
    JOIN vaccines v ON v.vaccine_id = ir.vaccine_id
    WHERE ir.child_id = ?
    ORDER BY ir.vaccination_date DESC
    LIMIT 1
");
$stmt->bind_param("i", $childId);
$stmt->execute();
$latestImm = $stmt->get_result()->fetch_assoc();

/**
 * NEXT IMMUNIZATION
 */
$stmt = $conn->prepare("
    SELECT
        v.vaccine_name,
        v.recommended_age_months
    FROM vaccines v
    WHERE v.target_recipients = 'child'
    ORDER BY v.recommended_age_months ASC
    LIMIT 1
");
$stmt->execute();
$nextImm = $stmt->get_result()->fetch_assoc();

/**
 * FINAL RESPONSE
 */
echo json_encode([
    'success' => true,
    'child' => $child,
    'birth' => $birth ?: [],
    'growth' => $growth ?: [],
    'latest_immunization' => $latestImm ?: [],
    'next_immunization' => $nextImm ?: []
]);
