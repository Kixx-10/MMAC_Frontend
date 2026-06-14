import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart'; 
// သင့်ရဲ့ PdfHelper လမ်းကြောင်းကို မှန်ကန်အောင် ပြင်ပါ
import 'package:mmac/ui/views/pages/new_application/pdf_heaper.dart';

class QrGenerate extends StatefulWidget {
  final String applicationNo;
  final VoidCallback onFinish;

  const QrGenerate({
    super.key, 
    required this.applicationNo,
    required this.onFinish,
  });

  @override
  State<QrGenerate> createState() => _QrGenerateState();
}

class _QrGenerateState extends State<QrGenerate> {
  Uint8List? _pdfBytes; // လမ်းကြောင်းအစား Data ကို သိမ်းပါမည်
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _generatePdfInBackground();
  }

  // နောက်ကွယ်တွင် PDF ဖန်တီးခြင်း
  Future<void> _generatePdfInBackground() async {
    if (widget.applicationNo.isEmpty) return;
    try {
      Uint8List bytes = await PdfHelper.generateArrivalFormPdf(widget.applicationNo);
      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint("PDF Generation Error: $e");
    }
  }

  // Dialog ဖြင့် PDF Preview ပြခြင်း (Web အတွက် PdfPreview အသုံးပြုထားသည်)
  void _showPdfPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(" Arrival form", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          // printing package မှ Preview Widget
          child: PdfPreview(
            build: (format) => _pdfBytes!,
            allowPrinting: false, // Toolbar များကို ဖျောက်ထားရန်
            allowSharing: false,
            canChangeOrientation: false,
            canChangePageFormat: false,
            maxPageWidth: 700,
          ),
        ),
      ),
    );
  }

  // ဖိုင်ဒေါင်းလုဒ် / Share လုပ်ခြင်း (Web တွင် Download အဖြစ်အလုပ်လုပ်ပါသည်)
  Future<void> _saveOrSharePdf() async {
    if (_pdfBytes == null) return;
    
    setState(() => _isProcessing = true);
    try {
      final validAppNo = widget.applicationNo.isNotEmpty ? widget.applicationNo : 'N/A';
      // Web ပေါ်တွင် ၎င်းသည် browser ၏ download box ကို ပေါ်စေပါသည်
      await Printing.sharePdf(
        bytes: _pdfBytes!,
        filename: 'ArrivalForm_$validAppNo.pdf',
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final validAppNo = widget.applicationNo.isNotEmpty ? widget.applicationNo : 'N/A';
    final String fileName = "ArrivalForm_$validAppNo.pdf";

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 12),
            const Text(
              "Submitted Successfully!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 20),
            
            Text(
              "Application Number: $validAppNo",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue),
            ),
            const SizedBox(height: 30),

            // ၁။ FILE NAME BOX (CLICK TO PREVIEW)
            GestureDetector(
              onTap: _pdfBytes != null ? () => _showPdfPreview(context) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Tap to preview document",
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    if (_pdfBytes == null) 
                      const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      const Icon(Icons.visibility, color: Colors.blue, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ၂။ DOCUMENT UTILITY ACTIONS (SAVE & SHARE)
            _isProcessing 
            ? const CircularProgressIndicator()
            : Row(
                children: [
                  // Action 1: Save (Download)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt_rounded),
                      label: const Text("Save"),
                      onPressed: _pdfBytes == null ? null : _saveOrSharePdf,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Action 2: Share (Web တွင် Save နှင့် အတူတူပင် အလုပ်လုပ်သည်)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.share_rounded),
                      label: const Text("Share"),
                      onPressed: _pdfBytes == null ? null : _saveOrSharePdf,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 40),

            // ၃။ FINISH BUTTON
            ElevatedButton(
              onPressed: widget.onFinish, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Finish", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}