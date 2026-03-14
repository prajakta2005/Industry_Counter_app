import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Center(
        child: Text(
          'Reports Screen',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
    );
  }
}