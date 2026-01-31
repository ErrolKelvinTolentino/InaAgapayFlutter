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
    $ctx->bind_param('i', $AUTH_USER['account_id']);
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
        'iiddiisissssss',
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
            $medPlanStmt->execute();
        }
    }

    // given medications
    if (!empty($first['given_medications'])) {
        $givenStmt = $conn->prepare("INSERT INTO given_medications (mother_id, given_medication_name, quantity, date_given) VALUES (?, ?, ?, ?)");
        foreach ($first['given_medications'] as $g) {
            if (empty($g['given_medication_name']) || empty($g['quantity'])) {
                continue;
            }
            $givenName = $g['given_medication_name'];
            $givenQty = $g['quantity'];
            $givenDate = fmtDate($g['date_given'] ?? null);

            $givenStmt->bind_param(
                'isis',
                $motherId,
                $givenName,
                $givenQty,
                $givenDate
            );
            $givenStmt->execute();
        }
    }

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
