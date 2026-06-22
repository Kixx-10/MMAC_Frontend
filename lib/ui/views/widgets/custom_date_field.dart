import 'package:flutter/material.dart';

class CustomDateField extends StatefulWidget {
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

  @override
  State<CustomDateField> createState() => _CustomDateFieldState();
}

class _CustomDateFieldState extends State<CustomDateField> {
  OverlayEntry? _overlayEntry;

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

  void _toggleOverlay() {
    if (_overlayEntry == null) {
      // 🎯 STEP 1: Find the exact absolute screen position of this widget row
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.attached) return;

      final Offset fieldPosition = renderBox.localToGlobal(Offset.zero);

      _overlayEntry = _createOverlayEntry(fieldPosition);
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _closeOverlay();
    }
  }

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry(Offset fieldPosition) {
    DateTime initialDate = widget.value ?? DateTime.now();
    if (initialDate.isBefore(widget.firstDate)) initialDate = widget.firstDate;
    if (initialDate.isAfter(widget.lastDate)) initialDate = widget.lastDate;

    const double calendarHeight = 350;
    const double gap = 4;

    // 🎯 STEP 2: Calculate perfect absolute screen alignment coordinates
    // Shift left past the label text + spacing width to match the box perfectly
    final double leftPosition = fieldPosition.dx + widget.labelWidth + 8;
    final double topPosition = fieldPosition.dy - calendarHeight - gap;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Background listener to dismiss when clicking outside
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeOverlay,
              child: Container(color: Colors.transparent),
            ),
          ),
          // 🎯 STEP 3: Position using absolute screen coordinates to bypass Flutter link bugs
          Positioned(
            left: leftPosition,
            top: topPosition,
            width: 320,
            height: calendarHeight,
            child: Material(
              elevation: 6,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: CalendarDatePicker(
                  initialDate: initialDate,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onDateChanged: (DateTime picked) {
                    widget.onPicked(picked);
                    _closeOverlay(); // Closes securely on selection
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _closeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null;
    final String displayText = widget.value != null
        ? _formatDate(widget.value!)
        : "Select Date";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14),
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
                onTap: widget.readOnly ? null : _toggleOverlay,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: widget.readOnly
                        ? Colors.grey.shade200
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.readOnly
                          ? Colors.grey.shade300
                          : (hasError
                                ? Colors.red
                                : (widget.value != null
                                      ? Colors.grey
                                      : Colors.grey.shade300)),
                      width: hasError && !widget.readOnly ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        displayText,
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.readOnly
                              ? Colors.grey.shade500
                              : (widget.value != null
                                    ? Colors.black87
                                    : Colors.grey),
                          fontWeight: widget.value != null && !widget.readOnly
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                      Icon(
                        Icons.calendar_month_outlined,
                        color: widget.readOnly
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
                    widget.errorText!,
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
