import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:servehub/sevice provider/earnings.dart';
import 'package:servehub/sevice provider/provider_home_screen.dart';
import 'package:servehub/sevice provider/provider_profile.dart';

class Myjobs extends StatefulWidget {
  const Myjobs({super.key});

  @override
  State<Myjobs> createState() => _MyjobsState();
}

class _MyjobsState extends State<Myjobs> {
  final int _selectedIndex = 1;

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProviderHomeScreen()),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Earnings()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProviderProfile()),
        );
        break;
    }
  }

  String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      // Customize the format as needed
      final formatted = DateFormat('MMM d, y – h:mm a').format(dateTime);
      return formatted;
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? providerId = FirebaseAuth.instance.currentUser?.uid;

    if (providerId == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('My Jobs'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('accepted')
            .where('serviceProviderId', isEqualTo: providerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading jobs'));
          }

          final jobs = snapshot.data?.docs ?? [];

          if (jobs.isEmpty) {
            return const Center(
              child: Text(
                'No jobs accepted yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final jobData = jobs[index].data() as Map<String, dynamic>;
              final userId = jobData['userId'] ?? '';

              final service = jobData['service'] ?? {};
              final serviceName = service['name'] ?? 'Service';
              final servicePrice = service['price'] ?? 0;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get(),
                builder: (context, userSnapshot) {
                  String customerName = 'Unknown';
                  String customerEmail = 'Unknown';
                  String customerPhone = 'Unknown';

                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    customerName = userData['name'] ?? 'Unknown';
                    customerEmail = userData['email'] ?? 'Unknown';
                    customerPhone = userData['phone'] ?? 'Unknown';
                  }

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(
                        bottom: 16, left: 16, right: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Customer: $customerName'),
                          Text('Email: $customerEmail'),
                          Text('Phone: $customerPhone'),
                          Text('Address: ${jobData['address'] ?? 'N/A'}'),
                          Text('Scheduled Time: ${formatDateTime(service['scheduledTime'])}'),
                          Text('Price: ₹$servicePrice'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'My Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Earnings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
