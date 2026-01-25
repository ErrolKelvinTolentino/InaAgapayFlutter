class VaccineModel {
  final int vaccineId;
  final String name;
  final int dose;
  final double recommendedAge;

  VaccineModel({
    required this.vaccineId,
    required this.name,
    required this.dose,
    required this.recommendedAge,
  });

  factory VaccineModel.fromJson(Map<String, dynamic> json) {
    return VaccineModel(
      vaccineId: int.parse(json['vaccine_id'].toString()),
      name: json['vaccine_name'].toString(),
      dose: int.parse(json['dose_number'].toString()),
      recommendedAge:
          double.parse(json['recommended_age_months'].toString()),
    );
  }

  String get displayLabel => '$name (Dose $dose)';
}
