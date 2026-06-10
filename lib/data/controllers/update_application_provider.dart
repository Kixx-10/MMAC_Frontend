import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/models/submit_request_model.dart';
import 'package:mmac/data/reposistories/submit_repository.dart';

// 1. Dependency injection for our repository
final submitRepositoryProvider = Provider<SubmitRepository>((ref) {
  return SubmitRepository();
});

// 2. Notifier to manage the search lifecycle (Idle -> Loading -> Success/Error)
class UpdateApplicationNotifier extends AsyncNotifier<SubmitRequestModel?> {
  @override
  Future<SubmitRequestModel?> build() async {
    return null; // Initial state is idle (null)
  }

  Future<void> findApplication({
    required String qrReference,
    required String email,
    required String passportNumber,
    required Function(String error) onError,
    required VoidCallback onSuccess,
  }) async {
    state = const AsyncValue.loading(); // Sets UI to loading state

    state = await AsyncValue.guard(() async {
      final repo = ref.read(submitRepositoryProvider);
      final application = await repo.fetchApplicationForUpdate(
        qrReference: qrReference,
        email: email,
        passportNumber: passportNumber,
      );

      if (application == null) {
        onError("No application found with the provided details.");
        return null;
      }

      onSuccess(); // Triggers UI callback (e.g., notification alert)
      return application;
    });
  }
}

// 3. The globally accessible provider
final updateApplicationProvider =
    AsyncNotifierProvider<UpdateApplicationNotifier, SubmitRequestModel?>(() {
      return UpdateApplicationNotifier();
    });
