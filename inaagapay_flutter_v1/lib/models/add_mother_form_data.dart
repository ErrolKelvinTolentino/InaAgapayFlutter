/// Medical condition entry captured in the wizard modal.
class MedicalConditionInput {
  MedicalConditionInput({
    required this.conditionName,
    this.diagnosisDate,
    this.status = 'active',
    this.remarks,
  });

  String conditionName;
  DateTime? diagnosisDate;
  String status; // active | resolved
  String? remarks;

  bool get isActive => status.toLowerCase() == 'active';
}

/// Allergy entry captured in the wizard modal.
class AllergyInput {
  AllergyInput({
    required this.allergen,
    this.diagnosisDate,
    this.status = 'active',
    this.treatment,
    this.remarks,
  });

  String allergen;
  DateTime? diagnosisDate;
  String status; // active | resolved
  String? treatment;
  String? remarks;

  bool get isActive => status.toLowerCase() == 'active';
}

/// Past pregnancy entry (ended pregnancies only).
class PregnancyHistoryInput {
  PregnancyHistoryInput({
    required this.outcome, // live_birth, stillbirth, miscarriage, ectopic, abortion
    this.outcomeDate,
    this.isOutcomeDateEstimated = false,
    this.deliveryDate,
    this.placeOfDelivery,
    this.deliveryMethod,
    this.gestationalAgeAtEnd,
  });

  String outcome;
  DateTime? outcomeDate;
  bool isOutcomeDateEstimated;
  DateTime? deliveryDate;
  String? placeOfDelivery;
  String? deliveryMethod;
  double? gestationalAgeAtEnd;
}

/// Snapshot of a prenatal checkup (latest) for risk scoring.
class PrenatalCheckupSnapshot {
  PrenatalCheckupSnapshot({
    this.ageOfGestationWeeks,
    this.checkupWeightKg,
    this.systolic,
    this.diastolic,
    this.fetalPosition,
    this.fetalHeartBeat,
    this.fetalHeartTone,
    this.edemaLevel, // none | mild | moderate | severe
  });

  double? ageOfGestationWeeks;
  double? checkupWeightKg;
  int? systolic;
  int? diastolic;
  String? fetalPosition;
  int? fetalHeartBeat;
  String? fetalHeartTone;
  String? edemaLevel;
}

class AddMotherFormData {
  // ===== ACCOUNT =====
  String? firstName;
  String? middleName;
  String? lastName;
  String? extensionName;
  String? email;
  String? phone;
  DateTime? birthdate;

  // ===== ADDRESS (mothers) =====
  int? assignedBhcId;
  String? assignedBhcName;
  bool isAddressSameAsAssignedBhc = true;
  String? houseNumber;
  String? street;
  String? barangay;
  String? cityMunicipality;
  String? province;

  // ===== EMERGENCY CONTACT =====
  String? ecFirstName;
  String? ecMiddleName;
  String? ecLastName;
  String? ecExtension;
  String? ecPhone;
  String? ecEmail;
  String? ecAffiliation;
  String? ecHouseNumber;
  String? ecStreet;
  String? ecBarangay;
  String? ecCityMunicipality;
  String? ecProvince;

  // ===== VITALS =====
  double? heightCm;
  double? weightKg;
  String? bloodType;

  // ===== MEDICAL =====
  List<MedicalConditionInput> medicalConditions = [];

  // ===== ALLERGIES =====
  List<AllergyInput> allergies = [];

  // ===== PREGNANCY HISTORY =====
  bool hadPastPregnancy = false;
  int pastPregnancyCount = 0;
  List<PregnancyHistoryInput> pastPregnancies = [];

  // ===== CURRENT PREGNANCY =====
  DateTime? lastMenstrualPeriod;
  DateTime? expectedDateOfDelivery;

  // ===== RISK SNAPSHOT (derived) =====
  String riskLevel = 'low';
  int riskScore = 0;
  List<String> riskFactors = [];
  String riskNote = '';

  /// Derived helper: age in whole years as of [onDate].
  int? ageInYears({DateTime? onDate}) {
    final dob = birthdate;
    if (dob == null) return null;
    final ref = onDate ?? DateTime.now();
    int years = ref.year - dob.year;
    final hadBirthdayThisYear =
        ref.month > dob.month || (ref.month == dob.month && ref.day >= dob.day);
    if (!hadBirthdayThisYear) years -= 1;
    return years;
  }

  /// Derived BMI using metric units.
  double? bmi() {
    if (heightCm == null || heightCm == 0 || weightKg == null) return null;
    final hM = heightCm! / 100;
    return weightKg! / (hM * hM);
  }

