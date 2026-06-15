import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:mmac/data/models/submit_request_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';

class PdfHelper {
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
        // ignore: deprecated_member_use
        emptyColor: const Color(0xFFFFFFFF),
        gapless: true,
      );
      final imageData = await painter.toImageData(300);
      return imageData!.buffer.asUint8List();
    }
    throw Exception('Failed to compile QR Code image matrix.');
  }

  static Future<File> buildPdfDocument(String applicationNo) async {
    final pdf = pw.Document();
    final qrBytes = await _generateQrImage(applicationNo);
    final qrImage = pw.MemoryImage(qrBytes);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "OFFICIAL APPLICATION RECEIPT",
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                "System Hub",
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.blue700,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
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
              pw.Text(
                "Generated secure payload via App Core Engine.",
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              ),
              pw.Text(
                "Page ${context.pageNumber} of ${context.pagesCount}",
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              ),
            ],
          ),
        ),
        // 3. CORE DOCUMENT ELEMENTS
        build: (pw.Context context) => [
          pw.Header(level: 0, text: "Submission Confirmation"),
          pw.SizedBox(height: 10),
          pw.Paragraph(
            text:
                "Thank you for submitting your digital filing. Your information profile has been indexed securely under the reference record specified below.",
          ),
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
                pw.Text(
                  "Application Reference Key:",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  applicationNo,
                  style: pw.TextStyle(
                    color: PdfColors.blue700,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
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
                pw.Text(
                  "Scan QR code to verify application status.",
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/Application_$applicationNo.pdf');
    return await file.writeAsBytes(bytes);
  }

  static Future<void> downloadAndOpenPdf(String applicationNo) async {
    final file = await buildPdfDocument(applicationNo);
    await OpenFilex.open(file.path);
  }

  static Future<void> sharePdfViaEmail(String applicationNo) async {
    final file = await buildPdfDocument(applicationNo);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Application Receipt: $applicationNo',
      text:
          'Hello,\n\nPlease find attached the receipt and verification QR code for Application No: $applicationNo.',
    );
  }

  static Future<Uint8List> generateArrivalFormPdf(
    String applicationNo,
    SubmitRequestModel data,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  " Arrival Form",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),

              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: applicationNo,
                  width: 150,
                  height: 150,
                ),
              ),
              pw.SizedBox(height: 30),

              _buildInfoRow("Application ID No.", applicationNo),
              _buildInfoRow("Name", data.fullName ?? "-"),
              _buildInfoRow(
                "Gender",
                data.gender == 'M'
                    ? "Male"
                    : (data.gender == 'F' ? "Female" : "-"),
              ),
              _buildInfoRow("Nationality", data.countryOfBirthCode ?? "-"),
              _buildInfoRow(
                "Passport / Visa No.",
                "${data.passportNo ?? '-'} / ${data.visaNo ?? '-'}",
              ),

              if (data.fatherName != null && data.fatherName!.isNotEmpty)
                _buildInfoRow("Father's Name", data.fatherName!),

              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              _buildInfoRow("Arrival Date", data.arrivalDate ?? "-"),
              _buildInfoRow("Purpose of Visit", data.purposeOfVisit ?? "-"),
              _buildInfoRow("Contact (MM)", data.mobileNumberMM ?? "-"),
              _buildInfoRow("Address in Myanmar", data.addressInMyanmar ?? "-"),

              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
          ),
          pw.Expanded(flex: 3, child: pw.Text(value)),
        ],
      ),
    );
  }
}
