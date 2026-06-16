import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final double labelWidth;
  final String? Function(String?)? validator;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final bool isRequired;
  final String? hintText;
  final double spacing;
  final Widget? suffixIcon;
  final TextInputType? keyboardtype;
  final List<TextInputFormatter>? filter;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.labelWidth = 140,
    this.validator,
    this.maxLength,
    this.onChanged,
    this.isRequired = true,
    this.hintText,
    this.spacing = 8,
    this.suffixIcon,
    this.keyboardtype,
    this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: SizedBox(
            width: labelWidth,
            child: RichText(
              text: TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  fontFamily: 'sans-serif',
                ),
                children: [
                  if (isRequired)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardtype,
            validator: validator,
            inputFormatters: filter,
            maxLength: maxLength,
            onChanged: onChanged,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              errorStyle: const TextStyle(fontSize: 12, color: Colors.red),

              suffixIcon: suffixIcon,
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade400,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
