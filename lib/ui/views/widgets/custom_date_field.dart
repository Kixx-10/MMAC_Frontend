import 'package:flutter/material.dart';

class CustomDateField extends StatefulWidget {
  final String label;
  final DateTime? value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onPicked;
  final double labelWidth;
  final String? errorText;

  const CustomDateField({
    super.key,
    required this.label,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onPicked,
    this.labelWidth = 140,
    this.errorText,
  });

  @override
  State<CustomDateField> createState() => _CustomDateFieldState();
}

class _CustomDateFieldState extends State<CustomDateField> {
  int? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _syncFromValue(widget.value);
  }

  @override
  void didUpdateWidget(CustomDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value == null) {
      setState(() {
        _selectedDay   = null;
        _selectedMonth = null;
        _selectedYear  = null;
      });
    }
  }

  void _syncFromValue(DateTime? date) {
    if (date != null) {
      _selectedDay   = date.day;
      _selectedMonth = date.month;
      _selectedYear  = date.year;
    }
  }

  List<int> get _days {
    if (_selectedMonth == null || _selectedYear == null) {
      return List.generate(31, (i) => i + 1);
    }
    final daysInMonth = DateTime(_selectedYear!, _selectedMonth! + 1, 0).day;
    return List.generate(daysInMonth, (i) => i + 1);
  }

  List<int> get _months => List.generate(12, (i) => i + 1);

  List<int> get _years {
    final start = widget.firstDate.year;
    final end   = widget.lastDate.year;
    return List.generate(end - start + 1, (i) => end - i);
  }

  void _onChanged() {
    if (_selectedDay == null || _selectedMonth == null || _selectedYear == null) return;

    final maxDay = DateTime(_selectedYear!, _selectedMonth! + 1, 0).day;
    if (_selectedDay! > maxDay) _selectedDay = maxDay;

    widget.onPicked(DateTime(_selectedYear!, _selectedMonth!, _selectedDay!));
  }
  InputDecoration _dropdownDecoration(bool hasError) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.only(left: 6, right: 2, top: 12, bottom: 12), 
      errorStyle: const TextStyle(fontSize: 0, height: 0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError ? Colors.red : Colors.grey.shade300,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError ? Colors.red : Colors.blue,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String hint,
    required ValueChanged<T?> onChanged,
    required String Function(T) label,
    required bool hasError,
    required int flex,
  }) {
    return Expanded(
      flex: flex,
      child: DropdownButtonFormField<T>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, size: 20), 
        hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        decoration: _dropdownDecoration(hasError),
        style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
        items: items.map((item) => DropdownMenuItem<T>(
          value: item,
          child: Text(label(item), overflow: TextOverflow.ellipsis),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: SizedBox(
                width: widget.labelWidth,
                child: RichText(
                  text: TextSpan(
                    text: widget.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontFamily: 'sans-serif',
                    ),
                    children: const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildDropdown<int>(
              value: _selectedDay,
              items: _days,
              hint: 'Day',
              hasError: hasError,
              flex: 25, // 👈 ပြင်ဆင်ချက်
              label: (d) => d.toString().padLeft(2, '0'),
              onChanged: (v) {
                setState(() => _selectedDay = v);
                _onChanged();
              },
            ),
            const SizedBox(width: 6),
            _buildDropdown<int>(
              value: _selectedMonth,
              items: _months,
              hint: 'Month',
              hasError: hasError,
              flex: 32,
              label: (m) => _monthNames[m - 1],
              onChanged: (v) {
                setState(() => _selectedMonth = v);
                _onChanged();
              },
            ),
            const SizedBox(width: 6),
            _buildDropdown<int>(
              value: _selectedYear,
              items: _years,
              hint: 'Year',
              hasError: hasError,
              flex: 35, 
              label: (y) => y.toString(),
              onChanged: (v) {
                setState(() => _selectedYear = v);
                _onChanged();
              },
            ),
          ],
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              widget.errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}