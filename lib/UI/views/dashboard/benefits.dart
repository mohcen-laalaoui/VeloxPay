import 'package:flutter/material.dart';

class BenefitsPage extends StatelessWidget {
  const BenefitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Check out your benefits here!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
