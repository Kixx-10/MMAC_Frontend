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

  const TripFormLayout({
    super.key,
    required this.controllers,
    required this.values,
    required this.actionButtons,
    required this.onValueChanged,
    required this.onReady,
  });

  @override
  ConsumerState<TripFormLayout> createState() => _TripFormLayoutState();
}

class _TripFormLayoutState extends ConsumerState<TripFormLayout>
    implements TripFormLayoutInterface {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _showDateErrors = false;
  List<String> _purposeList = [];

  // "Others" text controller
  final TextEditingController _otherPurposeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.onReady(this);

    if (widget.values['purposeOfVisit'] != null &&
        ![
          "Visit",
          "Business",
          "Education",
          "Health",
        ].contains(widget.values['purposeOfVisit']) &&
        widget.values['purposeOfVisit'].toString().isNotEmpty) {
      _otherPurposeController.text = widget.values['purposeOfVisit'];
    }

    Future.microtask(() async {
      if (!mounted) return;

      // 1. Purpose နဲ့ Port တွေကို အရင် Load မည်
      _loadPurposeFromJson();
      try {
        final currentMode = widget.values['modeOfTravel'];
        final modeId = currentMode == "Land"
            ? 2
            : currentMode == "Sea"
            ? 3
            : 1;
        ref
            .read(portOfArrivalProvider.notifier)
            .loadPortOfArrrivalByModeId(modeId);
      } catch (_) {}

      // 🎯 The Magic Fix: Direct Synchronous Cascade (ရိုးရှင်းပြီး အမှားကင်းတဲ့နည်းလမ်း)
      try {
        // ၁။ API ကနေ State တွေ အကုန်ကျလာတဲ့အထိ အရင်စောင့်မယ်
        var locState = await ref.read(locationProvider.future);
        if (locState.allStates.isEmpty) {
          await ref.read(locationProvider.notifier).retry();
          locState = await ref.read(locationProvider.future);
        }

        // ၂။ အချက်အလက်တွေ အဆင်သင့်ဖြစ်ပြီဆိုရင် အဆင့်ဆင့် တိုက်ရိုက် Restore လုပ်မယ်
        if (mounted && locState.allStates.isNotEmpty) {
          final savedState = widget.values['stateRegion'];
          final savedDistrict = widget.values['district'];
          final savedTownship = widget.values['township'];

          if (savedState != null) {
            // အဆင့် ၁: State ကို ရွေးလိုက်တာနဲ့ District စာရင်း ချက်ချင်းထွက်လာမယ်
            ref.read(locationProvider.notifier).selectState(savedState);

            if (savedDistrict != null) {
              // အဆင့် ၂: District ကို ရွေးလိုက်တာနဲ့ Township စာရင်း ချက်ချင်းထွက်လာမယ်
              ref.read(locationProvider.notifier).selectDistrict(savedDistrict);

              if (savedTownship != null) {
                // အဆင့် ၃: Township ကို ရွေးပေးလိုက်မယ်
                ref
                    .read(locationProvider.notifier)
                    .selectTownship(savedTownship);
              }
            }
          }
        }
      } catch (e) {
        debugPrint("❌ Location Restore Error: $e");
      }
    });
  }

  @override
  void dispose() {
    _otherPurposeController.dispose();
    super.dispose();
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

  // 🎯 Controller ထဲကို Session ထဲက ဒေတာတွေ မှန်မှန်ကန်ကန် စီးဝင်သွားအောင် ပြင်ဆင်ခြင်း
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

  Widget _row(Widget l, Widget r) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: l),
      const SizedBox(width: 40),
      Expanded(child: r),
    ],
  );

  Widget _column(Widget t, Widget b) =>
      Column(children: [t, const SizedBox(height: 16), b]);

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

  Widget _buildPurposeField() {
    if (_isOtherPurpose) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: SizedBox(
              width: 140,
              child: RichText(
                text: const TextSpan(
                  text: 'Purpose of Visit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
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
            child: TextFormField(
              controller: _otherPurposeController,
              autofocus: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) => FormValidators.required(v, 'Purpose detail'),
              onChanged: (v) {
                widget.onValueChanged('purposeOfVisit', v);
              },
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: "Please specify your purpose...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.arrow_drop_down_circle_outlined,
                    color: Colors.grey,
                  ),
                  tooltip: "Back to dropdown",
                  onPressed: () {
                    _otherPurposeController.clear();
                    widget.onValueChanged('selectedPurposeDropdown', null);
                    widget.onValueChanged('purposeOfVisit', null);
                    setState(() {});
                  },
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
              ),
            ),
          ),
        ],
      );
    }
    return CustomDropdownField(
      label: "Purpose of Visit",
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
          } else {
            widget.onValueChanged('purposeOfVisit', '');
          }
          setState(() {});
        }
      },
      spacing: 16,
    );
  }

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
        Widget pair(Widget a, Widget b) =>
            isDesktop ? _row(a, b) : _column(a, b);

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Arrival Date | Mode of Travel
              pair(
                CustomDateField(
                  label: "Arrival Date",
                  value: widget.values['arrivalDate'],
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  errorText:
                      _showDateErrors && widget.values['arrivalDate'] == null
                      ? 'Arrival Date is required'
                      : null,
                  onPicked: (d) {
                    widget.onValueChanged('arrivalDate', d);
                    setState(() => _showDateErrors = false);
                  },
                ),
                CustomDropdownField(
                  label: "Mode of Travel",
                  value: widget.values['modeOfTravel'],
                  dialogWidth: 100,
                  dialogHeight: 200,
                  hint: "Select Mode",
                  items: const ["Air", "Land", "Sea"],
                  validator: (v) =>
                      FormValidators.requiredDropdown(v, 'Mode of Travel'),
                  onChanged: (v) {
                    if (v != null && v != widget.values['modeOfTravel']) {
                      final modeId = v == "Land"
                          ? 2
                          : v == "Sea"
                          ? 3
                          : 1;
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
                ),
              ),
              const SizedBox(height: 16),

              // Row 2: Port of Arrival | Vehicle Number
              if (portAsync.hasError)
                _errorWidget('Port of arrival failed to load', () {
                  final mode = widget.values['modeOfTravel'];
                  final modeId = mode == "Land"
                      ? 2
                      : mode == "Sea"
                      ? 3
                      : 1;
                  ref
                      .read(portOfArrivalProvider.notifier)
                      .loadPortOfArrrivalByModeId(modeId);
                })
              else ...[
                pair(
                  CustomDropdownField(
                    label: "Port of Arrival",
                    value:
                        (portState!.portOfArrivalList.any(
                          (p) =>
                              p.portOfArrivalName ==
                              widget.values['portOfArrival'],
                        ))
                        ? widget.values['portOfArrival'] as String?
                        : null,
                    hint: "Select Port",
                    items: portState.portOfArrivalList
                        .map((p) => p.portOfArrivalName.toString())
                        .toList(),
                    dialogWidth: 250,
                    dialogHeight: 200,
                    validator: (v) =>
                        FormValidators.requiredDropdown(v, 'Port of Arrival'),
                    onChanged: (v) {
                      if (v != null) {
                        widget.onValueChanged('portOfArrival', v);
                        try {
                          final selected = portState.portOfArrivalList
                              .firstWhere((p) => p.portOfArrivalName == v);
                          widget.onValueChanged(
                            'portOfArrivalId',
                            selected.portOfArrivalId,
                          );
                          ref
                              .read(portOfArrivalProvider.notifier)
                              .selectPort(selected.portOfArrivalId);
                        } catch (_) {}
                      }
                    },
                    spacing: 16,
                  ),
                  CustomTextField(
                    label: "Vehicle Number",
                    controller: _getSafeController('vehicleNumber'),
                    maxLength: 15,
                    validator: (v) =>
                        FormValidators.required(v, 'Vehicle Number'),
                    onChanged: (v) {
                      widget.onValueChanged('vehicleNumber', v);
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Row 3: Vehicle Name | State/Region
              pair(
                CustomTextField(
                  label: "Vehicle Name",
                  hintText: "Flight, Vessel, Bus name etc.",
                  controller: _getSafeController('vehicleName'),
                  maxLength: 50,
                  validator: (v) => FormValidators.required(v, 'Vehicle Name'),
                  onChanged: (v) {
                    widget.onValueChanged('vehicleName', v);
                  },
                ),
                CustomDropdownField(
                  label: "State/Region",
                  dialogWidth: 300,
                  dialogHeight: 250,
                  value:
                      (locationState!.allStates.any(
                        (s) => s.name == widget.values['stateRegion'],
                      ))
                      ? widget.values['stateRegion'] as String?
                      : null,
                  hint: "Select State/Region",
                  items: locationState.allStates
                      .map((s) => s.name.toString())
                      .toList(),
                  validator: (v) =>
                      FormValidators.requiredDropdown(v, 'State/Region'),
                  onChanged: (v) {
                    if (v != widget.values['stateRegion']) {
                      widget.onValueChanged('stateRegion', v);
                      widget.onValueChanged('district', null);
                      widget.onValueChanged('districtId', null);
                      widget.onValueChanged('township', null);
                      widget.onValueChanged('townshipId', null);

                      try {
                        final selectedState = locationState.allStates
                            .firstWhere((s) => s.name == v);
                        widget.onValueChanged(
                          'stateRegionId',
                          selectedState.id,
                        );
                      } catch (_) {}

                      ref.read(locationProvider.notifier).selectState(v);
                    }
                  },
                  spacing: 16,
                ),
              ),
              const SizedBox(height: 16),

              // Row 4: District | Township
              pair(
                CustomDropdownField(
                  label: "District",
                  dialogWidth: 300,
                  dialogHeight: 250,
                  value:
                      (locationState.availableDistricts.contains(
                        widget.values['district'],
                      ))
                      ? widget.values['district'] as String?
                      : null,
                  hint: "Select District",
                  items: locationState.availableDistricts,
                  validator: (v) =>
                      FormValidators.requiredDropdown(v, 'District'),
                  onChanged: (v) {
                    if (v != widget.values['district']) {
                      widget.onValueChanged('district', v);
                      widget.onValueChanged('township', null);
                      widget.onValueChanged('townshipId', null);
                      try {
                        final selectedState = locationState.allStates
                            .firstWhere(
                              (s) => s.name == widget.values['stateRegion'],
                            );
                        final selectedDist = selectedState.districts.firstWhere(
                          (d) => d.name == v,
                        );
                        widget.onValueChanged(
                          'districtId',
                          selectedDist.districtId,
                        );
                      } catch (_) {}

                      ref.read(locationProvider.notifier).selectDistrict(v);
                    }
                  },
                  spacing: 16,
                ),
                CustomDropdownField(
                  label: "Township",
                  dialogWidth: 300,
                  dialogHeight: 250,
                  value:
                      (locationState.availableTownships.contains(
                        widget.values['township'],
                      ))
                      ? widget.values['township'] as String?
                      : null,
                  hint: "Select Township",
                  items: locationState.availableTownships,
                  validator: (v) =>
                      FormValidators.requiredDropdown(v, 'Township'),
                  onChanged: (v) {
                    if (v != widget.values['township']) {
                      widget.onValueChanged('township', v);
                      try {
                        final selectedState = locationState.allStates
                            .firstWhere(
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
                ),
              ),
              const SizedBox(height: 16),

              // Row 5: Address in Myanmar | Accommodation
              pair(
                CustomTextField(
                  label: "Address in Myanmar",
                  maxLength: 150,
                  controller: _getSafeController('addressInMyanmar'),
                  validator: (v) =>
                      FormValidators.required(v, 'Address in Myanmar'),
                  onChanged: (v) {
                    widget.onValueChanged('addressInMyanmar', v);
                  },
                ),
                CustomTextField(
                  label: "Accommodation",
                  controller: _getSafeController('accommodation'),
                  maxLength: 100,
                  validator: (v) => FormValidators.required(v, 'Accommodation'),
                  onChanged: (v) {
                    widget.onValueChanged('accommodation', v);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Row 6: Mobile Number | Purpose of Visit
              pair(
                CustomTextField(
                  label: "Mobile Number (MM)",
                  hintText: "09xxxxxxxx",
                  maxLength: 11,
                  controller: _getSafeController('mobileNumberMM'),
                  validator: (v) => FormValidators.required(v, 'Mobile Number'),
                  onChanged: (v) {
                    widget.onValueChanged('mobileNumberMM', v);
                  },
                ),
                _buildPurposeField(),
              ),
              const SizedBox(height: 16),

              // Row 7: Previous City | Layout Spacer
              pair(
                CustomTextField(
                  label: "Previous City",
                  controller: _getSafeController('previousCity'),
                  validator: (v) => FormValidators.required(v, 'Previous City'),
                  onChanged: (v) {
                    widget.onValueChanged('previousCity', v);
                  },
                ),
                const SizedBox(),
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
