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

  // 🎯 1. New Compact Native Dialog for Mobile Viewports
  void _showMobileDatePicker() async {
    DateTime initialDate = widget.value ?? DateTime.now();
    if (initialDate.isBefore(widget.firstDate)) initialDate = widget.firstDate;
    if (initialDate.isAfter(widget.lastDate)) initialDate = widget.lastDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      initialEntryMode: DatePickerEntryMode
          .calendarOnly, // ⚡ Trims header down so height is NOT too long!
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // Optional: Matches your web/desktop blue theme profile
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onPicked(picked);
    }
  }

  void _toggleOverlay() {
    if (_overlayEntry == null) {
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

    // 🎯 1. Create a temporary state variable to hold the user's selection
    DateTime tempSelectedDate = initialDate;

    // 🎯 2. Increased height safely from 300 to 380 to fit the new buttons!
    const double calendarHeight = 380;
    const double gap = 4;

    final double leftPosition = fieldPosition.dx + widget.labelWidth + 8;
    final double topPosition = fieldPosition.dy - calendarHeight - gap;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeOverlay,
              child: Container(color: Colors.transparent),
            ),
          ),
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
              // 🎯 3. Wrap in StatefulBuilder so the calendar can update without closing!
              child: StatefulBuilder(
                builder: (context, setStateOverlay) {
                  return Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: CalendarDatePicker(
                            initialDate: tempSelectedDate,
                            firstDate: widget.firstDate,
                            lastDate: widget.lastDate,
                            onDateChanged: (DateTime picked) {
                              // Only update the temporary variable inside the overlay!
                              setStateOverlay(() {
                                tempSelectedDate = picked;
                              });
                            },
                          ),
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey.shade200),
                      // 🎯 4. Add the Cancel and OK Action Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _closeOverlay,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black54,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                // Apply the final value back to the parent ONLY when OK is clicked!
                                widget.onPicked(tempSelectedDate);
                                _closeOverlay();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                              ),
                              child: const Text(
                                'OK',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
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

    // 🎯 2. Check current screen dimensions inside build loop
    final bool isMobile = MediaQuery.of(context).size.width < 500;

    final Widget lableWidget = Padding(
      padding: EdgeInsets.only(
        top: isMobile ? 0 : 14,
        bottom: isMobile ? 8 : 0,
      ),
      child: SizedBox(
        width: isMobile ? double.infinity : widget.labelWidth,
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
    );

    final Widget dateField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          // 🎯 3. Responsive Tap router branch
          onTap: widget.readOnly
              ? null
              : (isMobile ? _showMobileDatePicker : _toggleOverlay),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.readOnly ? Colors.grey.shade200 : Colors.white,
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
                        : (widget.value != null ? Colors.black87 : Colors.grey),
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
    );

    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [lableWidget, const SizedBox(height: 8), dateField],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              lableWidget,
              const SizedBox(width: 8),

              Expanded(child: dateField),
            ],
          );
  }
}
