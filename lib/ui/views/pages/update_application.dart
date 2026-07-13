// lib/ui/views/pages/update_application/update_application_page.dart

// ignore_for_file: curly_braces_in_flow_control_structures, prefer_function_declarations_over_variables, deprecated_member_use, unused_field, empty_catches

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/core/constants/api_endpoints.dart';
import 'package:mmac/core/constants/app_fonts.dart';
import 'package:mmac/data/models/search_request_model.dart';
import 'package:mmac/data/models/submit_request_model.dart';
import 'package:mmac/data/controllers/update_application_provider.dart';
import 'package:mmac/data/controllers/country_provider.dart';
import 'package:mmac/data/controllers/nrc_provider.dart';
import 'package:mmac/ui/views/pages/new_application/widget/nrc_selector_widget.dart';

class UpdateApplication extends ConsumerStatefulWidget {
  final String? initialCountry;
  final Function(SubmitRequestModel) onApplicationFetched;
  final VoidCallback onBackPressed;
  final VoidCallback? onStartNewApplication;

  const UpdateApplication({
    super.key,
    this.initialCountry,
    required this.onBackPressed,
    required this.onApplicationFetched,
    this.onStartNewApplication,
  });

  @override
  ConsumerState<UpdateApplication> createState() => _UpdateApplicationState();
}

class _UpdateApplicationState extends ConsumerState<UpdateApplication> {
  bool _isLoadingCountries = true;
  final List<dynamic> _rawCountryObjects = [];
  final GlobalKey<FormState> _searchFormKey = GlobalKey<FormState>();

  // --- NRC Variables ---
  String? _selectedNrcStateCode;
  String? _selectedTownshipCode;
  String? _selectedNrcType;
  final TextEditingController _nrcNumberController = TextEditingController();

  final Map<String, TextEditingController> _searchControllers = {
    'qrReference': TextEditingController(),
    'passportNumber': TextEditingController(),
    'nationalityCode': TextEditingController(),
    'dob': TextEditingController(),
    'passportExpiry': TextEditingController(),
    'arrivalDate': TextEditingController(),
  };

  final List<Map<String, String>> _nrcTypes = [
    {"code": "နိုင်", "label": "နိုင်"},
    {"code": "ဧည့်", "label": "ဧည့်"},
    {"code": "ပြု", "label": "ပြု"},
  ];

  int _arrivalDateOffset = -1;

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  @override
  void dispose() {
    _searchControllers.forEach((_, controller) => controller.dispose());
    _nrcNumberController.dispose();
    super.dispose();
  }

  String _text(String key) => _searchControllers[key]?.text.trim() ?? '';

