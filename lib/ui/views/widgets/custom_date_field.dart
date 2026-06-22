import 'package:flutter/material.dart';

class CustomDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime?> onPicked;
  final double labelWidth;
  final String? errorText;
  final bool readOnly;

  const CustomDateField({
    super.key,
    required this.label,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onPicked,
    this.labelWidth = 140,
    this.errorText,
    this.readOnly = false,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    return "$day $month $year";
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = value ?? DateTime.now();
    if (initialDate.isBefore(firstDate)) initialDate = firstDate;
    if (initialDate.isAfter(lastDate)) initialDate = lastDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onPicked(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorText != null;
    final String displayText = value != null
        ? _formatDate(value!)
        : "Select Date";

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
                children: const [
                  TextSpan(
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
        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: readOnly ? null : () => _selectDate(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    // 🎯 1. BACKGROUND: Turn light grey if readOnly is true
                    color: readOnly ? Colors.grey.shade200 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      // 🎯 2. BORDER: Keep it flat grey if readOnly, otherwise show normal/error states
                      color: readOnly
                          ? Colors.grey.shade300
                          : (hasError
                                ? Colors.red
                                : (value != null
                                      ? Colors.grey
                                      : Colors.grey.shade300)),
                      width: hasError && !readOnly ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        displayText,
                        style: TextStyle(
                          fontSize: 14,
                          // 🎯 3. TEXT: Fade the text out if it's readOnly
                          color: readOnly
                              ? Colors.grey.shade500
                              : (value != null ? Colors.black87 : Colors.grey),
                          fontWeight: value != null && !readOnly
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                      Icon(
                        Icons.calendar_month_outlined,
                        // 🎯 4. ICON: Fade the calendar icon if readOnly
                        color: readOnly
                            ? Colors.grey
                            : (hasError ? Colors.red : Colors.grey.shade700),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 6),
                  child: Text(
                    errorText!,
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
