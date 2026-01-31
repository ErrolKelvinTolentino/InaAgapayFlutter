<?php
require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../../mailer.php';

header('Content-Type: application/json');

$data = json_decode(file_get_contents("php://input"), true);

$email = $data['email'] ?? '';
$passwordRaw = $data['password'] ?? '';

if (empty($email) || empty($passwordRaw)) {
    echo json_encode([
        'success' => false,
        'message' => 'Email and password are required'
    ]);
    exit;
}

// Check if email already exists
$check = $conn->prepare("
    SELECT account_id
    FROM accounts
    WHERE email_address = ?
    LIMIT 1
");
$check->bind_param("s", $email);
$check->execute();

if ($check->get_result()->num_rows > 0) {
    echo json_encode([
        'success' => false,
        'message' => 'Email already exists'
    ]);
    exit;
}

$password = password_hash($passwordRaw, PASSWORD_DEFAULT);
$code = rand(100000, 999999);
$expires = date("Y-m-d H:i:s", strtotime("+5 minutes"));

$stmt = $conn->prepare("
    INSERT INTO accounts (
        email_address,
        password_hash,
        account_type,
        verification_code,
        verification_expires
    ) VALUES (?, ?, 'mother', ?, ?)
");

$stmt->bind_param("ssss", $email, $password, $code, $expires);

if (!$stmt->execute()) {
    echo json_encode([
        'success' => false,
        'message' => 'Registration failed'
    ]);
    exit;
}

// Send verification email
sendMail(
    $email,
    "Inaagapay Verification Code",
    "Your verification code is: <b>$code</b><br>This code expires in 5 minutes."
);

echo json_encode([
    'success' => true,
    'message' => 'Verification code sent'
]);
