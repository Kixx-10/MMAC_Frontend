
class TownshipModel {
  final int id;
  final int districtId;
  final String idCode;
  final String name;
  final String nameMM;

  TownshipModel({
    required this.id,
    required this.districtId,
    required this.idCode,
    required this.name,
    required this.nameMM,
  });

  factory TownshipModel.fromJson(Map<String, dynamic> json) {
    return TownshipModel(
      id: json['id'] ?? 0,
      districtId: json['districtId'] ?? 0,
      idCode: json['idCode'] ?? '',
      name: json['name'] ?? '',
      nameMM: json['nameMM'] ?? '',
    );
  }
}

class DistrictContainerModel {
  final int districtId;
  final int srId;
  final String idCode;
  final String name;
  final String nameMM;
  final List<TownshipModel> townships; 

  DistrictContainerModel({
    required this.districtId,
    required this.srId,
    required this.idCode,
    required this.name,
    required this.nameMM,
    required this.townships,
  });

  factory DistrictContainerModel.fromJson(Map<String, dynamic> json) {
    final districtJson = json['district'] ?? {};
    final townshipsList = (json['townships'] as List?)
            ?.map((t) => TownshipModel.fromJson(t))
            .toList() ?? [];

    return DistrictContainerModel(
      districtId: districtJson['districtId'] ?? 0,
      srId: districtJson['srId'] ?? 0,
      idCode: districtJson['idCode'] ?? '',
      name: districtJson['name'] ?? '',
      nameMM: districtJson['nameMM'] ?? '',
      townships: townshipsList,
    );
  }
}

class StateContainerModel {
  final int id;
  final String idCode;
  final String name;
  final String nameMM;
  final List<DistrictContainerModel> districts; 

  StateContainerModel({
    required this.id,
    required this.idCode,
    required this.name,
    required this.nameMM,
    required this.districts,
  });

  factory StateContainerModel.fromJson(Map<String, dynamic> json) {
    final stateJson = json['state'] ?? {};
    final districtsList = (json['districts'] as List?)
            ?.map((d) => DistrictContainerModel.fromJson(d))
            .toList() ?? [];
    return StateContainerModel(
      id: stateJson['id'] ?? 0,
      idCode: stateJson['idCode'] ?? '',
      name: stateJson['name'] ?? '',
      nameMM: stateJson['nameMM'] ?? '',
      districts: districtsList,
    );
  }
}