// ignore_for_file: use_null_aware_elements

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mmac/core/constants/app_fonts.dart';

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
  final bool readonly;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.labelWidth = 140,
    this.validator,
    this.maxLength,
    this.readonly = false,
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
    // Define the Label once
    final Widget labelWidget = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: AppFonts.primaryFont,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.primaryFont,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    // Define the exact Input Box once
    final Widget inputWidget = TextFormField(
      readOnly: readonly,
      controller: controller,
      keyboardType: keyboardtype,
      validator: validator,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'^ ')),
        FilteringTextInputFormatter.deny(RegExp(r' {2,}')),
        if (filter != null) ...filter!,
      ],
      maxLength: maxLength,
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        color: readonly ? Colors.grey.shade500 : Colors.black87,
        fontFamily: AppFonts.primaryFont,
      ),
      decoration: InputDecoration(
        counterText: "",
        filled: true,
        fillColor: readonly ? Colors.grey.shade200 : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          color: Colors.red,
          fontFamily: AppFonts.primaryFont,
        ),
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.grey.shade400,
          fontFamily: AppFonts.primaryFont,
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
    );

    //  3. The Responsive Switcher
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [labelWidget, inputWidget],
    );
  }
}
