<?php
require 'db.php';
require 'mailer.php';

$data = json_decode(file_get_contents("php://input"), true);
$email = $data['email'];
$password = password_hash($data['password'], PASSWORD_DEFAULT);
$code = rand(100000, 999999);
$expires = date("Y-m-d H:i:s", strtotime("+5 minutes"));

$stmt = $conn->prepare("
    INSERT INTO accounts
    (email_address, password_hash, account_type, verification_code, verification_expires)
    VALUES (?, ?, 'mother', ?, ?)
");
$stmt->bind_param("ssss", $email, $password, $code, $expires);

if (!$stmt->execute()) {
    echo json_encode(['success' => false]);
    exit;
}

sendMail($email, "Verification Code", "Your code is: $code");

echo json_encode(['success' => true]);
