// lib/ui/views/pages/update_application/update_application_page.dart

// ignore_for_file: prefer_function_declarations_over_variables, deprecated_member_use, unused_field, empty_catches

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/models/search_request_model.dart';
import 'package:mmac/data/models/submit_request_model.dart';
import 'package:mmac/data/controllers/update_application_provider.dart';
import 'package:mmac/data/controllers/country_provider.dart';
import 'package:mmac/data/controllers/nrc_provider.dart';
import 'package:mmac/ui/views/widgets/nrc_selector_field.dart';

class UpdateApplication extends ConsumerStatefulWidget {
  final String? initialCountry;
  final Function(SubmitRequestModel) onApplicationFetched;
  final VoidCallback onBackPressed;

  const UpdateApplication({
    super.key,
    this.initialCountry,
    required this.onBackPressed,
    required this.onApplicationFetched,
  });

  @override
  ConsumerState<UpdateApplication> createState() => _UpdateApplicationState();
}

class _UpdateApplicationState extends ConsumerState<UpdateApplication> {
  bool _isLoadingCountries = true;
  final List<dynamic> _rawCountryObjects = [];
  final List<String> _countryNameList = [];
  final GlobalKey<FormState> _searchFormKey = GlobalKey<FormState>();

  // --- NRC Dropdown သီးသန့် ပြောင်းလဲမှု မှတ်မည့် Variables ---
  String? _selectedNrcStateCode;
  String? _selectedTownshipCode;
  String? _selectedNrcType;
  final TextEditingController _nrcNumberController = TextEditingController();

