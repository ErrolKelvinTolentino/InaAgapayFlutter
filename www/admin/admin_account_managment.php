<?php
require_once __DIR__ . '/../api/db.php';
session_start();
if (!isset($_SESSION['admin_id']) || $_SESSION['account_type'] !== 'admin') {
    header('Location: login.php');
    exit;
}

// Handle search, filter, and sort
$search = isset($_GET['search']) ? trim($_GET['search']) : '';
$filter_type = isset($_GET['filter_type']) ? $_GET['filter_type'] : '';
$filter_status = isset($_GET['filter_status']) ? $_GET['filter_status'] : '';
$sort = isset($_GET['sort']) ? $_GET['sort'] : 'created_at';
$order = isset($_GET['order']) && strtolower($_GET['order']) === 'asc' ? 'ASC' : 'DESC';

// Build query
$where = [];
$params = [];
if ($search !== '') {
    $where[] = "(first_name LIKE :search OR last_name LIKE :search OR email_address LIKE :search)";
    $params[':search'] = "%$search%";
}
if ($filter_type !== '') {
    $where[] = "account_type = :type";
    $params[':type'] = $filter_type;
}
if ($filter_status !== '') {
    $where[] = "status = :status";
    $params[':status'] = $filter_status;
}
$where_sql = $where ? ('WHERE ' . implode(' AND ', $where)) : '';
$allowedSort = ['first_name', 'last_name', 'email_address', 'account_type', 'status', 'created_at'];
$sort = in_array($sort, $allowedSort) ? $sort : 'created_at';

$sql = "SELECT * FROM accounts $where_sql ORDER BY $sort $order";
$stmt = $conn->prepare($sql);
$stmt->execute($params);
$accounts = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Handle account type/status update
$actionSuccess = false;
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['account_id'])) {
    $id = $_POST['account_id'];
    $new_type = $_POST['account_type'] ?? null;
    $new_status = $_POST['status'] ?? null;
    $update = $conn->prepare("UPDATE accounts SET account_type = :type, status = :status WHERE account_id = :id");
    $update->execute([
        ':type' => $new_type,
        ':status' => $new_status,
        ':id' => $id
    ]);
    $actionSuccess = true;
}

// Handle AJAX requests for account type/status update
if (isset($_POST['ajax']) && $_POST['ajax'] == '1' && isset($_POST['account_id'])) {
    $id = $_POST['account_id'];
    $new_type = $_POST['account_type'] ?? null;
    $new_status = $_POST['status'] ?? null;
    $response = ['success' => false];
    try {
        $update = $conn->prepare("UPDATE accounts SET account_type = :type" . ($new_status !== null ? ", status = :status" : "") . " WHERE account_id = :id");
        $params = [':type' => $new_type, ':id' => $id];
        if ($new_status !== null) {
            $params[':status'] = $new_status;
        }
        $update->execute($params);
        $response['success'] = true;
    } catch (Exception $e) {
        $response['success'] = false;
        $response['message'] = $e->getMessage();
    }
    header('Content-Type: application/json');
    echo json_encode($response);
    exit;
}
?>
<?php include 'header_navbar.php'; ?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account Management - InaAgapay</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        .account-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1.5rem;
        }

        .account-table th,
        .account-table td {
            padding: 10px;
            border: 1px solid #eee;
            text-align: left;
        }

        .account-table th {
            background: #f8bbd0;
            color: #ad1457;
            cursor: pointer;
        }

        .account-table tr:nth-child(even) {
            background: #fdf6fa;
        }

        .account-table tr:hover {
            background: #ffe3ef;
        }

        .search-bar,
        .filters {
            margin: 1rem 0;
            display: flex;
            gap: 1rem;
        }

        .search-bar input,
        .filters select {
            padding: 0.5rem;
            border-radius: 5px;
            border: 1px solid #ccc;
        }

        .update-form {
            display: flex;
            gap: 0.5rem;
            align-items: center;
        }

        .update-form select {
            padding: 0.2rem 0.5rem;
        }

        .update-form button {
            background: #ec407a;
            color: #fff;
            border: none;
            border-radius: 4px;
            padding: 0.3rem 0.8rem;
            cursor: pointer;
        }

        .update-form button:hover {
            background: #ad1457;
        }
    </style>
