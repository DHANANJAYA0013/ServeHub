import 'package:flutter/material.dart';
import 'package:servehub/user/cart.dart'; // adjust path if needed

class PaintingPage extends StatefulWidget {
  const PaintingPage({super.key});

  @override
  _PaintingPageState createState() => _PaintingPageState();
}

class _PaintingPageState extends State<PaintingPage> {
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDateTime;

  final List<String> imageUrls = [
    'images/serviceimages/painting1.jpg',
    'images/serviceimages/painting2.jpg',
    'images/serviceimages/painting3.jpg',
    'images/serviceimages/painting4.jpeg',
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
    cartItems.add({
      'name': 'Painting',
      'price': 400,
      'note': _notesController.text,
      'scheduledTime': _selectedDateTime?.toIso8601String(),
      'image': null, // No user-uploaded image
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Painting service added to cart")),
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

            const SizedBox(height: 20),

            const Text(
              "Painting",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "₹400/hour",
              style: TextStyle(
                fontSize: 18,
                color: Colors.blueAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),

            const Text(
              "Professional painting service with experienced staff. We provide all paints and equipment.",
              style: TextStyle(fontSize: 16, height: 1.4),
            ),

            const SizedBox(height: 20),

            // Date & Time Picker
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

            const SizedBox(height: 20),

            // Notes
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
