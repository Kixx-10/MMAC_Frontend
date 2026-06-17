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

class UpdateApplicationNotifier extends AsyncNotifier<SubmitRequestModel?> {
  @override
  Future<SubmitRequestModel?> build() async {
    return null;
  }

  /// 🎯 SearchRequestModel ကို အသုံးပြု၍ ယခင်တင်ထားသော Application အား ရှာဖွေသည့် စနစ်
  Future<void> findApplication({
    required SearchRequestModel
    searchRequest, // 💡 Parameter တစ်ခုချင်းစီအစား Model တစ်ခုတည်းဖြင့် အုပ်လိုက်ပါပြီ
    required Function(String error) onError,
    required VoidCallback onSuccess,
  }) async {
    state =
        const AsyncValue.loading(); // UI ကို Loading အခြေအနေသို့ ပြောင်းလဲမည်

    state = await AsyncValue.guard(() async {
      final repo = ref.read(submitRepositoryProvider);

      // Repository ဆီသို့ သန့်ရှင်းစွာ ဒေတာ လွှဲပေးလိုက်ခြင်း
      final application = await repo.fetchApplicationForUpdate(
        qrReference: searchRequest.qrReference,
        residencyType: searchRequest.residencyType,
        nrc: searchRequest.nrc,
        passportNumber: searchRequest.passportNumber,
        nationalityCode: searchRequest.nationalityCode,
        dob: searchRequest.dob,
        passportExpiry: searchRequest.passportExpiry,
        arrivalDate: searchRequest
            .arrivalDate, // DateTime Object ဖြစ်ပြီးသားမို့ တိုက်ရိုက်ထည့်ရုံပါပဲ
      );

      if (application == null) {
        // ဒေတာမတွေ့ရင် သို့မဟုတ် အချက်အလက်မှားယွင်းနေရင် ပြမည့် Error Message
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
    AsyncNotifierProvider<UpdateApplicationNotifier, SubmitRequestModel?>(
      UpdateApplicationNotifier.new,
    );
