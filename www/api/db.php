<?php
// db.php
// Centralized database connection file
// ⚠️ IMPORTANT: Do NOT echo or print anything in this file

// AlwaysData MySQL credentials
$DB_HOST = 'mysql-inaagapay.alwaysdata.net';
$DB_USER = 'inaagapay';
$DB_PASS = 'Mine@0729';
$DB_NAME = 'inaagapay_db';

// Create MySQLi connection
$conn = new mysqli($DB_HOST, $DB_USER, $DB_PASS, $DB_NAME);

// If connection fails, stop silently
// (Caller PHP files will return valid JSON instead)
if ($conn->connect_error) {
    http_response_code(500);
    exit;
}

// Set charset for proper UTF-8 + JSON handling
$conn->set_charset('utf8mb4');
