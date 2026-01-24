class GreetingModel {
  final String role;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? extensionName;
  final String? bhcName;

  GreetingModel({
    required this.role,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.extensionName,
    this.bhcName,
  });

  factory GreetingModel.fromJson(Map<String, dynamic> json) {
    return GreetingModel(
      role: json['role'],
      firstName: json['first_name'],
      middleName: json['middle_name'],
      lastName: json['last_name'],
      extensionName: json['extension_name'],
      bhcName: json['bhc_name'],
    );
  }

  /// Builds a proper full name using your DB structure
  String get displayName {
    final parts = [
      firstName,
      if (middleName != null && middleName!.isNotEmpty) middleName,
      lastName,
      if (extensionName != null && extensionName!.isNotEmpty) extensionName,
    ];
    return parts.join(' ');
  }

  /// Human-readable role
  String get roleLabel {
    if (role == 'midwife') return 'Midwife';
    if (role == 'mother') return 'Mother';
    return 'User';
  }
}
