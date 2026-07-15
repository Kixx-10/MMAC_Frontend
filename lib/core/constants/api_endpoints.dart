class ApiEndpoints {
  static const String address = "Utility/Getlocations";
  static String portOfArrival(int modeOfTravelId) =>
      "PortOfArrival/$modeOfTravelId";
  static const String getAllCountries = "Country/AllCountries";
  static const String getIcaoMemberCountries="Country/IcaoMemberCountries";
  static const String getNRC = "Utility/GetNRCFormat";
  static const String submitApplication = "Application/Submit&UpdateApplication";
  static const String approveApplication= "Application/ApproveApplication";
  static const String findNative = "searchDetails/myanmarDetails";
  static const String findForeigner = "searchDetails/foreignerDetails";
  static const String sendEmail="Application/SendApplicationEmail";
  static const String healthRecord="FileUpload/HealthRecord";
  static const String digitalRecord="FileUpload/DigitalRecord";
  // ignore: non_constant_identifier_names
  static String searchApplicationByQRCode(String AppNo) => 
      "Application/SearchApplicationByQRCode$AppNo";
}
