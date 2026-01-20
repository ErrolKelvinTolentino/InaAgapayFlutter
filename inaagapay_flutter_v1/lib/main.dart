import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl =
    "https://inaagapay.alwaysdata.net/"; // Your online backend

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();

  List users = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  // FETCH USERS
  Future<void> fetchUsers() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/index.php?route=read"));

      if (res.body.trim().startsWith("<")) {
        debugPrint("❌ HTML received, not JSON");
        return;
      }

      setState(() {
        users = json.decode(res.body);
      });
    } catch (e) {
      debugPrint("Fetch error: $e");
    }
  }

  // ADD USER
  Future<void> addUser() async {
    if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty) return;

    setState(() => loading = true);

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/index.php?route=create"),
        body: {"name": nameCtrl.text, "email": emailCtrl.text},
      );

      final data = json.decode(res.body);
      if (data["success"] == true) {
        nameCtrl.clear();
        emailCtrl.clear();
        fetchUsers();
      } else {
        debugPrint("Add failed: ${data['error']}");
      }
    } catch (e) {
      debugPrint("Add error: $e");
    }

    setState(() => loading = false);
  }

  // DELETE USER
  Future<void> deleteUser(String id) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/index.php?route=delete"),
        body: {"id": id},
      );
      final data = json.decode(res.body);
      if (data["success"] == true) {
        fetchUsers();
      } else {
        debugPrint("Delete failed: ${data['error']}");
      }
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter CRUD")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: loading ? null : addUser,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Add"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: users.isEmpty
                ? const Center(child: Text("No users yet"))
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, i) {
                      final user = users[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          title: Text(user['name']),
                          subtitle: Text(user['email']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteUser(user['id']),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
