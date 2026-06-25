// lib/data/models/submit_response_model.dart

class SubmitResponseModel {
  final String message;
  final String applicationNo;
  final String referenceNo; 
  final String pdfData;      

  SubmitResponseModel({
    required this.message,
    required this.applicationNo,
    required this.referenceNo,
    required this.pdfData,
  });

  factory SubmitResponseModel.fromJson(Map<String, dynamic> json) {
    return SubmitResponseModel(
      message: json['message'] ?? '',
      applicationNo: json['applicationNo'] ?? '',
      referenceNo: json['referenceNo'] ?? 'N/A',
      pdfData: json['pdfData'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'applicationNo': applicationNo,
      'referenceNo': referenceNo,
      'pdfData': pdfData,
    };
  }
}