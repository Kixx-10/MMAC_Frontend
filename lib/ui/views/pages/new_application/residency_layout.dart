import 'package:flutter/material.dart';
import 'package:mmac/ui/views/widgets/footer.dart';

class ResidencyLayout extends StatelessWidget {
  final Function(String) onResidencySelected;

  const ResidencyLayout({super.key, required this.onResidencySelected});

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Residency Type",
          style: TextStyle(
            fontSize: isMobile ? 18 : 26,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Please select your appropriate residency status to continue the application.",
          style: const TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
        ),
      ],
    );
  }

  Widget _buildSelectionGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktopCard = constraints.maxWidth > 650;

        // 🎯 DRY Principle: Define cards once, use dynamically
        final Widget myanmarCard = ResidencySelectorCard(
          title: "Myanmar Citizen /\nPermanent Resident",
          imagePath: "assets/images/nrc.jpg",
          onTap: () => onResidencySelected('Myanmar'),
        );

        final Widget foreignerCard = ResidencySelectorCard(
          title: "Foreigner \nPass Holder",
          imagePath: "assets/images/passport.jpg",
          onTap: () => onResidencySelected('Foreigner'),
        );

        if (isDesktopCard) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [myanmarCard, const SizedBox(width: 32), foreignerCard],
          );
        } else {
          return Column(
            children: [myanmarCard, const SizedBox(height: 20), foreignerCard],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenSize = MediaQuery.of(context).size.width;
    final isMobile = screenSize < 500;

    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              if (!isMobile) const SizedBox(height: 40),

              //  --- MAIN SELECTION BOX ---
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
                    _buildHeader(isMobile),
                    SizedBox(height: isMobile ? 18 : 32),
                    _buildSelectionGrid(context),
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

  void _setHovered(bool hovered) => setState(() => _isHovered = hovered);
  void _setActive(bool active) => setState(() => _isActive = active);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
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
            // 🎯 Fixed: Replaced deprecated withAlpha with modern withOpacity
            color: _isActive
                ? Colors.black.withOpacity(0.04)
                : (_isHovered
                      ? Colors.black.withOpacity(0.10)
                      : Colors.black.withOpacity(0.06)),
            blurRadius: _isHovered ? 24 : 16,
            offset: _isHovered ? const Offset(0, 10) : const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: widget.onTap,
          onHover: _setHovered,
          onTapDown: (_) => _setActive(true),
          onTapUp: (_) => _setActive(false),
          onTapCancel: () => _setActive(false),
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
