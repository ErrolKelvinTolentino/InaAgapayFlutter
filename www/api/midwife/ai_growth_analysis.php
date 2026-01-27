<?php
require_once __DIR__ . '/../auth/auth_check.php';
header('Content-Type: application/json');

$input = json_decode(file_get_contents("php://input"), true);

$height = floatval($input['height'] ?? 0); // cm
$weight = floatval($input['weight'] ?? 0); // kg

if ($height <= 0 || $weight <= 0) {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid growth data'
    ]);
    exit;
}

/**
 * =========================
 * CORE GROWTH CALCULATIONS
 * =========================
 */
$bmi = round($weight / pow($height / 100, 2), 1);

/**
 * WHO-style heuristic ranges
 * (Simplified but defensible)
 */
$status = '';
$remarks = '';
$recommendation = '';

/**
 * =========================
 * AI GROWTH REASONING
 * =========================
 */
if ($bmi < 14) {
    $status = 'Underweight (At Risk)';

    $remarks = "The child’s body mass index is below the expected range for healthy growth. "
             . "This may indicate insufficient nutritional intake or delayed weight gain compared to height.";

    $recommendation = "It is recommended to closely monitor the child’s dietary intake and ensure regular follow-up growth measurements. "
                    . "Consultation with a healthcare professional is advised if low weight persists.";
}

elseif ($bmi >= 14 && $bmi <= 18) {
    $status = 'Normal Growth';

    $remarks = "Based on the available growth data, the child’s height and weight are proportionate and fall within a healthy range. "
             . "There are no immediate signs of growth-related risk at this time.";

    $recommendation = "Continue providing balanced nutrition and routine health check-ups to ensure sustained healthy growth.";
}

elseif ($bmi > 18 && $bmi <= 20) {
    $status = 'Above Average Weight';

    $remarks = "The child’s weight is slightly higher relative to height. While this does not automatically indicate a health concern, "
             . "it is important to monitor future growth trends.";

    $recommendation = "Encourage healthy eating habits and regular physical activity appropriate for the child’s age.";
}

else {
    $status = 'Overweight (Monitoring Recommended)';

    $remarks = "The child’s weight is significantly higher relative to height, which may increase the risk of future health concerns "
             . "if the trend continues.";

    $recommendation = "Gradual lifestyle adjustments, including balanced meals and active play, are recommended. "
                    . "A healthcare provider may offer additional guidance if needed.";
}

/**
 * =========================
 * FINAL AI RESPONSE
 * =========================
 */
echo json_encode([
    'success' => true,
    'bmi' => $bmi,
    'status' => $status,
    'remarks' => $remarks,
    'recommendation' => $recommendation,
    'disclaimer' =>
        'This AI-assisted analysis is for guidance only and does not replace professional medical advice.'
]);
