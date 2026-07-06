// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class NationalHeader extends StatelessWidget {
  const NationalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 551;

    return Container(
      height: 145,
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Coat of Arms Logo Container
                  if (isTablet)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 110,
                      width: 110,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/department_logo.jpg',
                          ),
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
                          height: isTablet
                              ? 50
                              : 70, // FIXED: Corrected mobile scaling typo
                          width: 70,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/national_logo.jpg',
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "The Republic of the Union of Myanmar",
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 10,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromRGBO(119, 119, 119, 1),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "MINISTRY OF IMMIGRATION AND POPULATION",
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Right Flag Element
                  if (isTablet)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      height: 80,
                      width: 120,
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
          ),
        ),
      ),
    );
  }
}
