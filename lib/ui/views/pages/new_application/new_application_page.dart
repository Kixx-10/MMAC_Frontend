// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/controllers/submit_provider.dart';
import 'package:mmac/data/models/submit_request_model.dart';
import 'package:mmac/ui/views/pages/new_application/declaration_layout.dart';
import 'package:mmac/ui/views/pages/new_application/identification_form_layout.dart';
import 'package:mmac/ui/views/pages/new_application/qr_generate_screen.dart';
import 'package:mmac/ui/views/pages/new_application/review_layout.dart';
import 'package:mmac/ui/views/pages/new_application/trip_form_layout.dart';
import 'package:mmac/ui/views/pages/update_application.dart';
import 'package:mmac/ui/views/widgets/footer.dart';
import 'package:mmac/utils/form_session_service.dart';
import '../../widgets/form_progress_bar.dart';

class NewApplication extends ConsumerStatefulWidget {
  final String? initialCountry;
  final VoidCallback? onBackPressed;
  final bool isUpdateMode;

  const NewApplication({
    super.key,
    this.initialCountry,
    this.onBackPressed,
    this.isUpdateMode = false,
  });

  @override
  ConsumerState<NewApplication> createState() => _NewApplicationState();
}

class _NewApplicationState extends ConsumerState<NewApplication>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int currentStep = 1;
  final int totalSteps = 4;
  String _generatedApplicationNo = '';
  bool _isSessionLoading = true;

  SubmitRequestModel? _submittedData;

  final GlobalKey<FormState> _step1FormKey = GlobalKey<FormState>();
  IdentificationFormLayoutInterface? _step1Interface;
  TripFormLayoutInterface? _step2Interface;
  DeclarationLayoutInterface? _step3Interface;

  final Map<String, TextEditingController> _step1Controllers = {
    'fullName': TextEditingController(),
    'email': TextEditingController(),
    'mobile': TextEditingController(),
    'visaNumber': TextEditingController(),
    'passportNumber': TextEditingController(),
    'address': TextEditingController(),
    'nrc': TextEditingController(),
    'fatherName': TextEditingController(),
  };

  final Map<String, TextEditingController> _step2Controllers = {
    'vehicleNumber': TextEditingController(),
    'vehicleName': TextEditingController(),
    'accommodation': TextEditingController(),
    'addressInMyanmar': TextEditingController(),
    'mobileNumberMM': TextEditingController(),
    'previousCity': TextEditingController(),
    'purposeOfVisitDetail': TextEditingController(),
  };

  final Map<String, dynamic> _formValues = {
    'residencyType': null,
    'gender': null,
    'dateOfBirth': null,
    'country': null,
    'countryCode': null,
    'issuedCountry': null,
    'issuedCountryCode': null,
    'issuedDate': null,
    'expiryDate': null,
    'arrivalDate': null,
    'modeOfTravel': null,
    'modeOfTravelId': null,
    'portOfArrival': null,
    'portOfArrivalId': null,
    'stateRegion': null,
    'stateRegionId': null,
    'district': null,
    'districtId': null,
    'township': null,
    'townshipId': null,
    'purposeOfVisit': null,
    'selectedPurposeDropdown': null,
    'hasSymptoms': null,
    'carryingRestricted': null,
    // 🎯 NRC Dropdown state များကို သိမ်းရန် ထပ်ထည့်ထားသည်
    'nrcStateCode': null,
    'nrcTownshipCode': null,
    'nrcTypeCode': null,
    'nrcRawNumber': null,
  };

  @override
  void initState() {
    super.initState();
    if (widget.isUpdateMode) {
      currentStep = 0;
    }
    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    try {
      final sessionData = await FormSessionService.loadDraft();

      if (sessionData != null && mounted) {
        setState(() {
          if (sessionData['currentStep'] != null) {
            currentStep = sessionData['currentStep'];
          }

          if (sessionData['values'] != null) {
            final Map<String, dynamic> savedValues = Map<String, dynamic>.from(
              sessionData['values'],
            );

            // DATE CRASH FIX: Json မှလာသော String ကို DateTime သို့ ပြန်ပြောင်းပေးခြင်း
            final dateFields = [
              'dateOfBirth',
              'issuedDate',
              'expiryDate',
              'arrivalDate',
            ];
            for (var field in dateFields) {
              if (savedValues[field] != null && savedValues[field] is String) {
                try {
                  savedValues[field] = DateTime.parse(savedValues[field]);
                } catch (e) {
                  savedValues[field] = null; // Parse မရပါက ဖျက်ပစ်မည်
                }
              }
            }

            _formValues.addAll(savedValues);

            _step1Controllers.forEach((key, controller) {
              if (savedValues.containsKey(key) && savedValues[key] != null) {
                controller.text = savedValues[key].toString();
              }
            });

            _step2Controllers.forEach((key, controller) {
              if (savedValues.containsKey(key) && savedValues[key] != null) {
                controller.text = savedValues[key].toString();
              }
            });
          }
        });
      } else {
        if (widget.initialCountry != null) {
          _formValues['residencyType'] = widget.initialCountry;

          if (widget.initialCountry == 'Myanmar') {
            _formValues['country'] = 'Myanmar';
            _formValues['countryCode'] = 'MMR';
          } else {
            _formValues['country'] = null;
            _formValues['countryCode'] = null;
          }
          _saveCurrentSession();
        }
      }
    } catch (e) {
      debugPrint("❌ Session Restoration Fail: $e");
    } finally {
      if (mounted) setState(() => _isSessionLoading = false);
    }
  }

  void _saveCurrentSession() {
    // 1. Grab latest text from controllers
    _step1Controllers.forEach(
      (key, controller) => _formValues[key] = controller.text,
    );
    _step2Controllers.forEach(
      (key, controller) => _formValues[key] = controller.text,
    );

    final Map<String, dynamic> dataToSave = Map<String, dynamic>.from(
      _formValues,
    );

    // 3. 🎯 CRITICAL FIX: Convert DateTime objects to ISO Strings before saving
    final dateFields = [
      'dateOfBirth',
      'issuedDate',
      'expiryDate',
      'arrivalDate',
    ];

    for (var field in dateFields) {
      if (dataToSave[field] != null && dataToSave[field] is DateTime) {
        dataToSave[field] = (dataToSave[field] as DateTime).toIso8601String();
      }
    }

    // 4. Save the sanitized map
    FormSessionService.saveDraft(dataToSave, currentStep);
  }

  @override
  void dispose() {
    _step1Controllers.forEach((_, controller) => controller.dispose());
    _step2Controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _updateFormValue(String key, dynamic value) {
    setState(() => _formValues[key] = value);
    _saveCurrentSession();
  }

  // 🎯 API မှ ကျလာသော ဒေတာဟောင်းများကို Form တစ်ခုလုံးသို့ ဖြည့်သွင်းပေးသည့် စနစ်
  void _injectFetchedData(SubmitRequestModel fetchedData) {
    setState(() {
      // ၁။ စာရိုက်တံ (Controllers) များထဲသို့ Data လိုက်ထည့်ခြင်း
      _step1Controllers['fullName']?.text = fetchedData.fullName;
      _step1Controllers['email']?.text = fetchedData.email;
      _step1Controllers['mobile']?.text = fetchedData.mobileNumber;
      _step1Controllers['visaNumber']?.text = fetchedData.visaNo!;
      _step1Controllers['passportNumber']?.text = fetchedData.passportNo;
      _step1Controllers['address']?.text = fetchedData.address;
      _step1Controllers['nrc']?.text = fetchedData.nrc!;
      _step1Controllers['fatherName']?.text = fetchedData.fatherName!;

      _step2Controllers['vehicleNumber']?.text = fetchedData.vehicleNumber;
      _step2Controllers['vehicleName']?.text = fetchedData.vehicleName;
      _step2Controllers['accommodation']?.text = fetchedData.accommodation!;
      _step2Controllers['addressInMyanmar']?.text =
          fetchedData.addressInMyanmar;
      _step2Controllers['mobileNumberMM']?.text = fetchedData.mobileNumberMM!;
      _step2Controllers['previousCity']?.text = fetchedData.previousCity!;

      // ၂။ Form Values (Dropdown & Dates) များကို သိမ်းဆည်းခြင်း
      _formValues['gender'] = fetchedData.gender == 'M' ? 'Male' : 'Female';
      if (fetchedData.dob.isNotEmpty)
        _formValues['dateOfBirth'] = DateTime.parse(fetchedData.dob);
      if (fetchedData.issuedDate.isNotEmpty)
        _formValues['issuedDate'] = DateTime.parse(fetchedData.issuedDate);
      if (fetchedData.expiryDate.isNotEmpty)
        _formValues['expiryDate'] = DateTime.parse(fetchedData.expiryDate);
      if (fetchedData.arrivalDate.isNotEmpty)
        _formValues['arrivalDate'] = DateTime.parse(fetchedData.arrivalDate);

      _formValues['countryCode'] = fetchedData.countryOfBirthCode;
      _formValues['issuedCountryCode'] = fetchedData.issuedCountryCode;
      _formValues['modeOfTravelId'] = fetchedData.modeOfTravelId;
      _formValues['portOfArrivalId'] = fetchedData.portOfArrivalId;
      _formValues['stateRegionId'] = fetchedData.stateRegionId;
      _formValues['districtId'] = fetchedData.districtId;
      _formValues['townshipId'] = fetchedData.townshipId;
      _formValues['purposeOfVisit'] = fetchedData.purposeOfVisit;
      _formValues['hasSymptoms'] = fetchedData.healthDeclaration;
      _formValues['carryingRestricted'] = fetchedData.digitalDeclarations;

      // ၃။ ဒေတာအားလုံး အဆင်သင့်ဖြစ်ပါက စာမျက်နှာ ၁ (Identification Form) သို့ တိုက်ရိုက် ခေါ်ဆောင်သွားမည်
      currentStep = 1;
    });

    // Local Draft ထဲသို့ပါ တစ်ခါတည်း သိမ်းဆည်းလိုက်မည်
    _saveCurrentSession();
  }

  String _text(String key) =>
      _step1Controllers[key]?.text.trim() ??
      _step2Controllers[key]?.text.trim() ??
      '';

  bool get _isMyanmar =>
      _formValues['country'] == 'Myanmar' || _formValues['country'] == 'MMR';

  String _safeString(dynamic value) => value?.toString() ?? '';

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) {
      final String year = date.year.toString();
      final String month = date.month.toString().padLeft(2, '0');
      final String day = date.day.toString().padLeft(2, '0');
      return '$year-$month-$day';
    }
    return date.toString();
  }

  String _genderCode(String? gender) {
    switch (gender) {
      case 'Male':
        return 'M';
      case 'Female':
        return 'F';
      default:
        return '';
    }
  }

  bool _isStep1DataValid() {
    return _text('fullName').isNotEmpty &&
        _text('email').isNotEmpty &&
        _formValues['gender'] != null &&
        _formValues['dateOfBirth'] != null;
  }

  bool _isStep2DataValid() {
    return _formValues['arrivalDate'] != null &&
        _formValues['portOfArrivalId'] != null &&
        _formValues['townshipId'] != null &&
        _formValues['purposeOfVisit'] != null;
  }

  bool _isStep3DataValid() {
    return _formValues['hasSymptoms'] != null &&
        _formValues['carryingRestricted'] != null;
  }

  SubmitRequestModel _buildRequestModel() {
    final String countryCode = _safeString(_formValues['countryCode']);
    final String issuedCountryCode = _safeString(
      _formValues['issuedCountryCode'],
    );
    final String finalNrc = _isMyanmar ? _text('nrc') : '';
    final String finalFatherName = _isMyanmar ? _text('fatherName') : '';

    return SubmitRequestModel(
      fullName: _text('fullName'),
      gender: _genderCode(_formValues['gender']),
      dob: _formatDate(_formValues['dateOfBirth']),
      countryOfBirthCode: countryCode,
      email: _text('email'),
      mobileNumber: _text('mobile'),
      address: _text('address'),
      visaNo: _text('visaNumber'),
      nrc: finalNrc,
      fatherName: finalFatherName,
      passportNo: _text('passportNumber'),
      issuedCountryCode: issuedCountryCode,
      issuedDate: _formatDate(_formValues['issuedDate']),
      expiryDate: _formatDate(_formValues['expiryDate']),
      arrivalDate: _formatDate(_formValues['arrivalDate']),
      modeOfTravelId: _safeString(_formValues['modeOfTravelId']),
      portOfArrivalId: _safeString(_formValues['portOfArrivalId']),
      stateRegionId: _safeString(_formValues['stateRegionId']),
      districtId: _safeString(_formValues['districtId']),
      townshipId: _safeString(_formValues['townshipId']),
      mobileNumberMM: _text('mobileNumberMM'),
      purposeOfVisit: _safeString(_formValues['purposeOfVisit']),
      addressInMyanmar: _text('addressInMyanmar'),
      vehicleNumber: _text('vehicleNumber'),
      vehicleName: _text('vehicleName'),
      accommodation: _text('accommodation'),
      previousCity: _text('previousCity'),
      healthDeclaration: _safeString(_formValues['hasSymptoms']),
      digitalDeclarations: _safeString(_formValues['carryingRestricted']),
    );
  }

  void _nextStep() {
    if (currentStep == 1) {
      if (_step1Interface == null) {
        _showError('Form not ready, please wait.');
        return;
      }
      if (_step1Interface!.validate()) {
        setState(() => currentStep++);
        _saveCurrentSession();
      }
    } else if (currentStep == 2) {
      if (_step2Interface == null) {
        _showError('Form not ready, please wait.');
        return;
      }
      if (_step2Interface!.validate()) {
        setState(() => currentStep++);
        _saveCurrentSession();
      }
    } else if (currentStep == 3) {
      if (_step3Interface == null) {
        _showError('Form not ready, please wait.');
        return;
      }
      if (_step3Interface!.validate()) {
        setState(() => currentStep++);
        _saveCurrentSession();
      }
    } else if (currentStep == 4) {
      if (!_isStep1DataValid()) {
        setState(() => currentStep = 1);
        _showError('Please check Section 1.');
        return;
      }
      if (!_isStep2DataValid()) {
        setState(() => currentStep = 2);
        _showError('Please check Section 2.');
        return;
      }
      if (!_isStep3DataValid()) {
        setState(() => currentStep = 3);
        _showError('Please check Section 3.');
        return;
      }
      _submitApplication();
    }
  }

  void _prevStep() {
    if (currentStep > 1) {
      setState(() => currentStep--);
      _saveCurrentSession();
    }
  }

  void _resetForm() {
    _step1Controllers.forEach((_, controller) => controller.clear());
    _step2Controllers.forEach((_, controller) => controller.clear());
    _formValues.updateAll((key, _) => null);
    FormSessionService.clearDraft();
    setState(() {
      _generatedApplicationNo = '';
      currentStep = 1;
    });
  }

  Future<void> _submitApplication() async {
    final requestModel = _buildRequestModel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final response = await ref
          .read(submitControllerProvider.notifier)
          .submitApplicationAction(requestModel);
      if (!mounted) return;
      Navigator.of(context).pop();
      if (response != null) {
        FormSessionService.clearDraft();
        setState(() {
          _submittedData = requestModel;
          _generatedApplicationNo = response.applicationNo;
          currentStep = 5;
        });
      } else {
        _showErrorDialog(
          'The server could not process your application. Please re-check your info.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showErrorDialog('An unexpected error occurred. Please try again later.');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600),
            const SizedBox(width: 10),
            const Text(
              'Submission Failed',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(message),
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

  String get _sectionTitle {
    switch (currentStep) {
      case 1:
        return "Identification & Personal Informations";
      case 2:
        return "Trip & Accommodation Details";
      case 3:
        return "Declarations";
      case 4:
        return "Review Application";
      case 5:
        return "Application Registered (QR Code)";
      default:
        return "";
    }
  }

  Widget _buildActionButtons() {
    if (currentStep == 5) return const SizedBox.shrink();
    final isLoading = ref.watch(submitControllerProvider).isLoading;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (currentStep > 1)
          ElevatedButton(
            onPressed: isLoading ? null : _prevStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Back'),
          )
        else
          const SizedBox.shrink(),
        ElevatedButton(
          onPressed: isLoading ? null : _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(currentStep == totalSteps ? 'Confirm & Submit' : 'Next'),
        ),
      ],
    );
  }

  Widget _buildCurrentStepForm() {
    switch (currentStep) {
      case 0:
        return UpdateApplication(
          initialCountry: widget.initialCountry, // 🎯 ဒါလေး ထပ်ထည့်ပေးပါ
          onApplicationFetched: (SubmitRequestModel fetchedData) {
            _injectFetchedData(fetchedData);
          },
        );
      case 1:
        return IdentificationFormLayout(
          controllers: _step1Controllers,
          values: _formValues,
          actionButtons: _buildActionButtons(),
          onValueChanged: _updateFormValue,
          formKey: _step1FormKey,
          onReady: (interfaceLayout) => _step1Interface = interfaceLayout,
        );
      case 2:
        return TripFormLayout(
          controllers: _step2Controllers,
          values: _formValues,
          actionButtons: _buildActionButtons(),
          onValueChanged: _updateFormValue,
          onReady: (interfaceLayout) => _step2Interface = interfaceLayout,
        );
      case 3:
        return DeclarationLayout(
          values: _formValues,
          actionButtons: _buildActionButtons(),
          onValueChanged: _updateFormValue,
          onReady: (interfaceLayout) => _step3Interface = interfaceLayout,
        );
      case 4:
        return ReviewLayout(
          controllers: {..._step1Controllers, ..._step2Controllers},
          values: _formValues,
          actionButtons: _buildActionButtons(),
          onEditRequested: (step) {
            setState(() => currentStep = step);
            _saveCurrentSession();
          },
        );
      case 5:
        return QrGenerateScreen(
          applicationNo: _generatedApplicationNo,
          requestData: _submittedData!,
          onFinish: _resetForm,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isSessionLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                //back button
                if (widget.onBackPressed != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: widget.onBackPressed,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Change Residency"),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ),

                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Please enter your information exactly as shown on official identity records.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 30),
                //we will show form progress bar if current step is >1
                if (currentStep > 0) ...[
                  FormProgressBar(currentStep: currentStep),
                  const SizedBox(height: 15),
                ],
                const SizedBox(height: 15),
                Container(
                  width: 950,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sectionTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildCurrentStepForm(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const FormFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
