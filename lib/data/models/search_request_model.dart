// lib/data/models/search_request_model.dart

// 🇲🇲 ၁။ မြန်မာနိုင်ငံသားများအတွက် သီးသန့် ရှာဖွေရေး Model
class NativeSearchRequestModel {
  final String qrReference;
  final String
  residencyType; // Backend က မတောင်းပေမယ့် Internal သုံးဖို့ ထားထားပါမည်
  final String nrc;
  final DateTime arrivalDate;

  NativeSearchRequestModel({
    required this.qrReference,
    required this.residencyType,
    required this.nrc,
    required this.arrivalDate,
  });

  Map<String, dynamic> toJson() {
    return {
      // 🎯 ပြင်ဆင်ချက်: Backend က လိုချင်သော နာမည်များအတိုင်း Key များကို ပြောင်းပေးလိုက်ပါသည်
      'referenceNo': qrReference,
      'nrc': nrc,
      // Backend က "2026-06-17T..." ပုံစံတောင်းထားသဖြင့် toIso8601String() အပြည့်ပို့ပါမည်
      'arrivalDate': arrivalDate.toIso8601String(),
    };
  }
}

// ✈️ ၂။ နိုင်ငံခြားသားများအတွက် သီးသန့် ရှာဖွေရေး Model
class ForeignerSearchRequestModel {
  final String qrReference;
  final String residencyType;
  final String passportNumber;
  final String nationalityCode;
  final String dob;
  final String passportExpiry;

  ForeignerSearchRequestModel({
    required this.qrReference,
    required this.residencyType,
    required this.passportNumber,
    required this.nationalityCode,
    required this.dob,
    required this.passportExpiry,
  });

  Map<String, dynamic> toJson() {
    return {
      // 🎯 ပြင်ဆင်ချက်: Backend က လိုချင်သော နာမည်များအတိုင်း Key များကို ပြောင်းပေးလိုက်ပါသည်
      'referenceNo': qrReference,
      'passportNo': passportNumber,
      'countryOfBirthCode': nationalityCode,
      'expiryDate':
          passportExpiry, // Front-End တွင် string ("YYYY-MM-DD") အနေဖြင့် ရှိနေသည်၊ ASP.NET က အလိုအလျောက် Date ပြောင်းပေးပါလိမ့်မည်
      'dob': dob,
    };
  }
}
