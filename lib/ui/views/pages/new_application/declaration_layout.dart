// lib/ui/views/pages/new_application/declaration_layout.dart

import 'package:flutter/material.dart';
import '../../../../utils/form_validators.dart';

abstract class DeclarationLayoutInterface {
  bool validate();
  List<String> getValidationErrors();
}

class DeclarationLayout extends StatefulWidget {
  final Map<String, dynamic> values;
  final Widget actionButtons;
  final Function(String, dynamic) onValueChanged;
  final void Function(DeclarationLayoutInterface) onReady;

  const DeclarationLayout({
    super.key,
    required this.values,
    required this.actionButtons,
    required this.onValueChanged,
    required this.onReady,
  });

  @override
  State<DeclarationLayout> createState() => _DeclarationLayoutState();
}

class _DeclarationLayoutState extends State<DeclarationLayout>
    implements DeclarationLayoutInterface {
  // STATE & LIFECYCLE
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    widget.onReady(this);
  }

  // VALIDATION
  @override
  bool validate() {
    final bool symptomValid =
        FormValidators.declaration(
          widget.values['hasSymptoms'],
          'Health Declaration',
        ) ==
        null;

    final bool restrictedValid =
        FormValidators.declaration(
          widget.values['carryingRestricted'],
          'Restricted Goods Declaration',
        ) ==
        null;

    final bool isValid = symptomValid && restrictedValid;

    if (!isValid && mounted) {
      setState(() => _showErrors = true);
    }

    return isValid;
  }

  @override
  List<String> getValidationErrors() {
    List<String> errors = [];
    if (widget.values['hasSymptoms'] == null) {
      errors.add("Health Declaration is missing.");
    }
    if (widget.values['carryingRestricted'] == null) {
      errors.add("Restricted Goods Declaration is missing.");
    }
    return errors;
  }

  // ---------------------------------------------------------------------------
  // MAIN BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _WarningBanner(),
        const SizedBox(height: 30),

        // 🩺 Health Section
        _DeclarationQuestion(
          title: "1. Health Declaration",
          description:
              "Do you currently have or have you had in the past 14 days any of the following symptoms: fever, cough, sore throat, or shortness of breath?",
          currentValue: widget.values['hasSymptoms'],
          errorText: _showErrors
              ? FormValidators.declaration(
                  widget.values['hasSymptoms'],
                  'Health Declaration',
                )
              : null,
          onChanged: (val) {
            widget.onValueChanged('hasSymptoms', val);
            if (mounted) setState(() => _showErrors = false);
          },
        ),

        const SizedBox(height: 20),
        Divider(color: Colors.grey.shade200),
        const SizedBox(height: 20),

        // 📦 Restricted Goods Section
        _DeclarationQuestion(
          title: "2. Restricted Goods Declaration",
          description:
              "Are you carrying any prohibited or restricted items such as plants, seeds, unprocessed foods, meats, endangered animal products, or illegal drugs?",
          currentValue: widget.values['carryingRestricted'],
          errorText: _showErrors
              ? FormValidators.declaration(
                  widget.values['carryingRestricted'],
                  'Restricted Goods Declaration',
                )
              : null,
          onChanged: (val) {
            widget.onValueChanged('carryingRestricted', val);
            if (mounted) setState(() => _showErrors = false);
          },
        ),

        const SizedBox(height: 40),
        widget.actionButtons,
      ],
    );
  }
}

// PRIVATE SUB-WIDGETS (Extracted for Clean Code)
class _WarningBanner extends StatelessWidget {
  const _WarningBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Please answer truthfully. False declarations may lead to penalties or entry refusal.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeclarationQuestion extends StatelessWidget {
  final String title;
  final String description;
  final String? currentValue;
  final String? errorText;
  final Function(String) onChanged;

  const _DeclarationQuestion({
    required this.title,
    required this.description,
    required this.currentValue,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade800,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildCheckboxItem("Yes"),
            const SizedBox(width: 30),
            _buildCheckboxItem("No"),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildCheckboxItem(String targetValue) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: currentValue == targetValue,
          activeColor: Colors.blue,
          onChanged: (checked) {
            if (checked == true) onChanged(targetValue);
          },
        ),
        Text(
          targetValue,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
