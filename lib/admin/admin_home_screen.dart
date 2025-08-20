import 'package:flutter/material.dart';
import 'package:servehub/admin/admin_profile.dart';
import 'package:servehub/admin/services_screen.dart';
import 'package:servehub/admin/users_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final List<Map<String, dynamic>> dashboardItems = [
    {"title": "Manage Users", "icon": Icons.group},
    {"title": "Service Providers", "icon": Icons.build},
    {"title": "Analytics", "icon": Icons.bar_chart},
    {"title": "System Settings", "icon": Icons.settings},
  ];

  final int _selectedIndex = 0;

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => UsersScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => ServicesScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminProfileScreen()));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldLogout = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Logout'),
            content: Text('Do you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Logout'),
              ),
            ],
          ),
        );

        if (shouldLogout) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminProfileScreen()),
          );
        }

        return false;
      },

      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.deepPurple,
          title: Text(
            "Admin Dashboard",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          actions: [IconButton(
            onPressed: () { 
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminProfileScreen()
                )
              );
            }, 
            icon: Icon(Icons.settings, color: Colors.white)
          ),]
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: dashboardItems.map((item) {
              return GestureDetector(
                onTap: () {
                  // Handle navigation

                  if (item['title'] == 'Manage Users') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UsersScreen()));
                  }else if(item['title'] == 'Service Providers'){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => UsersScreen()));
                  }else if(item['title'] == 'System Settings'){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AdminProfileScreen()));
                  }
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.deepPurple[100],
                          child: Icon(item["icon"], size: 28, color: Colors.deepPurple),
                        ),
                        SizedBox(height: 12),
                        Text(item["title"],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: "Users",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: "Bookings",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}