import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vaccine_model.dart';

Future<List<VaccineModel>> fetchVaccines() async {
  final res = await http.get(
    Uri.parse(
      'https://inaagapay.alwaysdata.net/api/midwife/get_vaccines.php',
    ),
  );

  if (res.statusCode != 200) {
    throw Exception('HTTP ${res.statusCode}');
  }

  final List decoded = jsonDecode(res.body);

  return decoded
      .map((e) => VaccineModel.fromJson(e))
      .toList();
}
