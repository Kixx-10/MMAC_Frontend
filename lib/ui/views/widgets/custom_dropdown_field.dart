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
    this.dialogWidth, this.spacing=8,  
  });

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  final GlobalKey<FormFieldState<String>> _fieldKey = GlobalKey<FormFieldState<String>>();

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

  void _showSearchDialog(BuildContext context, FormFieldState<String> state) {
    showDialog(
      context: context,
      builder: (context) {
        return SearchPickerDialog(
          title: widget.hint,
          items: widget.items,
          selectedValue: state.value,
          showSearch: widget.showSearch, 
          dialogHeight: widget.dialogHeight, 
          dialogWidth: widget.dialogWidth,   
          onSelected: (newValue) {
            state.didChange(newValue); 
            widget.onChanged(newValue); 
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
         SizedBox(width: widget.spacing),
        
        Expanded(
          child: FormField<String>(
            key: _fieldKey,
            initialValue: widget.value,
            validator: widget.validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            builder: (FormFieldState<String> state) {
              final bool hasError = state.hasError;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => _showSearchDialog(context, state),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: hasError 
                              ? Colors.red 
                              : (state.value != null ? Colors.grey.shade400 : Colors.grey.shade300),
                          width: hasError ? 1.5 : 1,
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
                                color: state.value != null ? Colors.black87 : Colors.grey.shade400,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down, 
                            color: hasError ? Colors.red : Colors.grey.shade600, 
                            size: 24,
                          ),
                        ],
                      ),
                    ),
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
          ),
        ),
      ],
    );
  }
}

class SearchPickerDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String> onSelected;
  final bool showSearch; 
  final double? dialogHeight; 
  final double? dialogWidth;  

  const SearchPickerDialog({
    super.key,
    required this.title,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    required this.showSearch, 
    this.dialogHeight, 
    this.dialogWidth,  
  });

  @override
  State<SearchPickerDialog> createState() => _SearchPickerDialogState();
}

class _SearchPickerDialogState extends State<SearchPickerDialog> {
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
    final double screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        widget.title, 
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      content: SizedBox(
        width: widget.dialogWidth ?? (screenWidth > 600 ? 450 : screenWidth * 0.9),
        height: widget.dialogHeight ?? (widget.showSearch ? 300 : 180), 
        child: Column(
          children: [
            if (widget.showSearch) ...[
              TextField(
                controller: _searchController,
                onChanged: _filterList,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search here...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
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
              const SizedBox(height: 12),
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
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = item == widget.selectedValue;
                        return ListTile(
                          title: Text(
                            item, 
                            style: TextStyle(
                              fontSize: 14, 
                              color: isSelected ? Colors.blue : Colors.black87,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected ? const Icon(Icons.check, color: Colors.blue, size: 20) : null,
                          onTap: () {
                            widget.onSelected(item);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Colors.grey, fontSize: 14)),
        )
      ],
    );
  }
}