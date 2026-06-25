// lib/ui/views/pages/new_application/residency_layout.dart

import 'package:flutter/material.dart';
import 'package:mmac/ui/views/widgets/footer.dart';

class ResidencyLayout extends StatelessWidget {
  final Function(String) onResidencySelected;

  const ResidencyLayout({super.key, required this.onResidencySelected});

  @override
  Widget build(BuildContext context) {
    final double screenSize = MediaQuery.of(context).size.width;
    final isMobile = screenSize < 650;

    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: isMobile ? 40 : 80),

              //  --- OFFICIAL DASHBOARD BOX ---
              Container(
                width: 850, // 🎯 Perfectly balanced width for a 2-column grid
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.circular(
                    4,
                  ), // 🎯 Very sharp, document-like corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 🎯 Header Section
                    Padding(
                      padding: EdgeInsets.all(isMobile ? 24 : 40),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Centered for authority
                        children: [
                          // Icon(
                          //   Icons
                          //       .gavel_rounded, // Official legal/government icon
                          //   color: Colors.lightBlue.shade700,
                          //   size: 36,
                          // ),
                          // const SizedBox(height: 16),
                          const Text(
                            "Declaration of Residency",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Please identify your official residency status. Providing incorrect information may result in processing delays.",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87.withOpacity(0.7),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: isMobile ? 32 : 48),

                          // 🎯 Side-by-Side Grid Layout
                          if (isMobile)
                            Column(
                              children: [
                                OfficialGridCard(
                                  title: "Myanmar Citizen",
                                  subtitle:
                                      "National Registration Card (NRC) or Permanent Resident.",
                                  icon: Icons.badge_outlined,
                                  onTap: () => onResidencySelected('Myanmar'),
                                ),
                                const SizedBox(height: 16),
                                OfficialGridCard(
                                  title: "Foreign National",
                                  subtitle:
                                      "International visitor holding a valid passport and visa.",
                                  icon: Icons.public,
                                  onTap: () => onResidencySelected('Foreigner'),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: OfficialGridCard(
                                    title: "Myanmar Citizen",
                                    subtitle:
                                        "National Registration Card (NRC) or Permanent Resident.",
                                    icon: Icons.badge_outlined,
                                    onTap: () => onResidencySelected('Myanmar'),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: OfficialGridCard(
                                    title: "Foreign National",
                                    subtitle:
                                        "International visitor holding a valid passport and visa.",
                                    icon: Icons.public,
                                    onTap: () =>
                                        onResidencySelected('Foreigner'),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Footer
              const FormFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class OfficialGridCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const OfficialGridCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  State<OfficialGridCard> createState() => _OfficialGridCardState();
}

class _OfficialGridCardState extends State<OfficialGridCard> {
  bool _isHovered = false;
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isActive = true),
        onTapUp: (_) {
          setState(() => _isActive = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isActive = false),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _isActive
                ? Colors.lightBlue.shade700.withOpacity(0.05)
                : (_isHovered
                      ? Colors.lightBlue.shade700.withOpacity(0.02)
                      : Colors.white),
            borderRadius: BorderRadius.circular(4), // 🎯 Sharp corners
            border: Border.all(
              color: _isHovered
                  ? Colors.lightBlue.shade700
                  : Colors.grey.shade300,
              width: _isHovered ? 2.0 : 1.0, // 🎯 Thicker border on hover
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Left aligned text inside the card
            children: [
              // 🎯 Top Icon
              Icon(
                widget.icon,
                size: 40,
                color: _isHovered
                    ? Colors.lightBlue.shade700
                    : Colors.black87.withOpacity(0.7),
              ),
              const SizedBox(height: 24),

              // 🎯 Title
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // 🎯 Subtitle
              Text(
                widget.subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87.withOpacity(0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // 🎯 Action Arrow / "Select" Indicator
              Row(
                children: [
                  Text(
                    "Select Status",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _isHovered
                          ? Colors.lightBlue.shade700
                          : Colors.black87.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: _isHovered
                        ? Colors.lightBlue.shade700
                        : Colors.black87.withOpacity(0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
