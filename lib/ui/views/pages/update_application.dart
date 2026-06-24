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
import 'package:mmac/ui/views/pages/new_application/widget/nrc_selector_widget.dart';

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
    // 'nrc': TextEditingController(),
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
    _nrcNumberController.dispose();
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
      // 🎯 THE FIX: Wrap the picker in your custom button blue theme!
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
          color: isFocused ? Colors.blue : Colors.black87,
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

    final double screenSize = MediaQuery.of(context).size.width;
    final bool isMobile = screenSize < 500;

    final primaryButton = ElevatedButton(
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
    );

    final secondaryButton = ElevatedButton(
      onPressed: isLoading ? null : widget.onBackPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
    );

    //  1. Packaged DE Number Widget
    final Widget deNumberWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("DE Number"),
        TextFormField(
          controller: _searchControllers['qrReference'],
          decoration: _inputDecoration(
            "",
            Icons.qr_code_scanner_outlined,
            isMobile,
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'QR Reference is mandatory'
              : null,
        ),
      ],
    );

    //  2. Packaged NRC Widget (With Full Riverpod Logic!)
    final Widget nrcWidgetBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("NRC Number"),
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
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) => setState(() {}),
            ),
          );

          return NrcSelectorWidget(
            isDesktop: MediaQuery.of(context).size.width > 600,
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
            onTownshipChanged: (v) {
              setState(() => _selectedTownshipCode = v);
            },
            onTypeChanged: (v) {
              setState(() => _selectedNrcType = v);
            },
          );
        })(),
      ],
    );

    final Widget passportNumberBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Passport Number "),
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

    final Widget countryBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Country"),
        _isLoadingCountries
            ? const LinearProgressIndicator()
            : buildCustomDropdownContainer(
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
                    dynamic country,
                  ) {
                    return DropdownMenuItem<String>(
                      value: country.countryCode,
                      child: Text(country.countryName),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _searchControllers['nationalityCode']?.text = newValue;
                      });
                    }
                  },
                ),
              ),
      ],
    );

    final Widget dateOfBirthBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Date of Birth "),
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

    final passportExpiryBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Passport Expiry Date "),
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

                // 🇲🇲 NATIVE (MYANMAR) LAYOUT
                if (isMyanmar) ...[
                  // 🎯 ROW 1: DE Number & NRC Number (Side-by-Side on Desktop)
                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            deNumberWidget,
                            const SizedBox(height: 20),
                            nrcWidgetBlock,
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: deNumberWidget),
                            const SizedBox(width: 16),
                            Expanded(child: nrcWidgetBlock),
                          ],
                        ),
                  const SizedBox(height: 20),

                  // 🎯 ROW 2: Expected Date of Arrival
                  _buildLabel("Expected Date of Arrival"),
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

                  // Hidden Validation Field
                  Offstage(
                    child: TextFormField(
                      controller: _searchControllers['arrivalDate'],
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please select an arrival date'
                          : null,
                    ),
                  ),
                ],

                // ✈️ FOREIGNER LAYOUT
                if (!isMyanmar) ...[
                  // Foreigners still need the DE Number field at the top!
                  deNumberWidget,
                  const SizedBox(height: 20),

                  // 1️⃣ First Row: Passport Number & Nationality
                  isMobile
                      ? Column(
                          children: [
                            passportNumberBlock,
                            const SizedBox(height: 20),
                            countryBlock,
                          ],
                        )
                      : _pair(passportNumberBlock, countryBlock),
                  const SizedBox(height: 20),

                  // 2️⃣ Second Row: Date of Birth & Passport Expiry Date
                  isMobile
                      ? Column(
                          children: [
                            dateOfBirthBlock,
                            const SizedBox(height: 20),
                            passportExpiryBlock,
                          ],
                        )
                      : _pair(dateOfBirthBlock, passportExpiryBlock),
                ],
                const SizedBox(height: 32),

                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          primaryButton,
                          const SizedBox(height: 10),
                          secondaryButton,
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 🎯 ပုံစံတူညီအောင် ပြင်ဆင်ထားသော Back Button အသစ်
                          secondaryButton,
                          // Find & Edit Application Button
                          primaryButton,
                        ],
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

  InputDecoration _inputDecoration(String hint, IconData icon, bool isMobile) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: isMobile ? 10 : 12, color: Colors.grey),
      prefixIcon: Icon(icon, size: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // --- this method will make two columns in a row ---
  Widget _pair(Widget a, Widget b) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 16),
        Expanded(child: b),
      ],
    );
  }

  //dynamic radio date selection buttons
  int _arrivalDateOffset = -1; // -1 means none selected yet
  Widget _buildArrivalRadioOption(int offset) {
    final targetDate = DateTime.now().add(Duration(days: offset));

    final day = targetDate.day.toString().padLeft(2, '0');
    final month = targetDate.month.toString().padLeft(2, '0');
    final year = targetDate.year.toString();
    final displayDate = "$day/$month/$year";

    final bool isSelected = _arrivalDateOffset == offset;

    return InkWell(
      onTap: () {
        setState(() {
          _arrivalDateOffset = offset;
          _searchControllers['arrivalDate']?.text =
              "${targetDate.year}-$month-$day";
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ), // Removed horizontal padding so it auto-centers
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
          mainAxisAlignment: MainAxisAlignment
              .center, // 🎯 Centers the circle and text inside the box
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Radio<int>(
                value: offset,
                groupValue: _arrivalDateOffset,
                activeColor: Colors.lightBlue.shade700,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (int? val) {
                  if (val != null) {
                    setState(() {
                      _arrivalDateOffset = val;
                      _searchControllers['arrivalDate']?.text =
                          "${targetDate.year}-$month-$day";
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              // 🎯 Prevents text from breaking if viewed on a super tiny phone screen
              child: Text(
                displayDate,
                style: TextStyle(
                  fontSize:
                      12, // 🎯 Scaled down slightly to fit 3 perfectly on mobile
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? Colors.lightBlue.shade700
                      : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 အသစ်ထည့်မည့် Notice Box Widget
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
                  //ဒီနေရာမှာ TapGestureRecognizer ထည့်ပြီး New Application ဘက်ကို ကူးသွားအောင် လုပ်လို့ရပါတယ်
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
