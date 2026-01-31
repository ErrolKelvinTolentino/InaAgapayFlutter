<?php
require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../auth/auth_check.php';

header('Content-Type: application/json');

// 🔐 ROLE CHECK
if ($AUTH_USER['account_type'] !== 'mother') {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

$childId = $_GET['child_id'] ?? null;
if (!$childId) {
    echo json_encode(['success' => false, 'message' => 'Child ID required']);
    exit;
}

$accountId = $AUTH_USER['account_id'];

// 🔍 VERIFY CHILD OWNERSHIP
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
    echo json_encode(['success' => false, 'message' => 'Child not found']);
    exit;
}

// 🧮 AGE IN WEEKS
$birthDate = new DateTime($child['birthdate']);
$now = new DateTime();
$childAgeWeeks = floor($birthDate->diff($now)->days / 7);

// 💉 FETCH VACCINES
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
    $requiredWeeks = $v['recommended_age_months'] * 4.345;
    $key = strtolower($v['vaccine_name']) . $v['dose_number'];

    if (in_array($v['vaccine_id'], $taken)) {
        $statuses[$key] = 'done';
    } elseif ($childAgeWeeks >= $requiredWeeks) {
        $statuses[$key] = 'pending';
        if (!$nextDue) {
            $nextDue = $v['vaccine_name'];
        }
    } else {
        $statuses[$key] = 'locked';
    }
}

echo json_encode([
    'success' => true,
    'child_age_weeks' => $childAgeWeeks,
    'statuses' => $statuses,
    'next_due' => $nextDue,
]);
