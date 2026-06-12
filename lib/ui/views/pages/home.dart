// lib/ui/views/pages/home.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mmac/ui/views/widgets/footer.dart';

class Home extends StatefulWidget {
  final VoidCallback? onStartNewApplication;
  final VoidCallback? onStartUpdateWorkflow;

  const Home({
    super.key,
    this.onStartNewApplication,
    this.onStartUpdateWorkflow,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  // Future<void> _checkActiveSession() async {
  //   final sessionData = await FormSessionService.loadDraft();

  //   if (sessionData != null && mounted) {
  //     // 🎯 ဖြည့်လက်စ Draft ရှိနေရင် Home Page ကို ဆက်မပြတော့ဘဲ Form ဆီ တန်းပို့လိုက်မည်
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const NewApplication()),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // Wrapped in a scroll view to prevent overflow on smaller screens
      body: SingleChildScrollView(
        child: Column(
          children: [
            LandingPage(
              // Visual design only: Empty callbacks for now
              onStartNewApplication: () {
                if (widget.onStartNewApplication != null) {
                  widget.onStartNewApplication!();
                }
              },
              onStartUpdateWorkflow: () {
                if (widget.onStartUpdateWorkflow != null) {
                  widget.onStartUpdateWorkflow!();
                }
              },
            ),
            const FormFooter(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// VISUAL DESIGN COMPONENTS BELOW
// ---------------------------------------------------------------------------

class LandingPage extends StatelessWidget {
  final VoidCallback onStartNewApplication;
  final VoidCallback onStartUpdateWorkflow;

  const LandingPage({
    super.key,
    required this.onStartNewApplication,
    required this.onStartUpdateWorkflow,
  });

  static const List<Map<String, String>> _stepData = [
    {
      'title': 'Personal Info',
      'desc':
          'Register verified full identity names, active tracking emails, and passports matching your core travel books.',
    },
    {
      'title': 'Itinerary Detail',
      'desc':
          'Specify incoming entry terminals, ports of registry, commercial flight transit logs, and local hotel nodes.',
    },
    {
      'title': 'Health & Customs',
      'desc':
          'Certify background safety questionnaires, quarantine health checks, and customs registry declarations.',
    },
    {
      'title': 'Review Preview',
      'desc':
          'Verify all compiled entry arrays for absolute data accuracy and review before sealing structural legal records.',
    },
    {
      'title': 'Secure QR Code',
      'desc':
          'Generate your secure immigration clearance code. Download it locally or distribute instantly via email nodes.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 650;

    return Column(
      children: [
        // Top Hero Banner Area
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff004578), Color(0xff0078D4), Color(0xff2B88D8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 40.0 : 60.0,
            horizontal: 20.0,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '✓  Secure Verification Environment',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Myanmar eArrival Information System',
                style: TextStyle(
                  fontSize: isMobile ? 26 : 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Text(
                  'Welcome to the official electronic declaration clearance system. Register your incoming trip vectors or pull existing records for operational adjustments before arrival barriers.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: isMobile ? 13 : 15,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 36),

              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onStartNewApplication,
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('New Application'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xff0078D4),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onStartUpdateWorkflow,
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: const Text('Update Application'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Instructions Step Grid Area
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: 50.0,
            horizontal: isMobile ? 16.0 : 24.0,
          ),
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Application Process Timeline',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1A1A1A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Review the core procedural checklist segments required to secure your compliance tokens.',
                style: TextStyle(color: Color(0xff6B7280), fontSize: 14),
              ),
              const SizedBox(height: 32),

              LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;

                  if (width < 600) {
                    return Column(
                      children: List.generate(_stepData.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _StepCard(
                            stepNumber: '${index + 1}',
                            title: _stepData[index]['title']!,
                            description: _stepData[index]['desc']!,
                          ),
                        );
                      }),
                    );
                  } else if (width < 1000) {
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _StepCard(
                                stepNumber: '1',
                                title: _stepData[0]['title']!,
                                description: _stepData[0]['desc']!,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StepCard(
                                stepNumber: '2',
                                title: _stepData[1]['title']!,
                                description: _stepData[1]['desc']!,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StepCard(
                                stepNumber: '3',
                                title: _stepData[2]['title']!,
                                description: _stepData[2]['desc']!,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(flex: 1),
                            Expanded(
                              flex: 2,
                              child: _StepCard(
                                stepNumber: '4',
                                title: _stepData[3]['title']!,
                                description: _stepData[3]['desc']!,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _StepCard(
                                stepNumber: '5',
                                title: _stepData[4]['title']!,
                                description: _stepData[4]['desc']!,
                              ),
                            ),
                            const Spacer(flex: 1),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(_stepData.length, (index) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index == 4 ? 0 : 16.0,
                            ),
                            child: _StepCard(
                              stepNumber: '${index + 1}',
                              title: _stepData[index]['title']!,
                              description: _stepData[index]['desc']!,
                            ),
                          ),
                        );
                      }),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final String stepNumber;
  final String title;
  final String description;

  const _StepCard({
    required this.stepNumber,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
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
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
