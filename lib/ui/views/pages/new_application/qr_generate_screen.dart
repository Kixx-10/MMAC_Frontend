// lib/ui/views/pages/new_application/qr_generate_screen.dart
// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart'; // 📄 pdfx package
import 'package:mmac/data/models/submit_response_model.dart';
import 'package:universal_html/html.dart' as html;

class QrGenerateScreen extends StatefulWidget {
  final SubmitResponseModel responseData;
  final VoidCallback onFinish;

  const QrGenerateScreen({
    Key? key,
    required this.responseData,
    required this.onFinish,
  }) : super(key: key);

  @override
  _QrGenerateScreenState createState() => _QrGenerateScreenState();
}

class _QrGenerateScreenState extends State<QrGenerateScreen> {
  bool isProcessing = false;
  String fileName = "";
  String? localFilePath;
  Uint8List? _pdfBytes;

  PdfControllerPinch? _pdfController;

  @override
  void initState() {
    super.initState();
    fileName = "ArrivalForm_${widget.responseData.applicationNo}.pdf";
    _convertBase64ToPdfFile();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
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

      // ✅ FIX: PdfControllerPinch ကို အသုံးပြု၍ openData ဖြင့် ဆောက်လုပ်သည်
      _pdfController = PdfControllerPinch(
        document: PdfDocument.openData(_pdfBytes!),
      );

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

  // 📄 FILE NAME BOX ကို နှိပ်လျှင် Dialog Box ဖြင့် PDF Preview ပြသမည့် လုပ်ဆောင်ချက်
  void _showPdfPreviewDialog() {
    if (_pdfController == null) {
      _showSnackBar("PDF preview is not ready yet.");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.all(16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
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
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              // ✅ ဤနေရာတွင် Type တူညီသွားပြီဖြစ်၍ error လုံးဝမတက်တော့ပါ
              child: PdfViewPinch(controller: _pdfController!),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Close",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // 💾 SAVE BUTTON ကို နှိပ်လျှင် Dialog ဖြင့် အမည်ပြောင်းပြီး သိမ်းဆည်းမည့် လုပ်ဆောင်ချက်
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
              onPressed: () =>
                  Navigator.pop(context, fileNameController.text.trim()),
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text(
                    "Preparing Document...",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 📄 ၁။ FILE NAME BOX (နှိပ်လျှင် Web/Mobile နှစ်ခုလုံး Dialog ဖြင့် Preview ပွင့်မည်)
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

                // 💾 ၂။ SAVE PDF BUTTON
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt_rounded),
                  label: const Text(
                    "Save PDF Document",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
