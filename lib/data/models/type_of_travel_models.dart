class PortOfArrival{
  final int modeOfTravelId;
  final String modeOfTravelName;
  final int portOfArrivalId;
  final String portOfArrivalName;

  PortOfArrival({
    required this.modeOfTravelId,
     required this.modeOfTravelName,
      required this.portOfArrivalId, 
      required this.portOfArrivalName});
 factory PortOfArrival.fromJson(Map<String, dynamic> json) {
    return PortOfArrival(
      modeOfTravelId: json['modeOfTravelId'] ?? 0,
      modeOfTravelName: json['modeOfTravelName'] ?? '',
      portOfArrivalId: json['portOfArrivalId'] ?? 0,
      portOfArrivalName: json['portOfArrivalName'] ?? '',
    );
  }     
}
