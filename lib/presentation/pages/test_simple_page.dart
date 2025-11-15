import 'package:flutter/material.dart';

/// ULTRA SIMPLE TEST PAGE - No wrappers, no complexity
class TestSimplePage extends StatelessWidget {
  const TestSimplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text('דף בדיקה פשוט'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'אם אתה רואה את זה - הבניה עובדת!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 20),
            
            // Test Field 1
            TextField(
              decoration: InputDecoration(
                labelText: 'שדה 1',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.black),
              ),
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            const SizedBox(height: 20),
            
            // Test Field 2
            TextField(
              decoration: InputDecoration(
                labelText: 'שדה 2',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.black),
              ),
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            const SizedBox(height: 20),
            
            // Test Field 3
            TextField(
              decoration: InputDecoration(
                labelText: 'שדה 3',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Colors.black),
              ),
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            const SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('הכפתור עובד!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(20),
              ),
              child: const Text('לחץ כאן לבדיקה', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

