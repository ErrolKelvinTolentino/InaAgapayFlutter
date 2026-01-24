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
    echo json_encode([
        'success' => false,
        'message' => 'Invalid credentials'
    ]);
    exit;
}

$user = $result->fetch_assoc();

if (!$user['is_verified']) {
    echo json_encode([
        'success' => false,
        'message' => 'Account not verified'
    ]);
    exit;
}

if ($user['status'] !== 'active') {
    echo json_encode([
        'success' => false,
        'message' => 'Account inactive'
    ]);
    exit;
}

if (!password_verify($password, $user['password_hash'])) {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid credentials'
    ]);
    exit;
}

// 🔐 TOKEN GENERATION
$token = bin2hex(random_bytes(32));

// ✅ STORE LOGIN STATE (THIS IS THE IMPORTANT PART)
$update = $conn->prepare("
    UPDATE accounts
    SET last_login_token = ?,
        last_login_at = NOW()
    WHERE account_id = ?
");
$update->bind_param("si", $token, $user['account_id']);
$update->execute();

// 🎉 RESPONSE
echo json_encode([
    'success' => true,
    'message' => 'Login successful',
    'token' => $token,
    'user' => [
        'id' => $user['account_id'],
        'role' => $user['account_type'],
    ]
]);
