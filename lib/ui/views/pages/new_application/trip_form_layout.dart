// lib/ui/views/pages/new_application/trip_form_layout.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/controllers/location_provider.dart';
import 'package:mmac/data/controllers/port_of_arrival_provider.dart';
import 'package:mmac/ui/views/widgets/custom_dropdown_field.dart';
import '../../../../utils/form_validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_date_field.dart';

abstract class TripFormLayoutInterface {
  bool validate();
}

class TripFormLayout extends ConsumerStatefulWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, dynamic> values;
  final Widget actionButtons;
  final Function(String, dynamic) onValueChanged;
  final void Function(TripFormLayoutInterface) onReady;
  final bool isUpdateMode;

  const TripFormLayout({
    super.key,
    required this.controllers,
    required this.values,
    required this.actionButtons,
    required this.onValueChanged,
    required this.onReady,
    required this.isUpdateMode,
  });

  @override
  ConsumerState<TripFormLayout> createState() => _TripFormLayoutState();
}

class _TripFormLayoutState extends ConsumerState<TripFormLayout>
    implements TripFormLayoutInterface {
  // --- State Variables ---
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _showDateErrors = false;
  List<String> _purposeList = [];
  List<String> _accommodationList = [];

  final TextEditingController _otherPurposeController = TextEditingController();
  final TextEditingController _otherAccommodationController =
      TextEditingController();

  // ---------------------------------------------------------------------------
  // LIFECYCLE & INITIALIZATION
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    widget.onReady(this);

    _restoreCustomTextValues();

    Future.microtask(() async {
      if (!mounted) return;

      await _loadPurposeFromJson();
      await _loadAccommodationFromJson();
      await _restoreWaterfallData();
    });
  }

  @override
  void dispose() {
    _otherPurposeController.dispose();
    _otherAccommodationController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // DATA RESTORATION & JSON LOADERS
  // ---------------------------------------------------------------------------

  void _restoreCustomTextValues() {
    // Purpose Session Restore
    final purpose = widget.values['purposeOfVisit'];
    if (purpose != null &&
        !["Visit", "Business", "Education", "Health"].contains(purpose) &&
        purpose.toString().isNotEmpty) {
      _otherPurposeController.text = purpose;
    }

    // Accommodation Session Restore
    final accommodation = widget.values['accommodation'];
    if (accommodation != null &&
        ![
          "Hotel",
          "Motel / Inn",
          "Company Staff Quarter",
          "Relative's House / Friend's House",
          "Apartment / Condo",
          "Monastery / Religious Center",
          "Embassy Housing",
        ].contains(accommodation) &&
        accommodation.toString().isNotEmpty) {
      _otherAccommodationController.text = accommodation;
    }
  }

  Future<void> _loadPurposeFromJson() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/purposes.json',
      );
      if (mounted) {
        setState(() {
          _purposeList = List<String>.from(jsonDecode(response));
          _purposeList.remove("Others");
          _purposeList.add("Others");
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _purposeList = ["Visit", "Business", "Education", "Health", "Others"];
        });
      }
    }
  }

  Future<void> _loadAccommodationFromJson() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/accommodations.json',
      );
      if (mounted) {
        setState(() {
          _accommodationList = List<String>.from(jsonDecode(response));
          _accommodationList.remove("Others");
          _accommodationList.add("Others");
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _accommodationList = [
            "Hotel",
            "Motel / Inn",
            "Company Staff Quarter",
            "Relative's House / Friend's House",
            "Apartment / Condo",
            "Monastery / Religious Center",
            "Embassy Housing",
            "Others",
          ];
        });
      }
    }
  }

  //  THE NAME-TO-ID REVERSE LOOKUP WATERFALL
  Future<void> _restoreWaterfallData() async {
    // --- 1. RESTORE TRAVEL MODE & PORT ---
    String? targetModeName = widget.values['modeOfTravel'];

    if (targetModeName != null) {
      final modeId = targetModeName == "Land"
          ? 2
          : (targetModeName == "Sea" ? 3 : 1);
      widget.onValueChanged('modeOfTravelId', modeId);

      await ref
          .read(portOfArrivalProvider.notifier)
          .loadPortOfArrrivalByModeId(modeId);

      String? targetPortName = widget.values['portOfArrival'];
      if (targetPortName != null) {
        final portState = ref.read(portOfArrivalProvider).valueOrNull;
        if (portState != null) {
          try {
            final p = portState.portOfArrivalList.firstWhere(
              (port) => port.portOfArrivalName == targetPortName,
            );
            widget.onValueChanged('portOfArrivalId', p.portOfArrivalId);
          } catch (_) {}
        }
      }
    }

    // --- 2. RESTORE LOCATIONS CASCADING ---
    var locState = await ref.read(locationProvider.future);
    if (locState.allStates.isEmpty) {
      await ref.read(locationProvider.notifier).retry();
      locState = await ref.read(locationProvider.future);
    }
    if (!mounted || locState.allStates.isEmpty) return;

    // STEP A: Select State & Look up ID
    String? targetStateName = widget.values['stateRegion'];
    if (targetStateName != null) {
      try {
        final s = locState.allStates.firstWhere(
          (st) => st.name == targetStateName,
        );
        widget.onValueChanged('stateRegionId', s.id);
      } catch (_) {}

      ref.read(locationProvider.notifier).selectState(targetStateName);

      // STEP B: Select District & Look up ID
      String? targetDistrictName = widget.values['district'];
      if (targetDistrictName != null) {
        try {
          final s = locState.allStates.firstWhere(
            (st) => st.name == targetStateName,
          );
          final d = s.districts.firstWhere(
            (dst) => dst.name == targetDistrictName,
          );
          widget.onValueChanged('districtId', d.districtId);
        } catch (_) {}

        ref.read(locationProvider.notifier).selectDistrict(targetDistrictName);

        // STEP C: Select Township & Look up ID
        String? targetTownshipName = widget.values['township'];
        if (targetTownshipName != null) {
          try {
            final s = locState.allStates.firstWhere(
              (st) => st.name == targetStateName,
            );
            final d = s.districts.firstWhere(
              (dst) => dst.name == targetDistrictName,
            );
            final t = d.townships.firstWhere(
              (twn) => twn.name == targetTownshipName,
            );
            widget.onValueChanged('townshipId', t.id);
          } catch (_) {}

          ref
              .read(locationProvider.notifier)
              .selectTownship(targetTownshipName);
        }
      }
    }
  }

  // VALIDATORS & GETTERS
  @override
  bool validate() {
    if (!mounted) {
      final bool hasArrivalDate = widget.values['arrivalDate'] != null;
      final bool isFormValid = _formKey.currentState?.validate() ?? true;
      return hasArrivalDate && isFormValid;
    }
    setState(() => _showDateErrors = true);
    return _formKey.currentState!.validate();
  }

  bool get _isOtherPurpose =>
      widget.values['selectedPurposeDropdown'] == "Others" ||
      (widget.values['purposeOfVisit'] != null &&
          widget.values['purposeOfVisit'].toString().isNotEmpty &&
          ![
            "Visit",
            "Business",
            "Education",
            "Health",
          ].contains(widget.values['purposeOfVisit']));

  bool get _isOtherAccommodation =>
      widget.values['selectedAccommodationDropdown'] == "Others" ||
      (widget.values['accommodation'] != null &&
          widget.values['accommodation'].toString().isNotEmpty &&
          ![
            "Hotel",
            "Motel / Inn",
            "Company Staff Quarter",
            "Relative's House / Friend's House",
            "Apartment / Condo",
            "Monastery / Religious Center",
            "Embassy Housing",
          ].contains(widget.values['accommodation']));

  TextEditingController _getSafeController(String key) {
    if (!widget.controllers.containsKey(key)) {
      widget.controllers[key] = TextEditingController(
        text: widget.values[key]?.toString() ?? '',
      );
    } else if (widget.controllers[key]!.text.isEmpty &&
        widget.values[key] != null) {
      widget.controllers[key]!.text = widget.values[key].toString();
    }
    return widget.controllers[key]!;
  }

  // WIDGET BUILDERS (Extracted for Clean Code)
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

  Widget _errorWidget(String message, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.red.shade600, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalDateField() {
    return CustomDateField(
      label: "Arrival Date",
      value: widget.values['arrivalDate'],
      firstDate: DateTime.now(),
      readOnly: widget.isUpdateMode,
      lastDate: DateTime.now().add(const Duration(days: 2)),
      errorText: _showDateErrors && widget.values['arrivalDate'] == null
          ? 'Arrival Date is required'
          : null,
      onPicked: (d) {
        widget.onValueChanged('arrivalDate', d);
        setState(() => _showDateErrors = false);
      },
    );
  }

  Widget _buildModeOfTravelField() {
    return CustomDropdownField(
      label: "Mode of Travel",
      value: widget.values['modeOfTravel'],
      dialogWidth: 100,
      dialogHeight: 200,
      hint: "Select Mode",
      items: const ["Air", "Land", "Sea"],
      validator: (v) => FormValidators.requiredDropdown(v, 'Mode of Travel'),
      onChanged: (v) {
        if (v != null && v != widget.values['modeOfTravel']) {
          final modeId = v == "Land" ? 2 : (v == "Sea" ? 3 : 1);
          widget.onValueChanged('modeOfTravel', v);
          widget.onValueChanged('modeOfTravelId', modeId);
          widget.onValueChanged('portOfArrival', null);
          widget.onValueChanged('portOfArrivalId', null);
          widget.onValueChanged('district', null);
          widget.onValueChanged('districtId', null);
          widget.onValueChanged('township', null);
          widget.onValueChanged('townshipId', null);
          ref
              .read(portOfArrivalProvider.notifier)
              .loadPortOfArrrivalByModeId(modeId);
        }
      },
      spacing: 16,
    );
  }

  Widget _buildPortOfArrivalField(dynamic portState) {
    return CustomDropdownField(
      label: "Port of Arrival",
      value:
          (portState.portOfArrivalList.any(
            (p) => p.portOfArrivalName == widget.values['portOfArrival'],
          ))
          ? widget.values['portOfArrival'] as String?
          : null,
      hint: "Select Port",
      items: portState.portOfArrivalList
          .map<String>((p) => p.portOfArrivalName.toString())
          .toList(),
      dialogWidth: 250,
      dialogHeight: 200,
      validator: (v) => FormValidators.requiredDropdown(v, 'Port of Arrival'),
      onChanged: (v) {
        if (v != null) {
          widget.onValueChanged('portOfArrival', v);
          try {
            final selected = portState.portOfArrivalList.firstWhere(
              (p) => p.portOfArrivalName == v,
            );
            widget.onValueChanged('portOfArrivalId', selected.portOfArrivalId);
            ref
                .read(portOfArrivalProvider.notifier)
                .selectPort(selected.portOfArrivalId);
          } catch (_) {}
        }
      },
      spacing: 16,
    );
  }

  Widget _buildPurposeField() {
    if (_isOtherPurpose) {
      return CustomTextField(
        label: "Purpose of Visit",
        hintText: "Please specify your purpose...",
        controller: _otherPurposeController,
        validator: (v) => FormValidators.required(v, 'Purpose detail'),
        onChanged: (v) {
          widget.onValueChanged('purposeOfVisit', v);
          _getSafeController('purposeOfVisit').text = v;
        },
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.arrow_drop_down_circle_outlined,
            color: Colors.grey,
          ),
          tooltip: "Back to dropdown",
          onPressed: () {
            _otherPurposeController.clear();
            _getSafeController('purposeOfVisit').clear();
            widget.onValueChanged('selectedPurposeDropdown', null);
            widget.onValueChanged('purposeOfVisit', null);
            setState(() {});
          },
        ),
      );
    }
    return CustomDropdownField(
      label: "Purpose of Visit",
      dialogWidth: 300,
      dialogHeight: 250,
      value:
          widget.values['selectedPurposeDropdown'] ??
          ([
                "Visit",
                "Business",
                "Education",
                "Health",
              ].contains(widget.values['purposeOfVisit'])
              ? widget.values['purposeOfVisit']
              : null),
      hint: "Select Purpose",
      items: _purposeList,
      validator: (v) => FormValidators.requiredDropdown(v, 'Purpose of Visit'),
      onChanged: (v) {
        if (v != null) {
          widget.onValueChanged('selectedPurposeDropdown', v);
          if (v != "Others") {
            _otherPurposeController.clear();
            widget.onValueChanged('purposeOfVisit', v);
            _getSafeController('purposeOfVisit').text = v;
          } else {
            widget.onValueChanged('purposeOfVisit', '');
            _getSafeController('purposeOfVisit').text = '';
          }
          setState(() {});
        }
      },
      spacing: 16,
    );
  }

  Widget _buildVehicleNameField() {
    return CustomTextField(
      label: "Vehicle Name",
      controller: _getSafeController('vehicleName'),
      maxLength: 50,
      filter: [FilteringTextInputFormatter.singleLineFormatter],
      validator: (v) => FormValidators.required(v, 'Vehicle Name'),
      onChanged: (v) => widget.onValueChanged('vehicleName', v),
    );
  }

  Widget _buildVehicleNumberField() {
    return CustomTextField(
      label: "Vehicle Number",
      controller: _getSafeController('vehicleNumber'),
      maxLength: 20,
      validator: (v) => FormValidators.required(v, 'Vehicle Number'),
      onChanged: (v) => widget.onValueChanged('vehicleNumber', v),
    );
  }

  Widget _buildStateRegionField(dynamic locationState) {
    return CustomDropdownField(
      label: "State/Region",
      dialogWidth: 300,
      dialogHeight: 250,
      value:
          (locationState.allStates.any(
            (s) => s.name == widget.values['stateRegion'],
          ))
          ? widget.values['stateRegion'] as String?
          : null,
      hint: "Select State/Region",
      items: locationState.allStates
          .map<String>((s) => s.name.toString())
          .toList(),
      validator: (v) => FormValidators.requiredDropdown(v, 'State/Region'),
      onChanged: (v) {
        if (v != widget.values['stateRegion']) {
          widget.onValueChanged('stateRegion', v);
          widget.onValueChanged('district', null);
          widget.onValueChanged('districtId', null);
          widget.onValueChanged('township', null);
          widget.onValueChanged('townshipId', null);

          try {
            final selectedState = locationState.allStates.firstWhere(
              (s) => s.name == v,
            );
            widget.onValueChanged('stateRegionId', selectedState.id);
          } catch (_) {}

          ref.read(locationProvider.notifier).selectState(v);
        }
      },
      spacing: 16,
    );
  }

  Widget _buildDistrictField(dynamic locationState) {
    return CustomDropdownField(
      label: "District",
      dialogWidth: 300,
      dialogHeight: 250,
      value:
          (locationState.availableDistricts.contains(widget.values['district']))
          ? widget.values['district'] as String?
          : null,
      hint: "Select District",
      items: locationState.availableDistricts,
      validator: (v) => FormValidators.requiredDropdown(v, 'District'),
      onChanged: (v) {
        if (v != widget.values['district']) {
          widget.onValueChanged('district', v);
          widget.onValueChanged('township', null);
          widget.onValueChanged('townshipId', null);
          try {
            final selectedState = locationState.allStates.firstWhere(
              (s) => s.name == widget.values['stateRegion'],
            );
            final selectedDist = selectedState.districts.firstWhere(
              (d) => d.name == v,
            );
            widget.onValueChanged('districtId', selectedDist.districtId);
          } catch (_) {}

          ref.read(locationProvider.notifier).selectDistrict(v);
        }
      },
      spacing: 16,
    );
  }

  Widget _buildTownshipField(dynamic locationState) {
    return CustomDropdownField(
      label: "Township",
      dialogWidth: 300,
      dialogHeight: 250,
      value:
          (locationState.availableTownships.contains(widget.values['township']))
          ? widget.values['township'] as String?
          : null,
      hint: "Select Township",
      items: locationState.availableTownships,
      validator: (v) => FormValidators.requiredDropdown(v, 'Township'),
      onChanged: (v) {
        if (v != widget.values['township']) {
          widget.onValueChanged('township', v);
          try {
            final selectedState = locationState.allStates.firstWhere(
              (s) => s.name == widget.values['stateRegion'],
            );
            final selectedDist = selectedState.districts.firstWhere(
              (d) => d.name == widget.values['district'],
            );
            final selectedTown = selectedDist.townships.firstWhere(
              (t) => t.name == v,
            );
            widget.onValueChanged('townshipId', selectedTown.id);
          } catch (_) {}
        }
      },
      spacing: 16,
    );
  }

  Widget _buildAddressInMyanmarField() {
    return CustomTextField(
      label: "Address in Myanmar",
      maxLength: 100,
      controller: _getSafeController('addressInMyanmar'),
      validator: (v) => FormValidators.required(v, 'Address in Myanmar'),
      onChanged: (v) => widget.onValueChanged('addressInMyanmar', v),
    );
  }

  Widget _buildPreviousCityField() {
    return CustomTextField(
      label: "Previous City",
      controller: _getSafeController('previousCity'),
      maxLength: 50,
      filter: [
        FilteringTextInputFormatter.singleLineFormatter,
        LengthLimitingTextInputFormatter(50),
      ],
      validator: (v) => FormValidators.required(v, 'Previous City'),
      onChanged: (v) => widget.onValueChanged('previousCity', v),
    );
  }

  Widget _buildMobileNumberMMField() {
    return CustomTextField(
      label: "Mobile Number(MM)",
      hintText: "09XXXXXXXXX",
      keyboardtype: TextInputType.number,
      filter: [FilteringTextInputFormatter.digitsOnly],
      maxLength: 11,
      controller: _getSafeController('mobileNumberMM'),
      validator: (v) => FormValidators.mobileNumber(v),
      onChanged: (v) => widget.onValueChanged('mobileNumberMM', v),
    );
  }

  Widget _buildAccommodationField() {
    if (_isOtherAccommodation) {
      return CustomTextField(
        label: "Accommodation Type",
        hintText: "Please specify your accommodation...",
        controller: _otherAccommodationController,
        validator: (v) => FormValidators.required(v, 'Accommodation detail'),
        onChanged: (v) {
          widget.onValueChanged('accommodation', v);
          _getSafeController('accommodation').text = v;
        },
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.arrow_drop_down_circle_outlined,
            color: Colors.grey,
          ),
          tooltip: "Back to dropdown",
          onPressed: () {
            _otherAccommodationController.clear();
            _getSafeController('accommodation').clear();
            widget.onValueChanged('selectedAccommodationDropdown', null);
            widget.onValueChanged('accommodation', null);
            setState(() {});
          },
        ),
      );
    }
    return CustomDropdownField(
      label: "Accommodation Type",
      dialogWidth: 300,
      dialogHeight: 250,
      value:
          widget.values['selectedAccommodationDropdown'] ??
          (_accommodationList.contains(widget.values['accommodation'])
              ? widget.values['accommodation']
              : null),
      hint: "Select Accommodation",
      items: _accommodationList,
      validator: (v) => FormValidators.requiredDropdown(v, 'Accommodation'),
      onChanged: (v) {
        if (v != null) {
          widget.onValueChanged('selectedAccommodationDropdown', v);
          if (v != "Others") {
            _otherAccommodationController.clear();
            widget.onValueChanged('accommodation', v);
            _getSafeController('accommodation').text = v;
          } else {
            widget.onValueChanged('accommodation', '');
            _getSafeController('accommodation').text = '';
          }
          setState(() {});
        }
      },
      spacing: 16,
    );
  }

  // MAIN BUILD METHOD
  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationProvider);
    final portAsync = ref.watch(portOfArrivalProvider);

    final locationState = locationAsync.valueOrNull;
    final portState = portAsync.valueOrNull;

    final locationFirstLoad = locationState == null && !locationAsync.hasError;
    final portFirstLoad = portState == null && !portAsync.hasError;

    if (locationFirstLoad || portFirstLoad) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 500;
        final bool isMyanmar =
            widget.values['country'] == 'Myanmar' ||
            widget.values['country'] == 'MMR';

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  Row 1: Arrival Date | Mode of Travel
              _buildPair(
                _buildArrivalDateField(),
                _buildModeOfTravelField(),
                isDesktop,
              ),
              const SizedBox(height: 16),

              //  Row 2: Port of Arrival | Purpose of Visit
              if (portAsync.hasError)
                _errorWidget('Port of arrival failed to load', () {
                  final mode = widget.values['modeOfTravel'];
                  final modeId = mode == "Land" ? 2 : (mode == "Sea" ? 3 : 1);
                  ref
                      .read(portOfArrivalProvider.notifier)
                      .loadPortOfArrrivalByModeId(modeId);
                })
              else
                _buildPair(
                  _buildPortOfArrivalField(portState),
                  _buildPurposeField(),
                  isDesktop,
                ),
              const SizedBox(height: 16),

              //  Row 3: Vehicle Name | Vehicle Number
              _buildPair(
                _buildVehicleNameField(),
                _buildVehicleNumberField(),
                isDesktop,
              ),
              const SizedBox(height: 16),

              //  Row 4: State/Region | District
              _buildPair(
                _buildStateRegionField(locationState),
                _buildDistrictField(locationState),
                isDesktop,
              ),
              const SizedBox(height: 16),

              //  Row 5: Township | Address in Myanmar
              _buildPair(
                _buildTownshipField(locationState),
                _buildAddressInMyanmarField(),
                isDesktop,
              ),
              const SizedBox(height: 16),

              // Row 6: Previous City | Mobile/Accommodation
              _buildPair(
                _buildPreviousCityField(),
                isMyanmar
                    ? _buildMobileNumberMMField()
                    : _buildAccommodationField(),
                isDesktop,
              ),
              const SizedBox(height: 30),

              // Action Buttons
              widget.actionButtons,
            ],
          ),
        );
      },
    );
  }
}
