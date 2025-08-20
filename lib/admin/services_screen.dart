import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:servehub/admin/admin_home_screen.dart';
import 'package:servehub/admin/admin_profile.dart';
import 'package:servehub/admin/users_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final int _selectedIndex = 2;
  final firestore = FirebaseFirestore.instance;

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => AdminHomeScreen()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const UsersScreen()));
        break;
      case 2:
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AdminProfileScreen()));
        break;
    }
  }

  Future<Map<String, dynamic>?> _fetchUserData(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      if (doc.exists) return doc.data();
    } catch (_) {}
    return null;
  }

  /// 🔥 Updated: Deletes from both `bookings` and `accepted` collections
  Future<void> _deleteBooking(String bookingId) async {
    try {
      // Delete from 'bookings'
      final bookingRef = firestore.collection('bookings').doc(bookingId);
      final bookingSnapshot = await bookingRef.get();
      if (bookingSnapshot.exists) {
        await bookingRef.delete();
      }

      // Delete from 'accepted'
      final acceptedRef = firestore.collection('accepted').doc(bookingId);
      final acceptedSnapshot = await acceptedRef.get();
      if (acceptedSnapshot.exists) {
        await acceptedRef.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete booking: $e')),
      );
    }
  }

  //for scheduled date and time
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

  Widget _buildBookingCard(
    DocumentSnapshot booking,
    Map<String, dynamic> userData, {
    String? acceptedBy,
  }) {
    final data = booking.data() as Map<String, dynamic>;
    final service = data['service'] as Map<String, dynamic>? ?? {};
    final serviceName = service['name'] ?? 'Unnamed Service';
    final servicePrice = service['price'] ?? 0;

    final sceduledtime = formatDateTime(service['scheduledTime']);

    final userName = userData['name'] ?? 'Unknown User';
    final userEmail = userData['email'] ?? 'Unknown Email';
    final userRole = userData['role'] ?? 'Unknown Role';
    final status = data['status'] ?? 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: ExpansionTile(
        title: Text(
          'Booking by: $userName',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('($userEmail)'),
            Text('Role: $userRole'),
            Text('Service: $serviceName'),
            Text('Sceduled Time: $sceduledtime'),
            Text('Status: $status'),
            if (acceptedBy != null) Text('Accepted by: $acceptedBy'),
          ],
        ),
        children: [
          ListTile(
            title: Text(serviceName),
            trailing: Text('₹$servicePrice'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _deleteBooking(booking.id),
              child: const Text('Delete Booking'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Bookings"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Pending Bookings
            StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('bookings')
                  .where('status', isEqualTo: 'Pending')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error loading pending bookings: ${snapshot.error}'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final pending = snapshot.data?.docs ?? [];

                if (pending.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No pending bookings"),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Pending Bookings",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...pending.map((b) {
                      final userId = b['userId'] ?? '';
                      return FutureBuilder<Map<String, dynamic>?>(
                        future: _fetchUserData(userId),
                        builder: (context, us) {
                          if (us.connectionState == ConnectionState.waiting) {
                            return const ListTile(title: Text('Loading user info...'));
                          }
                          return _buildBookingCard(b, us.data ?? {});
                        },
                      );
                    }),
                  ],
                );
              },
            ),

            /// Accepted Bookings
            StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('accepted')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error loading accepted bookings: ${snapshot.error}'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final accepted = snapshot.data?.docs ?? [];

                if (accepted.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No accepted bookings"),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Accepted Bookings",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...accepted.map((b) {
                      final userId = b['userId'] ?? '';
                      final providerId = b['serviceProviderId'] ?? '';
                      return FutureBuilder<Map<String, dynamic>?>(
                        future: _fetchUserData(userId),
                        builder: (context, us) {
                          if (us.connectionState == ConnectionState.waiting) {
                            return const ListTile(title: Text('Loading customer info...'));
                          }
                          return FutureBuilder<Map<String, dynamic>?>(
                            future: _fetchUserData(providerId),
                            builder: (context, ps) {
                              if (ps.connectionState == ConnectionState.waiting) {
                                return const ListTile(title: Text('Loading provider info...'));
                              }
                              final pr = ps.data ?? {};
                              final acceptedBy =
                                  '${pr['name'] ?? 'Unknown'} (${pr['email'] ?? '—'})';
                              return _buildBookingCard(b, us.data ?? {}, acceptedBy: acceptedBy);
                            },
                          );
                        },
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        ),
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
