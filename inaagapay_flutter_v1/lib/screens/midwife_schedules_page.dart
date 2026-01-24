import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MidwifeSchedulesPage extends StatelessWidget {
  const MidwifeSchedulesPage({super.key});

  Future<List> fetchSchedules() async {
    final res = await http.get(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/midwife_schedules.php',
      ),
    );

    final data = jsonDecode(res.body);
    return data['data'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkup Schedules')),
      body: FutureBuilder<List>(
        future: fetchSchedules(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final schedules = snapshot.data!;

          return ListView.builder(
            itemCount: schedules.length,
            itemBuilder: (context, i) {
              final s = schedules[i];
              return ListTile(
                title: Text(s['mother_name']),
                subtitle: Text(s['scheduled_date']),
                trailing: Text(s['status']),
              );
            },
          );
        },
      ),
    );
  }
}
