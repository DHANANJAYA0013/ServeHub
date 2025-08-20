import 'package:flutter/material.dart';
import 'package:servehub/user/cart.dart'; // Import the cart
import 'package:servehub/user/chat_screen.dart';
import 'package:servehub/user/profile_screen.dart';
import 'package:servehub/user/user_home_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final int _selectedIndex = 2;

  List<Map<String, dynamic>> get services => cartItems;

  int get totalPrice =>
      services.fold(0, (sum, item) => sum + (item['price'] as int));

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => UserHomeScreen()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ChatScreen()));
        break;
      case 2:
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ProfileScreen()));
        break;
      default:
        break;
    }
  }

  void removeService(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
            ),
          ),
        ),
      ),
      body: services.isEmpty
          ? Center(
              child: Text("No services booked yet.",
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w500)))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(service['name'],
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Price: \$${service['price']}'),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: Text('Remove'),
                            onPressed: () => removeService(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text('Total: \$$totalPrice',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                        ),
                        onPressed: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          final firestore = FirebaseFirestore.instance;

                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("You must be logged in to book services.")),
                            );
                            return;
                          }

                          if (services.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Your cart is empty.")),
                            );
                            return;
                          }

                          try {
                            // 🔍 Fetch user document from Firestore
                            final userDoc = await firestore.collection('users').doc(user.uid).get();

                            if (!userDoc.exists || userDoc.data()?['address'] == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Your address is not set.")),
                              );
                              return;
                            }

                            final userAddress = userDoc['address']; // 📍 Address field

                            final batch = firestore.batch();

                            for (var service in services) {
                              final docRef = firestore.collection('bookings').doc();

                              batch.set(docRef, {
                                'userId': user.uid,
                                'service': service,
                                'timestamp': Timestamp.now(),
                                'status': 'Pending',
                                'address': userAddress, // ✅ Include address in booking
                              });
                            }

                            await batch.commit();

                            cartItems.clear();
                            setState(() {});

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("All services booked successfully!")),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Booking failed: $e")),
                            );
                          }
                        },
                        child: Text('Book Services'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
