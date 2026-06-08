import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/models/country_model.dart';
import 'package:mmac/data/reposistories/country_repository.dart';

class CountryState{
  final List<CountryModel> countryList;
  final String? selectedCountryCode;
  CountryState({
    this.countryList=const [],
    this.selectedCountryCode,
  });
  CountryState copyWith({
  List<CountryModel>? countryList,
  String? selectedCountryCode,
  bool clearSelectedCountry=false,
}){
  return CountryState(
    countryList: countryList ?? this.countryList,
    selectedCountryCode: clearSelectedCountry ? null : (selectedCountryCode ?? this.selectedCountryCode),
  );
}
}
class CountryNotifier extends AsyncNotifier<CountryState>{
  final CountryRepository _repository=CountryRepository();
  @override
  Future<CountryState> build() async {
    return await _fetchCountries();
  }
  Future<CountryState> _fetchCountries()async{
    final countries=await _repository.fetchCountries();
    return CountryState(countryList: countries);
  }
  void selectCountry(String countryCode){
    final current=state.valueOrNull ?? CountryState();
    state=AsyncData(current.copyWith(selectedCountryCode: countryCode));
  }
}
final countryProvider=AsyncNotifierProvider<CountryNotifier, CountryState>(
  CountryNotifier.new,
);