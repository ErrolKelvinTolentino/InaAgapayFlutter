import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/add_mother_form_data.dart';
import '../services/auth_storage.dart';
import 'add_prenatal_checkup.dart';
import '../widgets/risk_preview_card.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not authenticated')));
      return;
    }

    final response = await http.post(
      Uri.parse('https://inaagapay.alwaysdata.net/api/midwife/add_mother.php'),
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
        'mother': {
          'assigned_bhc_id': form.assignedBhcId,
          'birthdate': form.birthdate?.toIso8601String(),
          'house_number': form.houseNumber,
          'street': form.street,
          'barangay': form.barangay,
          'city_municipality': form.cityMunicipality,
          'province': form.province,
          'height_cm': form.heightCm,
          'weight_kg': form.weightKg,
          'blood_type': form.bloodType,
        },
        'emergency_contact': {
          'first_name': form.ecFirstName,
          'middle_name': form.ecMiddleName,
          'last_name': form.ecLastName,
          'extension_name': form.ecExtension,
          'phone_number': form.ecPhone,
          'email_address': form.ecEmail,
          'affiliation': form.ecAffiliation,
          'house_number': form.ecHouseNumber,
          'street': form.ecStreet,
          'barangay': form.ecBarangay,
          'city_municipality': form.ecCityMunicipality,
          'province': form.ecProvince,
        },
        'medical_conditions': form.medicalConditions
            .map(
              (c) => {
                'condition_name': c.conditionName,
                'diagnosis_date': c.diagnosisDate?.toIso8601String(),
                'status': c.status,
                'remarks': c.remarks,
              },
            )
            .toList(),
        'allergies': form.allergies
            .map(
              (a) => {
                'allergen': a.allergen,
                'diagnosis_date': a.diagnosisDate?.toIso8601String(),
                'status': a.status,
                'treatment': a.treatment,
                'remarks': a.remarks,
              },
            )
            .toList(),
        'pregnancy_history': form.pastPregnancies
            .map(
              (p) => {
                'outcome': p.outcome,
                'outcome_date': p.outcomeDate?.toIso8601String(),
                'is_outcome_date_estimated': p.isOutcomeDateEstimated,
                'delivery_date': p.deliveryDate?.toIso8601String(),
                'place_of_delivery': p.placeOfDelivery,
                'delivery_method': p.deliveryMethod,
                'gestational_age_at_end': p.gestationalAgeAtEnd,
              },
            )
            .toList(),
        'pregnancy': {
          'pregnancy_risk_level': form.riskLevel,
          'risk_score': form.riskScore,
          'risk_note': form.riskNote,
          'risk_factors': form.riskFactors,
          'last_menstrual_period': form.lastMenstrualPeriod?.toIso8601String(),
          'expected_date_of_delivery': form.expectedDateOfDelivery
              ?.toIso8601String(),
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
          content: Text('Server error. Please try again or contact admin.'),
        ),
      );
      return;
    }

    final decoded = jsonDecode(rawBody);

    if (decoded['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mother added successfully')),
      );

      final int motherId =
          int.tryParse(decoded['mother_id']?.toString() ?? '') ?? 0;
      final int pregnancyId =
          int.tryParse(decoded['pregnancy_id']?.toString() ?? '') ?? 0;

      if (pregnancyId > 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AddPrenatalCheckupPage(
              motherId: motherId,
              pregnancyId: pregnancyId,
              lmp: form.lastMenstrualPeriod,
              initialWeight: form.weightKg,
            ),
          ),
        );
      } else {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(decoded['message'] ?? 'Failed to add mother')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 8 – Summary & Submit',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Review details. After saving, you will proceed to the first prenatal checkup.',
        ),
        const SizedBox(height: 16),
        RiskPreviewCard(
          level: form.riskLevel,
          score: form.riskScore,
          factors: form.riskFactors,
          note: form.riskNote,
        ),
        const SizedBox(height: 16),
        _summaryRow(
          'Name',
          '${form.firstName ?? ''} ${form.middleName ?? ''} ${form.lastName ?? ''} ${form.extensionName ?? ''}',
        ),
        _summaryRow(
          'Birthdate',
          form.birthdate?.toIso8601String().split('T').first ?? '—',
        ),
        _summaryRow('Phone', form.phone ?? '—'),
        _summaryRow('Email', form.email ?? '—'),
        const Divider(height: 24),
        _summaryRow(
          'Address',
          '${form.houseNumber ?? ''} ${form.street ?? ''}, ${form.barangay ?? ''}, ${form.cityMunicipality ?? ''}, ${form.province ?? ''}',
        ),
        _summaryRow(
          'Emergency Contact',
          [
            form.ecFirstName,
            form.ecMiddleName,
            form.ecLastName,
          ].where((e) => (e ?? '').isNotEmpty).join(' '),
        ),
        const Divider(height: 24),
        _summaryRow('Height (cm)', form.heightCm?.toString() ?? '—'),
        _summaryRow('Weight (kg)', form.weightKg?.toString() ?? '—'),
        _summaryRow('Blood Type', form.bloodType ?? '—'),
        const Divider(height: 24),
        _summaryRow(
          'Medical Conditions',
          form.medicalConditions.isEmpty
              ? 'None'
              : form.medicalConditions.map((c) => c.conditionName).join(', '),
        ),
        _summaryRow(
          'Allergies',
          form.allergies.isEmpty
              ? 'None'
              : form.allergies.map((a) => a.allergen).join(', '),
        ),
        _summaryRow(
          'LMP',
          form.lastMenstrualPeriod?.toIso8601String().split('T').first ?? '—',
        ),
        _summaryRow(
          'EDD',
          form.expectedDateOfDelivery?.toIso8601String().split('T').first ??
              '—',
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(onPressed: onBack, child: const Text('Back')),
            ElevatedButton(
              onPressed: () => submit(context),
              child: const Text('Add Patient & Start Prenatal'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value.trim().isEmpty ? '—' : value)),
        ],
      ),
    );
  }
}
