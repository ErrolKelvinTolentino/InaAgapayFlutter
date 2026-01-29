<?php
session_start();
require_once __DIR__ . '/../api/db.php';

$error = '';

// Redirect if already logged in
if (isset($_SESSION['account_id'])) {
    switch ($_SESSION['account_type']) {
        case 'admin':
            header('Location: /admin/admin_landing.php');
            break;
        case 'mother':
            header('Location: /mother/mother_landing.php');
            break;
        case 'midwife':
            header('Location: /midwife/midwife_landing.php');
            break;
    }
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';

    $stmt = $conn->prepare("
        SELECT account_id, full_name, password_hash, account_type, is_verified, status
        FROM accounts
        WHERE email_address = ?
        LIMIT 1
    ");
    $stmt->bind_param('s', $email);
    $stmt->execute();
    $res = $stmt->get_result();

    if ($res->num_rows === 1) {
        $u = $res->fetch_assoc();

        if (
            $u['is_verified'] &&
            $u['status'] === 'active' &&
            password_verify($password, $u['password_hash'])
        ) {
            session_regenerate_id(true);

            $_SESSION['account_id'] = $u['account_id'];
            $_SESSION['account_type'] = $u['account_type'];
            $_SESSION['user_name'] = $u['full_name'];

            $upd = $conn->prepare("UPDATE accounts SET last_login_at = NOW() WHERE account_id = ?");
            $upd->bind_param('i', $u['account_id']);
            $upd->execute();

            switch ($u['account_type']) {
                case 'admin':
                    header('Location: /admin/admin_landing.php');
                    break;
                case 'mother':
                    header('Location: /mother/mother_landing.php');
                    break;
                case 'midwife':
                    header('Location: /midwife/midwife_landing.php');
                    break;
            }
            exit;
        }
    }

    $error = 'Invalid email or password';
}
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Login | InaAgapay</title>
    <link rel="stylesheet" href="/styles/login.css">
</head>

<body class="login-page">

    <form method="POST" class="login-card">
        <h2>Login</h2>

        <?php if ($error): ?>
            <p class="error"><?= htmlspecialchars($error) ?></p>
        <?php endif; ?>

        <input type="email" name="email" placeholder="Email" required>
        <input type="password" name="password" placeholder="Password" required>

        <button type="submit">Login</button>
    </form>

</body>

</html>