// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class NationalHeader extends StatelessWidget {
  const NationalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900; // Mobile/Tablet breakpoint

    return Container(
      padding: EdgeInsets.only(
        left: isMobile ? 16.0 : 150.0,
        right: isMobile ? 16.0 : 150.0,
      ),
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(Colors.white24.value),
            offset: const Offset(0, 6),
            blurRadius: 1,
          ),
        ],
      ),
      child: Transform.translate(
        offset: const Offset(0, -12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Coat of Arms Logo Container
            if (!isMobile)
              Container(
                margin: const EdgeInsets.only(left: 20, top: 10),
                height: 90,
                width: 90,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/department_logo.jpg'),
                    fit: BoxFit.contain,
                  ),
                  color: Color(0xffF3F4F6),
                  shape: BoxShape.circle,
                ),
              ),

            // Central Identity Descriptions (Expanded to guarantee fluid scaling)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: isMobile
                        ? 50
                        : 70, // FIXED: Corrected mobile scaling typo
                    width: 70,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/national_logo.jpg'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "The Republic of the Union of Myanmar",
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Department of Immigration and Population",
                    style: TextStyle(
                      fontSize: isMobile ? 17 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Right Flag Element
            if (!isMobile)
              Container(
                margin: const EdgeInsets.only(right: 20, top: 10),
                height: 60,
                width: 90,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/national_flag.jpg'),
                    fit: BoxFit.cover,
                  ),
                  color: Color(0xffF3F4F6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
