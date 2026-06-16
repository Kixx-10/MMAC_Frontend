class SearchRequestModel {
  final String qrReference;
  final String residencyType;
  final String? nrc;
  final String? passportNumber;
  final String? nationalityCode;
  final String? dob;
  final String? passportExpiry;
  final DateTime? arrivalDate; // 🎯 ကျွန်တော်တို့ အသစ်ထည့်ထားတဲ့ Field

  SearchRequestModel({
    required this.qrReference,
    required this.residencyType,
    this.nrc,
    this.passportNumber,
    this.nationalityCode,
    this.dob,
    this.passportExpiry,
    this.arrivalDate,
  });

  // API ဆီသို့ Json ပုံစံဖြင့် ပို့ရန်
  Map<String, dynamic> toJson() {
    return {
      'qrReference': qrReference,
      'residencyType': residencyType,
      if (nrc != null) 'nrc': nrc,
      if (passportNumber != null) 'passportNumber': passportNumber,
      if (nationalityCode != null) 'nationalityCode': nationalityCode,
      if (dob != null) 'dob': dob,
      if (passportExpiry != null) 'passportExpiry': passportExpiry,
      if (arrivalDate != null)
        'arrivalDate': arrivalDate!.toIso8601String().split(
          'T',
        )[0], // YYYY-MM-DD format
    };
  }
}
