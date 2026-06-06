import 'package:flutter/material.dart';

class PageWrapper extends StatelessWidget {
  final Widget child;
  final String title;

  const PageWrapper({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This allows the UI to shift up when the keyboard opens
      resizeToAvoidBottomInset: true, 
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: child,
      ),
    );
  }
}