import 'dart:async';
import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:mmac/data/models/send_email_model.dart';
import 'package:mmac/data/models/submit_request_model.dart';
import 'package:mmac/service/sendEmail_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart'; 
import 'package:mmac/data/models/submit_response_model.dart';
import 'package:universal_html/html.dart' as html;

class QrGenerateScreen extends ConsumerStatefulWidget {
  final SubmitResponseModel responseData;
  final SubmitRequestModel requestData; 
  final VoidCallback onFinish;
  final String email;
  final VoidCallback? onReturnHome;

  const QrGenerateScreen({
    super.key,
    required this.responseData,
    required this.requestData, 
    required this.onFinish,
    required this.email,
    this.onReturnHome,
  });

  @override
  ConsumerState<QrGenerateScreen> createState() => _QrGenerateScreenState();
}

class _QrGenerateScreenState extends ConsumerState<QrGenerateScreen> {
  bool isProcessing = false;
  String fileName = "";
  String? localFilePath;
  Uint8List? _pdfBytes;

  int _sendCount = 0;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  bool _dialogShown = false; 

  @override
  void initState() {
    super.initState();
    fileName = "ArrivalForm_${widget.responseData.referenceNo}.pdf";
    _convertBase64ToPdfFile();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer(int seconds) {
    setState(() {
      _cooldownSeconds = seconds;
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        setState(() {
          _cooldownSeconds--;
        });
      } else {
        _cooldownTimer?.cancel();
      }
    });
  }

