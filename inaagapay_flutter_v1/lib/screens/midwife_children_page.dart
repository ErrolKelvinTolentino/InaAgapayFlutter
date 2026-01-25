import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'add_child_step1.dart';
import 'child_profile_page.dart';

class MidwifeChildrenPage extends StatelessWidget {
  const MidwifeChildrenPage({super.key});

  Future<List<Map<String, dynamic>>> fetchChildren() async {
    final res = await http.get(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/midwife_children.php',
      ),
    );

    final decoded = jsonDecode(res.body);
    return List<Map<String, dynamic>>.from(decoded['data'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Children'),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchChildren(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final children = snapshot.data ?? [];

          if (children.isEmpty) {
            return const Center(child: Text('No children found'));
          }

          return ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, i) {
              final c = children[i];

              return ListTile(
                leading: const Icon(Icons.child_care),
                title: Text(
                  '${c['first_name'] ?? ''} ${c['last_name'] ?? ''}',
                ),
                subtitle: Text(
                  'Mother: ${c['mother_name'] ?? ''}',
                ),
                trailing: Text(c['sex'] ?? ''),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChildProfilePage(
                        childData: c, // ✅ FIX IS HERE
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      // ➕ ADD CHILD BUTTON (RESTORED & KEPT)
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddChildStep1Parent(),
            ),
          );
        },
      ),
    );
  }
}
