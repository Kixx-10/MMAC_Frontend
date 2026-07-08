import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/models/country_model.dart';
import 'package:mmac/data/reposistories/country_repository.dart';

class CountryState {
  final List<CountryModel> countryList;
  final String? selectedCountryCode;
  
  CountryState({this.countryList = const [], this.selectedCountryCode});

  CountryState copyWith({List<CountryModel>? countryList, String? selectedCountryCode, bool clearSelectedCountry = false}) {
    return CountryState(
      countryList: countryList ?? this.countryList,
      selectedCountryCode: clearSelectedCountry ? null : (selectedCountryCode ?? this.selectedCountryCode),
    );
  }
}

class CountryNotifier extends FamilyAsyncNotifier<CountryState, String> {
  final CountryRepository _repository = CountryRepository();

  @override
  Future<CountryState> build(String endpoint) async {
    final countries = await _repository.fetchCountries(endpoint);
    return CountryState(countryList: countries);
  }
}

final allCountriesProvider = AsyncNotifierProviderFamily<CountryNotifier, CountryState, String>(
  () => CountryNotifier(),
);

// ignore: non_constant_identifier_names
final ICAOMemberCountriesProvider = AsyncNotifierProviderFamily<CountryNotifier, CountryState, String>(
  () => CountryNotifier(),
);