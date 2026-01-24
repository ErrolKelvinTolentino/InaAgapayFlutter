<?php
session_start();

if (
    !isset($_SESSION['admin_id']) ||
    ($_SESSION['account_type'] ?? '') !== 'admin'
) {
    http_response_code(403);
    echo 'Access denied';
    exit;
}
