// lib/ui/views/pages/new_application/review_layout.dart

import 'package:flutter/material.dart';
import 'package:mmac/core/constants/app_fonts.dart';

class ReviewLayout extends StatefulWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, dynamic> values;
  final Widget actionButtons;
  final Function(int targetStep) onEditRequested;
  final bool isUpdateMode;
  final Function(String, dynamic) onValueChanged;

  const ReviewLayout({
    super.key,
    required this.controllers,
    required this.values,
    required this.actionButtons,
    required this.onEditRequested,
    required this.isUpdateMode,
    required this.onValueChanged,
  });

  @override
  State<ReviewLayout> createState() => _ReviewLayoutState();
}

class _ReviewLayoutState extends State<ReviewLayout> {
  //  Track whether the user has agreed to the terms
  // bool _isAgreed = false;

  @override
  void initState() {
    super.initState();
    // _isAgreed = widget.values['isAgreed'] == true;
  }

  bool get _isAgreed => widget.values['isAgreed'] == true;

  bool get _isMyanmar =>
      widget.values['country'] == 'Myanmar' ||
      widget.values['country'] == 'MMR';

  String _formatDate(dynamic date) {
    if (date == null) return '—';
    if (date is DateTime) {
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }
    return date.toString();
  }

  // ---------------------------------------------------------------------------
  // SECTION BUILDERS
  // ---------------------------------------------------------------------------

  Widget _buildWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD0E7FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: Colors.blue.shade800,
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review Application Details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                    fontFamily: AppFonts.primaryFont,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Please double-check all fields below. You can update any step before final submission.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF335577),
                    height: 1.3,
                    fontFamily: AppFonts.primaryFont,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _ReviewSectionCard(
      title: 'Personal Information',
      icon: Icons.person_outline_rounded,
      step: 1,
      onEditRequested: widget.onEditRequested,
      iconColor: Colors.blue.shade700,
      iconBgColor: Colors.blue.shade50,
      children: [
        _ReviewTile(
          label: 'Full Name',
          value: widget.controllers['fullName']?.text,
        ),
        _ReviewTile(label: 'Gender', value: widget.values['gender']),
        _ReviewTile(
          label: 'Date of Birth',
          value: _formatDate(widget.values['dateOfBirth']),
        ),
        _ReviewTile(label: 'Nationality', value: widget.values['country']),
        _ReviewTile(
          label: 'Place of Birth',
          value: widget.values['placeOfBirth'],
        ),
        _ReviewTile(label: 'Email', value: widget.controllers['email']?.text),
        // _ReviewTile(
        //   label: 'Place of Residence',
        //   value: widget.controllers['placeOfResidence']?.text,
        // ),
        _ReviewTile(
          label: 'Mobile Number',
          value: widget.controllers['mobile']?.text,
        ),
        if (!_isMyanmar)
          _ReviewTile(
            label: 'Visa Number',
            value: widget.controllers['visaNumber']?.text,
          ),
        if (_isMyanmar) ...[
          _ReviewTile(label: 'NRC', value: widget.controllers['nrc']?.text),
          _ReviewTile(
            label: 'Father Name',
            value: widget.controllers['fatherName']?.text,
          ),
        ],
        _ReviewTile(
          label: 'Passport Number',
          value: widget.controllers['passportNumber']?.text,
        ),
        _ReviewTile(
          label: 'Passport Issued Date',
          value: _formatDate(widget.values['issuedDate']),
        ),
        _ReviewTile(
          label: 'Passport Expiry Date',
          value: _formatDate(widget.values['expiryDate']),
        ),
        _ReviewTile(
          label: 'Passport Issued Country',
          value: widget.values['issuedCountry'],
        ),
        _ReviewTile(
          label: 'Place of Residence',
          value: widget.values['placeOfResidence'],
        ),
      ],
    );
  }

  Widget _buildTripDetailsSection() {
    return _ReviewSectionCard(
      title: 'Trip Details',
      icon: Icons.local_airport_outlined,
      step: 2,
      onEditRequested: widget.onEditRequested,
      iconColor: Colors.blue.shade700,
      iconBgColor: Colors.blue.shade50,
      children: [
        _ReviewTile(
          label: 'Arrival Date',
          value: _formatDate(widget.values['arrivalDate']),
        ),
        _ReviewTile(
          label: 'Mode of Travel',
          value: widget.values['modeOfTravel'],
        ),
        _ReviewTile(
          label: 'Port of Arrival',
          value: widget.values['portOfArrival'],
        ),
        _ReviewTile(
          label: 'Vehicle Number',
          value: widget.controllers['vehicleNumber']?.text,
        ),

        if (!_isMyanmar)
          _ReviewTile(
            label: 'Accommodation',
            value: widget.values['accommodation'],
          ),
        _ReviewTile(
          label: 'Address in Myanmar',
          value: widget.controllers['addressInMyanmar']?.text,
        ),
        _ReviewTile(label: 'State/Region', value: widget.values['stateRegion']),
        _ReviewTile(label: 'District', value: widget.values['district']),
        _ReviewTile(label: 'Township', value: widget.values['township']),
        if (_isMyanmar)
          _ReviewTile(
            label: 'Mobile (MM)',
            value: widget.controllers['mobileNumberMM']?.text,
          ),
        _ReviewTile(
          label: 'Purpose of Visit',
          value: widget.values['purposeOfVisit'],
        ),
        _ReviewTile(
          label: 'Previous City',
          value: widget.controllers['previousCity']?.text,
        ),
      ],
    );
  }

  Widget _buildHealthDeclarationsSection() {
    return _ReviewSectionCard(
      title: 'Health & Declarations',
      icon: Icons.health_and_safety_outlined,
      step: 3,
      onEditRequested: widget.onEditRequested,
      iconColor: Colors.green.shade700,
      iconBgColor: Colors.green.shade50,
      isGrid: false,
      children: [
        _DeclarationCard(
          label:
              'Fever, cough, sore throat or shortness of breath in past 14 days?',
          value: widget.values['hasSymptoms'],
        ),
        _DeclarationCard(
          label: 'Carrying prohibited or restricted items?',
          value: widget.values['carryingRestricted'],
        ),
        if (widget.values['hasSymptoms'] == 'Yes' &&
            widget.values['healthRecordFileName'] != null)
          _AttachmentCard(fileName: widget.values['healthRecordFileName']!),
      ],
    );
  }

  // MAIN BUILD METHOD
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWarningBanner(),
        const SizedBox(height: 24),
        _buildPersonalInfoSection(),
        _buildTripDetailsSection(),
        _buildHealthDeclarationsSection(),

        widget.actionButtons,
        // Stack(
        //   children: [
        //     widget.actionButtons,
        //     if (!_isAgreed)
        //       Positioned(
        //         right: 0,
        //         top: 0,
        //         bottom: 0,
        //         width:
        //             MediaQuery.of(context).size.width *
        //             0.4, // Covers the right side (Submit button)
        //         child: GestureDetector(
        //           behavior: HitTestBehavior.opaque,
        //           onTap: () {
        //             ScaffoldMessenger.of(context).showSnackBar(
        //               SnackBar(
        //                 content: const Text(
        //                   'Please check the agreement box in the Legal Declaration to submit your application.',
        //                 ),
        //                 backgroundColor: Colors.red.shade600,
        //                 behavior: SnackBarBehavior.floating,
        //                 shape: RoundedRectangleBorder(
        //                   borderRadius: BorderRadius.circular(8),
        //                 ),
        //               ),
        //             );
        //           },
        //           child: Container(color: Colors.transparent),
        //         ),
        //       ),
        //   ],
        // ),
      ],
    );
  }
}

