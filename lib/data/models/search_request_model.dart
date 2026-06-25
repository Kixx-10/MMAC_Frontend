// lib/data/models/search_request_model.dart


class NativeSearchRequestModel {
  final String qrReference;
  final String
  residencyType; 
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
      'referenceNo': qrReference,
      'nrc': nrc,
      'arrivalDate': arrivalDate.toIso8601String(),
    };
  }
}

// နိုင်ငံခြားသားများအတွက် သီးသန့် ရှာဖွေရေး Model
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
