<?php
require_once __DIR__ . '/../db.php';

// swallow auth output for JSON safety
ob_start();
require_once __DIR__ . '/../auth/auth_check.php';
ob_end_clean();

header('Content-Type: application/json');

function expect(bool $condition, string $message): void
{
    if (!$condition) {
        throw new Exception($message);
    }
}

function fmtDate(?string $value): ?string
{
    if (empty($value)) {
        return null;
    }
    return date('Y-m-d', strtotime($value));
}

function weeksBetween(?string $start, ?string $end): ?float
{
    if (!$start || !$end) {
        return null;
    }
    $s = new DateTime($start);
    $e = new DateTime($end);
    $days = (int) $s->diff($e)->format('%r%a');
    return round($days / 7, 1);
}

function computeRisk(
    array $profile,
    array $conditions,
    array $allergies,
    array $history,
    array $first,
    ?string $lmp,
    ?string $checkupDate
): array {
    $score = 0;
    $add = function (int $points) use (&$score) {
        $score += $points;
    };

    // Age
    if (!empty($profile['birthdate'])) {
        $b = new DateTime($profile['birthdate']);
        $now = new DateTime();
        $age = $now->diff($b)->y;
        if ($age < 18) {
            $add(2);
        } elseif ($age >= 35) {
            $add(2);
        }
    }

    // BMI
    if (!empty($profile['height']) && !empty($profile['weight']) && $profile['height'] > 0) {
        $bmi = $profile['weight'] / pow($profile['height'] / 100, 2);
        if ($bmi < 18.5) {
            $add(2);
        } elseif ($bmi >= 25 && $bmi < 30) {
            $add(1);
        } elseif ($bmi >= 30) {
            $add(2);
        }
    }

    // Medical conditions (active)
    $activeCount = 0;
    foreach ($conditions as $cond) {
        if (($cond['status'] ?? 'active') !== 'active') {
            continue;
        }
        $activeCount++;
        $name = strtolower($cond['condition_name'] ?? '');
        $points = 1;
        if (strpos($name, 'anemia') !== false) {
            $points = 2;
        } elseif (strpos($name, 'diabetes') !== false) {
            $points = 3;
        } elseif (strpos($name, 'hypertension') !== false) {
            $points = 3;
        } elseif (strpos($name, 'asthma') !== false) {
            $points = 1;
        } elseif (strpos($name, 'smoking') !== false) {
            $points = 2;
        } elseif (strpos($name, 'alcohol') !== false) {
            $points = 2;
        } elseif (strpos($name, 'domestic') !== false || strpos($name, 'violence') !== false) {
            $points = 3;
        } elseif (strpos($name, 'other') !== false) {
            $points = 1;
        }
        $add($points);
    }
    if ($activeCount >= 2) {
        $add(1);
    }

    // Allergies
    foreach ($allergies as $allergy) {
        if (($allergy['status'] ?? 'active') === 'active') {
            $add(1);
            break;
        }
    }

    // Pregnancy history
    foreach ($history as $p) {
        switch ($p['outcome'] ?? '') {
            case 'miscarriage':
                $add(2);
                break;
            case 'stillbirth':
                $add(3);
                break;
            case 'ectopic':
                $add(3);
                break;
            case 'abortion':
                $add(1);
                break;
        }
    }
    $totalPregnancies = count($history) + 1;
    if ($totalPregnancies >= 3) {
        $add(1);
    }

    // Prenatal check factors
    if (!empty($first)) {
        $sys = (int) ($first['blood_pressure_systolic'] ?? 0);
        $dia = (int) ($first['blood_pressure_diastolic'] ?? 0);
        if ($sys >= 140 || $dia >= 90) {
            $add(3);
        }

        $edema = $first['edema'] ?? 'none';
        if ($edema === 'mild') {
            $add(1);
        } elseif ($edema === 'moderate') {
            $add(2);
        } elseif ($edema === 'severe') {
            $add(3);
        }

        $fetalBeat = $first['fetal_heart_beat'] ?? null;
        $beatAbnormal = ($first['abnormal_fetal_heart_beat'] ?? false) ||
            ($fetalBeat !== null && ($fetalBeat < 110 || $fetalBeat > 160));
        if ($beatAbnormal) {
            $add(3);
        }

        $aog = $first['age_of_gestation'] ?? weeksBetween($lmp, $checkupDate);
        $pos = strtolower($first['fetal_position'] ?? '');
        $posAbnormal = ($first['abnormal_fetal_position'] ?? false) ||
            ($pos !== '' && $pos !== 'cephalic' && $pos !== 'vertex' && $pos !== 'unknown');
        if ($aog !== null && $aog >= 28 && $posAbnormal) {
            $add(1);
        }

        if ($aog !== null && $aog > 20) {
            $add(2);
        }

        if (!empty($first['missed_scheduled_checkups'])) {
            $add(1);
        }
    }

    $level = $score >= 6 ? 'high' : ($score >= 3 ? 'medium' : 'low');
    return [$level, $score];
}

