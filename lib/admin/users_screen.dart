import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:servehub/admin/admin_home_screen.dart';
import 'package:servehub/admin/admin_profile.dart';
import 'package:servehub/admin/services_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final int _selectedIndex = 1;

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminHomeScreen()));
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ServicesScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Users"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Failed to load users."));
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          // Group data by role
          final admins = docs.where((d) => d['role'] == 'Admin').toList();
          final providers = docs.where((d) => d['role'] == 'Service Provider').toList();
          final users = docs.where((d) => d['role'] == 'User').toList();

          Widget buildSection(String title, List<QueryDocumentSnapshot> items) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.deepPurple.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...items.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name'] ?? 'No Name';
                  final email = data['email'] ?? 'No Email';
                  final role = data['role'] ?? '';
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple[100],
                      child: const Icon(Icons.person, color: Colors.deepPurple),
                    ),
                    title: Text(name),
                    subtitle: Text("$email • $role"),
                    trailing: role != 'Admin'
                        ? PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'delete') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete User'),
                                    content: Text('Are you sure you want to delete "$name"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await FirebaseFirestore.instance.collection('users').doc(doc.id).delete();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"$name" has been deleted')));
                                }
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          )
                        : null,
                  ); 
                }),
              ],
            );
          }

          return ListView(
            children: [
              if (admins.isNotEmpty) buildSection('Admins', admins),
              if (providers.isNotEmpty) buildSection('Service Providers', providers),
              if (users.isNotEmpty) buildSection('Users', users),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
