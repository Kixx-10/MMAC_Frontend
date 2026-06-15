// lib/ui/views/widgets/form_progress_bar.dart
import 'package:flutter/material.dart';

class FormProgressBar extends StatelessWidget {
  final int currentStep;

  const FormProgressBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {"number": 1, "label": "Personal Informations"},
      {"number": 2, "label": "Itinerary"},
      {"number": 3, "label": "Declarations"},
      {"number": 4, "label": "Review"},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length, (index) {
          final stepNumber = (steps[index]["number"] as int?) ?? (index + 1);
          final label = (steps[index]["label"] as String?) ?? "";
          final isCompleted = stepNumber < currentStep;
          final isActive = stepNumber == currentStep;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circle + Label
              SizedBox(
                width: 70, // ← circle column width fixed
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? Colors.blue
                            : isActive
                            ? Colors.blue
                            : Colors.grey.shade200,
                        border: Border.all(
                          color: isActive || isCompleted
                              ? Colors.blue
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : Text(
                                "$stepNumber",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isActive ? Colors.white : Colors.grey,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isActive ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Line between steps (narrow & centered vertically with circle)
              if (index < steps.length - 1)
                Container(
                  width: 60,
                  height: 1.5,
                  margin: const EdgeInsets.only(top: 10),
                  color: isCompleted ? Colors.blue : Colors.grey.shade300,
                ),
            ],
          );
        }),
      ),
    );
  }
}
