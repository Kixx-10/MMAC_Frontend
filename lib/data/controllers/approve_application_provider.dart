import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/models/approve_application_model.dart';
import 'package:mmac/data/reposistories/approve_application_repository.dart';

class ApproveApplicationProvider extends AsyncNotifier<bool?> {
  final ApproveApplicationRepository _repository = ApproveApplicationRepository();

  @override
  Future<bool?> build() async {
    return null; 
  }
  Future<bool?> approveApplicationAction(ApproveApplicationModel requestData) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      return await _repository.approveApplication(requestData);
    });
    state = result; 
    return result.value; 
  }
}
final approveApplicationProvider =AsyncNotifierProvider<ApproveApplicationProvider, bool?>(
  ApproveApplicationProvider.new,
);