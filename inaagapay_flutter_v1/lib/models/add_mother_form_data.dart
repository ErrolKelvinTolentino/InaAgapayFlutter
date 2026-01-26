class AddMotherFormData {
  // ===== ACCOUNT =====
  String? firstName;
  String? middleName;
  String? lastName;
  String? extensionName;
  String? email;
  String? phone;

  // ===== ADDRESS (mothers) =====
  String? houseNumber;
  String? street;
  String? barangay;
  String? city;
  String? province;

  // ===== EMERGENCY CONTACT =====
  String? ecFirstName;
  String? ecMiddleName;
  String? ecLastName;
  String? ecExtension;
  String? ecPhone;
  String? ecEmail;

  // ===== MEDICAL =====
  List<String> medicalConditions = [];

  // ===== ALLERGIES =====
  List<Map<String, dynamic>> allergies = [];

  // ===== PREGNANCY =====
  DateTime? lmp;
  DateTime? edd;
  String riskLevel = 'low';
}
