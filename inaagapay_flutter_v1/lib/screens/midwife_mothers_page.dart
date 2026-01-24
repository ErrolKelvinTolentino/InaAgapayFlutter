import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MidwifeMothersPage extends StatefulWidget {
  const MidwifeMothersPage({super.key});

  @override
  State<MidwifeMothersPage> createState() => _MidwifeMothersPageState();
}

class _MidwifeMothersPageState extends State<MidwifeMothersPage> {
  Future<List<dynamic>> fetchMothers() async {
    final response = await http.get(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/midwife_mothers.php',
      ),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load mothers');
    }

    final decoded = jsonDecode(response.body);
    return decoded['data'] as List<dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mothers')),
      body: FutureBuilder<List<dynamic>>(
        future: fetchMothers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final mothers = snapshot.data!;

          if (mothers.isEmpty) {
            return const Center(child: Text('No mothers found'));
          }

          return ListView.builder(
            itemCount: mothers.length,
            itemBuilder: (context, index) {
              final m = mothers[index];

              final fullName = [
                m['first_name'],
                m['middle_name'],
                m['last_name'],
                m['extension_name']
              ].where((e) => e != null && e.toString().isNotEmpty).join(' ');

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: const Icon(Icons.pregnant_woman),
                  title: Text(fullName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BHC: ${m['bhc_name'] ?? 'Unassigned'}'),
                      Text(
                        'Risk Level: ${m['pregnancy_risk_level'] ?? 'N/A'}',
                      ),
                    ],
                  ),
                  trailing: Text(
                    m['pregnancy_status'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
