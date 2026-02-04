<?php
require_once __DIR__ . '/../auth/auth_check.php';
require_once __DIR__ . '/../db.php';

header('Content-Type: application/json');

if (($AUTH_USER['account_type'] ?? null) !== 'mother') {
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

try {
    // Get mother ID
    $stmt = $conn->prepare("
        SELECT m.mother_id
        FROM mothers m
        WHERE m.account_id = ?
        LIMIT 1
    ");
    $stmt->bind_param("i", $AUTH_USER['account_id']);
    $stmt->execute();
    $mother = $stmt->get_result()->fetch_assoc();
    
    if (!$mother) {
        echo json_encode(['success' => false, 'message' => 'Mother profile not found']);
        exit;
    }

    // Fetch pregnancy history with delivery information
    $stmt = $conn->prepare("
        SELECT
            p.pregnancy_id,
            p.last_menstrual_period,
            p.expected_date_of_delivery,
            p.outcome,
            p.outcome_date,
            p.gestational_age_at_end,
            p.status,
            d.delivery_date,
            d.place_of_delivery,
            d.delivery_method,
            d.is_delivery_date_estimated
        FROM pregnancies p
        LEFT JOIN deliveries d ON p.pregnancy_id = d.pregnancy_id
        WHERE p.mother_id = ?
        ORDER BY p.created_at DESC
    ");
    $stmt->bind_param("i", $mother['mother_id']);
    $stmt->execute();
    
    $history = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    
    // Format dates for better readability
    foreach ($history as &$record) {
        // Format dates
        foreach (['last_menstrual_period', 'expected_date_of_delivery', 'outcome_date', 'delivery_date'] as $dateField) {
            if ($record[$dateField]) {
                $record[$dateField . '_formatted'] = date('F j, Y', strtotime($record[$dateField]));
            }
        }
        
        // Add delivery information if available
        if ($record['delivery_method']) {
            $record['method_display'] = ucfirst(strtolower($record['delivery_method']));
        } else {
            // Fallback based on outcome
            if ($record['outcome'] == 'live_birth') {
                $record['method_display'] = 'Normal Delivery';
            } else {
                $record['method_display'] = 'Not applicable';
            }
        }
        
        // Add outcome display text
        $outcomeMap = [
            'live_birth' => 'Live Birth',
            'stillbirth' => 'Stillbirth',
            'miscarriage' => 'Miscarriage',
            'abortion' => 'Abortion',
            'ectopic' => 'Ectopic Pregnancy'
        ];
        $record['outcome_display'] = $outcomeMap[$record['outcome']] ?? ucfirst(str_replace('_', ' ', $record['outcome']));
    }

    echo json_encode([
        'success' => true,
        'history' => $history,
        'count' => count($history)
    ]);

} catch (Exception $e) {
    error_log("Error fetching pregnancy history: " . $e->getMessage());
    echo json_encode([
        'success' => false,
        'message' => 'Failed to fetch pregnancy history',
        'error' => $e->getMessage()
    ]);
}