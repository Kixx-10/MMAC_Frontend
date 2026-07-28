import 'dart:async';
import 'dart:convert';
import 'dart:io' show File;
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
import 'package:flutter/services.dart'; 

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
  bool _isPdfExpanded = true;

  @override
  void initState() {
    super.initState();
    fileName = "ArrivalForm_${widget.responseData.referenceNo}.pdf";
    _convertBase64ToPdfFile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _showInitialNoticeDialog();
      });
    }
  void _showInitialNoticeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text(
                "Important Notice",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Please make sure to perform the following steps:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              _buildNoticeItem(
                icon: Icons.picture_as_pdf,
                iconColor: Colors.red,
                text: "1. Click 'Save PDF' to download your document.",
              ),
              const SizedBox(height: 8),
              _buildNoticeItem(
                icon: Icons.pin,
                iconColor: Colors.blue,
                text: "2. Save or copy your (DE Number).",
              ),
              // const SizedBox(height: 8),
              // _buildNoticeItem(
              //   icon: Icons.mark_email_read,
              //   iconColor: Colors.green,
              //   text: "3. Enter your email address correctly before sending.",
              // ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF014679),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "I Understand", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        );
      },
    );
  }
  Widget _buildNoticeItem({required IconData icon, required Color iconColor, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
          ),
        ),
      ],
    );
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
    } catch (e) {
      _showSnackBar("Error rendering PDF: $e");
    } finally {
      setState(() => isProcessing = false);
    }
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
                decoration: const InputDecoration(
                  labelText: "Email Address", 
                  border: OutlineInputBorder(), 
                  isDense: true,
                  labelStyle: TextStyle(
                    fontSize: 12, 
                    color: Colors.grey, 
                  ),
                ),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\x00-\x7F]'))],
                validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmEmailController,
                enableInteractiveSelection: false,
                contextMenuBuilder: (context, editableTextState) {return const SizedBox.shrink(); },
                decoration: const InputDecoration(
                  labelText: "Confirm Email Address", 
                  border: OutlineInputBorder(), 
                  isDense: true,
                  labelStyle: TextStyle(
                    fontSize: 12, 
                    color: Colors.grey, 
                  ),
                ),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\x00-\x7F]'))],
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
            child: const Text("Send "), 
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
        if (mounted) {
        _showEmailSuccessDialog(email);
      }
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
        child: CircularProgressIndicator(),
      );
    }

    String formatDuration(int secs) => '${(secs ~/ 60).toString().padLeft(2, '0')}:${(secs % 60).toString().padLeft(2, '0')}';

    return Center(
      child: SingleChildScrollView( 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 16, color: Color(0xFF014679)),
                        children: [
                          const TextSpan(text: "DE NUMBER: "),
                          TextSpan(
                            text: widget.responseData.referenceNo,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8), 
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: widget.responseData.referenceNo ?? ""));
                        _showSnackBar("Copied to clipboard");
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                         // Text("Copy", style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              "(Please keep this number carefully as your application DE Number)",
              style: TextStyle(fontSize: 13, color: Colors.red),
            ),
            const SizedBox(height: 24),
              
            LayoutBuilder(
              builder: (context, constraints) {
                double pdfWidth = constraints.maxWidth; 
                double pdfHeight = pdfWidth * 1.414;
              
                return Container(
                  width: pdfWidth, 
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400, width: 1.5),
                  ),
                 clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header အပိုင်း
                      Material(
                        color: Colors.grey.shade50,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isPdfExpanded = !_isPdfExpanded;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf, size: 20, color: Colors.redAccent),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    fileName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  _isPdfExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: Colors.grey.shade700,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      if (_isPdfExpanded)
                        Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

                      // PDF အပိုင်း
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: _isPdfExpanded ? pdfHeight : 0, 
                        child: _pdfBytes == null
                            ? const Center(child: CircularProgressIndicator())
                            : IgnorePointer( 
                                ignoring: false, 
                                child: MouseRegion(
                                  opaque: true,
                                  child: PdfViewer.data(
                                    _pdfBytes!,
                                    sourceName: fileName,
                                    params: PdfViewerParams(
                                      backgroundColor: Colors.white,
                                      pageDropShadow: const BoxShadow(color: Colors.transparent), 
                                      layoutPages: (pages, params) {
                                        double y = 0.0;
                                        final pageLayouts = <Rect>[];
                                        
                                        for (final page in pages) {
                                          final scale = pdfWidth / page.width;
                                          final scaledWidth = page.width * scale;
                                          final scaledHeight = page.height * scale;
                        
                                          pageLayouts.add(
                                            Rect.fromLTWH(0, y, scaledWidth, scaledHeight)
                                          );
                                          y += scaledHeight + 10.0; 
                                        }
                                        return PdfPageLayout(
                                          pageLayouts: pageLayouts,
                                          documentSize: Size(pdfWidth, y),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              }
            ),
            
            const SizedBox(height: 32),

            // 3. Action Buttons (Save PDF, Send Email)
            Row(
              children: [
                Expanded(
                  flex: 3, 
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
                        : const Text("Send", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
            
            // 4. Finish Process Button (Bottom)
            OutlinedButton(
              onPressed: widget.onFinish,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                foregroundColor: Colors.blue.shade800,
                side: BorderSide(color: Colors.blue.shade800, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                "Finish Process",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showEmailSuccessDialog(String sentEmail) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Row(
          children: [
            Icon(Icons.mark_email_read_rounded, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text(
              "Email Sent!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "PDF successfully sent to $sentEmail.",
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Please check your Email Inbox or Spam / Junk folder to confirm receipt of the file.",
                      style: TextStyle(fontSize: 13, color: Colors.black87,fontWeight: FontWeight.bold, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF014679),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}

  }