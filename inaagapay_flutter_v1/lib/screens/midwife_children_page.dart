import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'add_child_step1.dart';

class MidwifeChildrenPage extends StatelessWidget {
  const MidwifeChildrenPage({super.key});

  Future<List> fetchChildren() async {
    final res = await http.get(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/midwife_children.php',
      ),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load children');
    }

    final data = jsonDecode(res.body);
    return data['data'] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Children')),

      body: FutureBuilder<List>(
        future: fetchChildren(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final children = snapshot.data!;

          if (children.isEmpty) {
            return const Center(
              child: Text('No children found'),
            );
          }

          return ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, i) {
              final c = children[i];

              return ListTile(
                leading: const Icon(Icons.child_care),
                title: Text(
                  '${c['first_name']} ${c['last_name']}',
                ),
                subtitle: Text(
                  'Mother: ${c['mother_name'] ?? 'N/A'}',
                ),
                trailing: Text(
                  c['sex'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        },
      ),

      // ➕ ADD CHILD BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddChildStep1(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
