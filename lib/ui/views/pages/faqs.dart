// lib/ui/views/pages/faqs.dart

import 'package:flutter/material.dart';
import 'package:mmac/ui/views/widgets/footer.dart';

class FAQS extends StatefulWidget {
  final VoidCallback? onReturnHome;
  const FAQS({super.key, this.onReturnHome});

  @override
  State<FAQS> createState() => _FAQSState();
}

class _FAQSState extends State<FAQS> {
  String _searchQuery = '';

  // Clean Data Matrix Registry for the System's FAQs
  final List<Map<String, String>> _faqData = [
    {
      'category': 'Identity & Passport Validation',
      'question':
          'What should I do if my passport does not have an expiration date?',
      'answer':
          'Most official passports contain an expiration threshold. If your document is legally valid indefinitely under state terms, please contact your local consulate support desk before filing this entry.',
    },
    {
      'category': 'Identity & Passport Validation',
      'question':
          'How do Myanmar citizens format their National Registration Card (NRC)?',
      'answer':
          'The entry module automatically compiles split selections into a standardized string matrix (e.g., 12/TNY(N)123456). Ensure your state code, township token, identity type, and registration numbers precisely match your physical card.',
    },
    {
      'category': 'Application Amendments',
      'question':
          'Can I modify my entry submission after final processing dispatch?',
      'answer':
          'Yes. You can use the "Retrieve & Update Records" utility located in the top navigation header. Enter your unique system token and validation credentials to amend your profile coordinates safely.',
    },
    {
      'category': 'Technical & Health Protocols',
      'question':
          'What happens if I accidentally flag a health declaration symptom?',
      'answer':
          'Flagged health conditions trigger automated quarantine interlocks. If this was a clerical error, navigate back to Step 3 using the step indicator matrix before making your final submission.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter FAQ list based on search query
    final filteredFaqs = _faqData.where((faq) {
      final query = _searchQuery.toLowerCase();
      return faq['question']!.toLowerCase().contains(query) ||
          faq['answer']!.toLowerCase().contains(query) ||
          faq['category']!.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Section 1: Content Area (Stays cleanly bounded to 800px maximum)
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormHeader(
                      category: 'SYSTEM SUPPORT & DOCUMENTATION',
                      title: 'Frequently Asked Questions',
                      subtitle:
                          'Review statutory lookup parameters, application procedures, and security matrix troubleshooting steps.',
                    ),
                    const SizedBox(height: 16),

                    // Search Bar Component Block
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xffE2E8F0)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.search,
                            color: Color(0xff64748B),
                            size: 20,
                          ),
                          hintText:
                              'Search FAQ parameters (e.g., NRC, Update, Passport)...',
                          hintStyle: TextStyle(
                            color: Color(0xff94A3B8),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dynamic Accordion Rendering Grid
                    if (filteredFaqs.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'No matching documentation entries found.',
                            style: TextStyle(
                              color: Color(0xff64748B),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredFaqs.length,
                        itemBuilder: (context, index) {
                          final faq = filteredFaqs[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xffE2E8F0),
                              ),
                            ),
                            child: Theme(
                              data: Theme.of(
                                context,
                              ).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                leading: const Icon(
                                  Icons.help_outline,
                                  color: Color(0xff0078D4),
                                  size: 20,
                                ),
                                title: Text(
                                  faq['question']!,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff0F172A),
                                  ),
                                ),
                                subtitle: Text(
                                  faq['category']!.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff64748B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                childrenPadding: const EdgeInsets.only(
                                  left: 52,
                                  right: 16,
                                  bottom: 16,
                                ),
                                expandedAlignment: Alignment.topLeft,
                                children: [
                                  Text(
                                    faq['answer']!,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: Color(0xff334155),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 24),

                    // Back Action Control Route Dispatcher
                    // OutlinedButton.icon(
                    //   onPressed: () {
                    //     if (widget.onReturnHome != null) {
                    //       widget.onReturnHome!();
                    //     }
                    //   },
                    //   icon: const Icon(Icons.arrow_back, size: 16),
                    //   label: const Text('Return to Home Base'),
                    //   style: OutlinedButton.styleFrom(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 20,
                    //       vertical: 14,
                    //     ),
                    //     foregroundColor: const Color(0xff475569),
                    //     side: const BorderSide(color: Color(0xffD1D5DB)),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            const FormFooter(),
          ],
        ),
      ),
    );
  }
}

// LOCAL COMPONENTS
class FormHeader extends StatelessWidget {
  final String category;
  final String title;
  final String subtitle;

  const FormHeader({
    super.key,
    required this.category,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xff0078D4),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xff0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xff64748B),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
