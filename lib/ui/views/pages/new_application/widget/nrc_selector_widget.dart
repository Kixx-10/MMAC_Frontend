import 'package:flutter/material.dart';

class NrcSelectorWidget extends StatelessWidget {
  final bool isDesktop;
  final String? selectedNrcStateCode;
  final String? selectedTownshipCode;
  final String? selectedNrcType;
  final Widget numberField;
  final bool hasError; //  Error ရှိပါက အနီရောင် Border ပြောင်းရန် Flag
  final Function(int stateId, String stateIdCode) onStateChanged;
  final Function(String townshipIdCode) onTownshipChanged;
  final Function(String typeCode) onTypeChanged;
  final List<dynamic> stateList;
  final List<dynamic> townshipList;
  final List<Map<String, String>> nrcTypes;
  final int? activeStateId;

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
  });

  Widget _divider({Color? color}) => Container(
        width: 1,
        height: 24,
        color: color ?? Colors.grey.shade300,
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
        isExpanded: true,
        isDense: true,
        icon: const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black54),
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        hint: hint,
        items: items,
        onChanged: onChanged,
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
    final String? activeTownship = townshipList.any(
      (ts) => ts.idCode == selectedTownshipCode,
    )
        ? selectedTownshipCode
        : null;

    final String? activeType = nrcTypes.any(
      (t) => t['code'] == selectedNrcType,
    )
        ? selectedNrcType
        : null;

    final unifiedNrcRow = Row(
      children: [
        const SizedBox(width: 6),
        // ၁။ တိုင်း/ပြည်နယ် ကုဒ်
        _dropdown<int>(
          value: activeStateId,
          width: 50,
          hint: Text('၁၂/', style: TextStyle(color: Colors.grey.shade400)),
          items: stateList.map<DropdownMenuItem<int>>((st) {
            return DropdownMenuItem(value: st.id, child: Text(st.codeMM));
          }).toList(),
          onChanged: (id) {
            if (id != null) {
              final match = stateList.firstWhere((s) => s.id == id);
              onStateChanged(id, match.idCode);
            }
          },
        ),
        _divider(color: hasError ? Colors.red.shade300 : null),

        // ၂။ မြို့နယ်အတိုကောက်
        const SizedBox(width: 4),
        _dropdown<String>(
          value: activeTownship,
          width: 0,
          hint: Text('မြို့နယ်', style: TextStyle(color: Colors.grey.shade400)),
          items: townshipList.map<DropdownMenuItem<String>>((t) {
            return DropdownMenuItem(
              value: t.idCode,
              child: Text(t.codeMM, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onTownshipChanged(v);
          },
        ),
        _divider(color: hasError ? Colors.red.shade300 : null),

        // ၃။ အမျိုးအစား (နိုင်/ဧည့်/ပြု)
        const SizedBox(width: 6),
        _dropdown<String>(
          value: activeType,
          width: 50,
          hint: Text('နိုင်', style: TextStyle(color: Colors.grey.shade400)),
          items: nrcTypes.map<DropdownMenuItem<String>>((t) {
            return DropdownMenuItem(
              value: t['code'],
              child: Text(t['label']!),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onTypeChanged(v);
          },
        ),
        _divider(color: hasError ? Colors.red.shade300 : null),

        // ၄။ နံပါတ်ရိုက်ထည့်မည့် အကွက်
        Expanded(
          flex: 1,
          child: numberField,
        ),
      ],
    );

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasError ? Colors.red.shade700 : Colors.grey.shade300,
          width: hasError ? 1.5 : 1,
        ),
      ),
      child: unifiedNrcRow,
    );
  }
}