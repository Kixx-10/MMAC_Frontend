import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/models/type_of_travel_models.dart';
import 'package:mmac/data/reposistories/port_of_arrival_repository.dart'; 

// RIVERPOD STATE 
class PortOfArrivalState {
  final List<PortOfArrival> portOfArrivalList; 
  final int? selectedPortId;

  const PortOfArrivalState({
    this.portOfArrivalList = const [],
    this.selectedPortId,
  });

  PortOfArrivalState copyWith({
    List<PortOfArrival>? portOfArrivalList,
    int? selectedPortId,
    bool clearSelectedPort = false,
  }) {
    return PortOfArrivalState(
      portOfArrivalList: portOfArrivalList ?? this.portOfArrivalList,
      selectedPortId: clearSelectedPort ? null : (selectedPortId ?? this.selectedPortId),
    );
  }
}
// RIVERPOD NOTIFIER
class PortOfArrivalNotifier extends AsyncNotifier<PortOfArrivalState> {
  final PortOfArrivalRepository _repository = PortOfArrivalRepository();

  @override
  Future<PortOfArrivalState> build() async {
    return await _fetchPorts(1);
  }

  Future<PortOfArrivalState> _fetchPorts(int modeId) async {
    final ports = await _repository.fetchPortOfArrival(modeId); 
    return PortOfArrivalState(portOfArrivalList: ports);
  }

  // when user selects a different mode of travel, we need to fetch the corresponding ports and reset the selected port
  Future<void> loadPortOfArrrivalByModeId(int modeId) async {
    final current = state.valueOrNull ?? const PortOfArrivalState();
    state = AsyncData(current.copyWith(clearSelectedPort: true));
    state = await AsyncValue.guard(() => _fetchPorts(modeId));
  }
  // when user selects a port, we just update the selected port id in the state
  void selectPort(int portId) {
    final current = state.valueOrNull ?? const PortOfArrivalState();
    state = AsyncData(current.copyWith(selectedPortId: portId));
  }
}
// GLOBAL PROVIDER CREATION
final portOfArrivalProvider = AsyncNotifierProvider<PortOfArrivalNotifier, PortOfArrivalState>(
  PortOfArrivalNotifier.new,
);