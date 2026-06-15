import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';

class PdfHelper {
  // Generates a QR Code image block from the raw string data
  static Future<Uint8List> _generateQrImage(String data) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );
    if (qrValidationResult.status == QrValidationStatus.valid) {
      final qrCode = qrValidationResult.qrCode!;
      final painter = QrPainter.withQr(
        qr: qrCode,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
        gapless: true,
      );
      final imageData = await painter.toImageData(300);
      return imageData!.buffer.asUint8List();
    }
    throw Exception('Failed to compile QR Code image matrix.');
  }

  // Base Document Constructor Pipe
  static Future<File> buildPdfDocument(String applicationNo) async {
    final pdf = pw.Document();
    final qrBytes = await _generateQrImage(applicationNo);
    final qrImage = pw.MemoryImage(qrBytes);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        // 1. REUSABLE HEADER STRUCTURE
        header: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.centerRight,
         // border: const pw.Border(bottom: pw.BorderSide(color: PdfColors.blue700, width: 2)),
          //padding: const pw.EdgeInsets.bottom(8),
         // margin: const pw.EdgeInsets.bottom(24),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("OFFICIAL APPLICATION RECEIPT", style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700, fontWeight: pw.FontWeight.bold)),
              pw.Text("System Hub", style: pw.TextStyle(fontSize: 14, color: PdfColors.blue700, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
        // 2. REUSABLE FOOTER STRUCTURE
        footer: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.center,
          //margin: const pw.EdgeInsets.top(24),
         // border: const pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 1)),
        //  padding: const pw.EdgeInsets.top(8),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Generated secure payload via App Core Engine.", style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
              pw.Text("Page ${context.pageNumber} of ${context.pagesCount}", style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
            ],
          ),
        ),
        // 3. CORE DOCUMENT ELEMENTS
        build: (pw.Context context) => [
          pw.Header(level: 0, text: "Submission Confirmation"),
          pw.SizedBox(height: 10),
          pw.Paragraph(text: "Thank you for submitting your digital filing. Your information profile has been indexed securely under the reference record specified below."),
          pw.SizedBox(height: 20),
          
          // Metadata Box Template
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Application Reference Key:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(applicationNo, style: pw.TextStyle(color: PdfColors.blue700, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
          pw.SizedBox(height: 40),

          // QR Placement Framework
          pw.Center(
            child: pw.Column(
              children: [
                pw.Container(
                  width: 180,
                  height: 180,
                  padding: const pw.EdgeInsets.all(8),
                  //border: pw.Border.all(color: PdfColors.grey400, width: 1),
                  child: pw.Image(qrImage),
                ),
                pw.SizedBox(height: 8),
                pw.Text("Scan QR code to verify application status.", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              ],
            ),
          ),
        ],
      ),
    );

    // Save out document execution stream to storage targets[cite: 1]
  final bytes = await pdf.save(); // နောက်က ; ကို ဖျက်ပါ
    final directory = await getApplicationDocumentsDirectory(); // ဖျက်ပါ
    final file = File('${directory.path}/Application_$applicationNo.pdf'); // ဖျက်ပါ
    return await file.writeAsBytes(bytes);
  }

  // Action Method A: Save locally and launch viewer
  static Future<void> downloadAndOpenPdf(String applicationNo) async {
    final file = await buildPdfDocument(applicationNo);
    await OpenFilex.open(file.path);
  }

  // Action Method B: Send directly via external targets (Gmail, etc.)
  static Future<void> sharePdfViaEmail(String applicationNo) async {
    final file = await buildPdfDocument(applicationNo);
    
    // Triggers native overlay share controller
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Application Receipt: $applicationNo',
      text: 'Hello,\n\nPlease find attached the receipt and verification QR code for Application No: $applicationNo.',
    );
  }
 static Future<Uint8List> generateArrivalFormPdf(String applicationNo) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text( " Arrival Form",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),

              // QR Code
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: applicationNo, 
                  width: 150,
                  height: 150,
                ),
              ),
              pw.SizedBox(height: 30),

              // အချက်အလက်များ
              _buildInfoRow("Application ID No.", "NPW_2025_$applicationNo"),
              _buildInfoRow("Appointment Date", "31-01-2025\n12:00PM - 02:00PM"),
              _buildInfoRow("Name", "Nway Nway"), 
              _buildInfoRow("Father's Name", "U Aye"),
              
              pw.SizedBox(height: 20),
              
            ],
          );
        },
      ),
    );

    // File အဖြစ်မသိမ်းတော့ဘဲ Bytes အနေနဲ့သာ ပြန်ပို့သည် (Web Safe)
    return await pdf.save(); 
  }

  // Row UI Helper
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }
}
