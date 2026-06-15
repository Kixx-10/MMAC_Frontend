// lib/data/controllers/update_application_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/models/submit_request_model.dart';
import 'package:mmac/data/reposistories/submit_repository.dart';

// 1. Dependency injection for our repository
final submitRepositoryProvider = Provider<SubmitRepository>((ref) {
  return SubmitRepository();
});

class UpdateApplicationNotifier extends AsyncNotifier<SubmitRequestModel?> {
  @override
  Future<SubmitRequestModel?> build() async {
    return null;
  }

  Future<void> findApplication({
    required String qrReference,
    required String residencyType,
    String? nrc,
    String? passportNumber,
    String? nationalityCode,
    String? dob,
    String? passportExpiry,
    required Function(String error) onError,
    required VoidCallback onSuccess,
  }) async {
    state = const AsyncValue.loading(); // Sets UI to loading state

    state = await AsyncValue.guard(() async {
      final repo = ref.read(submitRepositoryProvider);

      // 🚀 Repository ဆီသို့ Parameter အားလုံး လွှဲပေးလိုက်ခြင်း
      final application = await repo.fetchApplicationForUpdate(
        qrReference: qrReference,
        residencyType: residencyType,
        nrc: nrc,
        passportNumber: passportNumber,
        nationalityCode: nationalityCode,
        dob: dob,
        passportExpiry: passportExpiry,
      );

      if (application == null) {
        // ဒေတာမတွေ့ရင် သို့မဟုတ် မှားယွင်းနေရင် ပြမည့် Error Message
        onError(
          "Application reference not found or verification details mismatch.",
        );
        return null;
      }

      onSuccess();
      return application;
    });
  }
}

final updateApplicationProvider =
    AsyncNotifierProvider<UpdateApplicationNotifier, SubmitRequestModel?>(() {
      return UpdateApplicationNotifier();
    });
