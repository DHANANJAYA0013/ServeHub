import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:servehub/user/booking_screen.dart';
import 'package:servehub/user/chat_screen.dart';
import 'package:servehub/user/profile_screen.dart';
import 'package:servehub/user/services/appliance_repair_page.dart';
import 'package:servehub/user/services/carpentry_page.dart';
import 'package:servehub/user/services/cleaning_page.dart';
import 'package:servehub/user/services/electrician_page.dart';
import 'package:servehub/user/services/gardening_page.dart';
import 'package:servehub/user/services/painting_page.dart';
import 'package:servehub/user/services/plumbing_page.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final int _selectedIndex = 0; // mutable index
  final TextEditingController _searchController = TextEditingController();

  final List<String> imageUrls = [
    'images/img1.jpg',
    'images/img2.jpg',
    'images/img3.png',
    'images/img4.jpg',
  ];

  final List<Map<String, dynamic>> categories = [
    {'title': 'Plumbing', 'icon': Icons.plumbing},
    {'title': 'Electrician', 'icon': Icons.electrical_services},
    {'title': 'Cleaning', 'icon': Icons.cleaning_services},
    {'title': 'Painting', 'icon': Icons.format_paint},
    {'title': 'Gardening', 'icon': Icons.park},
    {'title': 'Carpentry', 'icon': Icons.chair},
    {'title': 'Appliance Repair', 'icon': Icons.build_circle},
  ];

  List<Map<String, dynamic>> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = categories;
    // Removed listener for live search
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        // If empty, reset to all categories
        _filteredCategories = categories;
      } else {
        _filteredCategories = categories.where((category) {
          final title = category['title'].toString().toLowerCase();
          return title.contains(query);
        }).toList();
      }
    });
  }


  Future<Map<String, dynamic>?> _getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data();
  }

  void _onItemTapped(int index) {

    switch (index) {
      case 0:
        // Already on Home screen
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }

  void _navigateToService(String title) {
    Widget? page;

    switch (title) {
      case 'Plumbing':
        page = const PlumbingPage();
        break;
      case 'Electrician':
        page = const ElectricianPage();
        break;
      case 'Cleaning':
        page = const CleaningPage();
        break;
      case 'Painting':
        page = const PaintingPage();
        break;
      case 'Gardening':
        page = const GardeningPage();
        break;
      case 'Carpentry':
        page = const CarpentryPage();
        break;
      case 'Appliance Repair':
        page = const ApplianceRepairPage();
        break;
    }

    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    }
  }

  // Future<void> _handleLogout() async {
  //   await FirebaseAuth.instance.signOut();
  //   Navigator.pushReplacementNamed(context, '/login');
  // }

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
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        }

        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (!snapshot.hasData) {
                return const Center(child: Text("User data not found"));
              }

              final userData = snapshot.data!;
              final name = userData['name'] ?? 'User';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.yellow[700],
                              child: Icon(CupertinoIcons.person_fill, color: Colors.yellow[900]),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Welcome!", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                          },
                          icon: const Icon(Icons.settings),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar with Icon Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search for services...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        fillColor: Colors.white,
                        filled: true,
                        // suffixIcon: IconButton(
                        //   icon: const Icon(Icons.search),
                        //   onPressed: _performSearch,
                        // ),
                      ),
                      onSubmitted: (_) => _performSearch(), // Optional: also search on keyboard submit
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Image Carousel
                  SizedBox(
                    height: 180,
                    child: PageView.builder(
                      itemCount: imageUrls.length,
                      controller: PageController(viewportFraction: 0.9),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(imageUrls[index], fit: BoxFit.cover),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Categories Heading
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),

                  const SizedBox(height: 12),

                  // Scrollable Category Grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _filteredCategories.isEmpty
                          ? const Center(child: Text("No matching categories found."))
                          : GridView.builder(
                              itemCount: _filteredCategories.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 3 / 2,
                              ),
                              itemBuilder: (context, index) {
                                final category = _filteredCategories[index];
                                return GestureDetector(
                                  onTap: () => _navigateToService(category['title']),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(category['icon'], size: 32, color: Colors.deepPurple),
                                        const SizedBox(height: 8),
                                        Text(category['title'], style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Bookings'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
