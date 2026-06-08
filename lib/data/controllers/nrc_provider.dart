import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/models/nrc_model.dart';
import 'package:mmac/data/reposistories/nrc_repository.dart';

class NrcState {
  final List<NRCStateContainerModel> nrcStateList;
  final int? selectedNrcStateId;
  final List<NRCTownshipModel> availableNrcTownships; // list of townships based on selected state
  final String? selectedTownshipCode; // township selected by user

  const NrcState({
    this.nrcStateList = const [],
    this.selectedNrcStateId,
    this.availableNrcTownships = const [],
    this.selectedTownshipCode,
  });

  NrcState copyWith({
    List<NRCStateContainerModel>? nrcStateList,
    int? selectedNrcStateId,
    List<NRCTownshipModel>? availableNrcTownships,
    String? selectedTownshipCode,
    bool clearTownship = false, // if true, it will clear the selected township regardless of the provided value
  }) {
    return NrcState(
      nrcStateList: nrcStateList ?? this.nrcStateList,
      selectedNrcStateId: selectedNrcStateId ?? this.selectedNrcStateId,
      availableNrcTownships: availableNrcTownships ?? this.availableNrcTownships,
      selectedTownshipCode: clearTownship ? null : (selectedTownshipCode ?? this.selectedTownshipCode),
    );
  }
}

class NrcNotifier extends AsyncNotifier<NrcState> {
  final NrcRepository _repository = NrcRepository();

  @override
  Future<NrcState> build() async {
    return await _fetchNrcStates();
  }

  Future<NrcState> _fetchNrcStates() async {
    try {
      final nrcStates = await _repository.fetchNRCStates();
      return NrcState(nrcStateList: nrcStates);
    } catch (e) {
      return const NrcState();
    }
  }

  // if choose NRC State eg 1, then filter and show only townships that belong to that state
  void selectNrcState(int? stateId) {
    final current = state.valueOrNull;
    if (current == null) return;

    List<NRCTownshipModel> townships = [];
    if (stateId != null) {
      // take the selected state from the list and get its townships
      final match = current.nrcStateList.firstWhere(
        (s) => s.id == stateId,
        orElse: () => NRCStateContainerModel(id: 0, idCode: '', codeMM: '', nrcTownships: []),
      );
      townships = match.nrcTownships;
    }

    state = AsyncData(current.copyWith(
      selectedNrcStateId: stateId,
      availableNrcTownships: townships,
      clearTownship: true, // clear selected township when state changes
    ));
  }

  // when user selects a township, we just update the selectedTownshipCode in the state. The availableNrcTownships is already filtered based on the selected state.
  void selectNrcTownship(String? townshipCode) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(
      selectedTownshipCode: townshipCode,
    ));
  }
}

// GLOBAL PROVIDER
final nrcProvider = AsyncNotifierProvider<NrcNotifier, NrcState>(
  NrcNotifier.new,
);