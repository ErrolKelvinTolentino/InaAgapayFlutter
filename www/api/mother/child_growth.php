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

// 🧮 AGE IN MONTHS
$birthDate = new DateTime($child['birthdate']);
$now = new DateTime();
$ageMonths = max(1, floor($birthDate->diff($now)->days / 30));

// 📈 FETCH GROWTH RECORDS
$growthStmt = $conn->prepare("
    SELECT child_height, child_weight, created_at
    FROM child_details
    WHERE child_id = ?
    ORDER BY created_at ASC
");
$growthStmt->bind_param("i", $childId);
$growthStmt->execute();
$records = $growthStmt->get_result()->fetch_all(MYSQLI_ASSOC);

// 📊 BUILD DATA
$heightValues = [];
$weightValues = [];
$labels = [];

foreach ($records as $r) {
    $labels[] = date('M', strtotime($r['created_at']));
    $heightValues[] = (float) $r['child_height'];
    $weightValues[] = (float) $r['child_weight'];
}

$startHeight = $heightValues[0] ?? null;
$latestHeight = end($heightValues) ?: null;

$startWeight = $weightValues[0] ?? null;
$latestWeight = end($weightValues) ?: null;

// 🤖 AI INSIGHT (RULE-BASED)
$insight = 'Growth data is still being collected.';
if (count($records) >= 2) {
    $heightDiff = $latestHeight - $startHeight;
    $weightDiff = $latestWeight - $startWeight;

    if ($heightDiff > 2 && $weightDiff > 1) {
        $insight = 'Your child is growing very well and above average for their age.';
    } elseif ($heightDiff > 1) {
        $insight = 'Your child shows healthy and consistent growth.';
    } else {
        $insight = 'Growth is within normal range, continue regular checkups.';
    }
}

echo json_encode([
    'success' => true,
    'age_months' => $ageMonths,
    'height' => [
        'values' => $heightValues,
        'labels' => $labels,
        'starting' => $startHeight,
        'latest' => $latestHeight,
    ],
    'weight' => [
        'values' => $weightValues,
        'labels' => $labels,
        'starting' => $startWeight,
        'latest' => $latestWeight,
    ],
    'ai_insight' => $insight,
]);
