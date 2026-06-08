// lib/ui/views/pages/new_application/identification_form_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:mmac/data/controllers/country_provider.dart';
import 'package:mmac/data/controllers/nrc_provider.dart';
import '../../../../utils/form_validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_date_field.dart';
import '../../widgets/custom_dropdown_field.dart';

abstract class IdentificationFormLayoutInterface {
  bool validate();
}

class IdentificationFormLayout extends ConsumerStatefulWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, dynamic> values;
  final Widget actionButtons;
  final Function(String, dynamic) onValueChanged;
  final GlobalKey<FormState> formKey;
  final void Function(IdentificationFormLayoutInterface) onReady;

  const IdentificationFormLayout({
    super.key,
    required this.controllers,
    required this.values,
    required this.actionButtons,
    required this.onValueChanged,
    required this.formKey,
    required this.onReady,
  });

  @override
  ConsumerState<IdentificationFormLayout> createState() => _IdentificationFormLayoutState();
}

class _IdentificationFormLayoutState extends ConsumerState<IdentificationFormLayout>
    implements IdentificationFormLayoutInterface {

  bool _showDateErrors = false;
  
  // change objects to lists for dropdowns from API
  final List<dynamic> _rawCountryObjects = [];
  final List<String> _countryNameList = [];

  // ─── NRC State Variables ───
  String? _selectedNrcStateCode;   
  String? _selectedTownshipCode; 
  String? _selectedNrcType; 

  final TextEditingController _nrcNumberController = TextEditingController();
  final List<Map<String, String>> _nrcTypes = [
    {"code": "နိုင်", "label": "နိုင်"},
    {"code": "ဧည့်", "label": "ဧည့်"},
    {"code": "ပြု", "label": "ပြု"},
  ];

  @override
  void initState() {
    super.initState();
    widget.onReady(this);
    Future.microtask(() {
      ref.read(countryProvider.future).then((state) {
        if (!mounted) return;
        setState(() {
          _rawCountryObjects.clear();
          _countryNameList.clear();
          // to keep the full country objects for later use when we need to find the code based on selected name
          _rawCountryObjects.addAll(state.countryList);
          _countryNameList.addAll(state.countryList.map((c) => c.countryName).toList());
        });
      }).catchError((e) {
        debugPrint("❌ Failed to load countries from API: $e");
      });
    });
  }

  @override
  void dispose() {
    _nrcNumberController.dispose(); 
    super.dispose();
  }

  void _updateNrcControllerValue() {
    if (_selectedNrcStateCode != null &&
        _selectedTownshipCode != null &&
        _selectedNrcType != null &&
        _nrcNumberController.text.isNotEmpty) {
      
      final fullNrc = "$_selectedNrcStateCode/$_selectedTownshipCode($_selectedNrcType)${_nrcNumberController.text}";
      widget.controllers['nrc']?.text = fullNrc;
    } else {
      widget.controllers['nrc']?.text = ""; 
    }
  }

  @override
  bool validate() {
    if (!mounted) return false;
    
    setState(() => _showDateErrors = true);
    return widget.formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 500;
    final bool isMyanmar = widget.values['country'] == 'Myanmar' || widget.values['country'] == 'MMR';
    const double lw = 140;

    final nrcAsync = ref.watch(nrcProvider);
    final nrcState = nrcAsync.valueOrNull;

    Widget buildCustomDropdownContainer({required Widget child, bool isFocused = false}) {
      return Container(
        height: 42, 
        padding: const EdgeInsets.only(left: 6, right: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFocused ? Colors.blue : Colors.grey.shade300,
            width: isFocused ? 1.5 : 1,
          ),
        ),
        child: DropdownButtonHideUnderline(child: child),
      );
    }

    Widget pair(Widget a, Widget b) {
      if (isDesktop) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: a),
            const SizedBox(width: 24),
            Expanded(child: b),
          ],
        );
      }
      return Column(children: [a, const SizedBox(height: 16), b]);
    }

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pair(
            CustomTextField(
              label: "Full Name",
              controller: widget.controllers['fullName']!,
              labelWidth: lw,
              validator: (v) => FormValidators.required(v, 'Full Name'),
            ),
            CustomDropdownField(
              label: 'Gender',
              value: widget.values['gender'],
              hint: 'Select Gender',
              items: const ['Male', 'Female'],
              labelWidth: lw,
              validator: (v) => FormValidators.requiredDropdown(v, 'Gender'),
              onChanged: (v) => widget.onValueChanged('gender', v),
            ),
          ),
          const SizedBox(height: 20),

          pair(
            CustomDateField(
              label: "Date of Birth",
              value: widget.values['dateOfBirth'],
              labelWidth: lw,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              errorText: _showDateErrors && widget.values['dateOfBirth'] == null
                  ? 'Date of Birth is required' : null,
              onPicked: (d) {
                widget.onValueChanged('dateOfBirth', d);
                if (!mounted) return;
                setState(() => _showDateErrors = false);
              },
            ),
            // ── Country of Birth Dropdown ──
            CustomDropdownField(
              label: "Country", 
              value: widget.values['country'],
              hint: "Select Country",
              labelWidth: lw,
              items: _countryNameList, 
              validator: (v) => FormValidators.requiredDropdown(v, 'Country'),
              onChanged: (v) {
                widget.onValueChanged('country', v);
                if (v != null) {
                  ref.read(countryProvider.notifier).selectCountry(v);
                  try {
                    final matched = _rawCountryObjects.firstWhere((c) => c.countryName == v);
                    widget.onValueChanged('countryCode', matched.countryCode);
                  } catch (e) {
                    debugPrint("Country model mapping error: $e");
                  }
                }
                if (v != 'Myanmar' && v != 'MMR') {
                  widget.controllers['nrc']?.clear();
                  widget.controllers['fatherName']?.clear();
                  if (!mounted) return;
                  setState(() {
                    _selectedNrcStateCode = null;
                    _selectedTownshipCode = null; 
                    _selectedNrcType = null;
                    _nrcNumberController.clear();
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 20),

          pair(
            CustomTextField(
              label: "Email",
              controller: widget.controllers['email']!,
              labelWidth: lw,
              validator: FormValidators.email,
            ),
            CustomTextField(
              label: "Mobile Number",
              controller: widget.controllers['mobile']!,
              labelWidth: lw,
              validator: (v) => FormValidators.required(v, 'Mobile Number'),
            ),
          ),
          const SizedBox(height: 20),

          pair(
            CustomTextField(
              label: "Visa Number",
              controller: widget.controllers['visaNumber']!,
              labelWidth: lw,
              validator: (v) => FormValidators.required(v, 'Visa Number'),
            ),
            CustomTextField(
              label: "Passport Number",
              controller: widget.controllers['passportNumber']!,
              labelWidth: lw,
              validator: (v) => FormValidators.required(v, 'Passport Number'),
            ),
          ),
          const SizedBox(height: 20),

          if (isMyanmar) ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isNrcRowDesktop = constraints.maxWidth > 550;

                Widget nrcFields() {
                  final List<dynamic> stateList = nrcState?.nrcStateList ?? [];
                  final List<dynamic> townshipList = nrcState?.availableNrcTownships ?? [];

                  final int? currentProviderStateId = nrcState?.selectedNrcStateId;
                  final int? activeStateId = stateList.any((st) => st.id == currentProviderStateId) 
                      ? currentProviderStateId 
                      : null;

                  final String? activeTownshipCode = townshipList.any((ts) => ts.idCode == _selectedTownshipCode)
                      ? _selectedTownshipCode
                      : null;

                  final String? activeNrcType = _nrcTypes.any((t) => t['code'] == _selectedNrcType)
                      ? _selectedNrcType
                      : null;

                  final stateDropdown = buildCustomDropdownContainer(
                    child: DropdownButton<int>(
                      value: activeStateId,
                      isExpanded: true, 
                      icon: const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black54),
                      style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                      menuMaxHeight: 350,
                      items: stateList.map<DropdownMenuItem<int>>((st) {
                        return DropdownMenuItem<int>(
                          value: st.id,
                          child: Text(st.codeMM),
                        );
                      }).toList(),
                      onChanged: (id) {
                        if (id != null) {
                          ref.read(nrcProvider.notifier).selectNrcState(id);
                          final match = stateList.firstWhere((s) => s.id == id);
                          if (!mounted) return;
                          setState(() {
                            _selectedNrcStateCode = match.idCode;
                            _selectedTownshipCode = null;
                          });
                          _updateNrcControllerValue();
                        }
                      },
                    ),
                  );

                  final townshipDropdown = buildCustomDropdownContainer(
                    child: DropdownButton<String>(
                      value: activeTownshipCode,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black54),
                      style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                      menuMaxHeight: 350,
                      items: townshipList.map<DropdownMenuItem<String>>((ts) {
                        return DropdownMenuItem<String>(
                          value: ts.idCode,
                          child: Text(ts.codeMM, overflow: TextOverflow.visible),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (!mounted) return;
                        setState(() => _selectedTownshipCode = v);
                        _updateNrcControllerValue();
                      },
                    ),
                  );

                  final typeDropdown = buildCustomDropdownContainer(
                    child: DropdownButton<String>(
                      value: activeNrcType,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black54),
                      style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                      items: _nrcTypes.map<DropdownMenuItem<String>>((t) {
                        return DropdownMenuItem<String>(
                          value: t['code'],
                          child: Text(t['label']!),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (!mounted) return;
                        setState(() => _selectedNrcType = v);
                        _updateNrcControllerValue();
                      },
                    ),
                  );

                  final numberField = SizedBox(
                    height: 42,
                    child: TextFormField(
                      controller: _nrcNumberController,
                      keyboardType: TextInputType.number, 
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\u1040-\u1049]')), 
                        LengthLimitingTextInputFormatter(6), 
                      ],
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        hintText: "၁၂၃၄၅၆", 
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                        ),
                      ),
                      onChanged: (v) => _updateNrcControllerValue(),
                    ),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isNrcRowDesktop) 
                        Row(
                          children: [
                            Expanded(flex: 28, child: stateDropdown),    
                            const SizedBox(width: 4),
                            Expanded(flex: 48, child: townshipDropdown), 
                            const SizedBox(width: 4),
                            Expanded(flex: 26, child: typeDropdown),   
                            const SizedBox(width: 4),
                            Expanded(flex: 38, child: numberField),
                          ],
                        )
                      else 
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: stateDropdown),
                                const SizedBox(width: 6),
                                Expanded(child: townshipDropdown),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(child: typeDropdown),
                                const SizedBox(width: 6),
                                Expanded(child: numberField),
                              ],
                            ),
                          ],
                        ),
                    ],
                  );
                }

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: lw,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: RichText(
                                  text: const TextSpan(
                                    text: "NRC",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                                    children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: nrcFields()),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: CustomTextField(
                          label: "Father Name",
                          controller: widget.controllers['fatherName']!,
                          labelWidth: lw,
                          validator: (v) => FormValidators.fatherName(v, isMyanmar: isMyanmar),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: lw,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: RichText(
                                text: const TextSpan(
                                  text: "NRC",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                                  children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: nrcFields()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: "Father Name",
                        controller: widget.controllers['fatherName']!,
                        labelWidth: lw,
                        validator: (v) => FormValidators.fatherName(v, isMyanmar: isMyanmar),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],

          pair(
            CustomDateField(
              label: "Issued Date",
              value: widget.values['issuedDate'],
              labelWidth: lw,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              errorText: _showDateErrors && widget.values['issuedDate'] == null
                  ? 'Issued Date is required' : null,
              onPicked: (d) {
                widget.onValueChanged('issuedDate', d);
                if (!mounted) return;
                setState(() => _showDateErrors = false);
              },
            ),
            CustomDateField(
              label: "Expiry Date",
              value: widget.values['expiryDate'],
              labelWidth: lw,
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
              errorText: _showDateErrors && widget.values['expiryDate'] == null
                  ? 'Expiry Date is required' : null,
              onPicked: (d) {
                widget.onValueChanged('expiryDate', d);
                if (!mounted) return;
                setState(() => _showDateErrors = false);
              },
            ),
          ),
          const SizedBox(height: 20),

          pair(
            // ── Issued Country Dropdown ──
            CustomDropdownField(
              label: "Issued Country",
              value: widget.values['issuedCountry'],
              hint: "Select Country",
              items: _countryNameList, 
              labelWidth: lw,
              validator: (v) => FormValidators.requiredDropdown(v, 'Issued Country'),
              onChanged: (v) {
                widget.onValueChanged('issuedCountry', v);
                if (v != null) {
                  try {
                    final matched = _rawCountryObjects.firstWhere((c) => c.countryName == v);
                    widget.onValueChanged('issuedCountryCode', matched.countryCode);
                  } catch (e) {
                    debugPrint("Issued Country model mapping error: $e");
                  }
                }
              },
            ),
            CustomTextField(
              label: "Address",
              controller: widget.controllers['address']!,
              labelWidth: lw,
              validator: (v) => FormValidators.required(v, 'Address'),
            ),
          ),
          const SizedBox(height: 28),

          widget.actionButtons,
        ],
      ),
    );
  }
}