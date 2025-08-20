import 'package:flutter/material.dart';
import 'package:servehub/user/cart.dart';

class ApplianceRepairPage extends StatefulWidget {
  const ApplianceRepairPage({super.key});

  @override
  _ApplianceRepairPageState createState() => _ApplianceRepairPageState();
}

class _ApplianceRepairPageState extends State<ApplianceRepairPage> {
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDateTime;

  final List<String> imageUrls = [
    'images/serviceimages/appliancerepair4.webp',
    'images/serviceimages/appliancerepair2.jpg',
    'images/serviceimages/appliancerepair3.jpeg',
    'images/serviceimages/appliancerepair1.jpg',
  ];

  void _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _addToCart() {
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date and time for the service")),
      );
      return;
    }

    cartItems.add({
      'name': 'Appliance Repair',
      'price': 250,
      'scheduledTime': _selectedDateTime!.toIso8601String(),
      'note': _notesController.text,
      'image': null,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Appliance Repair added to cart")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      appBar: AppBar(
        title: const Text("Service Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      child: Image.asset(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            // Title & Price
            const Text(
              "Appliance Repair",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "₹250/hour",
              style: TextStyle(
                fontSize: 18,
                color: Colors.blueAccent,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              "Experienced technicians ready to repair all your household appliances: refrigerators, washing machines, ovens, and more. Quick service with genuine parts.",
              style: TextStyle(fontSize: 16, height: 1.4),
            ),

            const SizedBox(height: 15),

            // Schedule Picker
            const Text(
              "Schedule Service",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onPressed: _pickDateTime,
              label: Text(
                _selectedDateTime == null
                    ? "Pick Date & Time"
                    : "${_selectedDateTime!.toLocal()}".split('.')[0],
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

            const SizedBox(height: 15),

            // Notes Field
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Add any special instructions or comments...",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Add to Cart
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _addToCart,
                child: const Text("Add to Cart", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
