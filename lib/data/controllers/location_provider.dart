import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/reposistories/location_repository.dart';
import '../models/location_models.dart'; 
// REPOSITORY
//  RIVERPOD STATE & NOTIFIER

class LocationState {
  final List<StateContainerModel> allStates;            
  final List<String> availableDistricts;     
  final List<String> availableTownships;     
  final String? selectedStateName;           
  final String? selectedDistrictName;        
  final String? selectedTownshipName;        

  const LocationState({
    this.allStates            = const [],
    this.availableDistricts   = const [],
    this.availableTownships   = const [],
    this.selectedStateName,
    this.selectedDistrictName,
    this.selectedTownshipName,
  });

  LocationState copyWith({
    List<StateContainerModel>? allStates,
    List<String>? availableDistricts,
    List<String>? availableTownships,
    String? selectedStateName,
    String? selectedDistrictName,
    String? selectedTownshipName,
    bool clearDistrict  = false, 
    bool clearTownship  = false, 
  }) {
    return LocationState(
      allStates:            allStates            ?? this.allStates,
      availableDistricts:   availableDistricts   ?? this.availableDistricts,
      availableTownships:   availableTownships   ?? this.availableTownships,
      selectedStateName:    selectedStateName    ?? this.selectedStateName,
      selectedDistrictName: clearDistrict ? null : (selectedDistrictName ?? this.selectedDistrictName),
      selectedTownshipName: clearTownship ? null : (selectedTownshipName ?? this.selectedTownshipName),
    );
  }
}

class LocationNotifier extends AsyncNotifier<LocationState> {
  final LocationRepository _repository = LocationRepository();

  @override
  Future<LocationState> build() async {
    return _fetchLocations();
  }

  Future<LocationState> _fetchLocations() async {
    try {
      final locations = await _repository.fetchMyanmarLocations();
      return LocationState(allStates: locations);
    } catch (e) {
      debugPrint("❌ Notifier Fetch Error: $e");
      return const LocationState();
    }
  }

  // if API call fails, user can retry fetching the data
  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchLocations);
  }

  // choose state, then filter districts and reset downstream selections
  void selectState(String? stateName) {
    final current = state.valueOrNull;
    if (current == null) return;

    final districts = _getDistrictsForState(stateName, current.allStates);

    state = AsyncData(current.copyWith(
      selectedStateName:  stateName,
      availableDistricts: districts,
      availableTownships: const [],   
      clearDistrict:      true,       
      clearTownship:      true,       
    ));
  }

  // choose district, then filter townships and reset downstream selection
  void selectDistrict(String? districtName) {
    final current = state.valueOrNull;
    if (current == null) return;

    final townships = _getTownshipsForDistrict(districtName, current.allStates);

    state = AsyncData(current.copyWith(
      selectedDistrictName: districtName,
      availableTownships:   townships,  
      clearTownship:        true,       
    ));
  }

  // choose township, then update the selection
  void selectTownship(String? townshipName) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(
      selectedTownshipName: townshipName,
    ));
  }

  // Helper Functions
  
  List<String> _getDistrictsForState(String? stateName, List<StateContainerModel> allStates) {
    if (stateName == null) return [];
    try {
      final stateObj = allStates.firstWhere(
        (s) => s.name == stateName,
        orElse: () => throw Exception('State not found'),
      );
      return stateObj.districts.map((d) => d.name).toList();
    } catch (_) {
      return [];
    }
  }

  List<String> _getTownshipsForDistrict(String? districtName, List<StateContainerModel> allStates) {
    if (districtName == null) return [];
    try {
      // Since we don't have the state name at this point, we need to search through all states and their districts to find the matching district
      for (final stateObj in allStates) {
        final hasDistrict = stateObj.districts.any((d) => d.name == districtName);
        if (hasDistrict) {
          final dist = stateObj.districts.firstWhere((d) => d.name == districtName);
          return dist.townships.map((t) => t.name).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
// GLOBAL PROVIDER CREATION
final locationProvider = AsyncNotifierProvider<LocationNotifier, LocationState>(
  LocationNotifier.new,
);