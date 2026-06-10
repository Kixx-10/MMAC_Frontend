import 'package:flutter/material.dart';

class MobileCodeSearchDialog extends StatefulWidget {
  final List<Map<String, String>> countryCodes;
  final String? selectedValue;

  const MobileCodeSearchDialog({
    super.key,
    required this.countryCodes,
    required this.selectedValue,
  });

  @override
  State<MobileCodeSearchDialog> createState() => _MobileCodeSearchDialogState();
}

class _MobileCodeSearchDialogState extends State<MobileCodeSearchDialog> {
  late List<Map<String, String>> _filteredCodes;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCodes = widget.countryCodes;
  }

  void _filterList(String query) {
    setState(() {
      _filteredCodes = widget.countryCodes.where((item) {
        final country = (item['country'] ?? '').toLowerCase();
        final code = (item['code'] ?? '').toLowerCase();
        return country.contains(query.toLowerCase()) || code.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text("Select Country Code", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 250,
        height: 250,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _filterList,
              decoration: InputDecoration(
                hintText: 'Search country or code...',
                prefixIcon: const Icon(Icons.search),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.blue, width: 1.5)),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _filteredCodes.isEmpty
                  ? const Center(child: Text('No results found.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _filteredCodes.length,
                      itemBuilder: (context, index) {
                        final item = _filteredCodes[index];
                        final isSelected = item['code'] == widget.selectedValue;
                        return ListTile(
                          title: Text("${item['country']} (${item['code']})", style: TextStyle(color: isSelected ? Colors.blue : Colors.black87)),
                          trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                          onTap: () => Navigator.pop(context, item['code']),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: Colors.grey)))],
    );
  }
}