  Future<void> _convertBase64ToPdfFile() async {
    if (widget.responseData.pdfData.isEmpty) {
      _showSnackBar("PDF data is empty or missing from response.");
      return;
    }

    setState(() => isProcessing = true);
    try {
      String base64String = widget.responseData.pdfData;
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }
      _pdfBytes = base64Decode(base64String.trim());

      if (kIsWeb) {
        final blob = html.Blob([_pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        setState(() {
          localFilePath = url;
        });
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(_pdfBytes!, flush: true);

        if (await file.exists()) {
          setState(() {
            localFilePath = file.path;
          });
        }
      }

      if (mounted && !_dialogShown) {
        _dialogShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showPdfDialog();
        });
      }

    } catch (e) {
      _showSnackBar("Error rendering PDF: $e");
    } finally {
      setState(() => isProcessing = false);
    }
  }

  void _showPdfDialog() {
    if (_pdfBytes == null) return;

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
        final double screenHeight = MediaQuery.of(context).size.height;
        final double screenWidth = MediaQuery.of(context).size.width;

        return AlertDialog(
          backgroundColor: const Color(0xFFFAFAFA), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          titlePadding: const EdgeInsets.all(16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          actionsPadding: const EdgeInsets.all(16),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                  SizedBox(width: 8),
                  Text(
                    "PDF Arrival Form",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: SizedBox(
            width: screenWidth > 600 ? 550 : screenWidth * 0.9,
            height: screenHeight * 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Notice: Show this e-Arrival QR code (on your mobile or printed) to the officers upon arrival.",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: MouseRegion(
                        opaque: true,
                        child: PdfViewer.data(
                          _pdfBytes!,
                          sourceName: fileName,
                          params: const PdfViewerParams(backgroundColor: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.file_download_rounded),
                    label: const Text("Download"),
                    onPressed: () {
                      _savePdfFile();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4), 
                          ),
                    ),
                  ),
                ),
                // const SizedBox(width: 12),
                // OutlinedButton(
                //   onPressed: () => Navigator.of(context).pop(),
                //   style: OutlinedButton.styleFrom(
                //     foregroundColor: Colors.grey.shade700,
                //     side: BorderSide(color: Colors.grey.shade400),
                //     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                //   ),
                //   child: const Text("Close"),
                // ),
              ],
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _savePdfFile() async {
    if (_pdfBytes == null) return;
    final TextEditingController fileNameController = TextEditingController(text: fileName.replaceAll('.pdf', ''));

    String? inputName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Change File Name", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: TextField(controller: fileNameController, autofocus: true, decoration: const InputDecoration(border: OutlineInputBorder(), suffixText: '.pdf', isDense: true)),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), 
              ),
            ),
            child: const Text("Cancel"), 
            onPressed: () => Navigator.pop(context, null),
          ),
          
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), 
                side: const BorderSide(color: Colors.grey), 
              ),
            ),
            child: const Text("Save"), 
            onPressed: () => Navigator.pop(context, fileNameController.text.trim()),
          ),
        ],
      ),
    );

    if (inputName == null || inputName.isEmpty) return;
    if (!inputName.toLowerCase().endsWith('.pdf')) inputName = "$inputName.pdf";

    try {
      setState(() => fileName = inputName!);
      if (kIsWeb) {
        final blob = html.Blob([_pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)..setAttribute("download", inputName)..click();
        html.Url.revokeObjectUrl(url);
      }
      _showSnackBar("PDF saved successfully.");
    } catch (e) {
      _showSnackBar("Failed to save: $e");
    }
  }

  void _showShareEmailDialog() {
    if (_cooldownSeconds > 0) return;
    final TextEditingController emailController = TextEditingController(text: widget.email);
    final TextEditingController confirmEmailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Send to Email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.red.shade200)),
                child: const Text("Notice: Please fill your active email and verified.", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email Address", border: OutlineInputBorder(), isDense: true,labelStyle: TextStyle(
                fontSize: 12, 
                color: Colors.grey, 
              ),),
                validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmEmailController,
                decoration: const InputDecoration(labelText: "Confirm Email Address", border: OutlineInputBorder(), isDense: true,labelStyle: TextStyle(
                fontSize: 12, 
                color: Colors.grey, 
              ),),
                validator: (val) => (val != emailController.text) ? "Emails do not match" : null,
              ),
            ],
          ),
        ),
        actions: [
        
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), 
              ),
            ),
            child: const Text("Cancel"), 
            onPressed: () => Navigator.pop(context),
          ),
          
        
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), 
                side: const BorderSide(color: Colors.grey),
              ),
            ),
            child: const Text("Send"), 
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                _sendPdfToEmail(emailController.text.trim());
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sendPdfToEmail(String email) async {
    setState(() => isProcessing = true);
    try {
      final emailPayload = SendEmailModel(arrivalModel: widget.requestData, applicationNo: widget.responseData.applicationNo, referenceNo: widget.responseData.referenceNo ?? "N/A", targetEmail: email);
      final isSuccess = await ref.read(sendEmailServiceProvider.notifier).sendEmail(emailPayload);
      if (isSuccess) {
        _sendCount++;
        _showSnackBar("Email sent successfully.");
        _startCooldownTimer(_sendCount == 1 ? 60 : 180);
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    } finally {
      setState(() => isProcessing = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

 @override
  Widget build(BuildContext context) {
    final emailState = ref.watch(sendEmailServiceProvider);
    if (isProcessing || emailState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: CircularProgressIndicator(),
        ),
      );
    }

    String formatDuration(int secs) => '${(secs ~/ 60).toString().padLeft(2, '0')}:${(secs % 60).toString().padLeft(2, '0')}';

    // 1. Build the Left Card (Application Overview - Red Box)
    Widget buildApplicationOverviewCard() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // const Text(
            //   "Application Overview",
            //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            // ),
            // const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 18, color: Color(0xFF014679)),
                      children: [
                        const TextSpan(text: "Reference No: "),
                        TextSpan(
                          text: widget.responseData.referenceNo,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    // You can add Clipboard.setData logic here if you import 'package:flutter/services.dart';
                  },
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text("Copy", style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              "(Please keep this number carefully as your application reference number)",
              style: TextStyle(fontSize: 13, color: Colors.red),
            ),
            const SizedBox(height: 24),
            
            const Divider(height: 1, thickness: 1),
            //const SizedBox(height: 20),
            
            const SizedBox(height: 12),
           Container(
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  decoration: BoxDecoration(
    color: const Color(0xFF099CF4).withOpacity(0.1), // အပြာရောင်ဖျော့ဖျော့ နောက်ခံ
    borderRadius: BorderRadius.circular(6),
    border: Border.all(
      color: const Color(0xFF099CF4).withOpacity(0.3), // ဘောင်အတွက် အပြာနုရောင်
      width: 1,
    ),
  ),
  child: const Row(
    children: [
      Icon(
        Icons.info_outline_rounded,
        color: Color(0xFF099CF4),
        size: 20,
      ),
      SizedBox(width: 10),
      Expanded(
        child: Text(
          "Please carefully check your arrival PDF and download it. You can also save the file by sending it to your email.",
          style: TextStyle(
            color: Color(0xFF077AB8), // စာသားအတွက် အပြာရောင် အစင်း/အထိုက် (Contrast ကောင်းအောင်လို့ပါ)
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    ],
  ),
),
          ],
        ),
      );
    }

    // 2. Build the Right Card (Actions & Files - Green Box)
    Widget buildActionsAndFilesCard() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf, size: 14),
              label: const Text("View Arrival Form PDF", style: TextStyle(fontSize: 12)),
              onPressed: _pdfBytes == null ? null : _showPdfDialog,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade800,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                side: BorderSide(color: Colors.blue.shade200),
                elevation: 0,
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Divider(height: 1, thickness: 1),
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.file_download_rounded, size: 16),
                    label: const Text(
                      "Save PDF",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _pdfBytes == null ? null : _savePdfFile,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      backgroundColor: const Color(0xFF099CF4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: (_pdfBytes == null || _cooldownSeconds > 0) ? null : _showShareEmailDialog,
                    icon: _cooldownSeconds > 0 
                        ? const SizedBox.shrink() 
                        : const Icon(Icons.send, size: 16),
                    label: _cooldownSeconds > 0
                        ? Text(formatDuration(_cooldownSeconds), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))
                        : const Text("Send Email", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            OutlinedButton(
              onPressed: widget.onFinish,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                foregroundColor: Colors.blue.shade800,
                side: BorderSide(color: Colors.blue.shade800, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Finish Process",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    // 3. Main Layout Return
    return LayoutBuilder(
      builder: (context, constraints) {
        // If screen is wide enough (web/tablet), show them side-by-side
        if (constraints.maxWidth > 800) {
          return  Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             Expanded(flex: 20, child: buildApplicationOverviewCard()),
              const SizedBox(width: 5),
              Expanded(flex: 10, child: buildActionsAndFilesCard()),
            ],
          );
        } 
        // Otherwise, stack them vertically for mobile screens
        else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildApplicationOverviewCard(),
              const SizedBox(height: 16),
              buildActionsAndFilesCard(),
            ],
          );
        }
      },
    );
  }
  }