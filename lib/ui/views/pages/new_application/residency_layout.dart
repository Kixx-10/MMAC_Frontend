// lib/ui/views/pages/new_application/residency_layout.dart

import 'package:flutter/material.dart';
import 'package:mmac/core/constants/app_fonts.dart';
import 'package:mmac/ui/views/widgets/footer.dart';

class ResidencyLayout extends StatelessWidget {
  final Function(String) onResidencySelected;

  const ResidencyLayout({super.key, required this.onResidencySelected});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile =
        screenWidth < 800; // Switch to column earlier for large cards

    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              if (!isMobile) const SizedBox(height: 40),

              // MAIN CONTAINER
              Container(
                constraints: const BoxConstraints(maxWidth: 1100),
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
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 24.0 : 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Text(
                        "Select Residency Type",
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 30,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.primaryFont,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Text(
                          "Choose the status that matches your situation. This determines which documents you will need to provide in the next steps.",
                          style: TextStyle(
                            fontSize: isMobile ? 15 : 16,
                            color: Colors.grey.shade600,
                            fontFamily: AppFonts.primaryFont,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Responsive Cards Section
                      isMobile
                          ? Column(
                              children: [
                                _buildMyanmarCard(),
                                const SizedBox(height: 24),
                                _buildForeignerCard(),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildMyanmarCard()),
                                const SizedBox(width: 24),
                                Expanded(child: _buildForeignerCard()),
                              ],
                            ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
              const FormFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyanmarCard() {
    return _DetailedResidencyCard(
      img:
          "assets/images/residency_img1.jpg", // Using your original working asset
      icon: Icons.badge_outlined,
      subtitle: "CITIZEN / PERMANENT RESIDENT",
      header: "Myanmar Citizen",
      para:
          "For applicants holding a National Registration Card (NRC) or Permanent Residency in Myanmar.",
      iconColor: Colors.brown.shade600,
      requiredTextData:
          "Returning citizens and permanent residents must accurately declare their National Registration Card (NRC) or identity details. Travelers are required to provide their exact local residential address and an active contact number to facilitate secure border clearance and health protocols upon arrival.",
      onTap: () => onResidencySelected('Myanmar'),
    );
  }

  Widget _buildForeignerCard() {
    return _DetailedResidencyCard(
      img:
          "assets/images/residency_img2.jpg", // Using your original working asset
      icon: Icons.language_outlined,
      subtitle: "PASS / PERMIT HOLDER",
      header: "Foreigner",
      para:
          "For foreign nationals applying with a valid passport and an entry or stay permit.",
      iconColor: Colors.brown.shade700,
      requiredTextData:
          "Foreign nationals must hold a valid passport with a minimum of six (6) months validity remaining. In accordance with Myanmar immigration laws, travelers must possess a valid visa or entry permit and provide the exact address of their registered hotel, guest house, or legal accommodation during their stay in the Republic of the Union of Myanmar.",
      onTap: () => onResidencySelected('Foreigner'),
    );
  }
}

// ---------------------------------------------------------------------------
// NEW ANIMATED HOVER CARD
// ---------------------------------------------------------------------------

class _DetailedResidencyCard extends StatefulWidget {
  final String img;
  final IconData icon;
  final String subtitle;
  final String header;
  final String para;
  final Color iconColor;
  // final List<String> requiredData;
  final String requiredTextData;
  final VoidCallback onTap;

  const _DetailedResidencyCard({
    required this.img,
    required this.icon,
    required this.subtitle,
    required this.header,
    required this.para,
    required this.iconColor,
    required this.requiredTextData,
    required this.onTap,
  });

  @override
  State<_DetailedResidencyCard> createState() => _DetailedResidencyCardState();
}

class _DetailedResidencyCardState extends State<_DetailedResidencyCard> {
  bool _isHovered = false;
  bool _isActive = false;

  void _setHovered(bool hovered) => setState(() => _isHovered = hovered);
  void _setActive(bool active) => setState(() => _isActive = active);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()..translate(0.0, _isHovered ? -6.0 : 0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isHovered ? Colors.blue.shade300 : Colors.grey.shade200,
          width: _isHovered ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _isActive
                ? Colors.black.withOpacity(0.04)
                : (_isHovered
                      ? Colors.black.withOpacity(0.12)
                      : Colors.black.withOpacity(0.04)),
            blurRadius: _isHovered ? 24 : 10,
            offset: _isHovered ? const Offset(0, 12) : const Offset(0, 4),
          ),
        ],
      ),
      // ClipRRect ensures the image doesn't overflow the rounded borders
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: widget.onTap,
          onHover: _setHovered,
          onTapDown: (_) => _setActive(true),
          onTapUp: (_) => _setActive(false),
          onTapCancel: () => _setActive(false),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(widget.img),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle & Icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: widget.iconColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.icon,
                            size: 16,
                            color: widget.iconColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.iconColor,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppFonts.primaryFont,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Main Header
                    Text(
                      widget.header,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        fontFamily: AppFonts.primaryFont,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Paragraph
                    Text(
                      widget.para,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontFamily: AppFonts.primaryFont,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // Required Data Title
                    Row(
                      children: [
                        Icon(
                          Icons.edit_document,
                          color: Colors.grey.shade500,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "REQUIRED DATA",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 🎯 Wrap is used here so the chips drop to the next line on narrow mobile screens!
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Text(
                          widget.requiredTextData,
                          style: const TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            fontSize: 16,
                          ),
                        ),
                      ],
                      // children: widget.requiredData
                      //     .map((data) => _buildDataChip(data))
                      //     .toList(),
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

  // Widget _buildDataChip(String text) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: Colors.blue.shade50,
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(color: Colors.blue.shade100, width: 1),
  //     ),
  //     child: Text(
  //       text,
  //       style: TextStyle(
  //         fontSize: 13,
  //         color: Colors.blue.shade700,
  //         fontWeight: FontWeight.w600,
  //       ),
  //     ),
  //   );
  // }
}
