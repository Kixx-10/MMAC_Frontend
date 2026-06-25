import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/models/qr_response_model.dart';
import 'package:mmac/data/reposistories/qr_scan_repository.dart';

//  Plain Dart State Class
class QrScanState {
  final List<QrResponseModel> scannedDataList;

  QrScanState({this.scannedDataList = const []});

  QrScanState copyWith({List<QrResponseModel>? scannedDataList}) {
    return QrScanState(
      scannedDataList: scannedDataList ?? this.scannedDataList,
    );
  }
}

class QrScanNotifier extends AsyncNotifier<QrScanState> {
  final QrScanRepository _repository = QrScanRepository();

  @override
  Future<QrScanState> build() async {
    return QrScanState(scannedDataList: const []);
  }

  Future<void> verifyQrCode(String appNo) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      try {
        final QrResponseModel? result = await _repository
            .fetchApplicationByQrCode(appNo);

        if (result != null) {
          return QrScanState(scannedDataList: [result]);
        } else {
          throw Exception("Invalid QR");
        }
      } catch (e) {
        if (e.toString().contains("400")) {
          throw Exception("This qr is already approved");
        } else if (e.toString().contains("404")) {
          throw Exception("Invalid QR");
        }
        rethrow;
      }
    });
  }

  void resetScanner() {
    state = AsyncData(QrScanState(scannedDataList: const []));
  }
}

// Global Provider
final qrScanProvider = AsyncNotifierProvider<QrScanNotifier, QrScanState>(
  QrScanNotifier.new,
);
