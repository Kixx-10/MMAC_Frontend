
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pdfrx/pdfrx.dart';

Widget _buildFileContent(String fileUrl, String fileName) {
  final parts = fileName.split('.');
  final String ext = parts.length > 1 ? parts.last.toLowerCase() : '';

  //  PDF Viewer (pdfrx)
  if (ext == 'pdf') {
    return PdfViewer.uri(Uri.parse(fileUrl));
  }
  //  Image Viewer (photo_view)
  else if (['jpg', 'jpeg', 'png'].contains(ext)) {
    return PhotoView(imageProvider: NetworkImage(fileUrl));
  }
  //  DOCX & Others 
  else {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text("Unsupported file type!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text("Cannot preview $ext files.", style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

/// Full-page viewer — use with Navigator.push if you ever need a
/// dedicated screen instead of a popup.
class FileViewerWidget extends StatelessWidget {
  final String fileUrl;
  final String fileName;

  const FileViewerWidget({
    super.key,
    required this.fileUrl,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fileName)),
      body: _buildFileContent(fileUrl, fileName),
    );
  }
}

class FileViewerDialog extends StatelessWidget {
  final String fileUrl;
  final String fileName;

  const FileViewerDialog({
    super.key,
    required this.fileUrl,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: size.width * 0.50,
        height: size.height ,
        child: Column(
          children: [
            // ── Header: filename + close button ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      fileName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // ── Body: PDF / image / other ──
            Expanded(child: _buildFileContent(fileUrl, fileName)),
          ],
        ),
      ),
    );
  }
}