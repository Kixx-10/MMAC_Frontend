import 'package:flutter/material.dart';

PreferredSizeWidget customAppBar({
  required BuildContext context,
  required int currentIndex,
  required Function(int) onTabSelected,
}) {
  
  // Helper function for Navigation Buttons
  Widget navButton(String title, int index) {
    return TextButton(
      onPressed: () => onTabSelected(index),
      child: Text(
        title,
        style: TextStyle(
          color: currentIndex == index ? Colors.blue : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  return AppBar(
    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    elevation: 1, 
    automaticallyImplyLeading: false, //no back arrow
    leading: const SizedBox(width: 20), //left padding
    title: const Text(
      "eArrival", 
      style: TextStyle(
        color: Color(0xFF0B355B), 
        fontWeight: FontWeight.bold,
      ),
    ),
    actions: [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          navButton("Home", 0),
          navButton("New Application", 1),
          navButton("Update Application", 2),
          navButton("FAQs", 3),
          const SizedBox(width: 100), 
        ],
      ),
    ],
  );
}