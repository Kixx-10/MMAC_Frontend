class ApiEndpoints {
  static const String address = "Utility/Getlocations";
  static String portOfArrival(int modeOfTravelId) =>
      "PortOfArrival/$modeOfTravelId";
  static const String getNationalityCountry = "Country/NationalityCountry";
  static const String getPassportIssuedCountry="Country/PassportIssuedCountry";
  static const String getNRC = "Utility/GetNRCFormat";
  static const String submitApplication = "Application/Submit&UpdateApplication";
  static const String approveApplication= "Application/ApproveApplication";
  static const String findNative = "searchDetails/myanmarDetails";
  static const String findForeigner = "searchDetails/foreignerDetails";
  static const String sendEmail="Application/SendApplicationEmail";
  // ignore: non_constant_identifier_names
  static String searchApplicationByQRCode(String AppNo) => 
      "Application/SearchApplicationByQRCode$AppNo";
}
