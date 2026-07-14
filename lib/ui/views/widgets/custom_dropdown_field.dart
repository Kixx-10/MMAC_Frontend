import 'package:flutter/material.dart';

class CustomDropdownField extends StatefulWidget {
  final double spacing;
  final String label;
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final double labelWidth;
  final String? Function(String?)? validator;
  final bool showSearch;
  final double? dialogHeight;
  final double? dialogWidth;
  final bool readonly;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.labelWidth = 130,
    this.validator,
    this.showSearch = true,
    this.dialogHeight,
    this.dialogWidth,
    this.readonly = false,
    this.spacing = 8,
  });

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();

  // 🎯 THE LINK: Connects the dropdown box visually to the input box frame
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void didUpdateWidget(covariant CustomDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fieldKey.currentState?.didChange(widget.value);
        }
      });
    }
  }

  // 🎯 Toggles opening and closing the sticky dropdown overlay
  void _toggleOverlay(FormFieldState<String> state, double width) {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry(state, width);
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _closeOverlay();
    }
  }

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry(FormFieldState<String> state, double width) {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Dismisses the dropdown panel instantly if user clicks outside of it
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeOverlay,
            ),
          ),
          Positioned(
            width: width, // Inherits the exact field width
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              offset: const Offset(
                0,
                4,
              ), // 4px gap directly beneath the input field
              child: Material(
                elevation: 6,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                color: Colors.white,
                child: DropdownMenuPanel(
                  items: widget.items,
                  selectedValue: state.value,
                  showSearch: widget.showSearch,
                  dialogHeight: widget.dialogHeight,
                  onSelected: (newValue) {
                    state.didChange(newValue);
                    widget.onChanged(newValue);
                    _closeOverlay(); // Auto-closes on selection
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

    final Widget dropDownField = FormField<String>(
      key: _fieldKey,
      initialValue: widget.value,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (FormFieldState<String> state) {
        final bool hasError = state.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎯 LayoutBuilder measures exact responsive width available
            LayoutBuilder(
              builder: (context, constraints) {
                return CompositedTransformTarget(
                  link: _layerLink,
                  child: InkWell(
                    onTap: widget.readonly
                        ? null
                        : () => _toggleOverlay(state, constraints.maxWidth),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: widget.readonly
                            ? Colors.grey.shade100
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: widget.readonly
                              ? Colors.grey.shade300
                              : (hasError
                                    ? Colors.red
                                    : (state.value != null
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade300)),
                          width: hasError && !widget.readonly ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              state.value ?? widget.hint,
                              style: TextStyle(
                                fontSize: 14,
                                color: widget.readonly
                                    ? Colors.grey.shade500
                                    : (state.value != null
                                          ? Colors.black87
                                          : Colors.grey.shade400),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: widget.readonly
                                ? Colors.grey.shade400
                                : (hasError
                                      ? Colors.red
                                      : Colors.grey.shade600),
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 6),
                child: Text(
                  state.errorText ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
          ],
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [lableWidget, dropDownField],
    );
  }
}

// 🎯 Extracted & refactored menu panel optimized for Overlay viewing
class DropdownMenuPanel extends StatefulWidget {
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String> onSelected;
  final bool showSearch;
  final double? dialogHeight;

  const DropdownMenuPanel({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    required this.showSearch,
    this.dialogHeight,
  });

  @override
  State<DropdownMenuPanel> createState() => _DropdownMenuPanelState();
}

class _DropdownMenuPanelState extends State<DropdownMenuPanel> {
  late List<String> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _filterList(String query) {
    setState(() {
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Caps height safely beneath field without consuming whole viewport
      height: widget.dialogHeight ?? (widget.showSearch ? 260 : 160),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showSearch) ...[
            TextField(
              controller: _searchController,
              onChanged: _filterList,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search here...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: Colors.grey,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 18,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _filterList('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: _filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      'No results found.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected = item == widget.selectedValue;
                      return ListTile(
                        dense: true,
                        title: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.blue : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.blue,
                                size: 20,
                              )
                            : null,
                        onTap: () => widget.onSelected(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
