// lib/data/models/submit_model.dart

class SubmitResponseModel {
  final String message;
  final String applicationNo;
  final String qrCodeContent;

  SubmitResponseModel({
    required this.message,
    required this.applicationNo,
    required this.qrCodeContent,
  });

  factory SubmitResponseModel.fromJson(Map<String, dynamic> json) {
    return SubmitResponseModel(
      message: json['message'] ?? '',
      applicationNo: json['applicationNo'] ?? '',
      qrCodeContent: json['qrCodeContent'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'applicationNo': applicationNo,
      'qrCodeContent': qrCodeContent,
    };
  }
}