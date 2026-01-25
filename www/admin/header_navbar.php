<?php
// Start session if not already started
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Check if user is logged in
$isLoggedIn = isset($_SESSION['account_id']) || isset($_SESSION['user_id']);
$accountType = $isLoggedIn && isset($_SESSION['account_type']) ? $_SESSION['account_type'] : null;
$username = $isLoggedIn ? (isset($_SESSION['user_name']) ? $_SESSION['user_name'] : 'User') : 'Guest';
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>
        <?php echo isset($pageTitle) ? $pageTitle : 'InaAgapay'; ?>
    </title>
    <!-- Font Awesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="styles/header_navbar.css">
    <!-- SweetAlert2 CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
</head>

<body>
    <!-- Header -->
    <header class="header">
        <div class="brand">
            <button class="sidebar-toggle" id="sidebarToggle" aria-label="Toggle sidebar">
                <i class="fa-solid fa-bars"></i>
            </button>
            <img src="images/logo_icon.png" alt="InaAgapay Logo" class="logo" />
            <span class="brand-name">InaAgapay</span>
        </div>
        <div class="user-actions">
            <div class="user-info">
                <div class="user-avatar">
                    <i class="fa-solid fa-user"></i>
                </div>
                <span>
                    <?php echo htmlspecialchars($username); ?>
                </span>
                <?php if ($isLoggedIn && $accountType): ?>
                    <span class="account-type-label">(
                        <?php echo ucfirst($accountType); ?>)
                    </span>
                <?php endif; ?>
            </div>
            <?php if ($isLoggedIn): ?>
                <button class="logout-btn" onclick="confirmLogout()">
                    <i class="fa-solid fa-right-from-bracket"></i> Logout
                </button>
            <?php else: ?>
                <button class="logout-btn" onclick="window.location.href='login.php'">
                    <i class="fa-solid fa-right-to-bracket"></i> Login
                </button>
            <?php endif; ?>
        </div>
    </header>

    <!-- Sidebar -->
    <nav class="sidebar show" id="sidebar">
        <ul class="sidebar-menu">
            <?php if ($isLoggedIn && $accountType === 'admin'): ?>
                <li class="<?php echo basename($_SERVER['PHP_SELF']) === 'admin_landing.php' ? 'active' : ''; ?>">
                    <a href="admin_landing.php">
                        <i class="fa-solid fa-gauge"></i>
                        <span>Admin Dashboard</span>
                    </a>
                </li>
                <li class="<?php echo basename($_SERVER['PHP_SELF']) === 'admin_audit_trail.php' ? 'active' : ''; ?>">
                    <a href="audit_trail.php">
                        <i class="fa-solid fa-clipboard-list"></i>
                        <span>Audit Trail</span>
                    </a>
                </li>
                <li
                    class="<?php echo basename($_SERVER['PHP_SELF']) === 'admin_account_management.php' ? 'active' : ''; ?>">
                    <a href="admin_account_management.php">
                        <i class="fa-solid fa-users-cog"></i>
                        <span>Account Management</span>
                    </a>
                </li>
                <li class="<?php echo basename($_SERVER['PHP_SELF']) === 'admin_backup.php' ? 'active' : ''; ?>">
                    <a href="admin_backup.php">
                        <i class="fa-solid fa-database"></i>
                        <span>Database Backup</span>
                    </a>
                </li>
                <!-- Add more admin links here -->
            <?php elseif ($isLoggedIn && $accountType === 'mother'): ?>
                <li class="<?php echo basename($_SERVER['PHP_SELF']) === 'mother_landing.php' ? 'active' : ''; ?>">
                    <a href="mother_landing.php">
                        <i class="fa-solid fa-gauge"></i>
                        <span>Mother Dashboard</span>
                    </a>
                </li>
                <li class="<?php echo basename($_SERVER['PHP_SELF']) === 'mother_pregnancy.php' ? 'active' : ''; ?>">
                    <a href="mother_pregnancy.php">
                        <i class="fa-solid fa-baby"></i>
                        <span>Pregnancy</span>
                    </a>
                </li>
                <li class="<?php echo basename($_SERVER['PHP_SELF']) === 'view_my_childrens.php' ? 'active' : ''; ?>">
                    <a href="view_my_childrens.php">
                        <i class="fa-solid fa-children"></i>
                        <span>My Children</span>
                    </a>
                </li>
                <!-- Journal Links Added Here -->
                <li class="<?php echo basename($_SERVER['PHP_SELF']) === 'mother_journal.php' ? 'active' : ''; ?>">
                    <a href="mother_journal.php">
                        <i class="fa-solid fa-book"></i>
                        <span>Pregnancy Journal</span>
                    </a>
                </li>
                <li class="<?php echo basename($_SERVER['PHP_SELF']) === 'symptoms_journal.php' ? 'active' : ''; ?>">
                    <a href="symptoms_journal.php">
                        <i class="fa-solid fa-notes-medical"></i>
                        <span>Symptoms Journal</span>
                    </a>
                </li>
                <li class="<?php echo basename($_SERVER['PHP_SELF']) === 'vitamins_journal.php' ? 'active' : ''; ?>">
                    <a href="vitamins_journal.php">
                        <i class="fa-solid fa-pills"></i>
                        <span>Vitamins Journal</span>
                    </a>
                </li>
                <li class="<?php echo basename($_SERVER['PHP_SELF']) === 'journal_archive.php' ? 'active' : ''; ?>">
                    <a href="journal_archive.php">
                        <i class="fa-solid fa-book-open"></i>
                        <span>Journal Archive</span>
                    </a>
                </li>
                <!-- End Journal Links -->
            <?php elseif ($isLoggedIn && $accountType === 'midwife'): ?>
                <li class="<?php echo basename($_SERVER['PHP_SELF']) === 'midwife_landing.php' ? 'active' : ''; ?>">
                    <a href="midwife_landing.php">
                        <i class="fa-solid fa-gauge"></i>
                        <span>Midwife Dashboard</span>
                    </a>
                </li>

                <li class="<?php echo basename($_SERVER['PHP_SELF']) === 'midwife_patients.php' ? 'active' : ''; ?>">
                    <a href="midwife_patients.php">
                        <i class="fa-solid fa-users"></i>
                        <span>Patients</span>
                    </a>
                </li>
                <li
                    class="<?php echo basename($_SERVER['PHP_SELF']) === 'midwife_checkup_schedules.php' ? 'active' : ''; ?>">
                    <a href="midwife_checkup_schedules.php">
                        <i class="fa-solid fa-calendar-check"></i>
                        <span>Schedules</span>
                    </a>
                </li>
                <li class="<?php echo basename($_SERVER['PHP_SELF']) === 'children.php' ? 'active' : ''; ?>">
                    <a href="children.php">
                        <i class="fa-solid fa-baby"></i>
                        <span>Children</span>
                    </a>
                </li>
                <!-- Add more midwife links here -->
            <?php else: ?>
                <li class="<?php echo basename($_SERVER['PHP_SELF']) === 'index.php' ? 'active' : ''; ?>">
                    <a href="index.php">
                        <i class="fa-solid fa-house"></i>
                        <span>Home</span>
                    </a>
                </li>
            <?php endif; ?>

        </ul>
    </nav>

    <!-- Main Content -->
    <main class="main-content" id="mainContent">
        <!-- Content will be loaded from individual pages -->

        <!-- SweetAlert2 JS -->
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const sidebar = document.getElementById('sidebar');
                const sidebarToggle = document.getElementById('sidebarToggle');
                const mainContent = document.getElementById('mainContent');

                // Make sidebar open by default
                sidebar.classList.add('show');
                sidebar.classList.remove('collapsed');
                mainContent.classList.remove('expanded');

                // Toggle sidebar
                sidebarToggle.addEventListener('click', function () {
                    sidebar.classList.toggle('collapsed');
                    sidebar.classList.toggle('show');
                    mainContent.classList.toggle('expanded');
                    // Save state to localStorage
                    const isCollapsed = sidebar.classList.contains('collapsed');
                    localStorage.setItem('sidebarCollapsed', isCollapsed);
                });

                // Check for saved state
                const savedState = localStorage.getItem('sidebarCollapsed');
                if (savedState === 'true') {
                    sidebar.classList.add('collapsed');
                    sidebar.classList.remove('show');
                    mainContent.classList.add('expanded');
                }

                // Responsive behavior
                function handleResize() {
                    if (window.innerWidth <= 992) {
                        sidebar.classList.add('collapsed');
                        mainContent.classList.add('expanded');
                    } else {
                        // Only restore if user hasn't manually collapsed
                        if (localStorage.getItem('sidebarCollapsed') !== 'true') {
                            sidebar.classList.remove('collapsed');
                            mainContent.classList.remove('expanded');
                        }
                    }
                }

                // Initial check
                handleResize();

                // Listen for resize events
                window.addEventListener('resize', handleResize);
            });

            function confirmLogout() {
                Swal.fire({
                    title: 'Are you sure?',
                    text: "You will be logged out of the system.",
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#3085d6',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Yes, logout!',
                    cancelButtonText: 'Cancel'
                }).then((result) => {
                    if (result.isConfirmed) {
                        window.location.href = 'logout.php';
                    }
                });
            }
        </script>
</body>

</html>