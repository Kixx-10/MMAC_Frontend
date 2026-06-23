class QrResponseModel {
  final String referenceNo;
  final String appStatus;
  final String fullName;
  final String gender;
  final DateTime? dob;
  final String countryOfBirthCode;
  final String email;
  final String mobileNumber;
  final String address;
  final String passportNo;
  final String issuedCountryCode;
  final DateTime? issuedDate;
  final DateTime? expiryDate;
  final DateTime? arrivalDate;
  final String purposeOfVisit;
  final String addressInMyanmar;
  final String modeOfTravelName;
  final String portOfArrivalName;
  final String stateRegionName;
  final String districtName;
  final String townshipName;

  // 🎯 ပြည်တွင်း/ပြည်ပပေါ်မူတည်ပြီး Null ဖြစ်နိုင်သော Field များ
  final String? visaNo; // Myanmar Citizen အတွက် Null ဖြစ်မည်
  final String? accommodation; // Myanmar Citizen အတွက် Null ဖြစ်မည်
  final String? nrc; // Foreigner အတွက် Null ဖြစ်မည်
  final String? fatherName; // Foreigner အတွက် Null ဖြစ်မည်
  final String? mobileNumberMM; // Foreigner အတွက် Null ဖြစ်မည်

  // Optional ဖြစ်နိုင်သော Vehicle Info များ
  final String? vehicleNumber;
  final String? vehicleName;
  final String? previousCity;
  final String? healthDeclaration;
  final String? digitalDeclarations;

  QrResponseModel({
    required this.referenceNo,
    required this.appStatus,
    required this.fullName,
    required this.gender,
    this.dob,
    required this.countryOfBirthCode,
    required this.email,
    required this.mobileNumber,
    required this.address,
    required this.passportNo,
    required this.issuedCountryCode,
    this.issuedDate,
    this.expiryDate,
    this.arrivalDate,
    required this.purposeOfVisit,
    required this.addressInMyanmar,
    required this.modeOfTravelName,
    required this.portOfArrivalName,
    required this.stateRegionName,
    required this.districtName,
    required this.townshipName,
    // Nullable fields
    this.visaNo,
    this.accommodation,
    this.nrc,
    this.fatherName,
    this.mobileNumberMM,
    this.vehicleNumber,
    this.vehicleName,
    this.previousCity,
    this.healthDeclaration,
    this.digitalDeclarations,
  });

  factory QrResponseModel.fromJson(Map<String, dynamic> json) {
    return QrResponseModel(
      referenceNo: json['referenceNo'] ?? '',
      appStatus: json['appStatus'] ?? '',
      fullName: json['fullName'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      countryOfBirthCode: json['countryOfBirthCode'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      address: json['address'] ?? '',
      passportNo: json['passportNo'] ?? '',
      issuedCountryCode: json['issuedCountryCode'] ?? '',
      issuedDate: json['issuedDate'] != null
          ? DateTime.tryParse(json['issuedDate'])
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'])
          : null,
      arrivalDate: json['arrivalDate'] != null
          ? DateTime.tryParse(json['arrivalDate'])
          : null,
      purposeOfVisit: json['purposeOfVisit'] ?? '',
      addressInMyanmar: json['addressInMyanmar'] ?? '',
      modeOfTravelName: json['modeOfTravelName'] ?? '',
      portOfArrivalName: json['portOfArrivalName'] ?? '',
      stateRegionName: json['stateRegionName'] ?? '',
      districtName: json['districtName'] ?? '',
      townshipName: json['townshipName'] ?? '',

      visaNo: (json['visaNo'] == null || json['visaNo'] == "")
          ? null
          : json['visaNo'],
      accommodation:
          (json['accommodation'] == null || json['accommodation'] == "")
          ? null
          : json['accommodation'],
      nrc: (json['nrc'] == null || json['nrc'] == "") ? null : json['nrc'],
      fatherName: (json['fatherName'] == null || json['fatherName'] == "")
          ? null
          : json['fatherName'],
      mobileNumberMM:
          (json['mobileNumberMM'] == null || json['mobileNumberMM'] == "")
          ? null
          : json['mobileNumberMM'],

      vehicleNumber: json['vehicleNumber'],
      vehicleName: json['vehicleName'],
      previousCity: json['previousCity'],
      healthDeclaration: json['healthDeclaration'],
      digitalDeclarations: json['digitalDeclarations'],
    );
  }
}
