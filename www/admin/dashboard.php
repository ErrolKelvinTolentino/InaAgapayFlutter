<?php
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/../api/db.php';

// Stats
$mothers = $conn->query("SELECT COUNT(*) AS t FROM mothers")->fetch_assoc()['t'];
$midwives = $conn->query("SELECT COUNT(*) AS t FROM midwives")->fetch_assoc()['t'];
$preg = $conn->query("
    SELECT COUNT(*) AS t FROM pregnancies WHERE status='ongoing'
")->fetch_assoc()['t'];
$children = $conn->query("SELECT COUNT(*) AS t FROM children")->fetch_assoc()['t'];

$stmt = $conn->prepare("
    SELECT email_address, last_login_at
    FROM accounts WHERE account_id = ?
");
$stmt->bind_param('i', $_SESSION['admin_id']);
$stmt->execute();
$admin = $stmt->get_result()->fetch_assoc();

require_once __DIR__ . '/includes/header.php';
require_once __DIR__ . '/includes/sidebar.php';
?>

<h2>Dashboard</h2>
<p class="subtitle">
    Welcome back, <?= htmlspecialchars($admin['email_address']) ?>
</p>

<div class="dashboard-cards">
    <div class="card">
        <h3><?= $mothers ?></h3>
        <p>Total Mothers</p>
    </div>
    <div class="card">
        <h3><?= $midwives ?></h3>
        <p>Total Midwives</p>
    </div>
    <div class="card">
        <h3><?= $preg ?></h3>
        <p>Active Pregnancies</p>
    </div>
    <div class="card">
        <h3><?= $children ?></h3>
        <p>Total Children</p>
    </div>
</div>

<p class="last-login">
    Last login:
    <?= $admin['last_login_at']
        ? date('F j, Y g:i A', strtotime($admin['last_login_at']))
        : 'First login' ?>
</p>

<?php require_once __DIR__ . '/includes/footer.php'; ?>