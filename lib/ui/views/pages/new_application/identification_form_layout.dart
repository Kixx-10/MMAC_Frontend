// lib/ui/views/pages/new_application/identification_form_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/core/constants/api_endpoints.dart';
import 'package:mmac/data/controllers/country_provider.dart';
import 'package:mmac/data/controllers/nrc_provider.dart';
import 'package:mmac/data/models/country_model.dart';
import 'package:mmac/ui/views/pages/new_application/widget/nrc_selector_widget.dart';
import 'package:mmac/utils/form_validators.dart';
import 'package:mmac/utils/country_codes.dart';
import 'package:mmac/utils/upper_case_text_formatter.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_date_field.dart';
import '../../widgets/custom_dropdown_field.dart';
import '../../widgets/mobile_code_search_dialog.dart';

abstract class IdentificationFormLayoutInterface {
  bool validate();
  List<String> getValidationErrors();
}

class IdentificationFormLayout extends ConsumerStatefulWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, dynamic> values;
  final Widget actionButtons;
  final Function(String, dynamic) onValueChanged;
  final GlobalKey<FormState> formKey;
  final void Function(IdentificationFormLayoutInterface) onReady;
  final VoidCallback onBackPressed;
  final bool isUpdateMode;

  const IdentificationFormLayout({
    super.key,
    required this.controllers,
    required this.values,
    required this.actionButtons,
    required this.onValueChanged,
    required this.formKey,
    required this.onReady,
    required this.onBackPressed,
    required this.isUpdateMode,
  });

  @override
  ConsumerState<IdentificationFormLayout> createState() =>
      _IdentificationFormLayoutState();
}

