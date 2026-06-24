import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/controllers/approve_application_provider.dart';
import 'package:mmac/data/controllers/qr_scan_provider.dart';
import 'package:mmac/data/models/approve_application_model.dart';
import '../widgets/qr_scanner_view.dart';

class QrScanPage extends ConsumerStatefulWidget {
  const QrScanPage({super.key});

  @override
  ConsumerState<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends ConsumerState<QrScanPage> {
  String? _capturedAppNo;
  void _handleApproval(BuildContext context, WidgetRef ref, String appNo, String appStatus) async {
  showDialog(
    context: context,
    barrierDismissible: false, 
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  final request = ApproveApplicationModel(
    appNo: appNo,
    appStatus: appStatus,
  );

  final success = await ref.read(approveApplicationProvider.notifier)
                           .approveApplicationAction(request);

  if (context.mounted) Navigator.pop(context);
  if (context.mounted) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(success == true ? "Success" : "Error"),
        content: Text(success == true 
            ? "Successfully ${appStatus == 'Approved' ? 'Approved' : 'Rejected'}!" 
            : "Failed to perform action."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final asyncScanState = ref.watch(qrScanProvider);

    return asyncScanState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      // ...
      error: (error, stack) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  error.toString().replaceAll("Exception: ", ""),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B355B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () =>
                      ref.read(qrScanProvider.notifier).resetScanner(),
                  child: const Text(
                    "TRY AGAIN",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // ...
      data: (scanState) {
       
        if (scanState.scannedDataList.isEmpty){
                return QrScannerView(
  onScanned: (value) {
    setState(() {
      _capturedAppNo = value; 
    });
    debugPrint("✅ AppNo captured in Page: $value");
  },
);
        }
    

        final data = scanState.scannedDataList[0];
        final bool isMyanmar = data.issuedCountryCode == 'MMR';

        // ignore: no_leading_underscores_for_local_identifiers
        Widget _infoItem(String title, String value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 97, 96, 96),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        );

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.5,
                            children: [
                              _infoItem("Full Name", data.fullName),
                              _infoItem("DE Number", data.referenceNo),
                              _infoItem("AppStatus", data.appStatus),
                              _infoItem("Gender", data.gender),
                              _infoItem(
                                "Date of Birth",
                                data.dob?.toString().split(' ')[0] ?? "--",
                              ),
                              _infoItem("Country", data.countryOfBirthCode),
                              if (isMyanmar) ...[
                                _infoItem("NRC", data.nrc ?? "--"),
                                _infoItem(
                                  "Father Name",
                                  data.fatherName ?? "--",
                                ),
                                _infoItem(
                                  "Mobile Number (Myanamar)",
                                  data.mobileNumberMM ?? "--",
                                ),
                              ] else ...[
                                _infoItem("Visa Number", data.visaNo ?? "--"),
                                _infoItem(
                                  "Accommodation",
                                  data.accommodation ?? "--",
                                ),
                              ],
                              _infoItem("Email", data.email),
                              _infoItem("Moile Number", data.mobileNumber),
                              _infoItem("Passport Number", data.passportNo),
                              _infoItem(
                                "Issued Country",
                                data.issuedCountryCode,
                              ),
                              _infoItem(
                                "Issued Date",
                                data.issuedDate?.toString().split(' ')[0] ??
                                    "--",
                              ),
                              _infoItem(
                                "Expiry Date",
                                data.expiryDate?.toString().split(' ')[0] ??
                                    "--",
                              ),
                              _infoItem(
                                "Arrival Date",
                                data.arrivalDate?.toString().split(' ')[0] ??
                                    "--",
                              ),
                              _infoItem(
                                "Purpose Of Visit",
                                data.purposeOfVisit,
                              ),
                              _infoItem(
                                "Address in Myanmar",
                                data.addressInMyanmar,
                              ),
                              _infoItem(
                                "Mode of Travel",
                                data.modeOfTravelName,
                              ),
                              _infoItem(
                                "Port of Arrival",
                                data.portOfArrivalName,
                              ),
                              _infoItem(
                                "Health Declaration.",
                                data.healthDeclaration ?? "--",
                              ),
                              _infoItem(
                                "Digital Declaration.",
                                data.healthDeclaration ?? "--",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: 100,
                      height: 30,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B355B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            ref.read(qrScanProvider.notifier).resetScanner(),
                        child: const Text(
                          "Re-Scan",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: 100,
                      height: 30,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            _handleApproval(context,ref,_capturedAppNo!, "Approved"),
                        child: const Text(
                          "Approved",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: 100,
                      height: 30,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            _handleApproval(context,ref, _capturedAppNo!, "Rejected"),
                        child: const Text(
                          "Reject",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
