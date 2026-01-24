<?php
header('Content-Type: application/json');
header('X-Content-Type-Options: nosniff');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Method not allowed'
    ]);
    exit;
}

echo json_encode([
    'success' => true,
    'service' => 'Inaagapay API',
    'status' => 'running',
    'version' => '1.0',
    'timestamp' => date('Y-m-d H:i:s')
]);
