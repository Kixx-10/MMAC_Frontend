import 'package:flutter/material.dart';
import 'package:mmac/core/constants/app_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoticePage extends StatefulWidget {
  final VoidCallback onAccepted;

  const NoticePage({super.key, required this.onAccepted});

  @override
  State<NoticePage> createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Center(
        child: Container(
          width: 1200,
          // padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  color: Color.fromRGBO(1, 156, 244, 1),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    const Center(
                      child: Text(
                        'Notice',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Instructions for Submitting Online Arrival Card',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.primaryFont,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // SECTION 1
                    const Text(
                      'Who are required to submit Arrival Cards before arriving in Myanmar?',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Myanmar eArrival Card system is required for all travelers arriving in Myanmar via airports and border checkpoints. This requirement specifically includes:',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        fontFamily: AppFonts.primaryFont,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildBullet(
                      'Foreign Travelers: Must provide their passport details and relevant visa information.',
                      false,
                    ),
                    _buildBullet(
                      'Myanmar Citizens: Must provide their passport information, along with their National Registration Card (NRC) number and their father\'s name.',
                      false,
                    ),
                    const SizedBox(height: 30),

                    // SECTION 2
                    const Text(
                      'Instructions for Submitting the Myanmar eArrival Card',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildBullet(
                      'Please submit your eArrival Card at least 72 hours (or 3 days) prior to your arrival date in Myanmar, calculated using Myanmar Standard Time (UTC+6:30).',
                      true,
                    ),
                    // _buildBullet(
                    //   'A correct email address is mandatory. Please ensure that you provide a valid and active email address, as your completed eArrival Card and QR code PDF will be sent to this email for your records',
                    // ),
                    _buildBullet(
                      'Please fill out the eArrival Card accurately, ensuring no mandatory fields are left blank, as the system will not accept empty (null) values.',
                      false,
                    ),
                    // _buildBullet(
                    //   'It is crucial that you securely save the Reference Number (DE number) generated after your initial submission, as you will strictly need this number to log back into the system if you must update your application later.',
                    // ),
                    _buildBullet(
                      'If you need to correct non-core information such as your flight number or accommodation address, you may use the "Update Application" feature up to 3 days before your arrival.',
                      false,
                    ),
                    _buildBullet(
                      'If there are errors in restricted core fields (arrival date, full name, passport number, passport expiry date, date of birth, or nationality), you are not permitted to update them and must submit a completely new application.',
                      false,
                    ),
                    _buildBullet(
                      'The "Name" field must be filled out continuously and exactly as it appears in your passport.',
                      false,
                    ),
                    _buildBullet(
                      'Once the eArrival Card application is completed and verified by the system, you will be issued your Reference Number (DE number) and a QR code.',
                      false,
                    ),
                    _buildBullet(
                      'You must save or download this QR code as a digital file or screenshot or your QR code PDF will be delivered to the email you provide, so please double-check your email for accuracy before submitting.',
                      false,
                    ),
                    _buildBullet(
                      'Upon arrival in Myanmar, you are required to present this QR code to the immigration officer to proceed with your entry.',
                      false,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Important Notice",
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.primaryFont,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildBullet(
                      "Declaration (DE) Number: Upon successful submission, a unique Declaration (DE) Number will be assigned to your application. Please keep this number securely, as it is required to update your application before your arrival and for future reference.",
                      true,
                    ),
                    _buildBullet(
                      "Valid Email Address: You must provide a valid and active email address. Your application confirmation and QR Code will be sent to this email. An incorrect, inactive, or inaccessible email address may prevent you from receiving your QR Code and other important notifications.",
                      true,
                    ),
                    _buildBullet(
                      "Updating Your Application: If any information in your application changes before your arrival in Myanmar, you are responsible for updating your application through the official eArrival system using your assigned DE Number.",
                      true,
                    ),
                    const SizedBox(height: 40),

                    // NEXT BUTTON
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          //  Save to SharedPreferences so it survives browser refresh
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('hasAcceptedNotice', true);
                          widget.onAccepted();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'NEXT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
      ),
    );
  }

  Widget _buildBullet(String text, bool isImportant) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              fontSize: 20,
              height: 1.2,
              fontFamily: AppFonts.primaryFont,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
                fontFamily: AppFonts.primaryFont,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
