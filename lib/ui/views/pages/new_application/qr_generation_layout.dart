import 'package:flutter/material.dart';

class QrGenereate extends StatefulWidget {
  final String applicationNo;
  final VoidCallback onFinish;

  const QrGenereate({
    super.key, 
    required this.applicationNo,
    required this.onFinish,
  });

  @override
  State<QrGenereate> createState() => _QrGenereateState();
}

class _QrGenereateState extends State<QrGenereate> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 60),
          const SizedBox(height: 12),
          const Text(
            "Submitted Successfully!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 20),
          
          Text(
            "Application Number: ${widget.applicationNo.isNotEmpty ? widget.applicationNo : 'N/A'}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.qr_code_2_rounded, size: 200, color: Colors.black),
          ),
          const SizedBox(height: 30),

          // ပြီးဆုံးကြောင်း ခလုတ်
          ElevatedButton(
            onPressed: widget.onFinish, 
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Finish", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}