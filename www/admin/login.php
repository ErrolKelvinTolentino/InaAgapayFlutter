<?php
session_start();
require_once __DIR__ . '/../api/db.php';

$error = '';

if (
    isset($_SESSION['admin_id']) &&
    ($_SESSION['account_type'] ?? '') === 'admin'
) {
    header('Location: /admin/dashboard.php');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';

    $stmt = $conn->prepare("
        SELECT account_id, password_hash, account_type, is_verified, status
        FROM accounts WHERE email_address = ?
        LIMIT 1
    ");
    $stmt->bind_param('s', $email);
    $stmt->execute();
    $res = $stmt->get_result();

    if ($res->num_rows === 1) {
        $u = $res->fetch_assoc();

        if (
            $u['account_type'] === 'admin' &&
            $u['is_verified'] &&
            $u['status'] === 'active' &&
            password_verify($password, $u['password_hash'])
        ) {
            session_regenerate_id(true);

            $upd = $conn->prepare("
                UPDATE accounts SET last_login_at = NOW()
                WHERE account_id = ?
            ");
            $upd->bind_param('i', $u['account_id']);
            $upd->execute();

            $_SESSION['admin_id'] = $u['account_id'];
            $_SESSION['account_type'] = 'admin';

            header('Location: /admin/dashboard.php');
            exit;
        }
    }

    $error = 'Invalid credentials';
}
?>

<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Admin Login</title>
    <link rel="stylesheet" href="/admin/styles/admin.css">
</head>

<body class="login-page">

    <form method="POST" class="login-card">
        <h2>Admin Login</h2>

        <?php if ($error): ?>
            <p class="error"><?= htmlspecialchars($error) ?></p>
        <?php endif; ?>

        <input type="email" name="email" placeholder="Email" required>
        <input type="password" name="password" placeholder="Password" required>

        <button type="submit">Login</button>
    </form>

</body>

</html>