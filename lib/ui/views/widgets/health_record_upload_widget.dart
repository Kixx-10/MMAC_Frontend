
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/controllers/file_upload_provider.dart';

class HealthRecordUploadWidget extends ConsumerWidget {
  /// Called when upload succeeds — pass URL up to parent form
  final ValueChanged<String?> onUploaded;

  const HealthRecordUploadWidget({super.key, required this.onUploaded});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(fileUploadProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Label ──────────────────────────────────────────────────────────
        const Text(
          'Health Record Document',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Upload supporting document (jpg, png, pdf, doc, docx — max 5 MB)',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 10),

        // ── Upload button / status ──────────────────────────────────────────
        if (uploadState.uploadedUrl != null)
          // Already uploaded → show file name + remove button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    uploadState.localFileName ?? 'File uploaded',
                    style: TextStyle(fontSize: 13, color: Colors.green.shade800),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Remove / re-upload
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.red),
                  tooltip: 'Remove file',
                  onPressed: () {
                    ref.read(fileUploadProvider.notifier).clear();
                    onUploaded(null); // tell parent URL is gone
                  },
                ),
              ],
            ),
          )
        else if (uploadState.isUploading)
          // Uploading in progress
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text('Uploading...', style: TextStyle(color: Colors.blue.shade700)),
              ],
            ),
          )
        else
          // Pick file button
          OutlinedButton.icon(
            onPressed: () => _pickAndUpload(context, ref),
            icon: const Icon(Icons.upload_file, size: 18),
            label: const Text('Choose File'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

        // ── Error message ───────────────────────────────────────────────────
        if (uploadState.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              uploadState.error!,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
      ],
    );
  }

  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    // Open file picker — restrict to allowed types
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final url  = await ref.read(fileUploadProvider.notifier).upload(file);

    // Tell parent the URL (or null if failed)
    onUploaded(url);
  }
}
