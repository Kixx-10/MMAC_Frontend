// lib/ui/views/pages/new_application/identification_form_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/controllers/country_provider.dart';
import 'package:mmac/data/controllers/nrc_provider.dart';
import '../../../../utils/form_validators.dart';
import '../../../../utils/country_codes.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_date_field.dart';
import '../../widgets/custom_dropdown_field.dart';
import '../../widgets/mobile_code_search_dialog.dart';
import '../../widgets/nrc_selector_field.dart';

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
  ConsumerState<IdentificationFormLayout> createState() =>
      _IdentificationFormLayoutState();
}

class _IdentificationFormLayoutState
    extends ConsumerState<IdentificationFormLayout>
    implements IdentificationFormLayoutInterface {
  bool _showDateErrors = false;
  bool _isLoading = true;

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

  // ─── Mobile Country Codes State ───
  List<Map<String, String>> _countryCodes = [];
  final TextEditingController _mobileNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.onReady(this);

    // 🎯 Restore Values for Dropdowns & TextFields
    _selectedNrcStateCode = widget.values['nrcStateCode'];
    _selectedTownshipCode = widget.values['nrcTownshipCode'];
    _selectedNrcType = widget.values['nrcTypeCode'];
    _nrcNumberController.text = widget.values['nrcRawNumber'] ?? '';

    _countryCodes = CountryCodeData.codes;
    final String existingMobile = widget.controllers['mobile']?.text ?? '';
    final String? currentCode = widget.values['mobileCode'];

    if (existingMobile.isNotEmpty &&
        currentCode != null &&
        existingMobile.startsWith(currentCode)) {
      _mobileNumberController.text = existingMobile.substring(
        currentCode.length,
      );
    }

    // 🎯 The Pro Fix: Asynchronous Domino Effect
    Future.microtask(() async {
      // 1. Load Countries Data
      try {
        final countryState = await ref.read(countryProvider.future);
        if (mounted) {
          setState(() {
            _rawCountryObjects.clear();
            _countryNameList.clear();
            _rawCountryObjects.addAll(countryState.countryList);
            _countryNameList.addAll(
              countryState.countryList.map((c) => c.countryName).toList(),
            );
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("❌ Failed to load countries from API: $e");
        if (mounted) setState(() => _isLoading = false);
      }

      // 2. Restore NRC Cascade Dropdowns
      if (_selectedNrcStateCode != null && mounted) {
        try {
          final nrcData = await ref.read(nrcProvider.future);
          final matchedState = nrcData.nrcStateList.firstWhere(
            (s) => s.idCode == _selectedNrcStateCode,
          );
          // 🎯 မှော်ဆန်တဲ့အချက် - Draft ထဲက State ID ကို Provider ဆီ ပို့ပေးလိုက်ခြင်းဖြင့်
          // Provider က သက်ဆိုင်ရာ မြို့နယ် (Townships) တွေကို အလိုအလျောက် ပြန်ထုတ်ပေးသွားပါမယ်။
          ref.read(nrcProvider.notifier).selectNrcState(matchedState.id);
        } catch (e) {
          debugPrint("❌ Failed to restore NRC provider state: $e");
        }
      }
    });
  }

  @override
  void dispose() {
    _nrcNumberController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  void _updateMobileControllerValue() {
    final String? code = widget.values['mobileCode'];
    final String number = _mobileNumberController.text.trim();

    if (code != null && number.isNotEmpty) {
      final fullNumber = "$code$number";
      widget.controllers['mobile']?.text = fullNumber;
      widget.onValueChanged('mobile', fullNumber);
    } else {
      widget.controllers['mobile']?.text = "";
      widget.onValueChanged('mobile', "");
    }
  }

  void _updateNrcControllerValue() {
    if (_selectedNrcStateCode != null &&
        _selectedTownshipCode != null &&
        _selectedNrcType != null &&
        _nrcNumberController.text.isNotEmpty) {
      final nrcStateData = ref.read(nrcProvider).valueOrNull;
      final stateList = nrcStateData?.nrcStateList ?? [];
      final townshipList = nrcStateData?.availableNrcTownships ?? [];

      String stateMM = _selectedNrcStateCode!;
      String townshipMM = _selectedTownshipCode!;

      try {
        final matchedState = stateList.firstWhere(
          (st) => st.idCode == _selectedNrcStateCode,
        );
        stateMM = matchedState.codeMM;
      } catch (e) {}

      try {
        final matchedTownship = townshipList.firstWhere(
          (ts) => ts.idCode == _selectedTownshipCode,
        );
        townshipMM = matchedTownship.codeMM;
      } catch (e) {}

      final fullNrcMyanmar =
          "$stateMM/$townshipMM($_selectedNrcType)${_nrcNumberController.text}";

      widget.controllers['nrc']?.text = fullNrcMyanmar;
      widget.onValueChanged('nrc', fullNrcMyanmar);
    } else {
      widget.controllers['nrc']?.text = "";
      widget.onValueChanged('nrc', "");
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

    final bool isDesktop = MediaQuery.of(context).size.width > 500;
    final bool isMyanmar =
        widget.values['country'] == 'Myanmar' ||
        widget.values['country'] == 'MMR';
    const double lw = 140;

    final nrcAsync = ref.watch(nrcProvider);
    final nrcState = nrcAsync.valueOrNull;

    Widget buildCustomDropdownContainer({
      required Widget child,
      bool isFocused = false,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        height: 45,
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
              onChanged: (value) {
                widget.onValueChanged('fullName', value);
              },
            ),
            CustomDropdownField(
              label: "Gender",
              hint: "Select Gender",
              labelWidth: lw,
              dialogWidth: 200,
              dialogHeight: 100,
              value: widget.values['gender'],
              items: const ["Male", "Female"],
              showSearch: false,
              onChanged: (value) {
                widget.onValueChanged('gender', value);
              },
              validator: (value) =>
                  value == null ? "Please select gender" : null,
              spacing: 8,
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
                  ? 'Date of Birth is required'
                  : null,
              onPicked: (d) {
                widget.onValueChanged('dateOfBirth', d);
                if (!mounted) return;
                setState(() => _showDateErrors = false);
              },
            ),
            AbsorbPointer(
              absorbing:
                  widget.values['country'] == 'Myanmar' ||
                  widget.values['country'] == 'MMR',
              child: CustomDropdownField(
                label: "Country",
                value: widget.values['country'],
                hint: "Select Country",
                labelWidth: lw,
                dialogWidth: 250,
                dialogHeight: 250,
                items: _countryNameList,
                validator: (v) => FormValidators.requiredDropdown(v, 'Country'),
                onChanged: (v) {
                  widget.onValueChanged('country', v);
                  if (v != null) {
                    try {
                      final matched = _rawCountryObjects.firstWhere(
                        (c) => c.countryName == v,
                      );
                      widget.onValueChanged('countryCode', matched.countryCode);
                    } catch (e) {}
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
                spacing: 8,
              ),
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
              onChanged: (value) {
                widget.onValueChanged('email', value);
              },
            ),

            // ─── Mobile Number Field ───
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: SizedBox(
                    width: lw,
                    child: RichText(
                      text: const TextSpan(
                        text: "Mobile Number",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontFamily: 'sans-serif',
                        ),
                        children: [
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 80,
                        child: InkWell(
                          onTap: () {
                            showDialog<String>(
                              context: context,
                              builder: (context) => MobileCodeSearchDialog(
                                countryCodes: _countryCodes,
                                selectedValue: widget.values['mobileCode'],
                              ),
                            ).then((code) {
                              if (code != null) {
                                widget.onValueChanged('mobileCode', code);
                                _updateMobileControllerValue();
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.values['mobileCode'] ?? "Code",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: widget.values['mobileCode'] != null
                                          ? Colors.black87
                                          : Colors.grey.shade400,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  size: 18,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _mobileNumberController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(15),
                          ],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Enter phone number",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 16,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (v) => _updateMobileControllerValue(),
                          validator: (v) {
                            final String? code = widget.values['mobileCode'];
                            final String number = _mobileNumberController.text;
                            if (code == null) {
                              return 'Please select country code';
                            }
                            if (number.isEmpty) {
                              return 'Mobile Number is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
              validator: (v) => null,
              onChanged: (v) {
                if (v.trim().isEmpty) {
                  widget.onValueChanged('visaNumber', null);
                } else {
                  widget.onValueChanged('visaNumber', v);
                }
              },
            ),
            CustomTextField(
              label: "Passport Number",
              controller: widget.controllers['passportNumber']!,
              maxLength: 20,
              labelWidth: lw,
              validator: (v) => FormValidators.required(v, 'Passport Number'),
              onChanged: (value) {
                widget.onValueChanged('passportNumber', value);
              },
            ),
          ),
          const SizedBox(height: 20),

          if (isMyanmar) ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isNrcRowDesktop = constraints.maxWidth > 550;

                Widget nrcFields() {
                  final List<dynamic> stateList = nrcState?.nrcStateList ?? [];
                  final List<dynamic> townshipList =
                      nrcState?.availableNrcTownships ?? [];

                  final int? currentProviderStateId =
                      nrcState?.selectedNrcStateId;

                  // 🎯 Dropdown Button အတွက် တန်ဖိုးများကို အကာအကွယ်ပေးထားခြင်း
                  final int? activeStateId =
                      stateList.any((st) => st.id == currentProviderStateId)
                      ? currentProviderStateId
                      : null;

                  final String? activeTownshipCode =
                      townshipList.any(
                        (ts) => ts.idCode == _selectedTownshipCode,
                      )
                      ? _selectedTownshipCode
                      : null;

                  final String? activeNrcType =
                      _nrcTypes.any((t) => t['code'] == _selectedNrcType)
                      ? _selectedNrcType
                      : null;

                  final stateDropdown = buildCustomDropdownContainer(
                    child: DropdownButton<int>(
                      value: activeStateId,
                      isExpanded: true,
                      isDense: true,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: Colors.black54,
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
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
                          widget.onValueChanged('nrcStateCode', match.idCode);
                          widget.onValueChanged('nrcTownshipCode', null);
                          _updateNrcControllerValue();
                        }
                      },
                    ),
                  );

                  final townshipDropdown = buildCustomDropdownContainer(
                    child: DropdownButton<String>(
                      value: activeTownshipCode,
                      isExpanded: true,
                      isDense: true,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: Colors.black54,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      menuMaxHeight: 350,
                      items: townshipList.map<DropdownMenuItem<String>>((ts) {
                        return DropdownMenuItem<String>(
                          value: ts.idCode,
                          child: Text(
                            ts.codeMM,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (!mounted) return;
                        setState(() => _selectedTownshipCode = v);
                        widget.onValueChanged('nrcTownshipCode', v);
                        _updateNrcControllerValue();
                      },
                    ),
                  );

                  final typeDropdown = buildCustomDropdownContainer(
                    child: DropdownButton<String>(
                      value: activeNrcType,
                      isExpanded: true,
                      isDense: true,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: Colors.black54,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      items: _nrcTypes.map<DropdownMenuItem<String>>((t) {
                        return DropdownMenuItem<String>(
                          value: t['code'],
                          child: Text(t['label']!),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (!mounted) return;
                        setState(() => _selectedNrcType = v);
                        widget.onValueChanged('nrcTypeCode', v);
                        _updateNrcControllerValue();
                      },
                    ),
                  );

                  final numberField = Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: TextFormField(
                      controller: _nrcNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[\u1040-\u1049]'),
                        ),
                        LengthLimitingTextInputFormatter(6),
                      ],
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "၁၂၃၄၅၆",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (v) {
                        _updateNrcControllerValue();
                        widget.onValueChanged('nrcRawNumber', v);
                      },
                    ),
                  );

                  return NrcSelectorField(
                    isDesktop: isNrcRowDesktop,
                    stateDropdown: stateDropdown,
                    townshipDropdown: townshipDropdown,
                    typeDropdown: typeDropdown,
                    numberField: numberField,
                  );
                }

                Widget fatherNameField = CustomTextField(
                  label: "Father Name",
                  maxLength: 50,
                  controller: widget.controllers['fatherName']!,
                  labelWidth: lw,
                  validator: (v) =>
                      FormValidators.fatherName(v, isMyanmar: isMyanmar),
                  onChanged: (value) {
                    widget.onValueChanged('fatherName', value);
                  },
                );

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
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
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
                      Expanded(child: fatherNameField),
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
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ' *',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: nrcFields()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      fatherNameField,
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
                  ? 'Issued Date is required'
                  : null,
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
                  ? 'Expiry Date is required'
                  : null,
              onPicked: (d) {
                widget.onValueChanged('expiryDate', d);
                if (!mounted) return;
                setState(() => _showDateErrors = false);
              },
            ),
          ),
          const SizedBox(height: 20),

          pair(
            CustomDropdownField(
              label: "Issued Country",
              value: widget.values['issuedCountry'],
              hint: "Select Country",
              items: _countryNameList,
              labelWidth: lw,
              dialogWidth: 250,
              dialogHeight: 250,
              validator: (v) =>
                  FormValidators.requiredDropdown(v, 'Issued Country'),
              onChanged: (v) {
                widget.onValueChanged('issuedCountry', v);
                if (v != null) {
                  try {
                    final matched = _rawCountryObjects.firstWhere(
                      (c) => c.countryName == v,
                    );
                    widget.onValueChanged(
                      'issuedCountryCode',
                      matched.countryCode,
                    );
                  } catch (e) {}
                }
              },
              spacing: 8,
            ),
            CustomTextField(
              label: "Address",
              controller: widget.controllers['address']!,
              labelWidth: lw,
              maxLength: 100,
              validator: (v) => FormValidators.required(v, 'Address'),
              onChanged: (value) {
                widget.onValueChanged('address', value);
              },
            ),
          ),
          const SizedBox(height: 28),

          widget.actionButtons,
        ],
      ),
    );
  }
}
