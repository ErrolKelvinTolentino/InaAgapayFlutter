<?php
header('Content-Type: application/json');
require_once '../db.php';

$data = json_decode(file_get_contents("php://input"), true);

$email = trim($data['email'] ?? '');
$password = $data['password'] ?? '';

if ($email === '' || $password === '') {
    echo json_encode([
        'success' => false,
        'message' => 'Email and password are required'
    ]);
    exit;
}

// 🔍 Get account
$stmt = $conn->prepare("
    SELECT
        account_id,
        password_hash,
        account_type,
        is_verified,
        status
    FROM accounts
    WHERE email_address = ?
    LIMIT 1
");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid email or password'
    ]);
    exit;
}

$user = $result->fetch_assoc();

// 🚫 Status check
if ($user['status'] !== 'active') {
    echo json_encode([
        'success' => false,
        'message' => 'Account is not active'
    ]);
    exit;
}

// 🚫 Verification check
if ((int)$user['is_verified'] !== 1) {
    echo json_encode([
        'success' => false,
        'message' => 'Account not verified'
    ]);
    exit;
}

// 🔐 PASSWORD CHECK (supports BOTH hashed & plain text)
$passwordValid = false;

// Case 1: hashed password
if (!empty($user['password_hash']) && password_verify($password, $user['password_hash'])) {
    $passwordValid = true;
}

// Case 2: legacy plain-text password
if (!$passwordValid && $password === $user['password_hash']) {
    $passwordValid = true;
}

if (!$passwordValid) {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid email or password'
    ]);
    exit;
}

// 🔑 Generate login token
$token = bin2hex(random_bytes(64));
$now = date('Y-m-d H:i:s');

// 💾 Update login info
$update = $conn->prepare("
    UPDATE accounts
    SET last_login_token = ?, last_login_at = ?
    WHERE account_id = ?
");
$update->bind_param("ssi", $token, $now, $user['account_id']);
$update->execute();

// ✅ SUCCESS
echo json_encode([
    'success' => true,
    'token' => $token,
    'account_type' => $user['account_type']
]);
