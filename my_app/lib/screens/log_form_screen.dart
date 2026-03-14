import 'package:flutter/material.dart';

class LogFormScreen extends StatelessWidget {
  const LogFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Details')),
      body: Center(
        child: Text(
          'Log Form Screen',
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
    );
  }
}