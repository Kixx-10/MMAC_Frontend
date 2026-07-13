// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mmac/core/constants/app_fonts.dart';

class FormFooter extends StatelessWidget {
  const FormFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color.fromRGBO(33, 37, 41, 1), // Deep official blue
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
            children: [
              Wrap(
                spacing: 40, // Horizontal space between elements
                runSpacing: 24, // Vertical space when elements wrap on mobile
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Portal Identity Context',
                          style: TextStyle(
                            color: Color(0xffE1F0FA),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: AppFonts.primaryFont,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Official automated eArrival declaration asset pool. Processes live border transactions and tracks validation keys transparently.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.5,
                            fontFamily: AppFonts.primaryFont,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Support Operations',
                        style: TextStyle(
                          color: Color(0xffE1F0FA),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: AppFonts.primaryFont,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'System Storage Architecture Team\nOperational Data Registry Core',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.5,
                          fontFamily: AppFonts.primaryFont,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Divider(color: Colors.white.withOpacity(0.15)),
              const SizedBox(height: 16),
              Text(
                '© 2026 International eArrival Portal System. All rights reserved.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                  fontFamily: AppFonts.primaryFont,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
