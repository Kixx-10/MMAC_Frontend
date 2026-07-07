import 'dart:convert';
import 'dart:developer';
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
  final SubmitRequestModel? initialData;

  const NewApplication({
    super.key,
    this.initialCountry,
    this.onBackPressed,
    this.isUpdateMode = false,
    this.initialData,
  });

  @override
  ConsumerState<NewApplication> createState() => _NewApplicationState();
}

class _NewApplicationState extends ConsumerState<NewApplication>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // ---------------------------------------------------------------------------
  // STATE VARIABLES
  // ---------------------------------------------------------------------------
  int currentStep = 1;
  final int totalSteps = 4;
  bool _isSessionLoading = true;

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
    'uid': TextEditingController(),
    'occupation': TextEditingController(),
  };

  final Map<String, TextEditingController> _step2Controllers = {
    'vehicleNumber': TextEditingController(),
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
    //'country': null,
    'nationalityCode': null,
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
    'attachmentFile': null,
    'carryingRestricted': null,
    'nrcStateCode': null,
    'nrcTownshipCode': null,
    'nrcTypeCode': null,
    'nrcRawNumber': null,
    'placeOfBirthCode': null,
  };

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    if (widget.isUpdateMode) currentStep = 0;
    if (widget.initialData != null) currentStep = 1;
    _loadSavedSession();
  }

  @override
  void dispose() {
    _step1Controllers.forEach((_, controller) => controller.dispose());
    _step2Controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // DATA INJECTION & SESSION MANAGEMENT
  // ---------------------------------------------------------------------------
  Future<void> _loadSavedSession() async {
    try {
      if (widget.initialData != null) {
        setState(() => _injectFetchedData(widget.initialData!));
        return;
      }

      final sessionData = await FormSessionService.loadDraft(
        isUpdateMode: widget.isUpdateMode,
      );

      if (sessionData != null && mounted) {
        setState(() {
          if (sessionData['currentStep'] != null) {
            currentStep = sessionData['currentStep'] as int;
          }

          if (sessionData['values'] != null) {
            final Map<String, dynamic> savedValues = Map<String, dynamic>.from(
              sessionData['values'],
            );

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
                  savedValues[field] = null;
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
            _formValues['nationalityCode'] = 'MMR';
          } else {
            _formValues['country'] = null;
            _formValues['nationalityCode'] = null;
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
    _step1Controllers.forEach(
      (key, controller) => _formValues[key] = controller.text,
    );
    _step2Controllers.forEach(
      (key, controller) => _formValues[key] = controller.text,
    );

    final Map<String, dynamic> dataToSave = Map<String, dynamic>.from(
      _formValues,
    );

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

    FormSessionService.saveDraft(
      dataToSave,
      currentStep,
      isUpdateMode: widget.isUpdateMode,
    );
  }

  void _updateFormValue(String key, dynamic value) {
    Future.microtask(() {
      if (mounted) {
        setState(() => _formValues[key] = value);
        _saveCurrentSession();
      }
    });
  }

  void _injectFetchedData(SubmitRequestModel fetchedData) {
    try {
      final prettyJson = const JsonEncoder.withIndent(
        '  ',
      ).convert(fetchedData.toJson());
      log("INJECTING FETCHED DATA:\n$prettyJson", name: "NewApplicationPage");
    } catch (e) {
      log("Failed to log fetched data: $e", name: "NewApplicationPage");
    }

    setState(() {
      _formValues['qrReference'] = fetchedData.qrReference;
      _step1Controllers['fullName']?.text = fetchedData.fullName;
      _step1Controllers['email']?.text = fetchedData.email;
      _step1Controllers['mobile']?.text = fetchedData.mobileNumber;
      _step1Controllers['visaNumber']?.text = fetchedData.visaNo ?? '';
      _step1Controllers['passportNumber']?.text = fetchedData.passportNo;
      _step1Controllers['address']?.text = fetchedData.address;
      _step1Controllers['fatherName']?.text = fetchedData.fatherName ?? '';

      _step2Controllers['vehicleNumber']?.text = fetchedData.vehicleNumber;
      _step2Controllers['accommodation']?.text =
          fetchedData.accommodation ?? '';
      _step2Controllers['addressInMyanmar']?.text =
          fetchedData.addressInMyanmar;
      _step2Controllers['mobileNumberMM']?.text =
          fetchedData.mobileNumberMM ?? '';
      _step2Controllers['previousCity']?.text = fetchedData.previousCity;
      _step2Controllers['purposeOfVisitDetail']?.text =
          fetchedData.purposeOfVisit;

      _formValues['gender'] = fetchedData.gender == 'M' ? 'Male' : 'Female';

      if (fetchedData.nrc != null && fetchedData.nrc!.isNotEmpty) {
        _step1Controllers['nrc']?.text = fetchedData.nrc!;
        _parseAndInjectNrc(fetchedData.nrc!);
      }

      if (fetchedData.dob.isNotEmpty) {
        _formValues['dateOfBirth'] = DateTime.parse(fetchedData.dob);
      }
      if (fetchedData.issuedDate.isNotEmpty) {
        _formValues['issuedDate'] = DateTime.parse(fetchedData.issuedDate);
      }
      if (fetchedData.expiryDate.isNotEmpty) {
        _formValues['expiryDate'] = DateTime.parse(fetchedData.expiryDate);
      }
      if (fetchedData.arrivalDate.isNotEmpty) {
        _formValues['arrivalDate'] = DateTime.parse(fetchedData.arrivalDate);
      }

      _formValues['nationalityCode'] = fetchedData.nationalityCode;
      _formValues['issuedCountryCode'] = fetchedData.issuedCountryCode;
      _formValues['modeOfTravel'] = fetchedData.modeOfTravelName;
      _formValues['portOfArrival'] = fetchedData.portOfArrivalName;
      _formValues['stateRegion'] = fetchedData.stateRegionName;
      _formValues['district'] = fetchedData.districtName;
      _formValues['township'] = fetchedData.townshipName;

      _formValues['modeOfTravelId'] = fetchedData.modeOfTravelId;
      _formValues['portOfArrivalId'] = fetchedData.portOfArrivalId;
      _formValues['stateRegionId'] = fetchedData.stateRegionId;
      _formValues['districtId'] = fetchedData.districtId;
      _formValues['townshipId'] = fetchedData.townshipId;
      _formValues['purposeOfVisit'] = fetchedData.purposeOfVisit;
      _formValues['hasSymptoms'] = fetchedData.healthDeclaration;
      _formValues['attachmentFile'] = fetchedData.healthRecordUrl;
      _formValues['carryingRestricted'] = fetchedData.digitalDeclarations;

      currentStep = 1;
    });

    _saveCurrentSession();
  }

  // 🎯 EXTRACTED: Pure function to parse NRC cleanly
  void _parseAndInjectNrc(String nrc) {
    try {
      final firstSplit = nrc.split('/');
      if (firstSplit.length == 2) {
        _formValues['nrcStateCode'] = firstSplit[0];

        final secondSplit = firstSplit[1].split('(');
        if (secondSplit.length == 2) {
          _formValues['nrcTownshipCode'] = secondSplit[0];

          final thirdSplit = secondSplit[1].split(')');
          if (thirdSplit.length == 2) {
            _formValues['nrcTypeCode'] = thirdSplit[0];
            _formValues['nrcRawNumber'] = thirdSplit[1];
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ Failed to parse NRC segments: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // HELPERS & VALIDATORS
  // ---------------------------------------------------------------------------
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
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
    return date.toString();
  }

  String _genderCode(String? gender) =>
      gender == 'Male' ? 'M' : (gender == 'Female' ? 'F' : '');

  bool _isStep1DataValid() =>
      _text('fullName').isNotEmpty &&
      _text('email').isNotEmpty &&
      _formValues['gender'] != null &&
      _formValues['dateOfBirth'] != null;

  bool _isStep2DataValid() =>
      _formValues['arrivalDate'] != null &&
      _formValues['portOfArrivalId'] != null &&
      _formValues['townshipId'] != null &&
      _formValues['purposeOfVisit'] != null;

  bool _isStep3DataValid() =>
      _formValues['hasSymptoms'] != null &&
      _formValues['carryingRestricted'] != null;

  // ---------------------------------------------------------------------------
  // NAVIGATION & SUBMISSION
  // ---------------------------------------------------------------------------
  void _nextStep() {
    if (currentStep == 1) {
      if (_step1Interface == null) {
        return _showError('Form not ready, please wait.');
      }
      if (_step1Interface!.validate()) {
        setState(() => currentStep++);
        _saveCurrentSession();
      } else {
        final errors = _step1Interface!.getValidationErrors();
        if (errors.isNotEmpty) {
          _showErrorDialog(
            "Please fill in the following required fields:\n\n• ${errors.join('\n• ')}",
          );
        }
      }
    } else if (currentStep == 2) {
      if (_step2Interface == null) {
        return _showError('Form not ready, please wait.');
      }
      if (_step2Interface!.validate()) {
        setState(() => currentStep++);
        _saveCurrentSession();
      } else {
        final errors = _step2Interface!.getValidationErrors();
        if (errors.isNotEmpty) {
          _showErrorDialog(
            "Please fill in the following required fields:\n\n• ${errors.join('\n• ')}",
          );
        }
      }
    } else if (currentStep == 3) {
      if (_step3Interface == null) {
        return _showError('Form not ready, please wait.');
      }
      if (_step3Interface!.validate()) {
        setState(() => currentStep++);
        _saveCurrentSession();
      } else {
        final errors = _step3Interface!.getValidationErrors();
        if (errors.isNotEmpty) {
          _showErrorDialog(
            "Please fill in the following required fields:\n\n• ${errors.join('\n• ')}",
          );
        }
      }
    } else if (currentStep == 4) {
      if (!_isStep1DataValid()) {
        return _handleValidationError(1, 'Please check Section 1.');
      }
      if (!_isStep2DataValid()) {
        return _handleValidationError(2, 'Please check Section 2.');
      }
      if (!_isStep3DataValid()) {
        return _handleValidationError(3, 'Please check Section 3.');
      }
      _submitApplication();
    }
  }

  void _handleValidationError(int step, String message) {
    setState(() => currentStep = step);
    _showError(message);
  }

  void _prevStep() {
    if (currentStep > 1) {
      setState(() => currentStep--);
      _saveCurrentSession();
    }
  }

  SubmitRequestModel _buildRequestModel() {
    final String? secureQrReference =
        (widget.isUpdateMode && widget.initialData != null)
        ? widget.initialData!.qrReference
        : _formValues['qrReference'];

    return SubmitRequestModel(
      qrReference: secureQrReference,
      fullName: _text('fullName'),
      gender: _genderCode(_formValues['gender']),
      dob: _formatDate(_formValues['dateOfBirth']),
      nationalityCode: _safeString(_formValues['nationalityCode']),
      email: _text('email'),
      mobileNumber: _text('mobile'),
      address: _text('address'),
      visaNo: _text('visaNumber'),
      nrc: _isMyanmar ? _text('nrc') : '',
      fatherName: _isMyanmar ? _text('fatherName') : '',
      passportNo: _text('passportNumber'),
      issuedCountryCode: _safeString(_formValues['issuedCountryCode']),
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
      accommodation: _text('accommodation'),
      previousCity: _text('previousCity'),
      healthDeclaration: _safeString(_formValues['hasSymptoms']),
      digitalDeclarations: _safeString(_formValues['carryingRestricted']),
      uid: _text('uid'),
      occupation: _text('occupation'),
      placeOfBirthCode: _safeString(_formValues['placeOfBirthCode']),
      healthAttachmentBase64: _safeString(_formValues['healthAttachmentBase64']),
      healthAttachmentName: _safeString(_formValues['healthAttachmentName']),
    );
  }

  Future<void> _submitApplication() async {
    _showLoadingDialog();

    try {
      final requestModel = _buildRequestModel();
      log("PAYLOAD: ${jsonEncode(requestModel.toJson())}", name: "Submit");

      final response = await ref
          .read(submitControllerProvider.notifier)
          .submitApplicationAction(requestModel);

      if (mounted) Navigator.of(context).pop(); // Close loading

      if (response != null) {
        _handleSuccess(response, requestModel);
      } else {
        _showErrorDialog('The server could not process your application.');
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // Close loading
      _showErrorDialog(e.toString().replaceAll("Exception: ", ""));
    }
  }

  void _handleSuccess(dynamic response, SubmitRequestModel requestModel) {
    FormSessionService.clearDraft(isUpdateMode: widget.isUpdateMode);
    setState(() {
      currentStep = 5;
    });
  }

  // ---------------------------------------------------------------------------
  // UI BUILDERS
  // ---------------------------------------------------------------------------
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
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
        return "";
      case 2:
        return "";
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
            child: const Text(
              'Back',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
              : Text(
                  currentStep == totalSteps
                      ? (widget.isUpdateMode ? 'Update' : 'Confirm & Submit')
                      : 'Next',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Widget _buildCurrentStepForm() {
    switch (currentStep) {
      case 0:
        return UpdateApplication(
          onBackPressed: widget.onBackPressed ?? () {},
          initialCountry: widget.initialCountry,
          onApplicationFetched: _injectFetchedData,
        );
      case 1:
        return IdentificationFormLayout(
          controllers: _step1Controllers,
          values: _formValues,
          actionButtons: _buildActionButtons(),
          onValueChanged: _updateFormValue,
          isUpdateMode: widget.isUpdateMode,
          formKey: _step1FormKey,
          onReady: (interfaceLayout) => _step1Interface = interfaceLayout,
          onBackPressed: widget.onBackPressed ?? () {},
        );
      case 2:
        return TripFormLayout(
          controllers: _step2Controllers,
          values: _formValues,
          actionButtons: _buildActionButtons(),
          onValueChanged: _updateFormValue,
          isUpdateMode: widget.isUpdateMode,
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
          isUpdateMode: widget.isUpdateMode,
          onEditRequested: (step) {
            setState(() => currentStep = step);
            _saveCurrentSession();
          },
        );
      case 5:
        final submitState = ref.watch(submitControllerProvider);
        return submitState.when(
          data: (submitResponse) {
            if (submitResponse != null) {
              return QrGenerateScreen(
                responseData: submitResponse,
                requestData: _buildRequestModel(),

                onFinish: () {
                  setState(() {
                    currentStep = 1;
                    _formValues.clear();
                    _step1Controllers.forEach((_, c) => c.clear());
                    _step2Controllers.forEach((_, c) => c.clear());
                  });
                  FormSessionService.clearDraft(
                    isUpdateMode: widget.isUpdateMode,
                  );
                },
                email: _text('email'),
              );
            }
            return const Center(child: Text("No response data found."));
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    "Submitting Application & Generating PDF...",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Submission Failed: ${error.toString()}",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFormHeader() {
    if (currentStep <= 0) return const SizedBox.shrink();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Please enter your information exactly as shown on official identity records.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 30),
        FormProgressBar(currentStep: currentStep),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: 1200,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_sectionTitle.isNotEmpty) ...[
                Text(
                  _sectionTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              _buildCurrentStepForm(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

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
                const SizedBox(height: 20),
                _buildFormHeader(),
                const SizedBox(height: 15),
                _buildFormCard(),
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
