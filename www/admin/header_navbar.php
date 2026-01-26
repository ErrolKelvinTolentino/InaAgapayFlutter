<?php
// Start session safely
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Unified session model
$isLoggedIn = isset($_SESSION['account_id']);
$accountType = $_SESSION['account_type'] ?? null;
$username = $_SESSION['user_name'] ?? 'Guest';
$pageTitle = $pageTitle ?? 'InaAgapay';
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($pageTitle) ?></title>

    <!-- Fonts & Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">

    <!-- Styles -->
    <link rel="stylesheet" href="/styles/header_navbar.css">

    <!-- SweetAlert2 -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
</head>

<body>

    <header class="header">
        <div class="brand">
            <button class="sidebar-toggle" id="sidebarToggle">
                <i class="fa-solid fa-bars"></i>
            </button>
            <img src="/images/logo_icon.png" class="logo" alt="InaAgapay Logo">
            <span class="brand-name">InaAgapay</span>
        </div>

        <div class="user-actions">
            <div class="user-info">
                <div class="user-avatar">
                    <i class="fa-solid fa-user"></i>
                </div>
                <span><?= htmlspecialchars($username) ?></span>
                <?php if ($isLoggedIn && $accountType): ?>
                    <span class="account-type-label">(<?= ucfirst($accountType) ?>)</span>
                <?php endif; ?>
            </div>

            <?php if ($isLoggedIn): ?>
                <button class="logout-btn" onclick="confirmLogout()">
                    <i class="fa-solid fa-right-from-bracket"></i> Logout
                </button>
            <?php else: ?>
                <button class="logout-btn" onclick="location.href='/login.php'">
                    <i class="fa-solid fa-right-to-bracket"></i> Login
                </button>
            <?php endif; ?>
        </div>
    </header>

    <nav class="sidebar show" id="sidebar">
        <ul class="sidebar-menu">

            <?php if ($isLoggedIn && $accountType === 'admin'): ?>
                <li class="<?= basename($_SERVER['PHP_SELF']) === 'admin_landing.php' ? 'active' : '' ?>">
                    <a href="/admin/admin_landing.php"><i class="fa-solid fa-gauge"></i><span>Admin Dashboard</span></a>
                </li>
                <li class="<?= basename($_SERVER['PHP_SELF']) === 'audit_trail.php' ? 'active' : '' ?>">
                    <a href="/admin/audit_trail.php"><i class="fa-solid fa-clipboard-list"></i><span>Audit Trail</span></a>
                </li>
                <li class="<?= basename($_SERVER['PHP_SELF']) === 'admin_account_management.php' ? 'active' : '' ?>">
                    <a href="/admin/admin_account_management.php"><i class="fa-solid fa-users-cog"></i><span>Account
                            Management</span></a>
                </li>
                <li class="<?= basename($_SERVER['PHP_SELF']) === 'admin_backup.php' ? 'active' : '' ?>">
                    <a href="/admin/admin_backup.php"><i class="fa-solid fa-database"></i><span>Database Backup</span></a>
                </li>

            <?php elseif ($isLoggedIn && $accountType === 'mother'): ?>
                <li class="<?= basename($_SERVER['PHP_SELF']) === 'mother_landing.php' ? 'active' : '' ?>">
                    <a href="/mother/mother_landing.php"><i class="fa-solid fa-gauge"></i><span>Mother Dashboard</span></a>
                </li>
                <li class="<?= basename($_SERVER['PHP_SELF']) === 'mother_pregnancy.php' ? 'active' : '' ?>">
                    <a href="/mother/mother_pregnancy.php"><i class="fa-solid fa-baby"></i><span>Pregnancy</span></a>
                </li>
                <li class="<?= basename($_SERVER['PHP_SELF']) === 'view_my_childrens.php' ? 'active' : '' ?>">
                    <a href="/mother/view_my_childrens.php"><i class="fa-solid fa-children"></i><span>My Children</span></a>
                </li>
                <li class="<?= basename($_SERVER['PHP_SELF']) === 'mother_journal.php' ? 'active' : '' ?>">
                    <a href="/mother/mother_journal.php"><i class="fa-solid fa-book"></i><span>Pregnancy Journal</span></a>
                </li>

            <?php elseif ($isLoggedIn && $accountType === 'midwife'): ?>
                <li class="<?= basename($_SERVER['PHP_SELF']) === 'midwife_landing.php' ? 'active' : '' ?>">
                    <a href="/midwife/midwife_landing.php"><i class="fa-solid fa-gauge"></i><span>Midwife
                            Dashboard</span></a>
                </li>
                <li class="<?= basename($_SERVER['PHP_SELF']) === 'midwife_patients.php' ? 'active' : '' ?>">
                    <a href="/midwife/midwife_patients.php"><i class="fa-solid fa-users"></i><span>Patients</span></a>
                </li>
                <li class="<?= basename($_SERVER['PHP_SELF']) === 'midwife_checkup_schedules.php' ? 'active' : '' ?>">
                    <a href="/midwife/midwife_checkup_schedules.php"><i
                            class="fa-solid fa-calendar-check"></i><span>Schedules</span></a>
                </li>

            <?php else: ?>
                <li class="<?= basename($_SERVER['PHP_SELF']) === 'index.php' ? 'active' : '' ?>">
                    <a href="/index.php"><i class="fa-solid fa-house"></i><span>Home</span></a>
                </li>
            <?php endif; ?>

        </ul>
    </nav>

    <main class="main-content" id="mainContent">
        <!-- Scripts -->
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script>
            document.addEventListener('DOMContentLoaded', () => {
                const sidebar = document.getElementById('sidebar');
                const toggle = document.getElementById('sidebarToggle');
                const main = document.getElementById('mainContent');

                toggle.addEventListener('click', () => {
                    sidebar.classList.toggle('collapsed');
                    main.classList.toggle('expanded');
                    localStorage.setItem('sidebarCollapsed', sidebar.classList.contains('collapsed'));
                });

                if (localStorage.getItem('sidebarCollapsed') === 'true') {
                    sidebar.classList.add('collapsed');
                    main.classList.add('expanded');
                }
            });

            function confirmLogout() {
                Swal.fire({
                    title: 'Logout?',
                    text: 'You will be logged out.',
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonText: 'Logout'
                }).then(res => {
                    if (res.isConfirmed) location.href = '/logout.php';
                });
            }
        </script>

    </main>
</body>

</html>