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
                  'Please double-check all fields below. You can update any step before final submission by using the Back button.',
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

  List<Widget> _buildLeftColumn() {
    return [
      _ReviewTile(
        label: 'Full Name',
        value: widget.controllers['fullName']?.text,
      ),
      _ReviewTile(label: 'Nationality', value: widget.values['country']),
      _ReviewTile(label: 'Gender', value: widget.values['gender']),
      _ReviewTile(
        label: 'Date of Birth',
        value: _formatDate(widget.values['dateOfBirth']),
      ),
      _ReviewTile(
        label: 'Place of Birth',
        value: widget.values['placeOfBirth'],
      ),
      _ReviewTile(label: 'Email', value: widget.controllers['email']?.text),
      _ReviewTile(
        label: 'Mobile Number',
        value: widget.controllers['mobile']?.text,
      ),
      if (!_isMyanmar)
        _ReviewTile(
          label: 'Visa Number',
          value: widget.controllers['visaNumber']?.text,
        ),
      if (_isMyanmar)
        _ReviewTile(label: 'NRC', value: widget.controllers['nrc']?.text),
      if (_isMyanmar)
        _ReviewTile(
          label: 'Father Name',
          value: widget.controllers['fatherName']?.text,
        ),
      _ReviewTile(
        label: 'Place of Residence',
        value: widget.values['placeOfResidence'],
      ),
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
          label: 'Accommodation Type',
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
    ];
  }

  List<Widget> _buildRightColumn() {
    return [
      _ReviewTile(
        label: 'Passport No.',
        value: widget.controllers['passportNumber']?.text,
      ),
      _ReviewTile(
        label: 'Passport Issued Date',
        value: _formatDate(widget.values['issuedDate']),
      ),
      _ReviewTile(
        label: 'Date of Expiry',
        value: _formatDate(widget.values['expiryDate']),
      ),
      _ReviewTile(
        label: 'Passport Issuing Country/Region',
        value: widget.values['issuedCountry'],
      ),
      const SizedBox(height: 16),
      _ReviewTile(
        label: 'Fever in past 14 days?',
        value: widget.values['hasSymptoms'] == 'Yes'
            ? 'YES'
            : (widget.values['hasSymptoms'] == 'No' ? 'NO' : '—'),
      ),
      _ReviewTile(
        label: 'Prohibited items?',
        value: widget.values['carryingRestricted'] == 'Yes'
            ? 'YES'
            : (widget.values['carryingRestricted'] == 'No' ? 'NO' : '—'),
      ),
      if (widget.values['hasSymptoms'] == 'Yes' &&
          widget.values['healthRecordFileName'] != null)
        _ReviewTile(
          label: 'Health Record',
          value: widget.values['healthRecordFileName'],
          isAttachment: true,
        ),
      if (widget.values['carryingRestricted'] == 'Yes' &&
          widget.values['goodsRecordFileName'] != null)
        _ReviewTile(
          label: 'Goods Record',
          value: widget.values['goodsRecordFileName'],
          isAttachment: true,
        ),
    ];
  }

  // MAIN BUILD METHOD
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWarningBanner(),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Confirmation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: AppFonts.primaryFont,
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F7)),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isDesktop = constraints.maxWidth > 600;
                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildLeftColumn(),
                            ),
                          ),
                          const SizedBox(width: 40),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildRightColumn(),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._buildLeftColumn(),
                          const SizedBox(height: 16),
                          ..._buildRightColumn(),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        widget.actionButtons,
      ],
    );
  }
}

// PRIVATE SUB-WIDGETS
class _ReviewTile extends StatelessWidget {
  final String label;
  final String? value;
  final bool isAttachment;

  const _ReviewTile({
    required this.label,
    this.value,
    this.isAttachment = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = (value == null || value!.trim().isEmpty)
        ? '—'
        : value!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: AppFonts.primaryFont,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAttachment) ...[
                  Icon(
                    Icons.attach_file,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    displayValue,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: isAttachment
                          ? Colors.blue.shade700
                          : Colors.black87,
                      fontFamily: AppFonts.primaryFont,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
