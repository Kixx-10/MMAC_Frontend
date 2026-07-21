// lib/ui/views/widgets/form_progress_bar.dart
import 'package:flutter/material.dart';
import 'package:mmac/core/constants/app_fonts.dart';

class FormProgressBar extends StatelessWidget {
  final int currentStep;

  const FormProgressBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {"number": 1, "label": "Personal Information"},
      {"number": 2, "label": "Itinerary"},
      {"number": 3, "label": "Declarations"},
      {"number": 4, "label": "Review"},
      {"number": 5, "label": "Arrival Form PDF"},
    ];

    // 🎯 1. Detect screen size dynamically
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 500;

    // 🎯 2. Adjust dimensions based on the screen size
    final double circleSize = isMobile ? 32.0 : 40.0;
    final double columnWidth = isMobile ? 65.0 : 70.0;
    final double labelSize = isMobile ? 10.0 : 11.0;
    final double numberSize = isMobile ? 12.0 : 13.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            // The list elements are fed directly into the Row's children
            children: List.generate(steps.length, (index) {
              final stepNumber =
                  (steps[index]["number"] as int?) ?? (index + 1);
              final label = (steps[index]["label"] as String?) ?? "";
              final isCompleted = stepNumber < currentStep;
              final isActive = stepNumber == currentStep;

              // 🎯 3. Build the core package (Circle + Text Label)
              Widget stepContent = SizedBox(
                width: columnWidth,
                child: Column(
                  children: [
                    Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted || isActive
                            ? Colors.blue
                            : Colors.grey.shade200,
                        border: Border.all(
                          color: isCompleted || isActive
                              ? Colors.blue
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: isMobile ? 14 : 16,
                              )
                            : Text(
                                "$stepNumber",
                                style: TextStyle(
                                  fontSize: numberSize,
                                  fontWeight: FontWeight.bold,
                                  color: isActive ? Colors.white : Colors.grey,
                                  fontFamily: AppFonts.primaryFont,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: labelSize,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isActive ? Colors.blue : Colors.grey,
                        fontFamily: AppFonts.primaryFont,
                      ),
                    ),
                  ],
                ),
              );

              // 🎯 4. Last Step Logic: The final step has no line attached to it!
              if (index == steps.length - 1) {
                return stepContent;
              }

              // 🎯 5. The "Flex Spring" Magic for all other steps
              return Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    stepContent,

                    // The flexible connecting line
                    Expanded(
                      child: Container(
                        height: 1.5,
                        // Pushes the line down perfectly to the center of the dynamic circle
                        margin: EdgeInsets.only(top: circleSize / 2),
                        color: isCompleted ? Colors.blue : Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
