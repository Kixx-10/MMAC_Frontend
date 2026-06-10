import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/models/submit_request_model.dart';
import 'package:mmac/data/models/submit_response_model.dart';
import 'package:mmac/data/reposistories/submit_repository.dart';

class SubmitControllerProvider extends AsyncNotifier<SubmitResponseModel?> {
  final SubmitRepository _repository = SubmitRepository();
  @override
  Future<SubmitResponseModel?> build() async {
    return null; // initial state is null, meaning no submission has been made yet
  }

  Future<SubmitResponseModel?> submitApplicationAction(
    SubmitRequestModel requestData,
  ) async {
    state = const AsyncLoading(); // set state to loading when submission starts
    final result = await AsyncValue.guard(
      () => _repository.submitApplication(requestData),
    );
    state = result; // update state with the result (either data or error)
    return result
        .value; // return the response model if successful, or null if there was an error
  }
}

final submitControllerProvider =
    AsyncNotifierProvider<SubmitControllerProvider, SubmitResponseModel?>(
      SubmitControllerProvider.new,
    );
