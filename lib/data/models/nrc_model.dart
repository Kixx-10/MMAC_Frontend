class NRCTownshipModel {
  final int id;
  final String idCode; // English
  final String codeMM; // Myanmar
  final int nrcStateId;

  NRCTownshipModel({
    required this.id,
    required this.idCode,
    required this.codeMM,
    required this.nrcStateId,
  });

  factory NRCTownshipModel.fromJson(Map<String, dynamic> json) {
    return NRCTownshipModel(
      id: json['id'] ?? 0,
      idCode: json['idCode'] ?? '',
      codeMM: json['codeMM'] ?? '',
      nrcStateId: json['nrC_SRId'] ?? 0,
    );
  }
}

class NRCStateContainerModel {
  final int id;
  final String idCode; // 1
  final String codeMM; // ၁
  final List<NRCTownshipModel> nrcTownships; //store township list

  NRCStateContainerModel({
    required this.id,
    required this.idCode,
    required this.codeMM,
    required this.nrcTownships,
  });

  factory NRCStateContainerModel.fromJson(Map<String, dynamic> json) {
    // read nrcState object from json
    final nrcStateJson = json['nrcState'] as Map<String, dynamic>? ?? {};
    
    // change nrcTownships to nrcTownshipsJson and ensure it's a List<dynamic>
    final townshipsJson = json['nrcTownships'] as List<dynamic>? ?? [];

    return NRCStateContainerModel(
      id: nrcStateJson['id'] ?? 0,
      idCode: nrcStateJson['idCode'] ?? '',
      codeMM: nrcStateJson['codeMM'] ?? '',
      nrcTownships: townshipsJson
          .map((t) => NRCTownshipModel.fromJson(t))
          .toList(),
    );
  }
}