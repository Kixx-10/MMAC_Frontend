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
  bool _isLoading = true; 
  
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
          _isLoading = false; 
        });
      }).catchError((e) {
        debugPrint("❌ Failed to load countries from API: $e");
        if (!mounted) return;
        setState(() {
          _isLoading = false; 
        });
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
      
      // reading from rivepod
      final nrcStateData = ref.read(nrcProvider).valueOrNull;
      final stateList = nrcStateData?.nrcStateList ?? [];
      final townshipList = nrcStateData?.availableNrcTownships ?? [];

      String stateMM = _selectedNrcStateCode!;
      String townshipMM = _selectedTownshipCode!;

      try {
        final matchedState = stateList.firstWhere((st) => st.idCode == _selectedNrcStateCode);
        stateMM = matchedState.codeMM; 
      } catch (e) {
        debugPrint("State codeMM mapping error: $e");
      }

      // finding mynamr language
      try {
        final matchedTownship = townshipList.firstWhere((ts) => ts.idCode == _selectedTownshipCode);
        townshipMM = matchedTownship.codeMM; 
      } catch (e) {
        debugPrint("Township codeMM mapping error: $e");
      }
      //change myanmar
      final fullNrcMyanmar = "$stateMM/$townshipMM($_selectedNrcType)${_nrcNumberController.text}";
      
      widget.controllers['nrc']?.text = fullNrcMyanmar;
    } else {
      widget.controllers['nrc']?.text = ""; 
    }
  }

  // ─── Backend Validation Rules for Date Fields ───
  
  DateTime _toDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String? _getDobError() {
    if (!_showDateErrors) return null;
    final dob = widget.values['dateOfBirth'] as DateTime?;
    if (dob == null) return 'DOB is required';

    final today = _toDateOnly(DateTime.now());
    if (!dob.isBefore(today)) {
      return 'DOB must be in the past';
    }
    return null;
  }

  String? _getIssuedDateError() {
    if (!_showDateErrors) return null;
    final issuedDate = widget.values['issuedDate'] as DateTime?;
    if (issuedDate == null) return 'Passport Issue Date is required.';

    final today = _toDateOnly(DateTime.now());
    if (issuedDate.isAfter(today)) {
      return 'Issue date cannot be in the future.';
    }

    final dob = widget.values['dateOfBirth'] as DateTime?;
    if (dob != null && !issuedDate.isAfter(dob)) {
      return 'Issue date must be after your Date of Birth.';
    }
    return null;
  }

  String? _getExpiryDateError() {
    if (!_showDateErrors) return null;
    final expiryDate = widget.values['expiryDate'] as DateTime?;
    if (expiryDate == null) return 'Passport Expiry Date is required.';

    final issuedDate = widget.values['issuedDate'] as DateTime?;
    if (issuedDate != null && !expiryDate.isAfter(issuedDate)) {
      return 'Expiry date must be after the Passport Issue Date.';
    }

    final today = _toDateOnly(DateTime.now());
    final sixMonthsFromToday = DateTime(today.year, today.month + 6, today.day);
    if (expiryDate.isBefore(sixMonthsFromToday)) {
      return 'This passport cannot be used because it has expired or has less than 6 months of validity remaining from today.';
    }
    return null;
  }

  @override
  bool validate() {
    if (!mounted) return false;
    
    setState(() => _showDateErrors = true);
    
    final isFormValid = widget.formKey.currentState?.validate() ?? false;
    
    final hasDateErrors = _getDobError() != null || 
                          _getIssuedDateError() != null || 
                          _getExpiryDateError() != null;
                          
    return isFormValid && !hasDateErrors;
  }

  @override
  Widget build(BuildContext context) {
    // if waiting 
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60), 
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      );
    }

    //if get api
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
            const SizedBox(width: 40),
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
              maxLength: 50,
              labelWidth: lw,
              validator: (v) => FormValidators.required(v, 'Full Name'),
            ),
            CustomDropdownField(
              label: "Gender",
              hint: "Select Gender",
              value: widget.values['gender'], 
              items: const ["Male", "Female"],
              showSearch: false,             
              onChanged: (value) {
                widget.onValueChanged('gender', value); 
              },
              validator: (value) => value == null ? "Please select gender" : null,
            )
          ),
          const SizedBox(height: 20),

          pair(
            CustomDateField(
              label: "Date of Birth",
              value: widget.values['dateOfBirth'],
              labelWidth: lw,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              errorText: _getDobError(), 
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
              maxLength: 30,
              validator: FormValidators.email,
            ),
            CustomTextField(
              label: "Mobile Number",
              controller: widget.controllers['mobile']!,
              maxLength: 20,
              labelWidth: lw,
              validator: (v) => FormValidators.required(v, 'Mobile Number'),
            ),
          ),
          const SizedBox(height: 20),

          pair(
            CustomTextField(
              label: "Visa Number",
              controller: widget.controllers['visaNumber']!,
              maxLength: 50,
              labelWidth: lw,
              isRequired: false,
              //validator: (v) => FormValidators.required(v, 'Visa Number'),
            ),
            CustomTextField(
              label: "Passport Number",
              controller: widget.controllers['passportNumber']!,
              maxLength: 20,
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
                      const SizedBox(width: 40),
                      Expanded(
                        child: CustomTextField(
                          label: "Father Name",
                          maxLength: 50,
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
                        maxLength: 50,
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
              errorText: _getIssuedDateError(), 
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
              errorText: _getExpiryDateError(),
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
              maxLength: 100,
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