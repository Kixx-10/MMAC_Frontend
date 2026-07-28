import 'package:flutter/material.dart';
import 'package:mmac/core/constants/app_fonts.dart';
import 'package:mmac/ui/views/widgets/footer.dart';

class NoticeLayout extends StatefulWidget {
  final String? initialNotice;

  const NoticeLayout({super.key, this.initialNotice});

  @override
  State<NoticeLayout> createState() => _NoticeLayoutState();
}

class _NoticeLayoutState extends State<NoticeLayout> {
  late String _selectedNotice;

  final List<String> _validNotices = [
    "Before You Apply",
    "Terms and Conditions",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialNotice != null &&
        _validNotices.contains(widget.initialNotice)) {
      _selectedNotice = widget.initialNotice!;
    } else {
      _selectedNotice = _validNotices.first;
    }
  }

  @override
  void didUpdateWidget(covariant NoticeLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialNotice != oldWidget.initialNotice &&
        widget.initialNotice != null) {
      if (_validNotices.contains(widget.initialNotice)) {
        setState(() {
          _selectedNotice = widget.initialNotice!;
        });
      }
    }
  }

  // Helper for Section Titles
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontFamily: AppFonts.primaryFont,
        ),
      ),
    );
  }

  // Helper for regular paragraphs
  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
          height: 1.6,
          fontFamily: AppFonts.primaryFont,
        ),
      ),
    );
  }

  // Helper for bullet points with Rich Text
  Widget _buildBulletPoint(List<InlineSpan> spans) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0, right: 12.0),
            child: Icon(
              Icons.circle,
              size: 7,
              color: Color.fromRGBO(9, 156, 244, 1),
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.6,
                  fontFamily: AppFonts.primaryFont,
                ),
                children: spans,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for numbered terms (①, ②, etc.) with Rich Text
  Widget _buildNumberedTerm(String number, List<InlineSpan> spans) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0, right: 12.0),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromRGBO(9, 156, 244, 1),
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.primaryFont,
              ),
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.6,
                  fontFamily: AppFonts.primaryFont,
                ),
                children: spans,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeYouApplyContent() {
    const boldStyle = TextStyle(fontWeight: FontWeight.bold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildParagraph(
          "Please read the following information carefully before starting the Myanmar eArrival application.",
        ),

        _buildSectionHeader("Eligibility"),
        _buildParagraph(
          "The Myanmar eArrival Card is required for all travelers entering Myanmar through international airports and designated border checkpoints.",
        ),
        _buildBulletPoint([
          const TextSpan(text: 'Foreign Travelers', style: boldStyle),
          const TextSpan(
            text: ' must provide a valid passport and visa information.',
          ),
        ]),
        _buildBulletPoint([
          const TextSpan(text: 'Myanmar Citizens', style: boldStyle),
          const TextSpan(
            text:
                ' must provide passport information, National Registration Card (NRC) number, and Father\'s Name.',
          ),
        ]),

        _buildSectionHeader("Before Starting"),
        _buildBulletPoint([
          const TextSpan(text: 'Applications can be submitted only within '),
          const TextSpan(text: '72 hours (3 days)', style: boldStyle),
          const TextSpan(
            text:
                ' before the scheduled arrival in Myanmar. All time calculations are based on Myanmar Standard Time (UTC+6:30).',
          ),
        ]),
        _buildBulletPoint([
          const TextSpan(text: 'A '),
          const TextSpan(
            text: 'valid and active email address',
            style: boldStyle,
          ),
          const TextSpan(
            text:
                ' is required. The application confirmation, Disembarkation/Embarkation (DE) Number, and QR Code will be sent to the registered email address.',
          ),
        ]),
        _buildBulletPoint([
          const TextSpan(text: 'All required fields must be completed.'),
        ]),
        _buildBulletPoint([
          const TextSpan(text: 'The full name must '),
          const TextSpan(text: 'exactly match the passport', style: boldStyle),
          const TextSpan(
            text:
                ' and should be entered in the same format as shown on the passport.',
          ),
        ]),

        _buildSectionHeader("After Submission"),
        _buildBulletPoint([
          const TextSpan(text: 'A unique '),
          const TextSpan(
            text: 'Disembarkation/Embarkation (DE) Number',
            style: boldStyle,
          ),
          const TextSpan(
            text:
                ' will be generated after successful submission. This number is required to update the application before arrival and should be kept for future reference.',
          ),
        ]),
        _buildBulletPoint([
          const TextSpan(
            text:
                'Only permitted non-core information, such as accommodation details or flight information, can be updated before arrival.',
          ),
        ]),
        _buildBulletPoint([
          const TextSpan(text: 'Core personal information', style: boldStyle),
          const TextSpan(
            text:
                ', including Name, Date of Birth, Passport Number, Passport Expiry Date, Nationality, and Date of Arrival, ',
          ),
          const TextSpan(text: 'cannot be changed', style: boldStyle),
          const TextSpan(
            text:
                ' after submission. If any of these details are incorrect, a new application must be submitted.',
          ),
        ]),
        _buildBulletPoint([
          const TextSpan(text: 'Any application update will generate a '),
          const TextSpan(text: 'new QR Code', style: boldStyle),
          const TextSpan(
            text:
                '. Previously issued QR Codes will become invalid automatically.',
          ),
        ]),

        _buildSectionHeader("Before Arrival"),
        _buildBulletPoint([
          const TextSpan(
            text:
                'Download, print, or save a clear copy of the QR Code on a mobile device.',
          ),
        ]),
        _buildBulletPoint([
          const TextSpan(
            text:
                'Present the QR Code to the Immigration Officer upon arrival for immigration processing.',
          ),
        ]),
      ],
    );
  }

  Widget _buildTermsContent() {
    const boldStyle = TextStyle(fontWeight: FontWeight.bold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNumberedTerm("①", [
          const TextSpan(
            text:
                'All information submitted in the Myanmar eArrival application must be true, accurate, and complete.',
          ),
        ]),
        _buildNumberedTerm("②", [
          const TextSpan(text: 'Applications must be submitted within '),
          const TextSpan(text: ' 72 hours', style: boldStyle),
          const TextSpan(
            text: ' before the scheduled arrival time in Myanmar (UTC+6:30).',
          ),
        ]),
        _buildNumberedTerm("③", [
          const TextSpan(text: 'Upon successful submission, a '),
          const TextSpan(
            text: 'Disembarkation/Embarkation (DE) Number',
            style: boldStyle,
          ),
          const TextSpan(text: ' and '),
          const TextSpan(text: 'QR Code', style: boldStyle),
          const TextSpan(
            text:
                ' will be sent to the registered email address. The Disembarkation/Embarkation (DE) Number and email account should be retained for future application updates and official notifications.',
          ),
        ]),
        _buildNumberedTerm("④", [
          const TextSpan(
            text:
                'After submission, only permitted non-core information may be updated. ',
          ),
          const TextSpan(text: 'Core personal information', style: boldStyle),
          const TextSpan(
            text:
                ', including Name, Passport Number, Date of Birth, Nationality, and Date of Arrival, ',
          ),
          const TextSpan(text: 'cannot be changed', style: boldStyle),
          const TextSpan(
            text:
                '. Any correction to core information requires submission of a new application.',
          ),
        ]),
        _buildNumberedTerm("⑤", [
          const TextSpan(
            text: 'Updating permitted information will generate a ',
          ),
          const TextSpan(text: 'new QR Code', style: boldStyle),
          const TextSpan(
            text:
                '. All previously issued QR Codes will become invalid immediately.',
          ),
        ]),
        _buildNumberedTerm("⑥", [
          const TextSpan(text: 'The QR Code is valid for '),
          const TextSpan(text: 'one entry only', style: boldStyle),
          const TextSpan(
            text:
                ' and expires automatically after successful immigration clearance.',
          ),
        ]),
        _buildNumberedTerm("⑦", [
          const TextSpan(
            text:
                'Information submitted through the Myanmar eArrival system may be collected, verified, stored, shared, and processed by authorized government agencies in accordance with the laws of the Republic of the Union of Myanmar.',
          ),
        ]),
        _buildNumberedTerm("⑧", [
          const TextSpan(
            text:
                'False, misleading, incomplete, or fraudulent information may result in refusal of entry, investigation, administrative penalties, prosecution, or other actions permitted under the laws of the Republic of the Union of Myanmar.',
          ),
        ]),
        _buildNumberedTerm("⑨", [
          const TextSpan(
            text:
                'Immigration officers may request supporting documents or additional information for verification purposes.',
          ),
        ]),
        _buildNumberedTerm("⑩", [
          const TextSpan(
            text:
                'Receipt of a QR Code or acknowledgement from the Myanmar eArrival system does not guarantee entry into the Republic of the Union of Myanmar. The final decision on admission rests with the authorized Immigration Officer at the port of entry.',
          ),
        ]),
        _buildNumberedTerm("⑪", [
          const TextSpan(
            text:
                'Except for Myanmar citizens, passports must remain valid for at least ',
          ),
          const TextSpan(text: 'six (6) months', style: boldStyle),
          const TextSpan(text: ' from the date of arrival in Myanmar.'),
        ]),
      ],
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
                    // Dynamic Header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(9, 156, 244, 1),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _selectedNotice,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: AppFonts.primaryFont,
                          ),
                        ),
                      ),
                    ),

                    // Dynamic Content
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: _selectedNotice == "Terms and Conditions"
                          ? _buildTermsContent()
                          : _buildBeforeYouApplyContent(),
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
