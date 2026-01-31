<?php
require_once __DIR__ . '/../db.php';

header('Content-Type: application/json');

$data = json_decode(file_get_contents("php://input"), true);

$email = $data['email'] ?? '';
$password = $data['password'] ?? '';

if (empty($email) || empty($password)) {
    echo json_encode([
        'success' => false,
        'message' => 'Email and password are required'
    ]);
    exit;
}

// 1️⃣ Get account
$stmt = $conn->prepare("
    SELECT account_id, password_hash, account_type, is_verified, status
    FROM accounts
    WHERE email_address = ?
    LIMIT 1
");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows !== 1) {
    echo json_encode(['success' => false]);
    exit;
}

$user = $result->fetch_assoc();

if (!$user['is_verified']) {
    echo json_encode(['success' => false, 'message' => 'Account not verified']);
    exit;
}

if ($user['status'] !== 'active') {
    echo json_encode(['success' => false, 'message' => 'Account inactive']);
    exit;
}

if (!password_verify($password, $user['password_hash'])) {
    echo json_encode(['success' => false]);
    exit;
}

// 2️⃣ Generate token
$token = bin2hex(random_bytes(32));

$update = $conn->prepare("
    UPDATE accounts
    SET last_login_token = ?, last_login_at = NOW()
    WHERE account_id = ?
");
$update->bind_param("si", $token, $user['account_id']);
$update->execute();

// 3️⃣ CHECK PROFILE COMPLETION (🔥 THIS IS THE FIX)
$profileComplete = false;

if ($user['account_type'] === 'mother') {
    $stmt = $conn->prepare("
        SELECT mother_id
        FROM mothers
        WHERE account_id = ?
        LIMIT 1
    ");
    $stmt->bind_param("i", $user['account_id']);
    $stmt->execute();
    $profileComplete = $stmt->get_result()->num_rows === 1;
}

// 4️⃣ RESPONSE
echo json_encode([
    'success' => true,
    'token' => $token,
    'user' => [
        'id' => $user['account_id'],
        'role' => $user['account_type'],
        'profile_complete' => $profileComplete
    ]
]);