  final Map<String, TextEditingController> _searchControllers = {
    'qrReference': TextEditingController(),
    'passportNumber': TextEditingController(),
    'nrc': TextEditingController(),
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

  @override
  void dispose() {
    _searchControllers.forEach((_, controller) => controller.dispose());
    _nrcNumberController.dispose(); // Controller ဖျက်ပေးရန်
    _searchControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  String _text(String key) => _searchControllers[key]?.text.trim() ?? '';

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _handleFindApplication(bool isMyanmar) {
    if (_searchFormKey.currentState?.validate() ?? false) {
      // Error Message နှင့် Success လုပ်ဆောင်ချက်များကို ဤနေရာတွင် ကြိုတင်ရေးထားမည်
      final Function(String) onErrorCallback = (errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red.shade700,
          ),
        );
      };

      final VoidCallback onSuccessCallback = () {
        //  FIX: Wait a micro-tick for Riverpod's state to fully populate
        // before we attempt to read the value. This kills the double-tap bug!
        Future.microtask(() {
          final fetchedData = ref.read(updateApplicationProvider).value;
          if (fetchedData != null) {
            widget.onApplicationFetched(fetchedData);
          }
        });
      };

      if (isMyanmar) {
        // 🇲🇲 မြန်မာနိုင်ငံသားဖြစ်လျှင်
        String fullNrc = _generateFullNrcString();
        if (fullNrc.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please select all NRC fields carefully."),
              backgroundColor: Colors.amber,
            ),
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
        // ✈️ နိုင်ငံခြားသားဖြစ်လျှင်
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
  }

  @override
  void initState() {
    super.initState();

    // 🎯 API ကနေ နိုင်ငံစာရင်းတွေကို ဆွဲယူပြီး Dropdown အတွက် ပြင်ဆင်ခြင်း
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
            _isLoadingCountries = false;
          });
        }
      } catch (e) {
        debugPrint("❌ Failed to load countries in Update Portal: $e");
        if (mounted) setState(() => _isLoadingCountries = false);
      }
    });
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

      return "$stateMM/$townshipMM($_selectedNrcType)${_nrcNumberController.text}";
    }
    return "";
  }

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

  @override
  Widget build(BuildContext context) {
    // 🎯 Logic အမှန်: Parent က ပေးလိုက်တဲ့ initialCountry ကိုသာ စစ်ဆေးရမည်!
    final bool isMyanmar =
        widget.initialCountry == 'Myanmar' || widget.initialCountry == 'MMR';
    final searchState = ref.watch(updateApplicationProvider);
    final isLoading = searchState.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05), // ခပ်ဖျော့ဖျော့ အရိပ်လေး
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
                InkWell(
                  onTap: widget.onBackPressed, // Dialog ကို ခေါ်မည့် Function
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 4.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: Colors.blueGrey.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Back",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 🎯 ဘရို တောင်းဆိုထားသော Info Banner အသစ်
                _buildNoticeBox(isMyanmar),
                const SizedBox(height: 24),

                const Text(
                  "Verify Identity Details to Modify Record",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 24),

                // (ကျန်သော Form Field များသည် မူလအတိုင်းဖြစ်သည် - QR, NRC, Passport စသည်)
                _buildLabel("Digital Entry Number"),
                TextFormField(
                  controller: _searchControllers['qrReference'],
                  decoration: _inputDecoration(
                    "",
                    Icons.qr_code_scanner_outlined,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'QR Reference is mandatory'
                      : null,
                ),

                if (isMyanmar) ...[
                  const SizedBox(height: 20),
                  _buildLabel("Date of Arrival *"),
                  TextFormField(
                    controller: _searchControllers['arrivalDate'],
                    readOnly:
                        true, // User ကို လက်နဲ့ရိုက်ခွင့်မပေးဘဲ Calendar Picker နဲ့ပဲ ရွေးခိုင်းမည်
                    onTap: () => _selectDate(
                      context,
                      _searchControllers['arrivalDate']!,
                    ),
                    decoration: _inputDecoration(
                      "YYYY-MM-DD",
                      Icons.calendar_today,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Arrival date required'
                        : null,
                  ),
                ],
                const SizedBox(height: 20),

                if (isMyanmar) ...[
                  const Text(
                    "NRC Number *",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  // Riverpod ကနေ NRC Master Data ကို စောင့်ကြည့်ခြင်း
                  (() {
                    final nrcAsync = ref.watch(nrcProvider);
                    final nrcState = nrcAsync.valueOrNull;
                    final List<dynamic> stateList =
                        nrcState?.nrcStateList ?? [];
                    final List<dynamic> townshipList =
                        nrcState?.availableNrcTownships ?? [];
                    final int? currentProviderStateId =
                        nrcState?.selectedNrcStateId;

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

                    return NrcSelectorField(
                      isDesktop: MediaQuery.of(context).size.width > 600,
                      stateDropdown: buildCustomDropdownContainer(
                        child: DropdownButton<int>(
                          value: activeStateId,
                          isExpanded: true,
                          hint: const Text(
                            "ပြည်နယ်/တိုင်း",
                            style: TextStyle(fontSize: 12),
                          ),
                          items: stateList
                              .map<DropdownMenuItem<int>>(
                                (st) => DropdownMenuItem<int>(
                                  value: st.id,
                                  child: Text(st.codeMM),
                                ),
                              )
                              .toList(),
                          onChanged: (id) {
                            if (id != null) {
                              ref.read(nrcProvider.notifier).selectNrcState(id);
                              final match = stateList.firstWhere(
                                (s) => s.id == id,
                              );
                              setState(() {
                                _selectedNrcStateCode = match.idCode;
                                _selectedTownshipCode = null;
                              });
                            }
                          },
                        ),
                      ),
                      townshipDropdown: buildCustomDropdownContainer(
                        child: DropdownButton<String>(
                          value: activeTownshipCode,
                          isExpanded: true,
                          hint: const Text(
                            "မြို့နယ်",
                            style: TextStyle(fontSize: 12),
                          ),
                          items: townshipList
                              .map<DropdownMenuItem<String>>(
                                (ts) => DropdownMenuItem<String>(
                                  value: ts.idCode,
                                  child: Text(
                                    ts.codeMM,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedTownshipCode = v),
                        ),
                      ),
                      typeDropdown: buildCustomDropdownContainer(
                        child: DropdownButton<String>(
                          value: activeNrcType,
                          isExpanded: true,
                          items: _nrcTypes
                              .map<DropdownMenuItem<String>>(
                                (t) => DropdownMenuItem<String>(
                                  value: t['code'],
                                  child: Text(t['label']!),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedNrcType = v),
                        ),
                      ),
                      numberField: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
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
                          decoration: const InputDecoration(
                            hintText: "၁၂၃၄၅၆",
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (v) => setState(() {}),
                        ),
                      ),
                    );
                  })(),
                ],

                if (!isMyanmar) ...[
                  _buildLabel("Passport Number *"),
                  TextFormField(
                    controller: _searchControllers['passportNumber'],
                    textCapitalization: TextCapitalization.characters,
                    decoration: _inputDecoration("", Icons.badge_outlined),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Passport Number required'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  if (!isMyanmar) ...[
                    const Text(
                      "Nationality / Issued Country *",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    _isLoadingCountries
                        ? const LinearProgressIndicator()
                        : buildCustomDropdownContainer(
                            child: DropdownButton<String>(
                              //  ပြင်ဆင်ရန် - Controller ထဲမှာ ရှိနေမယ့် Country Code (e.g., 'USA') ကို တိုက်ရိုက် စစ်ဆေးခိုင်းမည်
                              value:
                                  _searchControllers['nationalityCode']
                                          ?.text
                                          .isEmpty ??
                                      true
                                  ? null
                                  : _searchControllers['nationalityCode']?.text,
                              isExpanded: true,
                              hint: const Text("Select Nationality"),

                              //  ပြင်ဆင်ရန် - _countryNameList အစား _rawCountryObjects ကို သုံးပြီး Value ကို Code ပေးပါမည်
                              items: _rawCountryObjects.map<DropdownMenuItem<String>>((
                                dynamic country,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: country
                                      .countryCode, // 🎯 Dropdown ရဲ့ နောက်ကွယ်က တန်ဖိုးကို Code (e.g., 'USA') ထားမည်
                                  child: Text(
                                    country.countryName,
                                  ), //  အပြင်ပန်း UI မှာတော့ နာမည် (e.g., 'United States') ပြမည်
                                );
                              }).toList(),

                              onChanged: (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    //  အခုဆိုရင် ရွေးချယ်လိုက်တဲ့ Code ကို Controller ထဲ တိုက်ရိုက် ထည့်ပေးရုံပါပဲ!
                                    _searchControllers['nationalityCode']
                                            ?.text =
                                        newValue;
                                  });
                                }
                              },
                            ),
                          ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Date of Birth *"),
                            TextFormField(
                              controller: _searchControllers['dob'],
                              readOnly: true,
                              onTap: () => _selectDate(
                                context,
                                _searchControllers['dob']!,
                              ),
                              decoration: _inputDecoration(
                                "YYYY-MM-DD",
                                Icons.calendar_today,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'DOB required'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Passport Expiry Date *"),
                            TextFormField(
                              controller: _searchControllers['passportExpiry'],
                              readOnly: true,
                              onTap: () => _selectDate(
                                context,
                                _searchControllers['passportExpiry']!,
                              ),
                              decoration: _inputDecoration(
                                "YYYY-MM-DD",
                                Icons.calendar_today,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Expiry date required'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => _handleFindApplication(isMyanmar),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // 🎯 အသစ်ထည့်မည့် Singapore-Style Notice Box Widget
  Widget _buildNoticeBox(bool isMyanmar) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF2F2), // Soft pinkish background
        border: Border.all(
          color:
              // const Color(0xFFF5C6C6)
              Colors.white,
        ), // Subtle red border
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Please note that you will not be able to update the following information:',
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          _buildNoticeListItem('1. Date of Arrival'),
          _buildNoticeListItem('2. Full Name'),

          // 🎯 Native (Myanmar) ဆိုရင် NRC, Foreigner ဆိုရင် Passport Number ပြမည်
          _buildNoticeListItem(
            '3. ${isMyanmar ? "NRC Number" : "Passport Number"}',
          ),

          _buildNoticeListItem('4. Date of Passport Expiry'),
          _buildNoticeListItem('5. Date of Birth'),
          _buildNoticeListItem('6. Nationality / Citizenship'),
          const SizedBox(height: 16),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 15, color: Colors.black87),
              children: [
                TextSpan(
                  text:
                      'If you wish to update any of the fields above, please make a ',
                ),
                TextSpan(
                  text: 'new submission',
                  style: TextStyle(
                    color: Colors.black87,
                    decoration: TextDecoration.none,
                  ),
                  // 💡 ဒီနေရာမှာ TapGestureRecognizer ထည့်ပြီး New Application ဘက်ကို ကူးသွားအောင် လုပ်လို့ရပါတယ်
                ),
                TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🎯 Notice Box ထဲက List Item လေးတွေအတွက် Helper
  Widget _buildNoticeListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }
}