  /// Derived age of gestation (weeks) based on LMP and a reference date.
  double? ageOfGestationWeeks({DateTime? onDate}) {
    if (lastMenstrualPeriod == null) return null;
    final ref = onDate ?? DateTime.now();
    final days = ref.difference(lastMenstrualPeriod!).inDays;
    return days / 7.0;
  }

  /// Ensure pastPregnancies list length matches [pastPregnancyCount].
  void normalizePregnancyHistory() {
    if (pastPregnancyCount < 0) pastPregnancyCount = 0;
    if (!hadPastPregnancy) {
      pastPregnancies.clear();
      pastPregnancyCount = 0;
      return;
    }

    while (pastPregnancies.length < pastPregnancyCount) {
      pastPregnancies.add(PregnancyHistoryInput(outcome: 'live_birth'));
    }
    if (pastPregnancies.length > pastPregnancyCount) {
      pastPregnancies = pastPregnancies.take(pastPregnancyCount).toList();
    }
  }

  /// Convenience setter to update the risk snapshot after computing.
  void applyRiskSnapshot({
    required String level,
    required int score,
    required List<String> factors,
    required String note,
  }) {
    riskLevel = level;
    riskScore = score;
    riskFactors = factors;
    riskNote = note;
  }

  /// Helper to fetch the top N risk factors for display.
  List<String> topRiskFactors([int count = 3]) =>
      riskFactors.take(count).toList(growable: false);

  /// Quick check if any active allergy exists.
  bool get hasActiveAllergy => allergies.any((a) => a.isActive);

  /// Count active medical conditions.
  int get activeMedicalConditionCount =>
      medicalConditions.where((c) => c.isActive).length;

  /// Returns true if any ended pregnancy matches the outcome.
  bool hasHistoryOutcome(String outcome) => pastPregnancies.any(
    (p) => p.outcome.toLowerCase() == outcome.toLowerCase(),
  );

  /// Total pregnancies (ended) stored in history.
  int get totalEndedPregnancies => pastPregnancies.length;

  /// Clone utility to avoid accidental reference sharing (shallow copy is enough here).
  AddMotherFormData clone() {
    return AddMotherFormData()
      ..firstName = firstName
      ..middleName = middleName
      ..lastName = lastName
      ..extensionName = extensionName
      ..email = email
      ..phone = phone
      ..birthdate = birthdate
      ..assignedBhcId = assignedBhcId
      ..assignedBhcName = assignedBhcName
      ..isAddressSameAsAssignedBhc = isAddressSameAsAssignedBhc
      ..houseNumber = houseNumber
      ..street = street
      ..barangay = barangay
      ..cityMunicipality = cityMunicipality
      ..province = province
      ..ecFirstName = ecFirstName
      ..ecMiddleName = ecMiddleName
      ..ecLastName = ecLastName
      ..ecExtension = ecExtension
      ..ecPhone = ecPhone
      ..ecEmail = ecEmail
      ..ecAffiliation = ecAffiliation
      ..ecHouseNumber = ecHouseNumber
      ..ecStreet = ecStreet
      ..ecBarangay = ecBarangay
      ..ecCityMunicipality = ecCityMunicipality
      ..ecProvince = ecProvince
      ..heightCm = heightCm
      ..weightKg = weightKg
      ..bloodType = bloodType
      ..medicalConditions = medicalConditions
          .map(
            (c) => MedicalConditionInput(
              conditionName: c.conditionName,
              diagnosisDate: c.diagnosisDate,
              status: c.status,
              remarks: c.remarks,
            ),
          )
          .toList()
      ..allergies = allergies
          .map(
            (a) => AllergyInput(
              allergen: a.allergen,
              diagnosisDate: a.diagnosisDate,
              status: a.status,
              treatment: a.treatment,
              remarks: a.remarks,
            ),
          )
          .toList()
      ..hadPastPregnancy = hadPastPregnancy
      ..pastPregnancyCount = pastPregnancyCount
      ..pastPregnancies = pastPregnancies
          .map(
            (p) => PregnancyHistoryInput(
              outcome: p.outcome,
              outcomeDate: p.outcomeDate,
              isOutcomeDateEstimated: p.isOutcomeDateEstimated,
              deliveryDate: p.deliveryDate,
              placeOfDelivery: p.placeOfDelivery,
              deliveryMethod: p.deliveryMethod,
              gestationalAgeAtEnd: p.gestationalAgeAtEnd,
            ),
          )
          .toList()
      ..lastMenstrualPeriod = lastMenstrualPeriod
      ..expectedDateOfDelivery = expectedDateOfDelivery
      ..riskLevel = riskLevel
      ..riskScore = riskScore
      ..riskFactors = riskFactors.toList()
      ..riskNote = riskNote;
  }
}
