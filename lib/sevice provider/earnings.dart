import 'package:flutter/material.dart';
import 'package:servehub/sevice%20provider/myjobs.dart';
import 'package:servehub/sevice%20provider/provider_home_screen.dart';
import 'package:servehub/sevice%20provider/provider_profile.dart';

class Earnings extends StatefulWidget {
  const Earnings({super.key});

  @override
  State<Earnings> createState() => _EarningsState();
}

class _EarningsState extends State<Earnings> {
  final int _selectedIndex = 2;

  void _onItemTapped(int index) {

    switch (index) {
      case 0:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => ProviderHomeScreen()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Myjobs()));
        break;
      case 2:
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ProviderProfile()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("My Earnings"),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEarningsCard(),
              const SizedBox(height: 30),
              const Text(
                "Earnings Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildSummaryRow("Today", "₹1,200"),
              _buildSummaryRow("This Week", "₹6,750"),
              _buildSummaryRow("This Month", "₹27,300"),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'My Jobs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
    );
  }

  Widget _buildEarningsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: const [
            Text(
              "Total Earnings",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              "₹56,200",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String amount) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.calendar_today_outlined, color: Colors.deepPurple),
      title: Text(title),
      trailing: Text(
        amount,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }
}
