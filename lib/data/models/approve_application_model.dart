
class ApproveApplicationModel {
  final String appNo;
  final String appStatus;
  final String approveUser;
  ApproveApplicationModel({
    required this.appNo,
    required this.appStatus,
    this.approveUser = "Immigration Officer",
  });
  Map<String,dynamic>tojson(){
  return
  {
    'appNo':appNo,
    'appStatus':appStatus,
    'approvedUser':approveUser,
  };
  }
}