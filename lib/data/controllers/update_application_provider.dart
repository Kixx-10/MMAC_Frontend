// lib/data/controllers/update_application_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/models/search_request_model.dart';
import 'package:mmac/data/models/submit_request_model.dart';
import 'package:mmac/data/reposistories/submit_repository.dart';

// 1. Dependency injection for our repository
final submitRepositoryProvider = Provider<SubmitRepository>((ref) {
  return SubmitRepository();
});

// lib/data/controllers/update_application_provider.dart

// ... (အပေါ်ပိုင်း import များနှင့် repository provider အပိုင်း မူလအတိုင်း)

class UpdateApplicationNotifier extends AsyncNotifier<SubmitRequestModel?> {
  @override
  Future<SubmitRequestModel?> build() async {
    return null;
  }

  //မြန်မာနိုင်ငံသားများအတွက် ရှာဖွေခြင်း Function (ဤ Method တစ်ခုလုံးကို အစားထိုးပါ)
  Future<void> findNativeApplication({
    required NativeSearchRequestModel searchRequest,
    required Function(String error) onError,
    required VoidCallback onSuccess,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(submitRepositoryProvider);

      // ပြင်ဆင်ချက်: Parameter အဟောင်းတွေအစား Model ကို တိုက်ရိုက်ပစ်ထည့်လိုက်ပါပြီ
      final application = await repo.fetchNativeApplication(searchRequest);

      if (application == null) {
        onError("Native application not found or mismatch.");
        return null;
      }
      onSuccess();
      return application;
    });
  }

  //နိုင်ငံခြားသားများအတွက် ရှာဖွေခြင်း Function (ဤ Method တစ်ခုလုံးကို အစားထိုးပါ)
  Future<void> findForeignerApplication({
    required ForeignerSearchRequestModel searchRequest,
    required Function(String error) onError,
    required VoidCallback onSuccess,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(submitRepositoryProvider);

      // 🎯 ပြင်ဆင်ချက်: Parameter အဟောင်းတွေအစား Model ကို တိုက်ရိုက်ပစ်ထည့်လိုက်ပါပြီ
      final application = await repo.fetchForeignerApplication(searchRequest);

      if (application == null) {
        onError("Foreigner application not found or mismatch.");
        return null;
      }
      onSuccess();
      return application;
    });
  }
}

// ... (အောက်ဆုံးက final updateApplicationProvider မူလအတိုင်း)

final updateApplicationProvider =
    AsyncNotifierProvider<UpdateApplicationNotifier, SubmitRequestModel?>(
      UpdateApplicationNotifier.new,
    );