try {
    expect(isset($AUTH_USER['account_type']), 'Unauthorized');
    expect($AUTH_USER['account_type'] === 'midwife', 'Only midwives can add prenatal checkups');

    $raw = file_get_contents('php://input');
    $input = json_decode($raw, true);
    expect(is_array($input), 'Invalid JSON payload');

    $pregnancyId = $input['pregnancy_id'] ?? null;
    expect(!empty($pregnancyId), 'pregnancy_id is required');

    // midwife context
    $ctx = $conn->prepare("SELECT m.midwife_id, m.assigned_bhc_id FROM midwives m WHERE m.account_id = ? LIMIT 1");
    $authAccountId = $AUTH_USER['account_id'];
    $ctx->bind_param('i', $authAccountId);
    $ctx->execute();
    $ctxRes = $ctx->get_result()->fetch_assoc();
    expect($ctxRes !== null, 'Midwife context not found');
    $midwifeId = (int) $ctxRes['midwife_id'];
    $midwifeBhcId = (int) $ctxRes['assigned_bhc_id'];

    // pregnancy context
    $pregStmt = $conn->prepare("SELECT p.pregnancy_id, p.mother_id, p.last_menstrual_period, p.status, m.assigned_bhc_id AS mother_bhc_id FROM pregnancies p JOIN mothers m ON m.mother_id = p.mother_id WHERE p.pregnancy_id = ? LIMIT 1");
    $pregStmt->bind_param('i', $pregnancyId);
    $pregStmt->execute();
    $pregRow = $pregStmt->get_result()->fetch_assoc();
    expect($pregRow !== null, 'Pregnancy not found');
    expect($pregRow['status'] === 'ongoing', 'Only ongoing pregnancies can receive prenatal checkups');
    expect((int) $pregRow['mother_bhc_id'] === $midwifeBhcId, 'Pregnancy is not assigned to your BHC');

    $motherId = (int) $pregRow['mother_id'];
    $lmp = $pregRow['last_menstrual_period'];

    $first = $input['prenatal_checkup'] ?? [];
    $checkupDate = fmtDate($first['checkup_date'] ?? date('Y-m-d'));
    $ageOfGestation = $first['age_of_gestation'] ?? weeksBetween($lmp, $checkupDate);

    $conn->begin_transaction();

    $checkupWeight = $first['checkup_weight'] ?? null;
    $bpSys = $first['blood_pressure_systolic'] ?? null;
    $bpDia = $first['blood_pressure_diastolic'] ?? null;
    $fetalPos = $first['fetal_position'] ?? null;
    $fetalHb = $first['fetal_heart_beat'] ?? null;
    $fetalHt = $first['fetal_heart_tone'] ?? null;
    $tdDose = $first['td_vaccine_dose'] ?? null;
    $edema = $first['edema'] ?? 'none';
    $remarks = $first['remarks'] ?? null;

    $prenatalStmt = $conn->prepare("INSERT INTO prenatal_checkups (pregnancy_id, midwife_id, age_of_gestation, checkup_weight, blood_pressure_systolic, blood_pressure_diastolic, fetal_position, fetal_heart_beat, fetal_heart_tone, td_vaccine_dose, edema, remarks, checkup_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $prenatalStmt->bind_param(
        'iiddiisisssss',
        $pregnancyId,
        $midwifeId,
        $ageOfGestation,
        $checkupWeight,
        $bpSys,
        $bpDia,
        $fetalPos,
        $fetalHb,
        $fetalHt,
        $tdDose,
        $edema,
        $remarks,
        $checkupDate
    );
    $prenatalStmt->execute();
    $prenatalId = $conn->insert_id;

    // medication plans
    if (!empty($first['mother_medications'])) {
        $medPlanStmt = $conn->prepare("INSERT INTO mother_medications (mother_id, mother_medication_name, frequency, quantity, start_date, end_date, status) VALUES (?, ?, ?, ?, ?, ?, ?)");
        $medName = null;
        $medFreq = null;
        $medQty = null;
        $medStart = null;
        $medEnd = null;
        $medStatus = null;
        $medPlanStmt->bind_param(
            'ississs',
            $motherId,
            $medName,
            $medFreq,
            $medQty,
            $medStart,
            $medEnd,
            $medStatus
        );
        foreach ($first['mother_medications'] as $m) {
            if (empty($m['mother_medication_name'])) {
                continue;
            }
            $medName = $m['mother_medication_name'];
            $medFreq = $m['frequency'] ?? null;
            $medQty = $m['quantity'] ?? null;
            $medStart = fmtDate($m['start_date'] ?? null);
            $medEnd = fmtDate($m['end_date'] ?? null);
            $medStatus = $m['status'] ?? 'active';
            $medPlanStmt->execute();
        }
    }

    // given medications
    if (!empty($first['given_medications'])) {
        $givenStmt = $conn->prepare("INSERT INTO given_medications (mother_id, given_medication_name, quantity, date_given) VALUES (?, ?, ?, ?)");
        $givenName = null;
        $givenQty = null;
        $givenDate = null;
        $givenStmt->bind_param(
            'isis',
            $motherId,
            $givenName,
            $givenQty,
            $givenDate
        );
        foreach ($first['given_medications'] as $g) {
            if (empty($g['given_medication_name']) || empty($g['quantity'])) {
                continue;
            }
            $givenName = $g['given_medication_name'];
            $givenQty = $g['quantity'];
            $givenDate = fmtDate($g['date_given'] ?? date('Y-m-d'));
            $givenStmt->execute();
        }
    }

    // Recompute pregnancy risk level based on latest checkup
    $profileStmt = $conn->prepare("SELECT birthdate, height, weight FROM mothers WHERE mother_id = ? LIMIT 1");
    $profileStmt->bind_param('i', $motherId);
    $profileStmt->execute();
    $profile = $profileStmt->get_result()->fetch_assoc() ?? [];

    $condStmt = $conn->prepare("SELECT condition_name, status FROM medical_conditions WHERE mother_id = ?");
    $condStmt->bind_param('i', $motherId);
    $condStmt->execute();
    $conditions = $condStmt->get_result()->fetch_all(MYSQLI_ASSOC);

    $allStmt = $conn->prepare("SELECT status FROM allergies WHERE mother_id = ?");
    $allStmt->bind_param('i', $motherId);
    $allStmt->execute();
    $allergies = $allStmt->get_result()->fetch_all(MYSQLI_ASSOC);

    $histStmt = $conn->prepare("SELECT outcome FROM pregnancies WHERE mother_id = ? AND status = 'ended'");
    $histStmt->bind_param('i', $motherId);
    $histStmt->execute();
    $history = $histStmt->get_result()->fetch_all(MYSQLI_ASSOC);

    [$riskLevel] = computeRisk(
        $profile,
        $conditions,
        $allergies,
        $history,
        $first,
        $lmp,
        $checkupDate
    );

    $riskStmt = $conn->prepare("UPDATE pregnancies SET pregnancy_risk_level = ? WHERE pregnancy_id = ?");
    $riskStmt->bind_param('si', $riskLevel, $pregnancyId);
    $riskStmt->execute();

    $conn->commit();

    echo json_encode([
        'success' => true,
        'prenatal_checkup_id' => $prenatalId,
        'pregnancy_id' => $pregnancyId,
        'mother_id' => $motherId,
        'age_of_gestation' => $ageOfGestation,
    ]);
} catch (Throwable $e) {
    $conn->rollback();
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage(),
    ]);
}
