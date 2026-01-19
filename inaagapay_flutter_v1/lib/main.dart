import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = "http://10.0.2.2/flutter_crud";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String baseUrl = "http://10.0.2.2/flutter_crud";

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();

  List users = [];

  Future<void> fetchUsers() async {
    final res = await http.get(Uri.parse("$baseUrl/read.php"));
    setState(() {
      users = json.decode(res.body);
    });
  }

  Future<void> addUser() async {
    await http.post(
      Uri.parse("$baseUrl/create.php"),
      body: {"name": nameCtrl.text, "email": emailCtrl.text},
    );
    nameCtrl.clear();
    emailCtrl.clear();
    fetchUsers();
  }

  Future<void> deleteUser(String id) async {
    await http.post(Uri.parse("$baseUrl/delete.php"), body: {"id": id});
    fetchUsers();
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
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
                ElevatedButton(onPressed: addUser, child: const Text("Add")),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(users[i]['name']),
                  subtitle: Text(users[i]['email']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteUser(users[i]['id']),
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