// PRIVATE SUB-WIDGETS
class _ReviewTile extends StatelessWidget {
  final String label;
  final String? value;

  const _ReviewTile({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    final displayValue = (value == null || value!.trim().isEmpty)
        ? '—'
        : value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          displayValue,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: AppFonts.primaryFont,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ReviewSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int step;
  final Function(int) onEditRequested;
  final List<Widget> children;
  final Color iconColor;
  final Color iconBgColor;
  final bool isGrid;

  const _ReviewSectionCard({
    required this.title,
    required this.icon,
    required this.step,
    required this.onEditRequested,
    required this.children,
    required this.iconColor,
    required this.iconBgColor,
    this.isGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: AppFonts.primaryFont,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => onEditRequested(step),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text(
                    "Edit",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.primaryFont,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F7)),

          // Body Content (Grid for details, Column for declarations)
          Padding(
            padding: const EdgeInsets.all(16),
            child: isGrid
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: children.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 58,
                        ),
                    itemBuilder: (context, index) => children[index],
                  )
                : Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _DeclarationCard extends StatelessWidget {
  final String label;
  final String? value;

  const _DeclarationCard({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    final bool isYes = value == 'Yes';
    final Color color = isYes ? Colors.red.shade700 : Colors.green.shade700;
    final Color bg = isYes ? Colors.red.shade50 : Colors.green.shade50;
    final String text = value ?? '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.4,
                fontFamily: AppFonts.primaryFont,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.1)),
            ),
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 0.5,
                fontFamily: AppFonts.primaryFont,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  final String fileName;

  const _AttachmentCard({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.attach_file, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade900,
                height: 1.4,
                fontFamily: AppFonts.primaryFont,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
