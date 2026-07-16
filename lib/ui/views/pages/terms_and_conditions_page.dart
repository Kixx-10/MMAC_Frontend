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
      padding: const EdgeInsets.only(top: 24, bottom: 8),
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
      padding: const EdgeInsets.only(bottom: 12),
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
                          'Legal Declaration and Consent',
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
                          _buildParagraph(
                            'I hereby declare that all information I have provided in this eArrival application, including my personal identity, passport or identification details, contact information, travel itinerary, accommodation details, health declaration, customs declaration, and all other submitted information, is true, accurate, complete, and provided to the best of my knowledge and belief.',
                          ),
                          _buildParagraph(
                            'I fully understand and agree to the following:',
                          ),
                          _buildSectionTitle('1. Responsibility for Accuracy'),
                          _buildParagraph(
                            'I am solely responsible for the accuracy and completeness of all information submitted in this application. If any information changes before my arrival in the Republic of the Union of Myanmar, I agree to update my application promptly using the official eArrival system in accordance with the regulations of the Ministry of Immigration and Population.',
                          ),
                          _buildSectionTitle(
                            '2. Declaration (DE) Number and Email Responsibility',
                          ),
                          _buildParagraph(
                            'I understand that, upon successful submission, I will receive a unique Declaration (DE) Number and that my application confirmation and QR Code will be sent to the email address I have provided.',
                          ),
                          _buildParagraph(
                            'I acknowledge that it is my responsibility to:',
                          ),
                          _buildBullet(
                            'Keep my DE Number secure for future reference and application updates.',
                          ),
                          _buildBullet(
                            'Provide a valid, active, and accessible email address.',
                          ),
                          _buildBullet(
                            'Ensure that I can access the registered email account to receive my QR Code and official communications.',
                          ),
                          _buildParagraph(
                            'I understand that failure to maintain my DE Number or provide a valid email address may prevent me from updating my application or receiving important information.',
                          ),
                          _buildSectionTitle(
                            '3. Submission on Behalf of Others',
                          ),
                          _buildParagraph(
                            'If I submit this eArrival application on behalf of another traveler, including a dependent or accompanying traveler, I confirm that I am authorized to do so and that all information submitted on their behalf is true, accurate, and complete to the best of my knowledge.',
                          ),
                          _buildSectionTitle(
                            '4. Government Processing of Information',
                          ),
                          _buildParagraph(
                            'I understand that the information provided in this application may be collected, stored, verified, shared, and processed by the Ministry of Immigration and Population and other authorized government agencies for immigration, border security, customs, public health, law enforcement, and other lawful governmental purposes in accordance with the applicable laws of the Republic of the Union of Myanmar.',
                          ),
                          _buildSectionTitle(
                            '5. False or Misleading Information',
                          ),
                          _buildParagraph(
                            'I understand that providing false, misleading, incomplete, fraudulent, or inaccurate information, or concealing material facts, may result in the refusal of entry, cancellation of permission to enter, investigation, prosecution, administrative penalties, or other actions permitted under the laws of the Republic of the Union of Myanmar.',
                          ),
                          _buildSectionTitle('6. Inspection and Verification'),
                          _buildParagraph(
                            'I understand that immigration officers and other authorized government officials may request supporting documents or additional information to verify any information submitted in this application.',
                          ),
                          _buildSectionTitle('7. Final Decision on Entry'),
                          _buildParagraph(
                            'I understand that submitting this eArrival application, receiving a QR Code, or obtaining any acknowledgement from the eArrival system does not guarantee permission to enter the Republic of the Union of Myanmar. The final decision regarding admission into Myanmar rests solely with the authorized Immigration Officer at the port of entry in accordance with the applicable laws and regulations.',
                          ),
                          _buildSectionTitle('8. Consent'),
                          _buildParagraph(
                            'I have carefully read and fully understood this declaration. I voluntarily confirm that all information provided is true and complete, and I agree to comply with all applicable laws, regulations, and requirements governing entry into the Republic of the Union of Myanmar.',
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
