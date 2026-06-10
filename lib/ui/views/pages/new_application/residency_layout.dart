// lib/ui/views/pages/new_application/residency_layout.dart

import 'package:flutter/material.dart';
import 'package:mmac/ui/views/widgets/footer.dart';

class ResidencyLayout extends StatelessWidget {
  final Function(String) onResidencySelected;

  const ResidencyLayout({super.key, required this.onResidencySelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // 📦 --- MAIN SELECTION BOX ---
              Container(
                width: 950,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Residency Type",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Please select your appropriate residency status to continue the application.",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool isDesktopCard = constraints.maxWidth > 650;

                        if (isDesktopCard) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ResidencySelectorCard(
                                title: "Myanmar Citizen /\nPermanent Resident",
                                imagePath: "assets/images/nrc.jpg",
                                onTap: () => onResidencySelected(
                                  'Myanmar',
                                ), // 👈 Callback သုံး၍ သက်ဆိုင်ရာ data လှမ်းပို့ပါသည်
                              ),
                              const SizedBox(width: 32),
                              ResidencySelectorCard(
                                title: "Foreigner \nPass Holder",
                                imagePath: "assets/images/passport.jpg",
                                onTap: () => onResidencySelected('Foreigner'),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              ResidencySelectorCard(
                                title: "Myanmar Citizen /\nPermanent Resident",
                                imagePath: "assets/images/nrc.jpg",
                                onTap: () => onResidencySelected('Myanmar'),
                              ),
                              const SizedBox(height: 20),
                              ResidencySelectorCard(
                                title: "Foreigner \nPass Holder",
                                imagePath: "assets/images/passport.jpg",
                                onTap: () => onResidencySelected('Foreigner'),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Footer
              const FormFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class ResidencySelectorCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const ResidencySelectorCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<ResidencySelectorCard> createState() => _ResidencySelectorCardState();
}

class _ResidencySelectorCardState extends State<ResidencySelectorCard> {
  bool _isHovered = false;
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      // ignore: deprecated_member_use
      transform: Matrix4.identity()..translate(0, _isHovered ? -4 : 0),
      constraints: const BoxConstraints(maxWidth: 290),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isHovered ? const Color(0xFF0F2942) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _isActive
                ? Colors.black.withAlpha(10)
                : (_isHovered
                      ? Colors.black.withAlpha(25)
                      : Colors.black.withAlpha(15)),
            blurRadius: _isHovered ? 24 : 16,
            offset: _isHovered ? const Offset(0, 10) : const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: widget.onTap,
          onHover: (hovered) => setState(() => _isHovered = hovered),
          onTapDown: (_) => setState(() => _isActive = true),
          onTapUp: (_) => setState(() => _isActive = false),
          onTapCancel: () => setState(() => _isActive = false),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 190,
                color: _isHovered
                    ? const Color(0xFF0A1424)
                    : const Color(0xFF0F1E36),
                padding: const EdgeInsets.all(20),
                child: Image.asset(widget.imagePath, fit: BoxFit.contain),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F2942),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
