import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD',
      debugShowCheckedModeBanner: false,
      home: const CrudPage(),
    );
  }
}

class CrudPage extends StatefulWidget {
  const CrudPage({super.key});

  @override
  State<CrudPage> createState() => _CrudPageState();
}

class _CrudPageState extends State<CrudPage> {
  // 🔴 CHANGE THIS TO YOUR REAL DOMAIN
  final String baseUrl = "https://inaagapay.zya.me";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  List users = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/read.php"));

      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
    }
  }

  Future<void> addUser() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty) return;

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/create.php"),
        body: {"name": nameController.text, "email": emailController.text},
      );

      if (response.statusCode == 200) {
        nameController.clear();
        emailController.clear();
        fetchUsers();
      }
    } catch (e) {
      debugPrint("Add error: $e");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter CRUD")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: loading ? null : addUser,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Add"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(users[index]['name']),
                    subtitle: Text(users[index]['email']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
