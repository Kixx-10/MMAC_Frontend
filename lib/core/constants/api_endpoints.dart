class ApiEndpoints {
  static const String address = "Utility/Getlocations";
  static String portOfArrival(int modeOfTravelId) =>
      "PortOfArrival/$modeOfTravelId";
  static const String getCountry = "Country";
  static const String getNRC = "Utility/GetNRCFormat";
  static const String submitApplication = "SubmitApplication";
  static const String findNative = "searchDetails/myanmarDetails";
  static const String findForeigner = "searchDetails/foreignerDetails";
  static const String updateApplication = "";
}
