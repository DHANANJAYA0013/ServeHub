import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:servehub/auth/login_screen.dart';

class ProviderProfile extends StatelessWidget {
  const ProviderProfile({super.key});

  Future<Map<String, dynamic>?> _getProviderData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Provider Profile"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _getProviderData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.hasError) {
              return const Center(child: Text("Failed to load provider data"));
            }

            final data = snapshot.data!;
            final name = data['name'] ?? 'N/A';
            final email = data['email'] ?? 'N/A';
            final category = data['category'] ?? 'Unknown';
            final location = data['location'] ?? 'Not specified';
            final rating = data['rating']?.toString() ?? '0.0';
            final reviewCount = data['reviews']?.toString() ?? '0';
            final availability = data['availability'] ?? 'Mon - Sat, 9:00 AM to 6:00 PM';
            final services = List<String>.from(data['services'] ?? []);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.deepPurple[100],
                    child: const Icon(Icons.person, size: 60, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),

                  // Email
                  Text(email, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  const SizedBox(height: 8),

                  // Service Category
                  Text(category, style: const TextStyle(fontSize: 18, color: Colors.deepPurple)),
                  const SizedBox(height: 8),

                  // Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text("$rating ($reviewCount reviews)", style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Services Offered
                  _sectionTitle("Services Offered"),
                  ...services.map((service) => _serviceListItem(service)),
                  const SizedBox(height: 20),

                  // Availability
                  _sectionTitle("Availability"),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(availability),
                  ),
                  const SizedBox(height: 20),

                  // Location
                  _sectionTitle("Location"),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(location),
                  ),
                  const SizedBox(height: 20),

                  // Profile Options
                  ProfileOption(
                    icon: Icons.edit,
                    title: "Edit Profile",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Edit Profile tapped")),
                      );
                    },
                  ),
                  ProfileOption(
                    icon: Icons.history,
                    title: "Booking History",
                    onTap: () {},
                  ),
                  ProfileOption(
                    icon: Icons.reviews,
                    title: "Reviews Received",
                    onTap: () {},
                  ),
                  ProfileOption(
                    icon: Icons.settings,
                    title: "Settings",
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),

                  // Logout Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      final shouldLogout = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Do you want to log out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout) {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Custom section title widget
  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Custom service list item widget
  Widget _serviceListItem(String service) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.check_circle_outline, color: Colors.deepPurple),
      title: Text(service),
    );
  }
}

// Reusable Profile Option Widget
class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
