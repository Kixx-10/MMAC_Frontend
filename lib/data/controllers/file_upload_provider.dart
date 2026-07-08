// lib/data/controllers/file_upload_provider.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/reposistories/file_upload_repository.dart';

class FileUploadState {
  final bool isUploading;
  final String? uploadedUrl;  // URL returned from server
  final String? error;
  final String? localFileName; // display name shown to user

  const FileUploadState({
    this.isUploading = false,
    this.uploadedUrl,
    this.error,
    this.localFileName,
  });

  FileUploadState copyWith({
    bool? isUploading,
    String? uploadedUrl,
    String? error,
    String? localFileName,
  }) => FileUploadState(
    isUploading:   isUploading   ?? this.isUploading,
    uploadedUrl:   uploadedUrl   ?? this.uploadedUrl,
    error:         error         ?? this.error,
    localFileName: localFileName ?? this.localFileName,
  );
}

class FileUploadNotifier extends Notifier<FileUploadState> {
  final _repo = FileUploadRepository();

  @override
  FileUploadState build() => const FileUploadState();

  Future<String?> upload(File file) async {
    state = state.copyWith(isUploading: true, error: null);
    try {
      final url = await _repo.uploadHealthRecord(file);
      state = state.copyWith(
        isUploading: false,
        uploadedUrl: url,
        localFileName: file.path.split('/').last,
      );
      return url;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }

  void clear() => state = const FileUploadState();
}

final fileUploadProvider =
    NotifierProvider<FileUploadNotifier, FileUploadState>(
  FileUploadNotifier.new,
);
