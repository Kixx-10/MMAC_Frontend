import 'package:flutter/material.dart';

class NrcSelectorField extends StatelessWidget {
  final bool isDesktop;
  final Widget stateDropdown;
  final Widget townshipDropdown;
  final Widget typeDropdown;
  final Widget numberField;

  const NrcSelectorField({
    super.key,
    required this.isDesktop,
    required this.stateDropdown,
    required this.townshipDropdown,
    required this.typeDropdown,
    required this.numberField,
  });

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Row(
        children: [
          Expanded(flex: 25, child: stateDropdown),
          Expanded(flex: 38, child: townshipDropdown),
          Expanded(flex: 29, child: typeDropdown),
          Expanded(flex: 40, child: numberField),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: stateDropdown),
              const SizedBox(width: 6),
              Expanded(child: townshipDropdown),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: typeDropdown),
              const SizedBox(width: 6),
              Expanded(child: numberField),
            ],
          ),
        ],
      );
    }
  }
}