// lib/ui/views/pages/terms_and_conditions_page.dart

import 'package:flutter/material.dart';
import 'package:mmac/core/constants/app_fonts.dart';
import 'package:mmac/ui/views/widgets/footer.dart';

class TermsAndConditionsPage extends StatefulWidget {
  final VoidCallback onAccepted;

  const TermsAndConditionsPage({super.key, required this.onAccepted});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool _isAgreed = false;

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontFamily: AppFonts.primaryFont,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.5,
          fontFamily: AppFonts.primaryFont,
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
                fontFamily: AppFonts.primaryFont,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                constraints: const BoxConstraints(maxWidth: 900),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(9, 156, 244, 1),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Myanmar eArrival Card System',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: AppFonts.primaryFont,
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Terms and Conditions'),
                          _buildParagraph(
                            'By accessing and using the Myanmar eArrival Card system, you agree to comply with and be bound by the following Terms and Conditions:',
                          ),
                          _buildSectionTitle(
                            '1. Application Timeframe (Time Limitation) ',
                          ),
                          _buildParagraph(
                            'Applications for the eArrival Card must be submitted within seventy-two (72) hours (UTC+6:30) prior to your scheduled arrival in Myanmar.',
                          ),
                          _buildSectionTitle(
                            '2. Modification of Information (Core Field Protection) ',
                          ),
                          _buildParagraph(
                            'After successful submission of the application, only specific non-core fields (such as accommodation details or flight changes) may be updated. Core personal data, including but not limited to Name, Passport Number, Date of Birth, Nationality, and Date of Arrival—cannot be modified. If changes to core fields are required, the applicant must discard the current application and submit a completely new one.',
                          ),
                          _buildSectionTitle('3. QR Code Invalidation '),
                          _buildParagraph(
                            'If an applicant updates their permitted information, a new QR code will be generated. Upon the generation of the new QR code, any previously issued QR code(s) associated with that application will be immediately invalidated and cannot be used for entry clearance.',
                          ),
                          _buildSectionTitle(
                            '4. Exception Handling and Information Accuracy ',
                          ),
                          _buildParagraph(
                            'The traveler is solely responsible for the accuracy of the submitted data. If the provided information is found to be incorrect, mismatched, or incomplete upon arrival, the traveler will be subjected to exception handling procedures and must undergo further verification through the designated secondary inspection channels by immigration authorities.',
                          ),
                          _buildSectionTitle(
                            '5. Passport Validity Requirement ',
                          ),
                          _buildParagraph(
                            'To be eligible for entry, the applicant${"'"} passport must have a minimum validity of six (6) months from the actual date of arrival in Myanmar. For Myanmar citizens, there is no minimum passport expiry date.',
                          ),
                          _buildSectionTitle(
                            '6. QR Code Lifecycle and Expiration',
                          ),
                          _buildParagraph(
                            'The issued eArrival Card QR code is valid for a single entry only. The QR code will automatically expire and be permanently deactivated in the system immediately after the traveler has successfully cleared immigration and entered the country.',
                          ),
                          _buildSectionTitle(
                            '7. Declaration and Acknowledgment ',
                          ),
                          _buildParagraph(
                            'By submitting this application, I hereby declare that I fully understand the terms stated herein and that all information provided in this form is true, accurate, and complete to the best of my knowledge. I acknowledge that providing false, fabricated, or misleading information may result in the rejection of the application, denial of entry, or other appropriate legal actions under the existing laws of Myanmar.',
                          ),

                          const SizedBox(height: 32),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFF5F5F7),
                          ),
                          const SizedBox(height: 24),

                          // Checkbox & Action Button
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FBFF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE5F0FF),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _isAgreed,
                                  onChanged: (val) {
                                    setState(() {
                                      _isAgreed = val ?? false;
                                    });
                                  },
                                  activeColor: const Color.fromRGBO(
                                    9,
                                    156,
                                    244,
                                    1,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text(
                                      'I have read, understood, and agree to the above Important Notice, Legal Declaration, and Consent.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontFamily: AppFonts.primaryFont,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isAgreed ? widget.onAccepted : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(
                                  9,
                                  156,
                                  244,
                                  1,
                                ),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.shade300,
                                disabledForegroundColor: Colors.grey.shade500,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Accept & Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppFonts.primaryFont,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              const FormFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