class _IdentificationFormLayoutState
    extends ConsumerState<IdentificationFormLayout>
    implements IdentificationFormLayoutInterface {
  // --- State Variables ---
  bool _showDateErrors = false;
  bool _showNrcError = false;
  bool _isLoading = true;

  List<String> _countryNameList = [];       
  List<String> _passportCountryNameList = []; 
  List<CountryModel> _rawCountryObjects = [];

  // --- NRC State Variables ---
  String? _selectedNrcStateCode;
  String? _selectedTownshipCode;
  String? _selectedNrcType;

  final TextEditingController _nrcNumberController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final List<Map<String, String>> _nrcTypes = [
    {"code": "နိုင်", "label": "နိုင်"},
    {"code": "ဧည့်", "label": "ဧည့်"},
    {"code": "ပြု", "label": "ပြု"},
  ];

  // --- Mobile Country Codes State ---
  List<Map<String, String>> _countryCodes = [];
  final TextEditingController _mobileNumberController = TextEditingController();

  // LIFECYCLE & INITIALIZATION
  @override
  void initState() {
    super.initState();
    widget.onReady(this);

    final fullName = widget.controllers['fullName']?.text.trim() ?? '';
    final nameParts = fullName.split(' ');
    if (nameParts.length > 1) {
      _lastNameController.text = nameParts.first;
      _firstNameController.text = nameParts.sublist(1).join(' ');
    } else {
      _firstNameController.text = fullName;
    }

    _selectedNrcStateCode = widget.values['nrcStateCode'];
    _selectedTownshipCode = widget.values['nrcTownshipCode'];
    _selectedNrcType = widget.values['nrcTypeCode'];
    _nrcNumberController.text = widget.values['nrcRawNumber'] ?? '';

    _countryCodes = CountryCodeData.codes;
    _initializeMobileNumber();
    _fetchAndResolveCountries();
  }

  @override
  void dispose() {
    _nrcNumberController.dispose();
    _mobileNumberController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  // DATA RESOLUTION & MUTATION METHODS
  void _onNameChanged() {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    final full = "$first $last".trim();
    widget.controllers['fullName']?.text = full;
    widget.onValueChanged('fullName', full);
  }

  void _initializeMobileNumber() {
    final String existingMobile = widget.controllers['mobile']?.text ?? '';
    String? currentCode = widget.values['mobileCode'];

    // 1. Auto-extract Country dial code if missing but phone is populated
    if (currentCode == null && existingMobile.isNotEmpty) {
      for (var codeObj in _countryCodes) {
        final code = codeObj['code'];
        if (code != null && existingMobile.startsWith(code)) {
          currentCode = code;
          Future.microtask(() {
            if (mounted) widget.onValueChanged('mobileCode', code);
          });
          break;
        }
      }
    }

    // 2. Waterfall Step: Auto-assign dial code if Country is pre-selected (e.g. Myanmar Residency)
    if (currentCode == null && widget.values['country'] != null) {
      try {
        final matchedPhone = _countryCodes.firstWhere(
          (c) =>
              c['country']?.toLowerCase() ==
              widget.values['country'].toString().toLowerCase(),
        );
        final String? code = matchedPhone['code'];
        if (code != null) {
          currentCode = code;
          Future.microtask(() {
            if (mounted) {
              widget.onValueChanged('mobileCode', code);
              _updateMobileControllerValue();
            }
          });
        }
      } catch (_) {}
    }

    if (existingMobile.isNotEmpty &&
        currentCode != null &&
        existingMobile.startsWith(currentCode)) {
      _mobileNumberController.text = existingMobile.substring(
        currentCode.length,
      );
    }
  }

  void _fetchAndResolveCountries() {
    Future.microtask(() async {
      try {
        final nationalityState = await ref.read(nationalityProvider(ApiEndpoints.getNationalityCountry).future);
        final passportState = await ref.read(passportCountryProvider(ApiEndpoints.getPassportIssuedCountry).future);
        if (mounted) {
          setState(() {
            _rawCountryObjects.clear();
          _rawCountryObjects.addAll(nationalityState.countryList);
        
          _countryNameList = nationalityState.countryList.map((c) => c.countryName).toList();
          
          _passportCountryNameList = passportState.countryList.map((c) => c.countryName).toList();

          _resolveCountryCodeToName('countryCode', 'country');
          _resolveCountryCodeToName('issuedCountryCode', 'issuedCountry');

            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Failed to load countries from API: $e");
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
          debugPrint("Failed to restore NRC provider state: $e");
        }
      }
    });
  }

  void _resolveCountryCodeToName(String codeKey, String nameKey) {
    final existingCode = widget.values[codeKey];
    if (existingCode != null && widget.values[nameKey] == null) {
      try {
        final matched = _rawCountryObjects.firstWhere(
          (c) => c.countryCode == existingCode,
        );
        widget.onValueChanged(nameKey, matched.countryName);
      } catch (_) {
        // Safe fallback if mapping fails
      }
    }
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
        stateMM = stateList
            .firstWhere((st) => st.idCode == _selectedNrcStateCode)
            .codeMM;
      } catch (_) {}

      try {
        townshipMM = townshipList
            .firstWhere((ts) => ts.idCode == _selectedTownshipCode)
            .codeMM;
      } catch (_) {}

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
        _showNrcError =
            (_selectedNrcStateCode == null ||
            _selectedTownshipCode == null ||
            _selectedNrcType == null ||
            _nrcNumberController.text.trim().length != 6);
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
  List<String> getValidationErrors() {
    List<String> errors = [];
    final bool isMyanmar =
        widget.values['country'] == 'Myanmar' ||
        widget.values['country'] == 'MMR';

    // Text Fields
    if (widget.controllers['fullName']?.text.trim().isEmpty ?? true) {
      errors.add("Full Name is missing.");
    }
    if (widget.controllers['email']?.text.trim().isEmpty ?? true) {
      errors.add("Email is missing.");
    } else if (FormValidators.email(widget.controllers['email']!.text.trim()) != null) {
      errors.add("Email is invalid.");
    }
    if (widget.controllers['mobile']?.text.trim().isEmpty ?? true) {
      errors.add("Contact number is missing.");
    }
    
    // Dropdowns
    if (widget.values['gender'] == null) errors.add("Gender is missing.");
    if (widget.values['dateOfBirth'] == null) errors.add("Date of Birth is missing.");
    if (widget.values['placeOfBirth'] == null) errors.add("Country/Place of birth is missing.");

    // NRC (if Myanmar)
    if (isMyanmar) {
      if (_selectedNrcStateCode == null ||
          _selectedTownshipCode == null ||
          _selectedNrcType == null ||
          _nrcNumberController.text.trim().length != 6) {
        errors.add("NRC information is incomplete or invalid.");
      }
    }

    // Passport info
    if (widget.controllers['passportNumber']?.text.trim().isEmpty ?? true) {
      errors.add("Passport Number is missing.");
    }
    if (widget.values['issuedCountry'] == null) {
      errors.add("Issued Country is missing.");
    }
    if (widget.values['issuedDate'] == null) {
      errors.add("Passport Issue Date is missing.");
    }
    if (widget.values['expiryDate'] == null) {
      errors.add("Passport Expiry Date is missing.");
    } else {
      final String? passportExpiryError = FormValidators.passportExpiry(
        expiryDate: widget.values['expiryDate'],
        issuedDate: widget.values['issuedDate'],
        isMyanmar: isMyanmar,
      );
      if (passportExpiryError != null) {
        errors.add(passportExpiryError);
      }
    }

    if (widget.controllers['address']?.text.trim().isEmpty ?? true) {
      errors.add("Address is missing.");
    }
    if (widget.controllers['occupation']?.text.trim().isEmpty ?? true) {
      errors.add("Occupation is missing.");
    }

    return errors;
  }

  // WIDGET BUILDERS
  Widget _buildPair(Widget a, Widget b, bool isDesktop) {
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

  Widget _buildFullNameField(double lw) {
    return CustomTextField(
      label: "Full Name",
      controller: widget.controllers['fullName']!,
      filter: [
        FilteringTextInputFormatter.singleLineFormatter,
        UpperCaseTextFormatter(),
        LengthLimitingTextInputFormatter(50),
      ],
      maxLength: 50,
      labelWidth: lw,
      readonly: widget.isUpdateMode,
      validator: (v) => FormValidators.required(v, 'Full Name'),
      onChanged: (value) => widget.onValueChanged('fullName', value),
    );
  }

  Widget _buildFirstNameField(double lw) {
    return CustomTextField(
      label: "First name * (in passport)",
      controller: _firstNameController,
      filter: [
        FilteringTextInputFormatter.singleLineFormatter,
        UpperCaseTextFormatter(),
        LengthLimitingTextInputFormatter(25),
      ],
      maxLength: 25,
      labelWidth: lw,
      readonly: widget.isUpdateMode,
      validator: (v) => FormValidators.required(v, 'First Name'),
      onChanged: (value) => _onNameChanged(),
    );
  }

  Widget _buildLastNameField(double lw) {
    return CustomTextField(
      label: "Last name (in passport)",
      controller: _lastNameController,
      filter: [
        FilteringTextInputFormatter.singleLineFormatter,
        UpperCaseTextFormatter(),
        LengthLimitingTextInputFormatter(25),
      ],
      maxLength: 25,
      labelWidth: lw,
      readonly: widget.isUpdateMode,
      validator: (v) => FormValidators.required(v, 'Last Name'),
      onChanged: (value) => _onNameChanged(),
    );
  }

  Widget _buildUidField(double lw) {
    return CustomTextField(
      label: "UID",
      hintText: "10 max (optional)",
      controller: widget.controllers['uid']!,
      maxLength: 10,
      labelWidth: lw,
      isRequired: false,
      readonly: widget.isUpdateMode,
      onChanged: (value) => widget.onValueChanged('uid', value),
    );
  }

  Widget _buildOccupationField(double lw) {
    return CustomTextField(
      label: "Occupation",
      controller: widget.controllers['occupation']!,
      maxLength: 50,
      labelWidth: lw,
      readonly: widget.isUpdateMode,
      validator: (v) => FormValidators.required(v, 'Occupation'),
      onChanged: (value) => widget.onValueChanged('occupation', value),
    );
  }

  Widget _buildPlaceOfBirthField(double lw, List<String> availableCountry) {
    return CustomDropdownField(
      label: "Country/ Place of birth",
      hint: "Select Country",
      labelWidth: lw,
      dialogWidth: 250,
      dialogHeight: 250,
      value: widget.values['placeOfBirth'],
      items: _countryNameList,
      validator: (v) => FormValidators.requiredDropdown(v, 'Place of birth'),
      onChanged: (value) => widget.onValueChanged('placeOfBirth', value),
      spacing: 8,
    );
  }

  Widget _buildGenderField(double lw) {
    return FormField<String>(
      initialValue: widget.values['gender'],
      validator: (value) => value == null ? "Please select gender" : null,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RichText(
                text: const TextSpan(
                  text: "Gender",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
            Row(
              children: [
                _buildRadioButton("Male", state),
                const SizedBox(width: 24),
                _buildRadioButton("Female", state),
              ],
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRadioButton(String title, FormFieldState<String> state) {
    return InkWell(
      onTap: () {
        state.didChange(title);
        widget.onValueChanged('gender', title);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: title,
            groupValue: state.value,
            onChanged: (value) {
              state.didChange(value);
              widget.onValueChanged('gender', value);
            },
            activeColor: Colors.blue,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildDateOfBirthField(double lw) {
    return CustomDateField(
      label: "Date of Birth",
      value: widget.values['dateOfBirth'],
      labelWidth: lw,
      readOnly: widget.isUpdateMode,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      errorText: _showDateErrors && widget.values['dateOfBirth'] == null
          ? 'Date of Birth is required'
          : null,
      onPicked: (d) {
        widget.onValueChanged('dateOfBirth', d);
        final DateTime? issued = widget.values['issuedDate'];
        if (issued != null && d != null && d.isAfter(issued)) {
          widget.onValueChanged('issuedDate', null);
        }
        if (mounted) setState(() => _showDateErrors = false);
      },
    );
  }

  Widget _buildCountryField(
    double lw,
    bool isMyanmar,
    List<String> availableCountry,
  ) {
    return AbsorbPointer(
      absorbing: isMyanmar,
      child: CustomDropdownField(
        label: "Nationality",
        value: widget.values['country'],
        hint: "Select Nationality",
        readonly: widget.isUpdateMode || isMyanmar,
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
            } catch (_) {}

            try {
              final matchedPhone = _countryCodes.firstWhere(
                (c) => c['country']?.toLowerCase() == v.toLowerCase(),
              );
              final String? code = matchedPhone['code'];
              if (code != null) {
                widget.onValueChanged('mobileCode', code);
                _updateMobileControllerValue();
                if (mounted) setState(() {});
              }
            } catch (_) {}
          }
          if (v != 'Myanmar' && v != 'MMR') {
            widget.controllers['nrc']?.clear();
            widget.controllers['fatherName']?.clear();
            if (mounted) {
              setState(() {
                _selectedNrcStateCode = null;
                _selectedTownshipCode = null;
                _selectedNrcType = null;
                _nrcNumberController.clear();
                _showNrcError = false;
              });
            }
          }
        },
        spacing: 8,
      ),
    );
  }

  Widget _buildFatherNameField(double lw) {
    final isMyanmar =
        widget.values['country'] == 'Myanmar' ||
        widget.values['country'] == 'MMR';
    return CustomTextField(
      label: "Father Name",
      filter: [UpperCaseTextFormatter()],
      maxLength: 50,
      controller: widget.controllers['fatherName']!,
      labelWidth: lw,
      validator: (v) => FormValidators.fatherName(v, isMyanmar: isMyanmar),
      onChanged: (value) => widget.onValueChanged('fatherName', value),
    );
  }

  Widget _buildEmailField(double lw, bool isMyanmar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: isMyanmar ? "Personal E-mail" : "Email",
          controller: widget.controllers['email']!,
          labelWidth: lw,
          maxLength: 30,
          readonly: widget.isUpdateMode && isMyanmar,
          validator: FormValidators.email,
          onChanged: (value) => widget.onValueChanged('email', value),
          suffixIcon: const HoverInfoIcon(
            message:
                "Upon successful submission of your Myanmar e-Arrival form, a confirmation email containing your QR code PDF will be sent automatically to the email address provided. Please ensure that your email address is active and spelled correctly before submitting. If you do not receive the email within a few minutes, please check your spam or junk folder. (Note: Email addresses are not case-sensitive).",
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 4,
            left: MediaQuery.of(context).size.width < 500 ? 0 : lw + 8,
          ),
          child: const Text(
            "Active Email needed to reply",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileField(double lw, bool isMobileWidth) {
    final mobileLabel = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: RichText(
          text: const TextSpan(
            text: "Contact",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
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
    );

    final mobileInputs = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: InkWell(
            onTap: () {
              showDialog<String>(
                context: context,
                builder: (context) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Colors.white,
                      onPrimary: Colors.grey,
                      onSurface: Colors.black87,
                    ),
                  ),
                  child: MobileCodeSearchDialog(
                    countryCodes: _countryCodes,
                    selectedValue: widget.values['mobileCode'],
                  ),
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
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: _mobileNumberController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(20),
            ],
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter phone number",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              errorStyle: const TextStyle(color: Colors.red),
            ),
            onChanged: (_) => _updateMobileControllerValue(),
            validator: (v) {
              final String? code = widget.values['mobileCode'];
              final String number = _mobileNumberController.text;
              if (code == null) return 'Please select country code';
              if (number.isEmpty) return 'Mobile Number is required';
              return null;
            },
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [mobileLabel, mobileInputs],
    );
  }

  Widget _buildVisaNumberField(double lw) {
    return CustomTextField(
      label: "Visa Number",
      controller: widget.controllers['visaNumber']!,
      maxLength: 50,
      filter: [
        FilteringTextInputFormatter.singleLineFormatter,
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
      ],
      labelWidth: lw,
      isRequired: false,
      validator: (v) => null,
      onChanged: (v) {
        widget.onValueChanged('visaNumber', v.trim().isEmpty ? null : v);
      },
    );
  }

  Widget _buildPassportNumberField(double lw, bool isMyanmar) {
    return CustomTextField(
      label: "Passport Number",
      controller: widget.controllers['passportNumber']!,
      maxLength: 20,
      labelWidth: lw,
      filter: [
        FilteringTextInputFormatter.singleLineFormatter,
        LengthLimitingTextInputFormatter(20),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
      ],
      readonly: (widget.isUpdateMode && !isMyanmar),
      validator: (v) => FormValidators.required(v, 'Passport Number'),
      onChanged: (value) => widget.onValueChanged('passportNumber', value),
    );
  }

  Widget _buildIssuedDateField(double lw) {
    final DateTime today = DateTime.now();
    final DateTime? dob = widget.values['dateOfBirth'];
    final DateTime? expiry = widget.values['expiryDate'];

    DateTime maxIssuedDate = today;
    if (expiry != null && expiry.isBefore(today)) {
      maxIssuedDate = expiry;
    }
    DateTime minIssuedDate = dob ?? DateTime(1900);

    return CustomDateField(
      label: "Passport Issued Date",
      value: widget.values['issuedDate'],
      labelWidth: lw,
      firstDate: minIssuedDate,
      lastDate: maxIssuedDate,
      errorText: _showDateErrors && widget.values['issuedDate'] == null
          ? 'Issued Date is required'
          : null,
      onPicked: (d) {
        widget.onValueChanged('issuedDate', d);
        if (expiry != null && d != null && expiry.isBefore(d)) {
          widget.onValueChanged('expiryDate', null);
        }
        if (mounted) setState(() => _showDateErrors = false);
      },
    );
  }

  Widget _buildExpiryDateField(double lw, bool isMyanmar) {
    final DateTime? issued = widget.values['issuedDate'];
    DateTime minExpiryDate = issued ?? DateTime(1900);

    String? getExpiryErrorText() {
      if (!_showDateErrors) return null;
      return FormValidators.passportExpiry(
        expiryDate: widget.values['expiryDate'],
        issuedDate: widget.values['issuedDate'],
        isMyanmar: isMyanmar,
      );
    }

    return CustomDateField(
      label: "Passport Expiry Date",
      value: widget.values['expiryDate'],
      labelWidth: lw,
      firstDate: minExpiryDate,
      lastDate: DateTime(2100),
      readOnly: (widget.isUpdateMode && !isMyanmar),
      errorText: getExpiryErrorText(),
      onPicked: (d) {
        widget.onValueChanged('expiryDate', d);
        if (issued != null && d != null && d.isBefore(issued)) {
          widget.onValueChanged('issuedDate', null);
        }
        if (mounted) setState(() => _showDateErrors = false);
      },
    );
  }

  Widget _buildIssuedCountryField(double lw) {
    return CustomDropdownField(
      label: "Passport Issued Country",
      value: widget.values['issuedCountry'],
      hint: "Select Country",
      items: _passportCountryNameList,
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
          } catch (_) {}
        }
      },
      spacing: 8,
    );
  }

  Widget _buildAddressField(double lw) {
    return CustomTextField(
      label: "Place of Residence",
      controller: widget.controllers['address']!,
      labelWidth: lw,
      filter: [
        LengthLimitingTextInputFormatter(100),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
      ],
      maxLength: 100,
      validator: (v) => FormValidators.required(v, 'Address'),
      onChanged: (value) => widget.onValueChanged('address', value),
    );
  }

  Widget _buildNrcField(
    double lw,
    bool isDesktop,
    bool isMobileWidth,
    bool isMyanmar,
  ) {
    final nrcAsync = ref.watch(nrcProvider);
    final nrcState = nrcAsync.valueOrNull;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNrcRowDesktop = MediaQuery.of(context).size.width > 499;

        Widget nrcFields() {
          final List<dynamic> stateList = nrcState?.nrcStateList ?? [];
          final List<dynamic> townshipList = _selectedNrcStateCode != null
              ? (nrcState?.availableNrcTownships ?? [])
              : [];
          final int? currentProviderStateId = nrcState?.selectedNrcStateId;
          final int? activeStateId =
              (_selectedNrcStateCode != null &&
                  stateList.any((st) => st.id == currentProviderStateId))
              ? currentProviderStateId
              : null;

          final numberField = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: _nrcNumberController,
              keyboardType: TextInputType.number,
              readOnly: widget.isUpdateMode && isMyanmar,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\u1040-\u1049]')),
                LengthLimitingTextInputFormatter(6),
              ],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: (widget.isUpdateMode && isMyanmar)
                    ? Colors.grey.shade500
                    : Colors.black87,
              ),
              decoration: InputDecoration(
                fillColor: Colors.grey.shade200,
                filled: widget.isUpdateMode && isMyanmar,
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
                readOnly: (widget.isUpdateMode && isMyanmar),
                selectedNrcStateCode:
                    stateList.any((s) => s.idCode == _selectedNrcStateCode)
                    ? _selectedNrcStateCode
                    : null,
                selectedTownshipCode:
                    townshipList.any((t) => t.idCode == _selectedTownshipCode)
                    ? _selectedTownshipCode
                    : null,
                selectedNrcType: _selectedNrcType,
                numberField: numberField,
                hasError: _showNrcError,
                stateList: stateList,
                townshipList: townshipList,
                nrcTypes: _nrcTypes,
                activeStateId: activeStateId,
                onStateChanged: (id, idCode) {
                  ref.read(nrcProvider.notifier).selectNrcState(id);
                  if (mounted) {
                    setState(() {
                      _selectedNrcStateCode = idCode;
                      _selectedTownshipCode = null;
                    });
                  }
                  widget.onValueChanged('nrcStateCode', idCode);
                  widget.onValueChanged('nrcTownshipCode', null);
                  _updateNrcControllerValue();
                },
                onTownshipChanged: (v) {
                  if (mounted) setState(() => _selectedTownshipCode = v);
                  widget.onValueChanged('nrcTownshipCode', v);
                  _updateNrcControllerValue();
                },
                onTypeChanged: (v) {
                  if (mounted) setState(() => _selectedNrcType = v);
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

        final nrcLabel = Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: RichText(
              text: const TextSpan(
                text: "NRC",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [nrcLabel, nrcFields()],
        );
      },
    );
  }

  Widget _buildActionButtonsRow() {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        widget.actionButtons,
        ElevatedButton(
          onPressed: widget.onBackPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Back',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              height: 30,
              width: 5,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(1, 156, 244, 1),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }

  // MAIN BUILD METHOD
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

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 850;
    final bool isMobileWidth = screenWidth < 500;

    final bool isMyanmar =
        widget.values['country'] == 'Myanmar' ||
        widget.values['country'] == 'MMR';

    final List<String> availableCountry = isMyanmar
        ? _countryNameList
        : _countryNameList.where((c) => c != 'Myanmar' && c != 'MMR').toList();

    const double lw = 140;
    List<Widget> formLayout;

    if (isMyanmar) {
      formLayout = [
        _buildSectionHeader("Personal Information"),
        _buildPair(
          _buildLastNameField(lw),
          _buildFirstNameField(lw),
          isDesktop,
        ),
        const SizedBox(height: 20),
        _buildPair(_buildGenderField(lw), _buildFatherNameField(lw), isDesktop),
        const SizedBox(height: 20),
        _buildPair(
          _buildNrcField(lw, isDesktop, isMobileWidth, isMyanmar),
          _buildUidField(lw),
          isDesktop,
        ),
        const SizedBox(height: 20),
        _buildPair(
          _buildDateOfBirthField(lw),
          _buildCountryField(lw, isMyanmar, availableCountry),
          isDesktop,
        ),
        const SizedBox(height: 20),
        isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildOccupationField(lw)),
                  const SizedBox(width: 40),
                  const Expanded(child: SizedBox.shrink()),
                ],
              )
            : _buildOccupationField(lw),
        const SizedBox(height: 24),

        _buildSectionHeader("Contact and location"),
        _buildPair(
          _buildPlaceOfBirthField(lw, availableCountry),
          _buildAddressField(lw),
          isDesktop,
        ),
        const SizedBox(height: 20),
        _buildPair(
          _buildMobileField(lw, isMobileWidth),
          _buildEmailField(lw, isMyanmar),
          isDesktop,
        ),
        const SizedBox(height: 24),

        _buildSectionHeader("Passport Information"),
        _buildPair(
          _buildPassportNumberField(lw, isMyanmar),
          _buildIssuedCountryField(lw),
          isDesktop,
        ),
        const SizedBox(height: 20),
        _buildPair(
          _buildIssuedDateField(lw),
          _buildExpiryDateField(lw, isMyanmar),
          isDesktop,
        ),
      ];
    } else {
      formLayout = [
        _buildSectionHeader("Personal Information"),
        _buildPair(
          _buildLastNameField(lw),
          _buildFirstNameField(lw),
          isDesktop,
        ),
        const SizedBox(height: 20),
        _buildPair(_buildGenderField(lw), _buildVisaNumberField(lw), isDesktop),
        const SizedBox(height: 20),
        _buildPair(
          _buildDateOfBirthField(lw),
          _buildCountryField(lw, isMyanmar, availableCountry),
          isDesktop,
        ),
        const SizedBox(height: 20),
        isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildOccupationField(lw)),
                  const SizedBox(width: 40),
                  const Expanded(child: SizedBox.shrink()),
                ],
              )
            : _buildOccupationField(lw),
        const SizedBox(height: 24),

        _buildSectionHeader("Contact and location"),
        _buildPair(
          _buildPlaceOfBirthField(lw, availableCountry),
          _buildAddressField(lw),
          isDesktop,
        ),
        const SizedBox(height: 20),
        _buildPair(
          _buildMobileField(lw, isMobileWidth),
          _buildEmailField(lw, isMyanmar),
          isDesktop,
        ),
        const SizedBox(height: 24),

        _buildSectionHeader("Passport Information"),
        _buildPair(
          _buildPassportNumberField(lw, isMyanmar),
          _buildIssuedCountryField(lw),
          isDesktop,
        ),
        const SizedBox(height: 20),
        _buildPair(
          _buildIssuedDateField(lw),
          _buildExpiryDateField(lw, isMyanmar),
          isDesktop,
        ),
      ];
    }

    formLayout.addAll([const SizedBox(height: 28), _buildActionButtonsRow()]);

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: formLayout,
      ),
    );
  }
}

