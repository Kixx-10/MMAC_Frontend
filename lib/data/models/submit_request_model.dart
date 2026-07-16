// lib/data/models/submit_request_model.dart

class SubmitRequestModel {
  final String? qrReference;
  final String fullName;
  final String gender;
  final String dob;
  final String nationalityCode;
  final String email;
  final String mobileNumber;
  final String placeOfResidence;
  final String passportNo;
  final String issuedCountryCode;
  final String issuedDate;
  final String expiryDate;
  final String arrivalDate;
  final String modeOfTravelId;
  final String portOfArrivalId;
  final String vehicleNumber;
  final String? accommodation;
  final String? visaNo;
  final String? nrc;
  final String? fatherName;
  final String? addressInMyanmar;
  final String stateRegionId;
  final String districtId;
  final String townshipId;
  final String? mobileNumberMM;
  final String purposeOfVisit;
  final String previousCity;
  final String healthDeclaration;
  final String? healthRecordUrl;
  final String? healthRecordFileName;
  final String? goodsRecordUrl;
  final String? goodsRecordFileName;
  final String digitalDeclarations;
  final String? modeOfTravelName;
  final String? portOfArrivalName;
  final String? stateRegionName;
  final String? districtName;
  final String? townshipName;
  final String? uID;
  final String? occupation;
  final String? placeOfBirthCode;

  SubmitRequestModel({
    required this.fullName,
    required this.gender,
    required this.dob,
    required this.nationalityCode,
    required this.email,
    required this.mobileNumber,
    required this.placeOfResidence,
    this.visaNo,
    this.nrc,
    this.fatherName,
    this.modeOfTravelName,
    this.portOfArrivalName,
    this.stateRegionName,
    this.districtName,
    this.townshipName,
    required this.passportNo,
    required this.issuedCountryCode,
    required this.issuedDate,
    required this.expiryDate,
    required this.arrivalDate,
    required this.modeOfTravelId,
    required this.portOfArrivalId,
    required this.vehicleNumber,
    this.accommodation,
    this.addressInMyanmar,
    required this.stateRegionId,
    required this.districtId,
    required this.townshipId,
    this.mobileNumberMM,
    this.qrReference,
    required this.purposeOfVisit,
    required this.previousCity,
    required this.healthDeclaration,
    this.healthRecordUrl,
    this.healthRecordFileName,
    required this.digitalDeclarations,
    this.uID,
    this.occupation,
    this.placeOfBirthCode,
    this.goodsRecordUrl,
    this.goodsRecordFileName,
  });

  Map<String, dynamic> toJson() {
    return {
      if (qrReference != null) 'referenceNo': qrReference,
      'fullName': fullName,
      'gender': gender,
      'dob': dob,
      'nationalityCode': nationalityCode,
      'email': email,
      'mobileNumber': mobileNumber,
      'placeOfResidence': placeOfResidence,
      'passportNo': passportNo,
      'issuedCountryCode': issuedCountryCode,
      'issuedDate': issuedDate,
      'expiryDate': expiryDate,
      'arrivalDate': arrivalDate,
      'modeOfTravelId': int.tryParse(modeOfTravelId) ?? 0,
      'portOfArrivalId': int.tryParse(portOfArrivalId) ?? 0,
      'vehicleNumber': vehicleNumber,
      'accommodation': accommodation,
      'addressInMyanmar': addressInMyanmar,
      'stateRegionId': int.tryParse(stateRegionId) ?? 0,
      'districtId': int.tryParse(districtId) ?? 0,
      'townshipId': int.tryParse(townshipId) ?? 0,
      'mobileNumberMM': mobileNumberMM,
      'purposeOfVisit': purposeOfVisit,
      'previousCity': previousCity,
      'healthDeclaration': healthDeclaration,
      'healthRecordUrl': healthRecordUrl,
      'healthRecordFileName': healthRecordFileName,
      'digitalDeclarations': digitalDeclarations,
      'visaNo': (visaNo == null || visaNo!.trim().isEmpty) ? null : visaNo,
      'nrc': (nrc == null || nrc!.trim().isEmpty) ? null : nrc,
      'fatherName': (fatherName == null || fatherName!.trim().isEmpty)
          ? null
          : fatherName,
      'uID': uID,
      'occupation': occupation,
      'placeOfBirthCode': placeOfBirthCode,
      'goodsRecordUrl': goodsRecordUrl,
      'goodsRecordFileName': goodsRecordFileName,
    };
  }

  //this Method is used in search application by id aka update
  factory SubmitRequestModel.fromJson(Map<String, dynamic> json) {
    return SubmitRequestModel(
      qrReference: (json['referenceNo'] ?? json['qrReference']) as String?,
      fullName: json['fullName'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      nationalityCode: json['nationalityCode'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      placeOfResidence: json['placeOfResidence'] ?? '',
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
      accommodation: json['accommodation'],
      addressInMyanmar: json['addressInMyanmar'] ?? '',
      stateRegionId: (json['stateRegionId'] ?? 0).toString(),
      districtId: (json['districtId'] ?? 0).toString(),
      townshipId: (json['townshipId'] ?? 0).toString(),
      mobileNumberMM: json['mobileNumberMM'] ?? '',
      purposeOfVisit: json['purposeOfVisit'] ?? '',
      previousCity: json['previousCity'],
      healthDeclaration: json['healthDeclaration'],
      healthRecordUrl: json['healthRecordUrl'],
      healthRecordFileName: json['healthRecordFileName'],
      digitalDeclarations: json['digitalDeclarations'],
      goodsRecordUrl: json['goodsRecordUrl'],
      goodsRecordFileName: json['goodsRecordFileName'],
      modeOfTravelName: json['modeOfTravelName'],
      portOfArrivalName: json['portOfArrivalName'],
      stateRegionName: json['stateRegionName'],
      districtName: json['districtName'],
      townshipName: json['townshipName'],
      uID: json['uid'] ?? json['uID'],
      occupation: json['occupation'],
      placeOfBirthCode: json['placeOfBirthCode'],
    );
  }
}
