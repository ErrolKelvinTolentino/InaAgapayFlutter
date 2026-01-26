import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/add_mother_form_data.dart';
import '../services/auth_storage.dart';

class AddMotherStep7Submit extends StatelessWidget {
  final AddMotherFormData form;
  final VoidCallback onBack;

  const AddMotherStep7Submit({
    super.key,
    required this.form,
    required this.onBack,
  });

  Future<void> submit(BuildContext context) async {
    final token = await AuthStorage.getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not authenticated')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/add_mother.php',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'account': {
          'first_name': form.firstName,
          'middle_name': form.middleName,
          'last_name': form.lastName,
          'extension_name': form.extensionName,
          'email_address': form.email,
          'phone_number': form.phone,
        },
        'address': {
          'house_number': form.houseNumber,
          'street': form.street,
          'barangay': form.barangay,
          'city_municipality': form.city,
          'province': form.province,
        },
        'emergency_contact': {
          'first_name': form.ecFirstName,
          'middle_name': form.ecMiddleName,
          'last_name': form.ecLastName,
          'extension_name': form.ecExtension,
          'phone_number': form.ecPhone,
          'email_address': form.ecEmail,
        },
        'medical_conditions': form.medicalConditions,
        'allergies': form.allergies,
        'pregnancy': {
          'pregnancy_risk_level': form.riskLevel,
          'last_menstrual_period': form.lmp?.toIso8601String(),
          'expected_date_of_delivery': form.edd?.toIso8601String(),
        },
      }),
    );

    final rawBody = response.body.trim();

    // 🛑 HARD GUARD — NEVER jsonDecode HTML
    if (!rawBody.startsWith('{')) {
      debugPrint('❌ NON-JSON API RESPONSE:');
      debugPrint(rawBody);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Server error. Please try again or contact admin.',
          ),
        ),
      );
      return;
    }

    final decoded = jsonDecode(rawBody);

    if (decoded['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mother added successfully')),
      );

      // go back to mothers list
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            decoded['message'] ?? 'Failed to add mother',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 7 – Review & Submit',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Please review all information before submitting.',
        ),

        const SizedBox(height: 32),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: onBack,
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: () => submit(context),
              child: const Text('Add Patient'),
            ),
          ],
        ),
      ],
    );
  }
}
