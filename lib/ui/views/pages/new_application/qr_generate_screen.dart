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

  @override
  void initState() {
    super.initState();
    fileName = "ArrivalForm_${widget.responseData.referenceNo}.pdf";
    _convertBase64ToPdfFile();
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
        return;
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');

      await file.writeAsBytes(_pdfBytes!, flush: true);

      if (await file.exists()) {
        setState(() {
          localFilePath = file.path;
        });
      } else {
        throw Exception("File verification failed on storage.");
      }
    } catch (e) {
      _showSnackBar("Error rendering PDF view: $e");
    } finally {
      setState(() => isProcessing = false);
    }
  }

 void _showPdfPreviewDialog() {
    if (_pdfBytes == null) {
      _showSnackBar("PDF preview is not ready yet.");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final double dialogWidth = MediaQuery.of(context).size.width * 0.9;
        final double dialogHeight = MediaQuery.of(context).size.height * 0.65;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.all(16),
          contentPadding: EdgeInsets.zero, 
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text(
                    "PDF Preview",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Container(
                color: Colors.grey.shade100,
                child: PdfViewer.data(
                  _pdfBytes!,
                  sourceName: fileName,
                  params: PdfViewerParams(
                    layoutPages: (pages, params) {
                      final pageLayouts = <Rect>[];
                      double y = 0.0;
                      
                      for (int i = 0; i < pages.length; i++) {
                        final page = pages[i];
                        final double h = dialogWidth * (page.height / page.width);
                        pageLayouts.add(Rect.fromLTWH(0, y, dialogWidth, h));
                        y += h + 8; 
                      }
                      
                      return PdfPageLayout(
                        pageLayouts: pageLayouts,
                        documentSize: Size(dialogWidth, y),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Future<void> _savePdfFile() async {
    if (_pdfBytes == null) {
      _showSnackBar("No PDF data available to save.");
      return;
    }

    final TextEditingController fileNameController = TextEditingController(
      text: fileName.replaceAll('.pdf', ''),
    );

    String? inputName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Change File Name to Save",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter new name:",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: fileNameController,
                autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  suffixText: '.pdf',
                  isDense: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context, null),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text("Save"),
              onPressed: () => Navigator.pop(context, fileNameController.text.trim()),
            ),
          ],
        );
      },
    );

    if (inputName == null || inputName.isEmpty) return;

    if (!inputName.toLowerCase().endsWith('.pdf')) {
      inputName = "$inputName.pdf";
    }

    try {
      setState(() => fileName = inputName!);

      if (kIsWeb) {
        final blob = html.Blob([_pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", inputName)
          ..click();
        html.Url.revokeObjectUrl(url);
        _showSnackBar("PDF saved successfully as $inputName");
      } else {
        _showSnackBar("PDF saved to local storage: $inputName");
      }
    } catch (e) {
      _showSnackBar("Failed to save PDF: $e");
    }
  }

  void _showShareEmailDialog() {
    final String initialEmail = widget.email; 
    final TextEditingController emailController = TextEditingController(text: initialEmail);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.mail_rounded, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text(
                "Share via Email",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Send PDF document to this email address:",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email Address",
                    hintText: "example@gmail.com",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter an email address";
                    }
                    final bool isValid = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                    ).hasMatch(value.trim());
                    if (!isValid) {
                      return "Please enter a valid email address";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text("Send"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final String recipientEmail = emailController.text.trim();
                  Navigator.pop(context);
                  _sendPdfToEmail(recipientEmail);
                }
              },
            ),
          ],
        );
      },
    );
  }

 Future<void> _sendPdfToEmail(String email) async {
    setState(() => isProcessing = true);
    try {
      // 💡 ပြင်ဆင်ရန် - ပြဿနာဖြစ်နေသော Field များအားလုံးကို widget.requestData ဆီမှ တိုက်ရိုက်ယူသုံးလိုက်ခြင်းဖြင့် Error ကင်းစင်သွားပါမည်
      final emailPayload = SendEmailModel(
        arrivalModel: widget.requestData, // Form တင်စဉ်က ဒေတာအပြည့်အစုံ ပါဝင်ပြီးသားဖြစ်သည်
        applicationNo: widget.responseData.applicationNo,
        referenceNo: widget.responseData.referenceNo ?? "N/A",
        targetEmail: email,
      );

      final isSuccess = await ref.read(sendEmailServiceProvider.notifier).sendEmail(emailPayload);

      if (isSuccess) {
        _showSnackBar("PDF has been successfully sent to $email");
      } else {
        _showSnackBar("Failed to send email. Please try again.");
      }
    } catch (e) {
      _showSnackBar("Failed to send email: $e");
    } finally {
      setState(() => isProcessing = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emailState = ref.watch(sendEmailServiceProvider);
    final bool showLoading = isProcessing || emailState.isLoading;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: showLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text(
                    "Sending Email, Please wait...",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 📄 ၁။ FILE NAME BOX
                InkWell(
                  onTap: _showPdfPreviewDialog,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.insert_drive_file_rounded,
                          color: Colors.blueAccent,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Tap to preview PDF document inside dialog",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.visibility_rounded,
                          color: Colors.blueAccent,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 💾 ✉️ ၂။ SAVE & SHARE BUTTONS (In a Row)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save_alt_rounded, size: 20),
                        label: const Text(
                          "Save PDF",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _pdfBytes == null ? null : _savePdfFile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.share_rounded, size: 20),
                        label: const Text(
                          "Share Email",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _pdfBytes == null ? null : _showShareEmailDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Divider(),
                const SizedBox(height: 16),

                // 🏁 ၃။ FINISH PROCESS BUTTON
                OutlinedButton(
                  onPressed: widget.onFinish,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue.shade800,
                    side: BorderSide(color: Colors.blue.shade800, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Finish Process",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
    );
  }
}