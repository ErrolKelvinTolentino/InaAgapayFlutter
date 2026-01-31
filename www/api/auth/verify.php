<?php
require_once __DIR__ . '/../db.php';

header('Content-Type: application/json');

$input = json_decode(file_get_contents("php://input"), true);

$email = $input['email'] ?? '';
$code = $input['code'] ?? '';

if (empty($email) || empty($code)) {
    echo json_encode([
        'success' => false,
        'message' => 'Missing email or verification code'
    ]);
    exit;
}

$stmt = $conn->prepare("
    SELECT verification_code, verification_expires, is_verified
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
        'message' => 'Account not found'
    ]);
    exit;
}

$account = $result->fetch_assoc();

if ((int)$account['is_verified'] === 1) {
    echo json_encode([
        'success' => false,
        'message' => 'Account already verified'
    ]);
    exit;
}

if ($account['verification_code'] !== $code) {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid verification code'
    ]);
    exit;
}

if (strtotime($account['verification_expires']) < time()) {
    echo json_encode([
        'success' => false,
        'message' => 'Verification code expired'
    ]);
    exit;
}

$update = $conn->prepare("
    UPDATE accounts
    SET is_verified = 1,
        verification_code = NULL,
        verification_expires = NULL
    WHERE email_address = ?
");
$update->bind_param("s", $email);

if (!$update->execute()) {
    echo json_encode([
        'success' => false,
        'message' => 'Verification failed'
    ]);
    exit;
}

echo json_encode([
    'success' => true,
    'message' => 'Account successfully verified'
]);
