import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:servehub/sevice provider/myjobs.dart';
import 'package:servehub/sevice provider/earnings.dart';
import 'package:servehub/sevice provider/provider_profile.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final int _selectedIndex = 0;
  final Set<String> _processingIds = {};

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const Myjobs()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const Earnings()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProviderProfile()));
        break;
    }
  }

  Future<void> _acceptBooking(DocumentSnapshot booking) async {
    setState(() {
      _processingIds.add(booking.id);
    });

    try {
      final bookingData = booking.data() as Map<String, dynamic>;
      final String serviceProviderId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

      final updateFields = {
        'status': 'Accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
        'serviceProviderId': serviceProviderId,
      };

      await firestore.collection('bookings').doc(booking.id).update(updateFields);

      await firestore.collection('accepted').doc(booking.id).set({
        ...bookingData,
        ...updateFields,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking accepted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept booking: $e')),
      );
    } finally {
      setState(() {
        _processingIds.remove(booking.id);
      });
    }
  }

  Future<void> _rejectBooking(DocumentSnapshot booking) async {
    setState(() {
      _processingIds.add(booking.id);
    });

    try {
      await firestore.collection('bookings').doc(booking.id).update({
        'status': 'Rejected',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking rejected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not reject booking: $e')),
      );
    } finally {
      setState(() {
        _processingIds.remove(booking.id);
      });
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
    return WillPopScope(
      onWillPop: () async {
        bool shouldLogout = await showDialog(
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
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProviderProfile()));
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome, Provider!'),
          backgroundColor: Colors.deepPurpleAccent,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProviderProfile()),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('bookings')
                .where('status', isEqualTo: 'Pending')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Center(child: Text('No new service requests.'));
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final doc = docs[i];
                  final data = doc.data() as Map<String, dynamic>;

                  final service = data['service'] ?? {};
                  final serviceName = service['name'] ?? 'Service';
                  final price = service['price'] ?? 0;

                  final address = data['address'] ?? 'N/A';
                  final time = formatDateTime(service['scheduledTime']);
                  final userId = data['userId'] ?? '';
                  final isProcessing = _processingIds.contains(doc.id);

                  return FutureBuilder<DocumentSnapshot>(
                    future: firestore.collection('users').doc(userId).get(),
                    builder: (context, userSnapshot) {
                      String customerName = 'Unknown';
                      String customerEmail = 'Unknown';
                      String customerPhone = 'Unknown';

                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                        customerName = userData['name'] ?? 'Unknown';
                        customerEmail = userData['email'] ?? 'Unknown';
                        customerPhone = userData['phone'] ?? 'Unknown';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Customer: $customerName'),
                              Text('Email: $customerEmail'),
                              Text('Phone: $customerPhone'),
                              Text('Address: $address'),
                              Text('Scheduled Time: $time'),
                              Text('Price: ₹$price'),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green),
                                    onPressed: isProcessing
                                        ? null
                                        : () => _acceptBooking(doc),
                                    child: const Text('Accept'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    onPressed: isProcessing
                                        ? null
                                        : () => _rejectBooking(doc),
                                    child: const Text('Reject'),
                                  ),
                                ],
                              ),
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
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Request'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'My Jobs'),
            BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Earnings'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