class HoverInfoIcon extends StatefulWidget {
  final String message;
  const HoverInfoIcon({super.key, required this.message});

  @override
  State<HoverInfoIcon> createState() => _HoverInfoIconState();
}

class _HoverInfoIconState extends State<HoverInfoIcon> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isHovered = false;

  void _showOverlay() {
    if (_overlayEntry != null) return;
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        // Adjust for mobile vs desktop width
        final screenWidth = MediaQuery.of(context).size.width;
        final bool isMobile = screenWidth < 500;
        return Positioned(
          width: isMobile ? screenWidth * 0.8 : 350,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            // Anchor the popup's bottom edge to the target's top edge
            targetAnchor: Alignment.topCenter,
            followerAnchor: isMobile
                ? Alignment.bottomCenter
                : Alignment.bottomCenter,
            offset: isMobile ? const Offset(0, -24) : const Offset(0, -8),
            child: Material(
              elevation: 4,
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _showOverlay();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _hideOverlay();
        },
        child: GestureDetector(
          onTap: () {
            if (_overlayEntry == null) {
              _showOverlay();
              Future.delayed(const Duration(seconds: 4), () {
                if (mounted) _hideOverlay();
              });
            } else {
              _hideOverlay();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Icon(
              Icons.info_outline,
              color: _isHovered ? Colors.blue.shade700 : Colors.blue,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
