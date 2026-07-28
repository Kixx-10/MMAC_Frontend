// lib/ui/views/pages/home.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mmac/core/constants/app_fonts.dart';
import 'package:mmac/ui/views/widgets/footer.dart';

class Home extends StatelessWidget {
  final VoidCallback? onStartNewApplication;
  final VoidCallback? onStartUpdateWorkflow;

  const Home({
    super.key,
    this.onStartNewApplication,
    this.onStartUpdateWorkflow,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            LandingPage(
              onStartNewApplication: onStartNewApplication,
              onStartUpdateWorkflow: onStartUpdateWorkflow,
            ),
            const FormFooter(),
          ],
        ),
      ),
    );
  }
}

// VISUAL DESIGN COMPONENTS

class LandingPage extends StatelessWidget {
  final VoidCallback? onStartNewApplication;
  final VoidCallback? onStartUpdateWorkflow;

  const LandingPage({
    super.key,
    this.onStartNewApplication,
    this.onStartUpdateWorkflow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroBanner(
          onStartNewApplication: onStartNewApplication,
          onStartUpdateWorkflow: onStartUpdateWorkflow,
        ),

        const _ProcessTimeline(),
      ],
    );
  }
}

// PRIVATE SUB-WIDGETS FOR MODULARITY

class _HeroBanner extends StatelessWidget {
  final VoidCallback? onStartNewApplication;
  final VoidCallback? onStartUpdateWorkflow;

  const _HeroBanner({this.onStartNewApplication, this.onStartUpdateWorkflow});

  String _getMonthStr(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[month - 1];
  }

  String _getWeekdayStr(int weekday) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday - 1];
  }

  Widget _buildDateBox(DateTime date) {
    return Container(
      width: 100,
      height: 96,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getMonthStr(date.month),
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            date.day.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            _getWeekdayStr(date.weekday),
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateWidget() {
    final today = DateTime.now();
    final plusTwo = today.add(const Duration(days: 2));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Submission is Free.",
            style: TextStyle(
              color: Color(0xFF0078D4),
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Complete and submit within 72 hours before arrival.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF0078D4), fontSize: 18),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDateBox(today),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "~",
                  style: TextStyle(color: Colors.grey, fontSize: 20),
                ),
              ),
              _buildDateBox(plusTwo),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue, // Ripple and default text/icon color
        surfaceTintColor: Colors.white,
        elevation: 2, // Base elevation, increases on hover
        shadowColor: Colors.black.withOpacity(0.15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xff0078D4), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile =
        screenWidth < 768; // breakpoint for stacked vs horizontal

    final welcomeText = const Text(
      'Welcome to',
      style: TextStyle(
        fontSize: 35,
        fontWeight: FontWeight.bold,
        fontFamily: AppFonts.primaryFont,
        // color: const Color.fromRGBO(9, 156, 244, 1),
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.left,
    );

    final welcomeText2 = const Text(
      'Myanmar eArrival',
      style: TextStyle(
        fontSize: 35,
        fontWeight: FontWeight.bold,
        fontFamily: AppFonts.primaryFont,
        // color: const Color.fromRGBO(9, 156, 244, 1),
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.left,
    );

    final actionCards = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildActionCard(
          "New Application",
          "Start new form",
          Icons.add_circle_outline,
          onStartNewApplication,
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          "Update Application",
          "Modify application",
          Icons.edit_note,
          onStartUpdateWorkflow,
        ),
      ],
    );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: AssetImage('assets/images/home_image.jpg'),
          fit: BoxFit.cover,
          opacity: 0.6,
        ),
      ), // Remove blue background
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 32.0 : 60.0,
        horizontal: 20.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Ensure children stretch to width
            children: [
              if (isMobile) ...[
                welcomeText,
                const SizedBox(height: 5),
                welcomeText2,
                const SizedBox(height: 24),
                _buildDateWidget(),
                const SizedBox(height: 24),
                actionCards,
              ] else ...[
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            welcomeText,
                            const SizedBox(height: 5),
                            welcomeText2,
                            const SizedBox(height: 24),
                            actionCards,
                          ],
                        ),
                      ),
                      const SizedBox(width: 40),
                      Expanded(flex: 5, child: _buildDateWidget()),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProcessTimeline extends StatelessWidget {
  const _ProcessTimeline();

  static const List<Map<String, String>> _stepData = [
    {
      'title': 'Personal Information',
      'desc':
          'Provide identity details exactly as shown on passport. Myanmar nationals must also include their NRC number and father"${"'"}s" name.',
    },
    {
      'title': 'Trip and Accommodation',
      'desc':
          'Enter flight or vehicle details and mandatory stay address while in Myanmar.',
    },
    {
      'title': 'Health & Customs',
      'desc':
          'Declare health status for the last 14 days and report any restricted goods or currency digitally.',
    },
    {
      'title': 'Review and Submit',
      'desc':
          'Verify all entered data for accuracy. Provide a digital signature to finalize and lock your submission for processing.',
    },
    {
      'title': 'Receive QR Code',
      'desc':
          'Obtain Disembarkation/Embarkation (DE) Number and digital QR code. Download the file or send it to own email for easy access.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 24.0),
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Application Process Timeline',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.primaryFont,
              color: Color(0xff1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Review the core procedural checklist segments required to secure your compliance tokens.',
            style: TextStyle(
              color: Color(0xff6B7280),
              fontSize: 14,
              fontFamily: AppFonts.primaryFont,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < _stepData.length; i++) ...[
                      Expanded(
                        child: _StepCard(
                          stepNumber: '${i + 1}',
                          title: _stepData[i]['title']!,
                          description: _stepData[i]['desc']!,
                          isDesktop: true,
                        ),
                      ),
                      if (i != _stepData.length - 1) const SizedBox(width: 16),
                    ],
                  ],
                )
              : Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: List.generate(_stepData.length, (index) {
                    return _StepCard(
                      stepNumber: '${index + 1}',
                      title: _stepData[index]['title']!,
                      description: _stepData[index]['desc']!,
                      isDesktop: false,
                    );
                  }),
                ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String stepNumber;
  final String title;
  final String description;
  final bool isDesktop;

  const _StepCard({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isDesktop ? null : 280,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffE5E7EB)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 5,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(9, 156, 244, 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xffE1F0FA),
                    child: Text(
                      stepNumber,
                      style: const TextStyle(
                        color: Color(0xff0078D4),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            fontFamily: AppFonts.primaryFont,
                            color: Color(0xff1A1A1A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Color(0xff6B7280),
                            fontSize: 13,
                            fontFamily: AppFonts.primaryFont,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
