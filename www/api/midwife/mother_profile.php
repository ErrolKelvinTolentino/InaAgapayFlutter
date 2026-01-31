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
        mo.weight,
        mo.blood_type,
        mo.birthdate,

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

$mother = $result->fetch_assoc();

// Medical conditions
$medStmt = $conn->prepare("SELECT condition_name, diagnosis_date, status, remarks, created_at FROM medical_conditions WHERE mother_id = ? ORDER BY created_at DESC");
$medStmt->bind_param('i', $motherId);
$medStmt->execute();
$medRes = $medStmt->get_result();
$medicalConditions = $medRes->fetch_all(MYSQLI_ASSOC);

// Allergies
$allStmt = $conn->prepare("SELECT allergen, diagnosis_date, status, treatment, remarks, created_at FROM allergies WHERE mother_id = ? ORDER BY created_at DESC");
$allStmt->bind_param('i', $motherId);
$allStmt->execute();
$allRes = $allStmt->get_result();
$allergies = $allRes->fetch_all(MYSQLI_ASSOC);

// Pregnancies (current + past)
$pregStmt = $conn->prepare("SELECT * FROM pregnancies WHERE mother_id = ? ORDER BY created_at DESC");
$pregStmt->bind_param('i', $motherId);
$pregStmt->execute();
$pregRes = $pregStmt->get_result();

$currentPregnancy = null;
$pastPregnancies = [];

while ($p = $pregRes->fetch_assoc()) {
    $pid = (int) $p['pregnancy_id'];

    // Prenatal checkups
    $chkStmt = $conn->prepare("SELECT * FROM prenatal_checkups WHERE pregnancy_id = ? ORDER BY checkup_date DESC");
    $chkStmt->bind_param('i', $pid);
    $chkStmt->execute();
    $checkups = $chkStmt->get_result()->fetch_all(MYSQLI_ASSOC);

    // Ultrasounds
    $usStmt = $conn->prepare("SELECT * FROM ultrasounds WHERE pregnancy_id = ? ORDER BY ultrasound_date DESC");
    $usStmt->bind_param('i', $pid);
    $usStmt->execute();
    $ultrasounds = $usStmt->get_result()->fetch_all(MYSQLI_ASSOC);

    // Lab tests
    $labStmt = $conn->prepare("SELECT * FROM lab_tests WHERE pregnancy_id = ? ORDER BY lab_test_date DESC");
    $labStmt->bind_param('i', $pid);
    $labStmt->execute();
    $labTests = $labStmt->get_result()->fetch_all(MYSQLI_ASSOC);

    // Delivery (if any)
    $deliveryStmt = $conn->prepare("SELECT * FROM deliveries WHERE pregnancy_id = ? LIMIT 1");
    $deliveryStmt->bind_param('i', $pid);
    $deliveryStmt->execute();
    $delivery = $deliveryStmt->get_result()->fetch_assoc();

    $p['checkups'] = $checkups;
    $p['ultrasounds'] = $ultrasounds;
    $p['lab_tests'] = $labTests;
    $p['delivery'] = $delivery;

    if ($p['status'] === 'ongoing' && $currentPregnancy === null) {
        $currentPregnancy = $p;
    } else {
        $pastPregnancies[] = $p;
    }
}

$mother['medical_conditions'] = $medicalConditions;
$mother['allergies'] = $allergies;
$mother['current_pregnancy'] = $currentPregnancy;
$mother['past_pregnancies'] = $pastPregnancies;

echo json_encode([
    'success' => true,
    'mother' => $mother
]);
