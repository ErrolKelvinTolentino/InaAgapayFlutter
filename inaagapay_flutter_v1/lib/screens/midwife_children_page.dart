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

    final data = jsonDecode(res.body);
    return data['data'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Children')),

      body: FutureBuilder<List>(
        future: fetchChildren(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final children = snapshot.data!;

          return ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, i) {
              final c = children[i];
              return ListTile(
                leading: const Icon(Icons.child_care),
                title: Text('${c['first_name']} ${c['last_name']}'),
                subtitle: Text('Mother: ${c['mother_name']}'),
                trailing: Text(c['sex']),
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
              builder: (_) => const AddChildStep1Parent(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
