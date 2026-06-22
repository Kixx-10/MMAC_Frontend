// lib/ui/views/pages/new_application/review_layout.dart

import 'package:flutter/material.dart';

class ReviewLayout extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, dynamic> values;
  final Widget actionButtons;
  final Function(int targetStep) onEditRequested;
  final bool isUpdateMode;

  const ReviewLayout({
    super.key,
    required this.controllers,
    required this.values,
    required this.actionButtons,
    required this.onEditRequested,
    required this.isUpdateMode,
  });

  String _formatDate(dynamic date) {
    if (date == null) return '—';
    if (date is DateTime) {
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }
    return date.toString();
  }

  // ── Modern Information Grid Block
  Widget _reviewTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? '—' : value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ── Premium Card Section Header
  Widget _sectionBlock({
    required String title,
    required IconData icon,
    required int step,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
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
          // Header Row inside Card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.blue.shade700, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F7)),
          // Grid content
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: children.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 46, // Fix height overflow
              ),
              itemBuilder: (context, index) => children[index],
            ),
          ),
        ],
      ),
    );
  }

  // ── Modern Declaration Block
  Widget _declarationCard(String label, String? value) {
    final bool isYes = value == 'Yes';
    final color = isYes ? Colors.red.shade700 : Colors.green.shade700;
    final bg = isYes ? Colors.red.shade50 : Colors.green.shade50;
    final text = value ?? '—';

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
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              // ignore: deprecated_member_use
              border: Border.all(color: color.withOpacity(0.1)),
            ),
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMyanmar =
        values['country'] == 'Myanmar' || values['country'] == 'MMR';

    // 🎯 Dynamically generate Trip Details widgets list to avoid empty slots or broken UI grids
    final List<Widget> tripDetailsTiles = [
      _reviewTile('Arrival Date', _formatDate(values['arrivalDate'])),
      _reviewTile('Mode of Travel', values['modeOfTravel'] ?? ''),
      _reviewTile('Port of Arrival', values['portOfArrival'] ?? ''),
      _reviewTile('Vehicle Number', controllers['vehicleNumber']?.text ?? ''),
      _reviewTile('Vehicle Name', controllers['vehicleName']?.text ?? ''),
      if (!isMyanmar)
        _reviewTile('Accommodation', values['accommodation'] ?? '—'),
      _reviewTile(
        'Address in Myanmar',
        controllers['addressInMyanmar']?.text ?? '',
      ),
      _reviewTile('State/Region', values['stateRegion'] ?? ''),
      _reviewTile('District', values['district'] ?? ''),
      _reviewTile('Township', values['township'] ?? ''),
      if (isMyanmar)
        _reviewTile('Mobile (MM)', controllers['mobileNumberMM']?.text ?? ''),
      _reviewTile('Purpose of Visit', values['purposeOfVisit'] ?? ''),
      _reviewTile('Previous City', controllers['previousCity']?.text ?? ''),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Premium Warning Alert Banner
        Container(
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
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Please double-check all fields below. You can update any step before final submission.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF335577),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ══ STEP 1: Personal Information
        _sectionBlock(
          title: 'Personal Information',
          icon: Icons.person_outline_rounded,
          step: 1,
          children: [
            _reviewTile('Full Name', controllers['fullName']?.text ?? ''),
            _reviewTile('Gender', values['gender'] ?? ''),
            _reviewTile('Date of Birth', _formatDate(values['dateOfBirth'])),
            _reviewTile('Country', values['country'] ?? ''),
            _reviewTile('Email', controllers['email']?.text ?? ''),
            _reviewTile('Mobile Number', controllers['mobile']?.text ?? ''),
            if (values['country'] != 'Myanmar') ...[
              _reviewTile('Visa Number', controllers['visaNumber']?.text ?? ''),
            ],
            if (values['country'] == 'Myanmar') ...[
              _reviewTile('NRC', controllers['nrc']?.text ?? ''),
              _reviewTile('Father Name', controllers['fatherName']?.text ?? ''),
            ],
            _reviewTile(
              'Passport Number',
              controllers['passportNumber']?.text ?? '',
            ),
            _reviewTile('Issued Date', _formatDate(values['issuedDate'])),
            _reviewTile('Expiry Date', _formatDate(values['expiryDate'])),
            _reviewTile('Issued Country', values['issuedCountry'] ?? ''),
            _reviewTile('Address', controllers['address']?.text ?? ''),
          ],
        ),

        // ══ STEP 2: Trip Details ═════════════════════════════════════════════
        _sectionBlock(
          title: 'Trip Details',
          icon: Icons.local_airport_outlined,
          step: 2,
          children:
              tripDetailsTiles, // 🎯 Clean list without conditional index bugs
        ),

        // ══ STEP 3: Health & Declarations ════════════════════════════════════
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.health_and_safety_outlined,
                        color: Colors.green.shade700,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Health & Declarations',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => onEditRequested(3),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F7)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _declarationCard(
                      'Fever, cough, sore throat or shortness of breath in past 14 days?',
                      values['hasSymptoms'],
                    ),
                    _declarationCard(
                      'Carrying prohibited or restricted items?',
                      values['carryingRestricted'],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        actionButtons,
      ],
    );
  }
}
