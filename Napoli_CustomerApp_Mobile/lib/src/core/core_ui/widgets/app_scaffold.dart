import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final Widget? floatingActionButton;

  const AppScaffold({super.key, required this.body, this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
