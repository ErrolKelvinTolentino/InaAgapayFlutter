<?php
require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../auth/auth_check.php';

header('Content-Type: application/json');

if ($AUTH_USER['account_type'] !== 'mother') {
    echo json_encode(['success' => false]);
    exit;
}

$childId = (int) ($_GET['child_id'] ?? 0);
$accountId = $AUTH_USER['account_id'];

$verify = $conn->prepare("
    SELECT c.child_id, bd.birthdate
    FROM children c
    JOIN mothers m ON c.mother_id = m.mother_id
    LEFT JOIN birth_details bd ON c.child_id = bd.child_id
    WHERE c.child_id = ? AND m.account_id = ?
");
$verify->bind_param("ii", $childId, $accountId);
$verify->execute();
$child = $verify->get_result()->fetch_assoc();

if (!$child) {
    echo json_encode(['success' => false]);
    exit;
}

if (!$child['birthdate']) {
    echo json_encode([
        'success' => true,
        'child_age_weeks' => 0,
        'statuses' => [],
        'next_due' => null
    ]);
    exit;
}

$birthDate = new DateTime($child['birthdate']);
$now = new DateTime();
$childAgeWeeks = (int) floor($birthDate->diff($now)->days / 7);

/**
 * 🔑 UI VACCINE KEY MAP
 * This MUST match VaccineList keys
 */
$keyMap = [
    'BCG_1'     => 'bcg',
    'OPV_0'     => 'opv0',
    'OPV_1'     => 'opv1',
    'OPV_2'     => 'opv2',
    'OPV_3'     => 'opv3',
    'PENTA_1'   => 'penta1',
    'PENTA_2'   => 'penta2',
    'PENTA_3'   => 'penta3',
    'PCV_1'     => 'pcv1',
    'PCV_2'     => 'pcv2',
    'PCV_3'     => 'pcv3',
    'ROTA_1'    => 'rota1',
    'ROTA_2'    => 'rota2',
    'IPV_1'     => 'ipv',
];

$vaccineStmt = $conn->query("
    SELECT vaccine_id, vaccine_name, dose_number, recommended_age_months
    FROM vaccines
    WHERE target_recipients = 'child'
");

$recordStmt = $conn->prepare("
    SELECT vaccine_id
    FROM immunization_record
    WHERE child_id = ?
");
$recordStmt->bind_param("i", $childId);
$recordStmt->execute();
$taken = array_column(
    $recordStmt->get_result()->fetch_all(MYSQLI_ASSOC),
    'vaccine_id'
);

$statuses = [];
$nextDue = null;

while ($v = $vaccineStmt->fetch_assoc()) {
    $lookupKey = strtoupper($v['vaccine_name']) . '_' . $v['dose_number'];

    if (!isset($keyMap[$lookupKey])) {
        continue; // skip vaccines not shown in UI
    }

    $uiKey = $keyMap[$lookupKey];
    $requiredWeeks = (int) round($v['recommended_age_months'] * 4.345);

    if (in_array($v['vaccine_id'], $taken)) {
        $statuses[$uiKey] = 'done';
    } elseif ($childAgeWeeks >= $requiredWeeks) {
        $statuses[$uiKey] = 'pending';
        if (!$nextDue) {
            $nextDue = $v['vaccine_name'] . ' Dose ' . $v['dose_number'];
        }
    } else {
        $statuses[$uiKey] = 'locked';
    }
}

echo json_encode([
    'success' => true,
    'child_age_weeks' => $childAgeWeeks,
    'statuses' => $statuses,
    'next_due' => $nextDue,
]);
