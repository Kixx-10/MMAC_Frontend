// lib/data/models/submit_request_model.dart

class SubmitRequestModel {
  final String fullName;
  final String gender;          
  final String dob;             
  final String countryOfBirthCode;
  final String email;
  final String mobileNumber;
  final String address;
  final String visaNo;
  final String nrc;            
  final String fatherName;     
  final String passportNo;
  final String issuedCountryCode;
  final String issuedDate;      
  final String expiryDate;      
  final String arrivalDate;     
  final String modeOfTravelId;  
  final String portOfArrivalId; 
  final String? vehicleNumber;  
  final String? vehicleName;    
  final String? accommodation;  
  final String addressInMyanmar;
  final String stateRegionId;   
  final String districtId;     
  final String townshipId;      
  final String mobileNumberMM;  
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
    required this.visaNo,
    required this.nrc,
    required this.fatherName,
    required this.passportNo,
    required this.issuedCountryCode,
    required this.issuedDate,
    required this.expiryDate,
    required this.arrivalDate,
    required this.modeOfTravelId,
    required this.portOfArrivalId,
    this.vehicleNumber,
    this.vehicleName,
    this.accommodation,
    required this.addressInMyanmar,
    required this.stateRegionId,
    required this.districtId,
    required this.townshipId,
    required this.mobileNumberMM,
    required this.purposeOfVisit,
    this.previousCity,
    this.healthDeclaration,
    this.digitalDeclarations,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName':           fullName,
      'gender':             gender,
      'dob':                dob,
      'countryOfBirthCode': countryOfBirthCode,
      'email':              email,
      'mobileNumber':       mobileNumber,
      'address':            address,
      'visaNo':             visaNo,
      'nrc':                nrc,
      'fatherName':         fatherName,
      'passportNo':         passportNo,
      'issuedCountryCode':  issuedCountryCode,
      'issuedDate':         issuedDate,
      'expiryDate':         expiryDate,
      'arrivalDate':        arrivalDate,
      'modeOfTravelId':     int.tryParse(modeOfTravelId) ?? 0,
      'portOfArrivalId':    int.tryParse(portOfArrivalId) ?? 0,
      'vehicleNumber':      vehicleNumber,
      'vehicleName':        vehicleName,
      'accommodation':      accommodation,
      'addressInMyanmar':   addressInMyanmar,
      'stateRegionId':      int.tryParse(stateRegionId) ?? 0,
      'districtId':         int.tryParse(districtId) ?? 0,
      'townshipId':         int.tryParse(townshipId) ?? 0,
      'mobileNumberMM':     mobileNumberMM,
      'purposeOfVisit':     purposeOfVisit,
      'previousCity':       previousCity,
      'healthDeclaration':  healthDeclaration,
      'digitalDeclarations': digitalDeclarations,
    };
  }
}