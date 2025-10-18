import 'package:flutter/material.dart';

class HardwareView extends StatelessWidget {
  const HardwareView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('صفحة الحديده'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'هذه صفحة الحديده',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
