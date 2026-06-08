class CountryModel{
  final String countryCode;
  final String countryName;
  CountryModel({
    required this.countryCode,
    required this.countryName,
  });
  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      countryCode: json['countryCode'] ?? '',
      countryName: json['name'] ?? '',
    );
  }
}