  Future<void> _fetchCountries() async {
    Future.microtask(() async {
      try {
        // ignore: non_constant_identifier_names
        final ICAOMemberState = await ref.read(
          ICAOMemberCountriesProvider(
            ApiEndpoints.getIcaoMemberCountries,
          ).future,
        );
        // ignore: unused_local_variable
        final allCountriesState = await ref.read(
          allCountriesProvider(ApiEndpoints.getAllCountries).future,
        );
        if (mounted) {
          setState(() {
            _rawCountryObjects.clear();
            _rawCountryObjects.addAll(ICAOMemberState.countryList);
            _isLoadingCountries = false;
          });
        }
      } catch (e) {
        debugPrint("❌ Failed to load countries: $e");
        if (mounted) setState(() => _isLoadingCountries = false);
      }
    });
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.lightBlue.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  String _generateFullNrcString() {
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
        stateMM = stateList
            .firstWhere((st) => st.idCode == _selectedNrcStateCode)
            .codeMM;
      } catch (e) {}

      try {
        townshipMM = townshipList
            .firstWhere((ts) => ts.idCode == _selectedTownshipCode)
            .codeMM;
      } catch (e) {}

      return "$stateMM/$townshipMM($_selectedNrcType)${_nrcNumberController.text}";
    }
    return "";
  }

  void _handleFindApplication(bool isMyanmar) {
    if (!(_searchFormKey.currentState?.validate() ?? false)) return;

    // 🎯 1. Error Interceptor (Handles the "User Not Found" issue)
    final Function(String) onErrorCallback = (errorMessage) {
      String displayTitle = "Verification Failed";
      String displayMessage = errorMessage;

      // If backend returns 'not found', it usually means the application was already processed.
      if (errorMessage.toLowerCase().contains("not found")) {
        displayTitle = "Application Uneditable";
        displayMessage =
            "We could not find a pending application with these details. The application may have already been Approved or Rejected, or the details are incorrect. \n\nApproved applications cannot be modified.";
      }

      _showInfoDialog(displayTitle, displayMessage, isError: true);
    };

    // Success Interceptor
    final VoidCallback onSuccessCallback = () {
      Future.microtask(() {
        final fetchedData = ref.read(updateApplicationProvider).value;
        if (fetchedData != null) {
          // Optional Safety Guard: If your SubmitRequestModel has a status field, check it here!
          // final status = fetchedData.status?.toLowerCase() ?? 'pending';
          // if (status == 'approved' || status == 'rejected') {
          //   _showInfoDialog("Status: ${fetchedData.status}", "This application has already been processed and cannot be edited.", isError: false);
          //   return;
          // }

          widget.onApplicationFetched(fetchedData);
        }
      });
    };

    // Dispatch appropriate API Request
    if (isMyanmar) {
      String fullNrc = _generateFullNrcString();
      if (fullNrc.isEmpty) {
        _showInfoDialog(
          "Incomplete Data",
          "Please select all NRC fields carefully.",
          isError: true,
        );
        return;
      }

      final nativeModel = NativeSearchRequestModel(
        qrReference: _text('qrReference'),
        residencyType: "Myanmar",
        nrc: fullNrc,
        arrivalDate: DateTime.parse(_text('arrivalDate')),
      );

      ref
          .read(updateApplicationProvider.notifier)
          .findNativeApplication(
            searchRequest: nativeModel,
            onError: onErrorCallback,
            onSuccess: onSuccessCallback,
          );
    } else {
      final foreignerModel = ForeignerSearchRequestModel(
        qrReference: _text('qrReference'),
        residencyType: "Foreigner",
        passportNumber: _text('passportNumber'),
        nationalityCode: _text('nationalityCode'),
        dob: _text('dob'),
        passportExpiry: _text('passportExpiry'),
      );

      ref
          .read(updateApplicationProvider.notifier)
          .findForeignerApplication(
            searchRequest: foreignerModel,
            onError: onErrorCallback,
            onSuccess: onSuccessCallback,
          );
    }
  }

  void _showInfoDialog(String title, String message, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              color: isError ? Colors.red.shade600 : Colors.blue.shade700,
            ),
            const SizedBox(width: 10),
            // Wrap title in Expanded to prevent stretching/overflow
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        // Use SizedBox to constrain the maximum width of the dialog
        content: SizedBox(
          width: 400, // Forces the dialog to be a normal, readable width
          child: Text(
            message,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          fontFamily: AppFonts.primaryFont,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, bool isMobile) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: isMobile ? 10 : 12, color: Colors.grey),
      prefixIcon: Icon(icon, size: 18, color: Colors.black54),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildArrivalRadioOption(int offset) {
    final targetDate = DateTime.now().add(Duration(days: offset));
    final displayDate =
        "${targetDate.day.toString().padLeft(2, '0')}/${targetDate.month.toString().padLeft(2, '0')}/${targetDate.year}";
    final bool isSelected = _arrivalDateOffset == offset;

    return InkWell(
      onTap: () {
        setState(() {
          _arrivalDateOffset = offset;
          _searchControllers['arrivalDate']?.text =
              "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Colors.lightBlue.shade700
                : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Radio<int>(
                value: offset,
                groupValue: _arrivalDateOffset,
                activeColor: Colors.lightBlue.shade700,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _arrivalDateOffset = val;
                      _searchControllers['arrivalDate']?.text =
                          "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(
              displayDate,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.lightBlue.shade700 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeNumberField(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("DE Number *"),
        TextFormField(
          controller: _searchControllers['qrReference'],
          decoration: _inputDecoration(
            "",
            Icons.qr_code_scanner_outlined,
            isMobile,
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'DE Number is mandatory' : null,
        ),
      ],
    );
  }

  Widget _buildNrcSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("NRC Number *"),
        (() {
          final nrcAsync = ref.watch(nrcProvider);
          final nrcState = nrcAsync.valueOrNull;

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
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\u1040-\u1049]')),
                LengthLimitingTextInputFormatter(6),
              ],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: "၁၂၃၄၅၆",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (v) => setState(() {}),
            ),
          );

          return NrcSelectorWidget(
            isDesktop: isDesktop,
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
            hasError: false,
            stateList: stateList,
            townshipList: townshipList,
            nrcTypes: _nrcTypes,
            activeStateId: activeStateId,
            onStateChanged: (id, idCode) {
              ref.read(nrcProvider.notifier).selectNrcState(id);
              setState(() {
                _selectedNrcStateCode = idCode;
                _selectedTownshipCode = null;
              });
            },
            onTownshipChanged: (v) => setState(() => _selectedTownshipCode = v),
            onTypeChanged: (v) => setState(() => _selectedNrcType = v),
          );
        })(),
      ],
    );
  }

  Widget _buildNativeLayout(bool isMobile, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDeNumberField(isMobile),
                  const SizedBox(height: 20),
                  _buildNrcSection(isDesktop),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildDeNumberField(isMobile)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildNrcSection(isDesktop)),
                ],
              ),
        const SizedBox(height: 20),

        _buildLabel("Expected Date of Arrival *"),
        isMobile
            ? Column(
                children: [
                  _buildArrivalRadioOption(0),
                  const SizedBox(height: 8),
                  _buildArrivalRadioOption(1),
                  const SizedBox(height: 8),
                  _buildArrivalRadioOption(2),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _buildArrivalRadioOption(0)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildArrivalRadioOption(1)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildArrivalRadioOption(2)),
                ],
              ),

        // Hidden Validation
        Offstage(
          child: TextFormField(
            controller: _searchControllers['arrivalDate'],
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please select an arrival date'
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildForeignerLayout(bool isMobile) {
    final passportField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Passport Number *"),
        TextFormField(
          controller: _searchControllers['passportNumber'],
          textCapitalization: TextCapitalization.characters,
          decoration: _inputDecoration("", Icons.badge_outlined, isMobile),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Passport Number required'
              : null,
        ),
      ],
    );

    final countryField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Country *"),
        _isLoadingCountries
            ? const LinearProgressIndicator()
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black87, width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value:
                        _searchControllers['nationalityCode']?.text.isEmpty ??
                            true
                        ? null
                        : _searchControllers['nationalityCode']?.text,
                    isExpanded: true,
                    hint: Text(
                      "Select Nationality",
                      style: TextStyle(fontSize: isMobile ? 10 : 12),
                    ),
                    items: _rawCountryObjects.map<DropdownMenuItem<String>>((
                      c,
                    ) {
                      return DropdownMenuItem<String>(
                        value: c.countryCode,
                        child: Text(c.countryName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null)
                        setState(
                          () =>
                              _searchControllers['nationalityCode']?.text = val,
                        );
                    },
                  ),
                ),
              ),
      ],
    );

    final dobField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Date of Birth *"),
        TextFormField(
          controller: _searchControllers['dob'],
          readOnly: true,
          onTap: () => _selectDate(context, _searchControllers['dob']!),
          decoration: _inputDecoration(
            "YYYY-MM-DD",
            Icons.calendar_today,
            isMobile,
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'DOB required' : null,
        ),
      ],
    );

    final expiryField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Passport Expiry Date *"),
        TextFormField(
          controller: _searchControllers['passportExpiry'],
          readOnly: true,
          onTap: () =>
              _selectDate(context, _searchControllers['passportExpiry']!),
          decoration: _inputDecoration(
            "YYYY-MM-DD",
            Icons.calendar_today,
            isMobile,
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Expiry date required' : null,
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDeNumberField(isMobile),
        const SizedBox(height: 20),
        isMobile
            ? Column(
                children: [
                  passportField,
                  const SizedBox(height: 20),
                  countryField,
                ],
              )
            : Row(
                children: [
                  Expanded(child: passportField),
                  const SizedBox(width: 16),
                  Expanded(child: countryField),
                ],
              ),
        const SizedBox(height: 20),
        isMobile
            ? Column(
                children: [dobField, const SizedBox(height: 20), expiryField],
              )
            : Row(
                children: [
                  Expanded(child: dobField),
                  const SizedBox(width: 16),
                  Expanded(child: expiryField),
                ],
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMyanmar =
        widget.initialCountry == 'Myanmar' || widget.initialCountry == 'MMR';
    final isLoading = ref.watch(updateApplicationProvider).isLoading;
    final isMobile = MediaQuery.of(context).size.width < 500;
    final isDesktop = MediaQuery.of(context).size.width > 600;

    final primaryBtn = ElevatedButton(
      onPressed: isLoading ? null : () => _handleFindApplication(isMyanmar),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'Find & Edit Application',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.primaryFont,
              ),
            ),
    );

    final secondaryBtn = ElevatedButton(
      onPressed: isLoading ? null : widget.onBackPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _searchFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildNoticeBox(isMyanmar),
                const SizedBox(height: 30),

                const Text(
                  "Verify Identity Details to Modify Record",
                  style: AppFonts.pageTitle,
                ),
                const SizedBox(height: 24),

                if (isMyanmar)
                  _buildNativeLayout(isMobile, isDesktop)
                else
                  _buildForeignerLayout(isMobile),

                const SizedBox(height: 32),
                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          primaryBtn,
                          const SizedBox(height: 10),
                          secondaryBtn,
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [secondaryBtn, primaryBtn],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeBox(bool isMyanmar) {
    final isMobile = MediaQuery.of(context).size.width < 500;
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Container(
      width: 1100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          const BoxShadow(
            color: Colors.grey,
            offset: Offset(1, 1),
            blurRadius: 1,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 8,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 80,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Colors.white54),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.shade50,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 30),
                  Text(
                    "Important Notice",
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Please note that the following Details cannot be edited after submission:",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: AppFonts.primaryFont,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                isDesktop
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: 250,
                            child: Column(
                              children: [
                                _buildNoticeItems("Full Name"),
                                const SizedBox(height: 20),
                                _buildNoticeItems("Date of Birth"),
                                const SizedBox(height: 20),
                                _buildNoticeItems("Nationality"),
                              ],
                            ),
                          ),
                          isDesktop
                              ? const SizedBox(width: 50)
                              : const SizedBox(),
                          SizedBox(
                            width: 250,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildNoticeItems(
                                  isMyanmar ? "Passport Number" : "NRC Number",
                                ),
                                const SizedBox(height: 20),
                                _buildNoticeItems("Passport Expiry Date"),
                                const SizedBox(height: 20),
                                _buildNoticeItems("Date of Arrival"),
                              ],
                            ),
                          ),
                          isDesktop
                              ? const SizedBox(width: 50)
                              : const SizedBox(),
                        ],
                      )
                    : Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.spaceBetween,
                        runAlignment: WrapAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 250,
                            child: Column(
                              children: [
                                _buildNoticeItems("Full Name"),
                                const SizedBox(height: 20),
                                _buildNoticeItems("Date of Birth"),
                                const SizedBox(height: 20),
                                _buildNoticeItems("Nationality"),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 250,
                            child: Column(
                              children: [
                                _buildNoticeItems(
                                  isMyanmar ? "Passport Number" : "NRC Number",
                                ),
                                const SizedBox(height: 20),
                                _buildNoticeItems("Passport Expiry Date"),
                                const SizedBox(height: 20),
                                _buildNoticeItems("Date of Arrival"),
                              ],
                            ),
                          ),
                        ],
                      ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      "Need to make a change?",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontFamily: AppFonts.primaryFont,
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: widget.onStartNewApplication,
                      child: const Text(
                        "Start a new submission",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromRGBO(1, 156, 244, 1),
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.primaryFont,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeItems(String lable) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: Colors.blue),
        const SizedBox(width: 10),
        Expanded(child: Text(lable, style: const TextStyle(fontSize: 18))),
      ],
    );
  }
}
