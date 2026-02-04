<?php
require_once __DIR__ . '/../db.php';
require_once __DIR__ . '/../../mailer.php';

$data = json_decode(file_get_contents("php://input"), true);
$email = $data['email'] ?? '';
$rawPassword = $data['password'] ?? '';

if (empty($email) || empty($rawPassword)) {
    echo json_encode([
        'success' => false,
        'code' => 'MISSING_FIELDS',
        'message' => 'Email and password are required.',
    ]);
    exit;
}

$password = password_hash($rawPassword, PASSWORD_DEFAULT);
$code = rand(100000, 999999);
$expires = date("Y-m-d H:i:s", strtotime("+5 minutes"));

// Check for existing account
$check = $conn->prepare("
    SELECT id, password_hash, is_verified
    FROM accounts
    WHERE email_address = ?
    LIMIT 1
");
$check->bind_param("s", $email);
$check->execute();
$existing = $check->get_result()->fetch_assoc();

if ($existing) {
    $hasPassword = !empty($existing['password_hash']);

    // If account already has a password, block registration
    if ($hasPassword) {
        echo json_encode([
            'success' => false,
            'code' => 'EMAIL_HAS_PASSWORD',
            'message' => 'Email already has an account. Please sign in or reset your password.',
        ]);
        exit;
    }

    // Linking flow: set password, refresh code/expiry, set account type, reset verification
    $update = $conn->prepare("
        UPDATE accounts
        SET password_hash = ?,
            account_type = 'mother',
            verification_code = ?,
            verification_expires = ?,
            is_verified = 0
        WHERE id = ?
    ");
    $update->bind_param("sssi", $password, $code, $expires, $existing['id']);

    if (!$update->execute()) {
        echo json_encode([
            'success' => false,
            'code' => 'UPDATE_FAILED',
            'message' => 'Unable to update existing account.',
        ]);
        exit;
    }

    sendMail($email, "Verification Code", "Your code is: $code");

    echo json_encode([
        'success' => true,
        'code' => 'LINKED_EXISTING',
        'linked_existing' => true,
        'message' => 'Verification code sent to your email.',
    ]);
    exit;
}

// Fresh registration
$stmt = $conn->prepare("
    INSERT INTO accounts
    (email_address, password_hash, account_type, verification_code, verification_expires)
    VALUES (?, ?, 'mother', ?, ?)
");
$stmt->bind_param("ssss", $email, $password, $code, $expires);

if (!$stmt->execute()) {
    echo json_encode([
        'success' => false,
        'code' => 'INSERT_FAILED',
        'message' => 'Could not create account. Please try again.',
    ]);
    exit;
}

sendMail($email, "Verification Code", "Your code is: $code");

echo json_encode([
    'success' => true,
    'code' => 'NEW_ACCOUNT',
    'message' => 'Verification code sent to your email.',
]);
