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

  const QrGenerateScreen({
    super.key,
    required this.responseData,
    required this.requestData, 
    required this.onFinish,
    required this.email,
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
                          "Notice: PDF is important",
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  child: const Text("Close"),
                ),
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
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context, null)),
          ElevatedButton(child: const Text("Save"), onPressed: () => Navigator.pop(context, fileNameController.text.trim())),
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
        title: const Text("Share via Email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context)),
          ElevatedButton(child: const Text("Send"), onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context);
              _sendPdfToEmail(emailController.text.trim());
            }
          }),
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

   return Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  mainAxisSize: MainAxisSize.min,
  children: [
    Row(
      children: [
        const Text(
          "Reference No: ", 
          style: TextStyle(fontSize: 13, color: Color(0xFF014679))
        ),
        Text(
          widget.responseData.referenceNo, 
          style: const TextStyle(fontSize: 14, color: Color(0xFF014679), fontWeight: FontWeight.bold)
        ),
      ],
    ),
    const SizedBox(height: 4),
    const Text(
      "(Please keep this number carefully as your application reference number)", 
      style: TextStyle(fontSize: 13, color: Colors.red)
    ),
    const SizedBox(height: 24),
    
    Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf, size: 20),
            label: const Text("View Arrival Form PDF"),
            onPressed: _pdfBytes == null ? null : _showPdfDialog,
            style: ElevatedButton.styleFrom(
              // လေးထောင့်ပုံစံ (Rectangular) ပြောင်းရန်
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), 
              ),
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.blue.shade200),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Share Button အသေး
        ElevatedButton(
          onPressed: (_pdfBytes == null || _cooldownSeconds > 0) ? null : _showShareEmailDialog,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            elevation: 0,
          ),
          child: _cooldownSeconds > 0 
              // စောင့်ရမယ့် အချိန်ရှိနေရင် စာသားပြမည်
              ? Text(formatDuration(_cooldownSeconds), style: const TextStyle(fontSize: 12)) 
              // မရှိရင် Share Icon လေးသာ ပြမည်
              : const Icon(Icons.share_rounded, size: 20), 
        ),
      ],
    ),
    const SizedBox(height: 16),

    ElevatedButton.icon(
      icon: const Icon(Icons.file_download_rounded, size: 20),
      label: const Text(
        "Save PDF",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), 
      ),
      onPressed: _pdfBytes == null ? null : _savePdfFile,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.blue.shade600, 
        foregroundColor: Colors.white, 
        padding: const EdgeInsets.symmetric(vertical: 15),
        elevation: 0
      ),
    ),
    const SizedBox(height: 16),

    OutlinedButton(
      onPressed: widget.onFinish,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        foregroundColor: Colors.blue.shade800, 
        side: BorderSide(color: Colors.blue.shade800, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 15), 
      ),
      child: const Text(
        "Finish Process",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), 
      ),
    ),
  ],
);
}
}