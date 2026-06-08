import 'package:flutter/material.dart';
class FAQS extends StatefulWidget {
  const FAQS({super.key});

  @override
  State<FAQS> createState() => _FAQSState();
}

class _FAQSState extends State<FAQS> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Welcome to the FAQs Page"),
      ),
    );
  }
}