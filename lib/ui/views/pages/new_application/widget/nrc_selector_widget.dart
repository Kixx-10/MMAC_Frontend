import 'package:flutter/material.dart';

class NrcSelectorWidget extends StatelessWidget {
  final bool isDesktop;
  final String? selectedNrcStateCode;
  final String? selectedTownshipCode;
  final String? selectedNrcType;
  final Widget numberField;
  final bool hasError;
  final Function(int stateId, String stateIdCode) onStateChanged;
  final Function(String townshipIdCode) onTownshipChanged;
  final Function(String typeCode) onTypeChanged;
  final List<dynamic> stateList;
  final List<dynamic> townshipList;
  final List<Map<String, String>> nrcTypes;
  final int? activeStateId;

  // 🎯 1. Added the readOnly flag
  final bool readOnly;

  const NrcSelectorWidget({
    super.key,
    required this.isDesktop,
    required this.selectedNrcStateCode,
    required this.selectedTownshipCode,
    required this.selectedNrcType,
    required this.numberField,
    required this.hasError,
    required this.onStateChanged,
    required this.onTownshipChanged,
    required this.onTypeChanged,
    required this.stateList,
    required this.townshipList,
    required this.nrcTypes,
    required this.activeStateId,
    this.readOnly =
        false, // Defaults to false so it doesn't break existing screens!
  });

  // 🎯 2. Fade the vertical dividers if disabled
  Widget _divider({Color? color}) => Container(
    width: 1,
    height: 24,
    color: color ?? (readOnly ? Colors.grey.shade200 : Colors.grey.shade300),
  );

  Widget _dropdown<T>({
    required T? value,
    required double? width,
    required Widget hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final dropdownBody = DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,

        alignment: Alignment.center,
        isExpanded: true,
        isDense: true,
        dropdownColor: Colors.white,
        // 🎯 3. Fade the arrow icon
        icon: Icon(
          Icons.arrow_drop_down,
          size: 18,
          color: readOnly ? Colors.grey.shade400 : Colors.black54,
        ),
        // 🎯 4. Fade the selected text
        style: TextStyle(
          fontSize: 13,
          color: readOnly ? Colors.grey.shade500 : Colors.black87,
          fontWeight: readOnly ? FontWeight.normal : FontWeight.w500,
        ),
        hint: hint,
        items: items,
        // 🎯 5. Physically disable the dropdown from opening if readOnly is true
        onChanged: readOnly ? null : onChanged,
        menuMaxHeight: 300,
      ),
    );

    if (width == 0) {
      return Expanded(child: dropdownBody);
    }
    return SizedBox(width: width, child: dropdownBody);
  }

  @override
  Widget build(BuildContext context) {
    final String? activeTownship =
        townshipList.any((ts) => ts.idCode == selectedTownshipCode)
        ? selectedTownshipCode
        : null;

    final String? activeType = nrcTypes.any((t) => t['code'] == selectedNrcType)
        ? selectedNrcType
        : null;

    final unifiedNrcRow = Row(
      children: [
        const SizedBox(width: 6),
        _dropdown<int>(
          value: activeStateId,
          width: 50,
          hint: Text('၁၂/', style: TextStyle(color: Colors.grey.shade400)),
          items: stateList.map<DropdownMenuItem<int>>((st) {
            return DropdownMenuItem(
              value: st.id,
              alignment: Alignment.center,
              child: Text(st.codeMM),
            );
          }).toList(),
          onChanged: (id) {
            if (id != null) {
              final match = stateList.firstWhere((s) => s.id == id);
              onStateChanged(id, match.idCode);
            }
          },
        ),
        // 🎯 6. Ignore the red error state if the field is disabled
        _divider(
          color: readOnly
              ? Colors.grey.shade200
              : (hasError ? Colors.red.shade300 : null),
        ),

        const SizedBox(width: 4),
        _dropdown<String>(
          value: activeTownship,
          width: 0,
          hint: Text('မြို့နယ်', style: TextStyle(color: Colors.grey.shade400)),
          items: townshipList.map<DropdownMenuItem<String>>((t) {
            return DropdownMenuItem(
              value: t.idCode,
              alignment: Alignment.center,
              child: Text(t.codeMM, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onTownshipChanged(v);
          },
        ),
        _divider(
          color: readOnly
              ? Colors.grey.shade200
              : (hasError ? Colors.red.shade300 : null),
        ),

        const SizedBox(width: 6),
        _dropdown<String>(
          value: activeType,
          width: 50,
          hint: Text('နိုင်', style: TextStyle(color: Colors.grey.shade400)),
          items: nrcTypes.map<DropdownMenuItem<String>>((t) {
            return DropdownMenuItem(
              value: t['code'],
              alignment: Alignment.center,
              child: Text(t['label']!),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onTypeChanged(v);
          },
        ),
        _divider(
          color: readOnly
              ? Colors.grey.shade200
              : (hasError ? Colors.red.shade300 : null),
        ),

        Expanded(flex: 1, child: numberField),
      ],
    );

    return Container(
      height: 44,
      decoration: BoxDecoration(
        // 🎯 7. Apply the grey disabled background
        color: readOnly ? Colors.grey.shade200 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          // 🎯 8. Apply the flat grey disabled border
          color: readOnly
              ? Colors.grey.shade300
              : (hasError ? Colors.red.shade700 : Colors.grey.shade300),
          width: hasError && !readOnly ? 1.5 : 1,
        ),
      ),
      child: unifiedNrcRow,
    );
  }
}
