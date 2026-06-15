// lib/ui/views/pages/new_application/identification_form_layout.dart

// ignore_for_file: empty_catches

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/controllers/country_provider.dart';
import 'package:mmac/data/controllers/nrc_provider.dart';
import 'package:mmac/ui/views/pages/new_application/widget/nrc_selector_widget.dart';
import '../../../../utils/form_validators.dart';
import '../../../../utils/country_codes.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_date_field.dart';
import '../../widgets/custom_dropdown_field.dart';
import '../../widgets/mobile_code_search_dialog.dart';

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
  bool _showNrcError = false;
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

    Future.microtask(() async {
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

      if (_selectedNrcStateCode != null && mounted) {
        try {
          final nrcData = await ref.read(nrcProvider.future);
          final matchedState = nrcData.nrcStateList.firstWhere(
            (s) => s.idCode == _selectedNrcStateCode,
          );
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
        _nrcNumberController.text.trim().length == 6) {
      if (_showNrcError) {
        setState(() => _showNrcError = false);
      }

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
          "$stateMM/$townshipMM($_selectedNrcType)${_nrcNumberController.text.trim()}";

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

    final bool isMyanmar =
        widget.values['country'] == 'Myanmar' ||
        widget.values['country'] == 'MMR';

    setState(() {
      _showDateErrors = true;

      if (isMyanmar) {
        if (_selectedNrcStateCode == null ||
            _selectedTownshipCode == null ||
            _selectedNrcType == null ||
            _nrcNumberController.text.trim().length != 6) {
          _showNrcError = true;
        } else {
          _showNrcError = false;
        }
      } else {
        _showNrcError = false;
      }
    });

    final String? passportExpiryError = FormValidators.passportExpiry(
      expiryDate: widget.values['expiryDate'],
      issuedDate: widget.values['issuedDate'],
      isMyanmar: isMyanmar,
    );

    bool isExpiryValid = passportExpiryError == null;

    final bool basicFormValid = widget.formKey.currentState!.validate();

    if (isMyanmar) {
      return basicFormValid &&
          !_showNrcError &&
          isExpiryValid &&
          widget.values['dateOfBirth'] != null &&
          widget.values['issuedDate'] != null;
    }

    return basicFormValid &&
        isExpiryValid &&
        widget.values['dateOfBirth'] != null &&
        widget.values['issuedDate'] != null;
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

    String? getExpiryErrorText() {
      if (!_showDateErrors) return null;

      return FormValidators.passportExpiry(
        expiryDate: widget.values['expiryDate'],
        issuedDate: widget.values['issuedDate'],
        isMyanmar: isMyanmar,
      );
    }

    // ─── COMPONENT EXTRACTION BLOCK ───

    final fullNameField = CustomTextField(
      label: "Full Name",
      controller: widget.controllers['fullName']!,
      maxLength: 50,
      labelWidth: lw,
      validator: (v) => FormValidators.required(v, 'Full Name'),
      onChanged: (value) {
        widget.onValueChanged('fullName', value);
      },
    );

    final genderField = CustomDropdownField(
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
      validator: (value) => value == null ? "Please select gender" : null,
      spacing: 8,
    );

    final dateOfBirthField = CustomDateField(
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
    );

    final countryField = AbsorbPointer(
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
              _showNrcError = false;
            });
          }
        },
        spacing: 8,
      ),
    );

    final emailField = CustomTextField(
      label: "Email",
      controller: widget.controllers['email']!,
      labelWidth: lw,
      maxLength: 30,
      validator: FormValidators.email,
      onChanged: (value) {
        widget.onValueChanged('email', value);
      },
    );

    final mobileField = Row(
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
                      border: Border.all(color: Colors.grey.shade300, width: 1),
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
                      borderSide: const BorderSide(color: Colors.red, width: 1),
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
    );

    final visaNumberField = CustomTextField(
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
    );

    final passportNumberField = CustomTextField(
      label: "Passport Number",
      controller: widget.controllers['passportNumber']!,
      maxLength: 20,
      labelWidth: lw,
      validator: (v) => FormValidators.required(v, 'Passport Number'),
      onChanged: (value) {
        widget.onValueChanged('passportNumber', value);
      },
    );

    final issuedDateField = CustomDateField(
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
    );

    final expiryDateField = CustomDateField(
      label: "Expiry Date",
      value: widget.values['expiryDate'],
      labelWidth: lw,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      errorText: getExpiryErrorText(),
      onPicked: (d) {
        widget.onValueChanged('expiryDate', d);
        if (!mounted) return;
        setState(() => _showDateErrors = false);
      },
    );

    final issuedCountryField = CustomDropdownField(
      label: "Issued Country",
      value: widget.values['issuedCountry'],
      hint: "Select Country",
      items: _countryNameList,
      labelWidth: lw,
      dialogWidth: 250,
      dialogHeight: 250,
      validator: (v) => FormValidators.requiredDropdown(v, 'Issued Country'),
      onChanged: (v) {
        widget.onValueChanged('issuedCountry', v);
        if (v != null) {
          try {
            final matched = _rawCountryObjects.firstWhere(
              (c) => c.countryName == v,
            );
            widget.onValueChanged('issuedCountryCode', matched.countryCode);
          } catch (e) {}
        }
      },
      spacing: 8,
    );

    final addressField = CustomTextField(
      label: "Address",
      controller: widget.controllers['address']!,
      labelWidth: lw,
      maxLength: 100,
      validator: (v) => FormValidators.required(v, 'Address'),
      onChanged: (value) {
        widget.onValueChanged('address', value);
      },
    );

    // Dynamic layout generator structured matching your handwritten sheets
    final nrcAndFatherNameSection = LayoutBuilder(
      builder: (context, constraints) {
        final bool isNrcRowDesktop = constraints.maxWidth > 550;

        Widget nrcFields() {
          final List<dynamic> stateList = nrcState?.nrcStateList ?? [];
          final List<dynamic> townshipList =
              nrcState?.availableNrcTownships ?? [];
          final int? currentProviderStateId = nrcState?.selectedNrcStateId;
          final int? activeStateId =
              stateList.any((st) => st.id == currentProviderStateId)
              ? currentProviderStateId
              : null;

          final numberField = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: _nrcNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\u1040-\u1049]')),
                LengthLimitingTextInputFormatter(6),
              ],
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: "၁၂၃၄၅၆",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NrcSelectorWidget(
                isDesktop: isNrcRowDesktop,
                selectedNrcStateCode: _selectedNrcStateCode,
                selectedTownshipCode: _selectedTownshipCode,
                selectedNrcType: _selectedNrcType,
                numberField: numberField,
                hasError: _showNrcError,
                stateList: stateList,
                townshipList: townshipList,
                nrcTypes: _nrcTypes,
                activeStateId: activeStateId,
                onStateChanged: (id, idCode) {
                  ref.read(nrcProvider.notifier).selectNrcState(id);
                  if (!mounted) return;
                  setState(() {
                    _selectedNrcStateCode = idCode;
                    _selectedTownshipCode = null;
                  });
                  widget.onValueChanged('nrcStateCode', idCode);
                  widget.onValueChanged('nrcTownshipCode', null);
                  _updateNrcControllerValue();
                },
                onTownshipChanged: (v) {
                  if (!mounted) return;
                  setState(() => _selectedTownshipCode = v);
                  widget.onValueChanged('nrcTownshipCode', v);
                  _updateNrcControllerValue();
                },
                onTypeChanged: (v) {
                  if (!mounted) return;
                  setState(() => _selectedNrcType = v);
                  widget.onValueChanged('nrcTypeCode', v);
                  _updateNrcControllerValue();
                },
              ),
              if (_showNrcError)
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    'Please complete all Myanmar NRC fields properly (6 digits)',
                    style: TextStyle(color: Colors.red, fontSize: 11),
                  ),
                ),
            ],
          );
        }

        Widget fatherNameWidget = CustomTextField(
          label: "Father Name",
          maxLength: 50,
          controller: widget.controllers['fatherName']!,
          labelWidth: lw,
          validator: (v) => FormValidators.fatherName(v, isMyanmar: isMyanmar),
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
              Expanded(child: fatherNameWidget),
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
              fatherNameWidget,
            ],
          );
        }
      },
    );

    // ─── CONDITIONAL COMPOSITION MATRIX ───
    List<Widget> formLayout;

    if (isMyanmar) {
      // 1:1 Match with "For Native" Layout Checklist
      formLayout = [
        pair(fullNameField, genderField),
        const SizedBox(height: 20),
        pair(dateOfBirthField, countryField),
        const SizedBox(height: 20),
        nrcAndFatherNameSection,
        const SizedBox(height: 20),
        pair(emailField, mobileField),
        const SizedBox(height: 20),
        pair(passportNumberField, issuedCountryField),
        const SizedBox(height: 20),
        pair(issuedDateField, expiryDateField),
        const SizedBox(height: 20),
        isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: addressField),
                  const SizedBox(
                    width: 40,
                  ), // Matches the spacing inside your pair() method
                  const Expanded(
                    child: SizedBox.shrink(),
                  ), // Invisible right-column placeholder
                ],
              )
            : addressField, // Keeps standard layout for mobile screens

        const SizedBox(height: 28),
        widget.actionButtons,
      ];
    } else {
      // 1:1 Match with "For Foreigner" Layout Checklist
      formLayout = [
        pair(fullNameField, genderField),
        const SizedBox(height: 20),
        pair(dateOfBirthField, countryField),
        const SizedBox(height: 20),
        pair(emailField, mobileField),
        const SizedBox(height: 20),
        pair(passportNumberField, issuedCountryField),
        const SizedBox(height: 20),
        pair(issuedDateField, expiryDateField),
        const SizedBox(height: 20),
        pair(addressField, visaNumberField), // Paired bottom row layout
        const SizedBox(height: 28),
        widget.actionButtons,
      ];
    }

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: formLayout,
      ),
    );
  }
}
