// lib/data/models/submit_request_model.dart

class SubmitRequestModel {
  final String fullName;
  final String gender;
  final String dob;
  final String countryOfBirthCode;
  final String email;
  final String mobileNumber;
  final String address;
  final String passportNo;
  final String issuedCountryCode;
  final String issuedDate;
  final String expiryDate;
  final String arrivalDate;
  final String modeOfTravelId;
  final String portOfArrivalId;
  final String vehicleNumber;
  final String vehicleName;
  final String? accommodation;
  final String? visaNo;
  final String? nrc;
  final String? fatherName;
  final String addressInMyanmar;
  final String stateRegionId;
  final String districtId;
  final String townshipId;
  final String? mobileNumberMM;
  final String purposeOfVisit;
  final String? previousCity;
  final String? healthDeclaration;
  final String? digitalDeclarations;
  SubmitRequestModel({
    required this.fullName,
    required this.gender,
    required this.dob,
    required this.countryOfBirthCode,
    required this.email,
    required this.mobileNumber,
    required this.address,
    this.visaNo,
    this.nrc,
    this.fatherName,
    required this.passportNo,
    required this.issuedCountryCode,
    required this.issuedDate,
    required this.expiryDate,
    required this.arrivalDate,
    required this.modeOfTravelId,
    required this.portOfArrivalId,
    required this.vehicleNumber,
    required this.vehicleName,
    this.accommodation,
    required this.addressInMyanmar,
    required this.stateRegionId,
    required this.districtId,
    required this.townshipId,
    this.mobileNumberMM,
    required this.purposeOfVisit,
    required this.previousCity,
    required this.healthDeclaration,
    required this.digitalDeclarations,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'gender': gender,
      'dob': dob,
      'countryOfBirthCode': countryOfBirthCode,
      'email': email,
      'mobileNumber': mobileNumber,
      'address': address,
      'passportNo': passportNo,
      'issuedCountryCode': issuedCountryCode,
      'issuedDate': issuedDate,
      'expiryDate': expiryDate,
      'arrivalDate': arrivalDate,
      'modeOfTravelId': int.tryParse(modeOfTravelId) ?? 0,
      'portOfArrivalId': int.tryParse(portOfArrivalId) ?? 0,
      'vehicleNumber': vehicleNumber,
      'vehicleName': vehicleName,
      'accommodation': accommodation,
      'addressInMyanmar': addressInMyanmar,
      'stateRegionId': int.tryParse(stateRegionId) ?? 0,
      'districtId': int.tryParse(districtId) ?? 0,
      'townshipId': int.tryParse(townshipId) ?? 0,
      'mobileNumberMM': mobileNumberMM,
      'purposeOfVisit': purposeOfVisit,
      'previousCity': previousCity,
      'healthDeclaration': healthDeclaration,
      'digitalDeclarations': digitalDeclarations,
      'visaNo': (visaNo == null || visaNo!.trim().isEmpty) ? null : visaNo,
      'nrc': (nrc == null || nrc!.trim().isEmpty) ? null : nrc,
      'fatherName': (fatherName == null || fatherName!.trim().isEmpty)
          ? null
          : fatherName,
    };
  }

  //this Method is used in search application by id aka update
  factory SubmitRequestModel.fromJson(Map<String, dynamic> json) {
    return SubmitRequestModel(
      fullName: json['fullName'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      countryOfBirthCode: json['countryOfBirthCode'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      address: json['address'] ?? '',
      visaNo: json['visaNo'] ?? '',
      nrc: json['nrc'] ?? '',
      fatherName: json['fatherName'] ?? '',
      passportNo: json['passportNo'] ?? '',
      issuedCountryCode: json['issuedCountryCode'] ?? '',
      issuedDate: json['issuedDate'] ?? '',
      expiryDate: json['expiryDate'] ?? '',
      arrivalDate: json['arrivalDate'] ?? '',
      modeOfTravelId: (json['modeOfTravelId'] ?? 0).toString(),
      portOfArrivalId: (json['portOfArrivalId'] ?? 0).toString(),
      vehicleNumber: json['vehicleNumber'],
      vehicleName: json['vehicleName'],
      accommodation: json['accommodation'],
      addressInMyanmar: json['addressInMyanmar'] ?? '',
      stateRegionId: (json['stateRegionId'] ?? 0).toString(),
      districtId: (json['districtId'] ?? 0).toString(),
      townshipId: (json['townshipId'] ?? 0).toString(),
      mobileNumberMM: json['mobileNumberMM'] ?? '',
      purposeOfVisit: json['purposeOfVisit'] ?? '',
      previousCity: json['previousCity'],
      healthDeclaration: json['healthDeclaration'],
      digitalDeclarations: json['digitalDeclarations'],
    );
  }
}
