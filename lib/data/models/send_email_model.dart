import 'package:mmac/data/models/submit_request_model.dart';

class SendEmailModel {
  final SubmitRequestModel arrivalModel; // CompleteArrivalDTO နှင့် ကိုက်ညီမည့် Data
  final String applicationNo;
  final String referenceNo;
  final String targetEmail;

  SendEmailModel({
    required this.arrivalModel,
    required this.applicationNo,
    required this.referenceNo,
    required this.targetEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': arrivalModel.toJson(), 
      'applicationNo': applicationNo,
      'referenceNo': referenceNo,
      'targetEmail': targetEmail,
    };
  }
}