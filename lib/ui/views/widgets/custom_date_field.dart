import 'package:flutter/material.dart';

enum CalendarViewMode { day, month, year }

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
  final LayerLink _layerLink = LayerLink();

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

  void _showMobileDatePicker() async {
    DateTime initialDate = widget.value ?? DateTime.now();
    if (initialDate.isBefore(widget.firstDate)) initialDate = widget.firstDate;
    if (initialDate.isAfter(widget.lastDate)) initialDate = widget.lastDate;

    // Use a custom Dialog on mobile to maintain the identical UX as the overlay
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext dialogContext) {
        DateTime tempSelectedDate = initialDate;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          child: SizedBox(
            width: 320,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: CustomCalendarPicker(
                    initialDate: tempSelectedDate,
                    firstDate: widget.firstDate,
                    lastDate: widget.lastDate,
                    onDateChanged: (DateTime picked) {
                      tempSelectedDate = picked;
                    },
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(tempSelectedDate),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) {
      widget.onPicked(picked);
    }
  }

  void _toggleOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _closeOverlay();
    }
  }

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    DateTime initialDate = widget.value ?? DateTime.now();
    if (initialDate.isBefore(widget.firstDate)) initialDate = widget.firstDate;
    if (initialDate.isAfter(widget.lastDate)) initialDate = widget.lastDate;

    DateTime tempSelectedDate = initialDate;

    const double calendarHeight = 400;
    const double gap = 4;

    return OverlayEntry(
      builder: (context) => CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: Offset(widget.labelWidth + 8, -calendarHeight - gap),
        child: Align(
          alignment: Alignment.topLeft,
          child: TapRegion(
            groupId:
                this, // Grouped with the text field to prevent self-closing when tapping inside
            child: SizedBox(
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
                child: StatefulBuilder(
                  builder: (context, setStateOverlay) {
                    return Column(
                      children: [
                        Expanded(
                          child: CustomCalendarPicker(
                            initialDate: tempSelectedDate,
                            firstDate: widget.firstDate,
                            lastDate: widget.lastDate,
                            onDateChanged: (DateTime picked) {
                              setStateOverlay(() {
                                tempSelectedDate = picked;
                              });
                            },
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
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
          ),
        ),
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
    final bool isMobile = MediaQuery.of(context).size.width < 500;

    final Widget lableWidget = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: RichText(
          text: TextSpan(
            text: widget.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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

    return TapRegion(
      groupId: this,
      onTapOutside: (event) {
        if (_overlayEntry != null) {
          _closeOverlay();
        }
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            lableWidget,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: widget.readOnly
                      ? null
                      : (isMobile ? _showMobileDatePicker : _toggleOverlay),
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
          ],
        ),
      ),
    );
  }
}

class CustomCalendarPicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateChanged;

  const CustomCalendarPicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
  });

  @override
  State<CustomCalendarPicker> createState() => _CustomCalendarPickerState();
}

class _CustomCalendarPickerState extends State<CustomCalendarPicker> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;
  CalendarViewMode _viewMode = CalendarViewMode.day;

  final List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<String> _shortMonthNames = [
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

  late ScrollController _yearScrollController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayedMonth = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
    );
    _yearScrollController = ScrollController();
  }

  @override
  void dispose() {
    _yearScrollController.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.black87),
            onPressed: _viewMode == CalendarViewMode.year
                ? null
                : () {
                    setState(() {
                      if (_viewMode == CalendarViewMode.day) {
                        _displayedMonth = DateTime(
                          _displayedMonth.year,
                          _displayedMonth.month - 1,
                        );
                      } else if (_viewMode == CalendarViewMode.month) {
                        _displayedMonth = DateTime(
                          _displayedMonth.year - 1,
                          _displayedMonth.month,
                        );
                      }
                    });
                  },
          ),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_viewMode == CalendarViewMode.day) ...[
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () =>
                        setState(() => _viewMode = CalendarViewMode.month),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 4.0,
                      ),
                      child: Text(
                        _monthNames[_displayedMonth.month - 1],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    setState(() => _viewMode = CalendarViewMode.year);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_yearScrollController.hasClients) {
                        int index =
                            _displayedMonth.year - widget.firstDate.year;
                        double offset = (index / 4).floor() * 60.0;
                        _yearScrollController.jumpTo(offset);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 4.0,
                    ),
                    child: Text(
                      '${_displayedMonth.year}',
                      style: TextStyle(
                        fontSize: _viewMode == CalendarViewMode.year ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: _viewMode == CalendarViewMode.year
                            ? Colors.blue
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.black87),
            onPressed: _viewMode == CalendarViewMode.year
                ? null
                : () {
                    setState(() {
                      if (_viewMode == CalendarViewMode.day) {
                        _displayedMonth = DateTime(
                          _displayedMonth.year,
                          _displayedMonth.month + 1,
                        );
                      } else if (_viewMode == CalendarViewMode.month) {
                        _displayedMonth = DateTime(
                          _displayedMonth.year + 1,
                          _displayedMonth.month,
                        );
                      }
                    });
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildDayGrid() {
    int daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;
    int firstWeekday = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    ).weekday;
    int emptyLeadingDays = firstWeekday == 7 ? 0 : firstWeekday;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: emptyLeadingDays + daysInMonth,
            itemBuilder: (context, index) {
              if (index < emptyLeadingDays) return const SizedBox.shrink();

              int dayNumber = index - emptyLeadingDays + 1;
              DateTime cellDate = DateTime(
                _displayedMonth.year,
                _displayedMonth.month,
                dayNumber,
              );

              bool isSelected =
                  cellDate.year == _selectedDate.year &&
                  cellDate.month == _selectedDate.month &&
                  cellDate.day == _selectedDate.day;

              bool isToday =
                  cellDate.year == DateTime.now().year &&
                  cellDate.month == DateTime.now().month &&
                  cellDate.day == DateTime.now().day;

              bool isOutdated =
                  cellDate.isBefore(
                    DateTime(
                      widget.firstDate.year,
                      widget.firstDate.month,
                      widget.firstDate.day,
                    ),
                  ) ||
                  cellDate.isAfter(
                    DateTime(
                      widget.lastDate.year,
                      widget.lastDate.month,
                      widget.lastDate.day,
                    ),
                  );

              return InkWell(
                onTap: isOutdated
                    ? null
                    : () {
                        setState(() {
                          _selectedDate = cellDate;
                          widget.onDateChanged(_selectedDate);
                        });
                      },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday && !isSelected
                        ? Border.all(color: Colors.blue, width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      dayNumber.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: isOutdated
                            ? Colors.grey.shade400
                            : (isSelected ? Colors.white : Colors.black87),
                        fontWeight: isSelected || isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        // crossAxisSpacing: 8.0,
        // mainAxisSpacing: 8.0,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        int targetMonth = index + 1;
        DateTime cellDate = DateTime(_displayedMonth.year, targetMonth);

        bool isSelectedMonth =
            _displayedMonth.year == _selectedDate.year &&
            _selectedDate.month == targetMonth;

        bool isOutdated =
            (cellDate.year == widget.firstDate.year &&
                targetMonth < widget.firstDate.month) ||
            (cellDate.year == widget.lastDate.year &&
                targetMonth > widget.lastDate.month);

        return InkWell(
          onTap: isOutdated
              ? null
              : () {
                  setState(() {
                    _displayedMonth = DateTime(
                      _displayedMonth.year,
                      targetMonth,
                    );
                    _viewMode = CalendarViewMode.day;
                  });
                },
          // borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelectedMonth ? Colors.blue : Colors.white,
              // borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _shortMonthNames[index],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelectedMonth
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: isOutdated
                      ? Colors.grey.shade400
                      : (isSelectedMonth ? Colors.white : Colors.black87),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildYearGrid() {
    int totalYears = widget.lastDate.year - widget.firstDate.year + 1;

    return GridView.builder(
      controller: _yearScrollController,
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
        // crossAxisSpacing: 8.0,
        // mainAxisSpacing: 8.0,
      ),
      itemCount: totalYears,
      itemBuilder: (context, index) {
        int cellYear = widget.firstDate.year + index;
        bool isSelectedYear = cellYear == _displayedMonth.year;

        return InkWell(
          onTap: () {
            setState(() {
              _displayedMonth = DateTime(cellYear, _displayedMonth.month);
              _viewMode = CalendarViewMode.month;
            });
          },
          // borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: isSelectedYear ? Colors.blue : Colors.transparent,
              // borderRadius: BorderRadius.circular(20),
              // border: isSelectedYear
              //     ? null
              //     : Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                cellYear.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelectedYear
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isSelectedYear ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(
              key: ValueKey(_viewMode),
              child: () {
                switch (_viewMode) {
                  case CalendarViewMode.day:
                    return _buildDayGrid();
                  case CalendarViewMode.month:
                    return _buildMonthGrid();
                  case CalendarViewMode.year:
                    return _buildYearGrid();
                }
              }(),
            ),
          ),
        ),
      ],
    );
  }
}
