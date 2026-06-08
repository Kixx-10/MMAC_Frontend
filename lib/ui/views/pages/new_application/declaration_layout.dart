// lib/ui/views/pages/new_application/declaration_layout.dart
import 'package:flutter/material.dart';
import '../../../../utils/form_validators.dart';

abstract class DeclarationLayoutInterface {
  bool validate();
}

class DeclarationLayout extends StatefulWidget {
  final Map<String, dynamic> values;
  final Widget actionButtons;
  final Function(String, dynamic) onValueChanged;
  final void Function(DeclarationLayoutInterface) onReady; //  Callback

  const DeclarationLayout({
    super.key,
    required this.values,
    required this.actionButtons,
    required this.onValueChanged,
    required this.onReady, // 👈
  });

  @override
  State<DeclarationLayout> createState() => _DeclarationLayoutState();
}

class _DeclarationLayoutState extends State<DeclarationLayout> implements DeclarationLayoutInterface {
  bool _showErrors = false;
  @override
  void initState() {
    super.initState();
    widget.onReady(this); // Register
  }

 
  @override
  bool validate() {
  if (!mounted) {
    final symptomValid = FormValidators.declaration(widget.values['hasSymptoms'], 'Health Declaration') == null;
    final restrictedValid = FormValidators.declaration(widget.values['carryingRestricted'], 'Restricted Goods Declaration') == null;
    
    return symptomValid && restrictedValid;
  }
  setState(() => _showErrors = true);
  final symptomValid = FormValidators.declaration(widget.values['hasSymptoms'], 'Health Declaration') == null;
  final restrictedValid = FormValidators.declaration(widget.values['carryingRestricted'], 'Restricted Goods Declaration') == null;
  
  return symptomValid && restrictedValid;
}

  Widget _buildCheckboxOptions({
    required String? currentValue,
    required Function(String) onChanged,
    required String? errorText, 
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: currentValue == 'Yes',
                  activeColor: Colors.blue,
                  onChanged: (checked) {
                    if (checked == true) onChanged("Yes");
                  },
                ),
                const Text("Yes", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(width: 30), 
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: currentValue == 'No',
                  activeColor: Colors.blue,
                  onChanged: (checked) {
                    if (checked == true) onChanged("No");
                  },
                ),
                const Text("No", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(errorText, style: const TextStyle(color: Colors.red, fontSize: 12)), // 👈 Error စာတန်းပြခြင်း
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Alert Box
            Container(
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
                      style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 🩺 Health Section
            const Text("1. Health Declaration", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 6),
            Text(
              "Do you currently have or have you had in the past 14 days any of the following symptoms: fever, cough, sore throat, or shortness of breath?",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4),
            ),
            const SizedBox(height: 10), 
            _buildCheckboxOptions(
              currentValue: widget.values['hasSymptoms'],
              onChanged: (val) {
                widget.onValueChanged('hasSymptoms', val);
                setState(() => _showErrors = false);
              },
              errorText: _showErrors ? FormValidators.declaration(widget.values['hasSymptoms'], 'Health Declaration') : null,
            ),

            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 20),

            // 📦 Restricted Goods Section
            const Text("2. Restricted Goods Declaration", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 6),
            Text(
              "Are you carrying any prohibited or restricted items such as plants, seeds, unprocessed foods, meats, endangered animal products, or illegal drugs?",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4),
            ),
            const SizedBox(height: 10), 
            _buildCheckboxOptions(
              currentValue: widget.values['carryingRestricted'],
              onChanged: (val) {
                widget.onValueChanged('carryingRestricted', val);
                setState(() => _showErrors = false);
              },
              errorText: _showErrors ? FormValidators.declaration(widget.values['carryingRestricted'], 'Restricted Goods Declaration') : null,
            ),

            const SizedBox(height: 40),
            widget.actionButtons, 
          ],
        );
      },
    );
  }
}