</head>

<body>
    <main class="content" id="mainContent">
        <div style="padding:2rem;">
            <h2>Account Management</h2>
            <?php if ($actionSuccess): ?>
                <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
                <script>
                    Swal.fire({
                        icon: 'success',
                        title: 'Success',
                        text: 'Account updated successfully!',
                        timer: 1500,
                        showConfirmButton: false
                    }).then(() => { window.location = 'admin_account_management.php'; });
                </script>
            <?php endif; ?>
            <a href="admin_account_creation.php">
                <button type="button"
                    style="background:#ec407a;color:#fff;padding:0.5rem 1.2rem;border:none;border-radius:4px;margin-bottom:1rem;cursor:pointer;">
                    <i class="fas fa-user-plus"></i> Create New Account
                </button>
            </a>
            <form class="search-bar" method="get">
                <input type="text" name="search" placeholder="Search name or email..."
                    value="<?= htmlspecialchars($search) ?>">
                <div class="filters">
                    <select name="filter_type">
                        <option value="">All Types</option>
                        <option value="admin" <?= $filter_type === 'admin' ? 'selected' : '' ?>>Admin</option>
                        <option value="midwife" <?= $filter_type === 'midwife' ? 'selected' : '' ?>>Midwife</option>
                        <option value="mother" <?= $filter_type === 'mother' ? 'selected' : '' ?>>Mother</option>
                    </select>
                    <select name="filter_status">
                        <option value="">All Status</option>
                        <option value="active" <?= $filter_status === 'active' ? 'selected' : '' ?>>Active</option>
                        <option value="inactive" <?= $filter_status === 'inactive' ? 'selected' : '' ?>>Inactive</option>
                    </select>
                    <select name="sort">
                        <option value="created_at" <?= $sort === 'created_at' ? 'selected' : '' ?>>Newest</option>
                        <option value="first_name" <?= $sort === 'first_name' ? 'selected' : '' ?>>First Name</option>
                        <option value="last_name" <?= $sort === 'last_name' ? 'selected' : '' ?>>Last Name</option>
                        <option value="email_address" <?= $sort === 'email_address' ? 'selected' : '' ?>>Email</option>
                        <option value="account_type" <?= $sort === 'account_type' ? 'selected' : '' ?>>Type</option>
                        <option value="status" <?= $sort === 'status' ? 'selected' : '' ?>>Status</option>
                    </select>
                    <select name="order">
                        <option value="desc" <?= $order === 'DESC' ? 'selected' : '' ?>>Desc</option>
                        <option value="asc" <?= $order === 'ASC' ? 'selected' : '' ?>>Asc</option>
                    </select>
                    <button type="submit">Apply</button>
                </div>
            </form>
            <table class="account-table">
                <thead>
                    <tr>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th>Type</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($accounts as $acc): ?>
                        <tr>
                            <td>
                                <?php
                                $fullName = htmlspecialchars($acc['first_name']) . ' ' .
                                    ($acc['middle_name'] ? htmlspecialchars($acc['middle_name']) . ' ' : '') .
                                    htmlspecialchars($acc['last_name']) .
                                    ($acc['extension_name'] ? ' ' . htmlspecialchars($acc['extension_name']) : '');
                                echo $fullName;
                                ?>
                            </td>
                            <td><?= htmlspecialchars($acc['email_address']) ?></td>
                            <td>
                                <select name="account_type" id="account_type_<?= $acc['account_id'] ?>"
                                    data-id="<?= $acc['account_id'] ?>" class="account-type-dropdown">
                                    <option value="admin" <?= $acc['account_type'] === 'admin' ? 'selected' : '' ?>>Admin
                                    </option>
                                    <option value="midwife" <?= $acc['account_type'] === 'midwife' ? 'selected' : '' ?>>Midwife
                                    </option>
                                    <option value="mother" <?= $acc['account_type'] === 'mother' ? 'selected' : '' ?>>Mother
                                    </option>
                                </select>
                            </td>
                            <td>
                                <span
                                    id="status-text-<?= $acc['account_id'] ?>"><?= htmlspecialchars(ucfirst($acc['status'])) ?></span>
                            </td>
                            <td style="display:flex; gap:0.5rem;">
                                <button type="button" class="update-btn" data-id="<?= $acc['account_id'] ?>">Update</button>
                                <button type="button" class="status-btn" data-id="<?= $acc['account_id'] ?>"
                                    data-action="<?= $acc['status'] === 'active' ? 'deactivate' : 'activate' ?>"
                                    style="background:<?= $acc['status'] === 'active' ? '#ad1457' : '#4CAF50' ?>;color:#fff;">
                                    <?= $acc['status'] === 'active' ? 'Deactivate' : 'Activate' ?>
                                </button>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
            <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
            <script>
                // AJAX update for account type
                function updateAccountType(accountId) {
                    const type = document.getElementById('account_type_' + accountId).value;
                    Swal.fire({
                        title: 'Are you sure you want to update this account?',
                        icon: 'question',
                        showCancelButton: true,
                        confirmButtonColor: '#ec407a',
                        cancelButtonColor: '#aaa',
                        confirmButtonText: 'Yes, update'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            fetch('admin_account_management.php', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                                body: `ajax=1&account_id=${accountId}&account_type=${type}`
                            })
                                .then(res => res.json())
                                .then(data => {
                                    if (data.success) {
                                        Swal.fire({ icon: 'success', title: 'Success', text: `Account type updated to ${type.charAt(0).toUpperCase() + type.slice(1)}!`, timer: 1200, showConfirmButton: false });
                                    } else {
                                        Swal.fire({ icon: 'error', title: 'Error', text: data.message || 'Update failed.' });
                                    }
                                });
                        }
                    });
                }
                // AJAX update for status
                function updateAccountStatus(accountId, action) {
                    const type = document.getElementById('account_type_' + accountId).value;
                    const newStatus = action === 'deactivate' ? 'inactive' : 'active';
                    Swal.fire({
                        title: action === 'deactivate' ? 'Deactivate this account?' : 'Activate this account?',
                        text: action === 'deactivate' ? 'The user will not be able to login.' : 'The user will be able to login.',
                        icon: 'warning',
                        showCancelButton: true,
                        confirmButtonColor: action === 'deactivate' ? '#ad1457' : '#4CAF50',
                        cancelButtonColor: '#aaa',
                        confirmButtonText: action === 'deactivate' ? 'Yes, deactivate' : 'Yes, activate'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            fetch('admin_account_management.php', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                                body: `ajax=1&account_id=${accountId}&account_type=${type}&status=${newStatus}`
                            })
                                .then(res => res.json())
                                .then(data => {
                                    if (data.success) {
                                        // Update status text in the status column
                                        document.getElementById('status-text-' + accountId).textContent = newStatus.charAt(0).toUpperCase() + newStatus.slice(1);
                                        const statusBtn = document.querySelector(`.status-btn[data-id='${accountId}']`);
                                        if (newStatus === 'active') {
                                            statusBtn.textContent = 'Deactivate';
                                            statusBtn.dataset.action = 'deactivate';
                                            statusBtn.style.background = '#ad1457';
                                        } else {
                                            statusBtn.textContent = 'Activate';
                                            statusBtn.dataset.action = 'activate';
                                            statusBtn.style.background = '#4CAF50';
                                        }
                                        Swal.fire({ icon: 'success', title: 'Success', text: `Account status updated to ${newStatus.charAt(0).toUpperCase() + newStatus.slice(1)}!`, timer: 1200, showConfirmButton: false });
                                    } else {
                                        Swal.fire({ icon: 'error', title: 'Error', text: data.message || 'Update failed.' });
                                    }
                                });
                        }
                    });
                }
                // Event listeners

                document.querySelectorAll('.update-btn').forEach(function (btn) {
                    btn.addEventListener('click', function () {
                        updateAccountType(btn.dataset.id);
                    });
                });
                document.querySelectorAll('.status-btn').forEach(function (btn) {
                    btn.addEventListener('click', function () {
                        updateAccountStatus(btn.dataset.id, btn.dataset.action);
                    });
                });
            </script>
        </div>
    </main>
</body>

</html>