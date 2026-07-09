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
      'referenceNo': qrReference,
      'passportNo': passportNumber,
      'countryOfBirthCode': nationalityCode,
      'expiryDate':
          passportExpiry, 
      'dob': dob,
    };
  }
}
