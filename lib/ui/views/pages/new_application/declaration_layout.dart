import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/core/constants/app_fonts.dart';
import 'package:mmac/data/controllers/file_upload_provider.dart';
import '../../../../utils/form_validators.dart';

abstract class DeclarationLayoutInterface {
  bool validate();
  List<String> getValidationErrors();
}

class DeclarationLayout extends ConsumerStatefulWidget {
  final Map<String, dynamic> values;
  final Widget actionButtons;
  final Function(String, dynamic) onValueChanged;
  final void Function(DeclarationLayoutInterface) onReady;

  const DeclarationLayout({
    super.key,
    required this.values,
    required this.actionButtons,
    required this.onValueChanged,
    required this.onReady,
  });

  @override
  ConsumerState<DeclarationLayout> createState() => _DeclarationLayoutState();
}

class _DeclarationLayoutState extends ConsumerState<DeclarationLayout>
    implements DeclarationLayoutInterface {
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    widget.onReady(this);
  }

  @override
  bool validate() {
    final bool symptomValid =
        FormValidators.declaration(
          widget.values['hasSymptoms'],
          'Health Declaration',
        ) ==
        null;

    final bool restrictedValid =
        FormValidators.declaration(
          widget.values['carryingRestricted'],
          'Restricted Goods Declaration',
        ) ==
        null;

    final bool isValid = symptomValid && restrictedValid;

    if (!isValid && mounted) {
      setState(() => _showErrors = true);
    }

    return isValid;
  }

  @override
  List<String> getValidationErrors() {
    final errors = <String>[];

    if (widget.values['hasSymptoms'] == null) {
      errors.add("Health Declaration is missing.");
    }
    if (widget.values['carryingRestricted'] == null) {
      errors.add("Restricted Goods Declaration is missing.");
    }

    return errors;
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    // ignore: unnecessary_null_comparison
    if (result == null || result.files.single.name == null) return;

    final platformFile = result.files.single;

    if (platformFile.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to read selected file.")),
      );
      return;
    }

    final uploadResult = await ref
        .read(fileUploadProvider.notifier)
        .upload(platformFile.bytes!, platformFile.name);

    if (uploadResult != null) {
      widget.onValueChanged("healthRecordUrl", uploadResult['fileUrl']);
      widget.onValueChanged(
        "healthRecordFileName",
        uploadResult['originalFileName'],
      );
      setState(() {});
    }
  }

  void _clearHealthRecord() {
    ref.read(fileUploadProvider.notifier).clear();
    widget.onValueChanged('healthRecordUrl', null);
    widget.onValueChanged('healthRecordFileName', null);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(fileUploadProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _WarningBanner(),
        const SizedBox(height: 30),

        _DeclarationQuestion(
          title: "1. Health Declaration",
          description:
              "Do you currently have or have you had in the past 14 days any of the following symptoms: fever, cough, sore throat, or shortness of breath?",
          currentValue: widget.values['hasSymptoms'],
          errorText: _showErrors
              ? FormValidators.declaration(
                  widget.values['hasSymptoms'],
                  'Health Declaration',
                )
              : null,
          onChanged: (val) {
            widget.onValueChanged('hasSymptoms', val);

            if (val != 'Yes') {
              _clearHealthRecord();
            }

            if (mounted) setState(() => _showErrors = false);
          },
        ),

        if (widget.values['hasSymptoms'] == 'Yes') ...[
          const SizedBox(height: 16),
          _HealthRecordUploadSection(
            uploadState: uploadState,
            fallbackUrl: widget.values['healthRecordUrl'] as String?,
            fallbackFileName: widget.values['healthRecordFileName'] as String?,
            onPickAndUpload: _pickAndUpload,
            onClear: _clearHealthRecord,
          ),
        ],

        const SizedBox(height: 20),
        Divider(color: Colors.grey.shade200),
        const SizedBox(height: 20),

        _DeclarationQuestion(
          title: "2. Restricted Goods Declaration",
          description:
              "Are you carrying any prohibited or restricted items such as plants, seeds, unprocessed foods, meats, endangered animal products, or illegal drugs?",
          currentValue: widget.values['carryingRestricted'],
          errorText: _showErrors
              ? FormValidators.declaration(
                  widget.values['carryingRestricted'],
                  'Restricted Goods Declaration',
                )
              : null,
          onChanged: (val) {
            widget.onValueChanged('carryingRestricted', val);
            if (mounted) setState(() => _showErrors = false);
          },
        ),

        const SizedBox(height: 40),
        widget.actionButtons,
      ],
    );
  }
}

class _HealthRecordUploadSection extends StatelessWidget {
  final dynamic uploadState;
  final String? fallbackUrl;
  final String? fallbackFileName;
  final VoidCallback onPickAndUpload;
  final VoidCallback onClear;

  const _HealthRecordUploadSection({
    required this.uploadState,
    required this.onPickAndUpload,
    required this.onClear,
    this.fallbackUrl,
    this.fallbackFileName,
  });

  @override
  Widget build(BuildContext context) {
    final displayUrl = uploadState.uploadedUrl ?? fallbackUrl;
    final displayFileName = uploadState.localFileName ?? fallbackFileName;
    if (displayUrl != null) {
      return Container(
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
                displayFileName ?? 'File uploaded',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.green.shade800,
                  fontFamily: AppFonts.primaryFont,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.red),
              onPressed: onClear,
            ),
          ],
        ),
      );
    }

    if (uploadState.isUploading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text(
              'Uploading...',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontFamily: AppFonts.primaryFont,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "If you have any symptoms, please upload your medical record or test result file using the button below.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontFamily: AppFonts.primaryFont,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Health Record Document',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.primaryFont,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Upload supporting document (jpg, png, pdf, doc, docx — max 5 MB)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontFamily: AppFonts.primaryFont,
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onPickAndUpload,
          icon: const Icon(Icons.upload_file, size: 18),
          label: const Text('Choose File'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        if (uploadState.error != null) ...[
          const SizedBox(height: 8),
          Text(
            uploadState.error!,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.red,
              fontFamily: AppFonts.primaryFont,
            ),
          ),
        ],
      ],
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Please answer truthfully. False declarations may lead to penalties or entry refusal.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.primaryFont,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeclarationQuestion extends StatelessWidget {
  final String title;
  final String description;
  final String? currentValue;
  final String? errorText;
  final Function(String) onChanged;

  const _DeclarationQuestion({
    required this.title,
    required this.description,
    required this.currentValue,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontFamily: AppFonts.primaryFont,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade800,
            height: 1.4,
            fontFamily: AppFonts.primaryFont,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildCheckboxItem("Yes"),
            const SizedBox(width: 30),
            _buildCheckboxItem("No"),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontFamily: AppFonts.primaryFont,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCheckboxItem(String targetValue) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: currentValue == targetValue,
          activeColor: Colors.blue,
          onChanged: (checked) {
            if (checked == true) onChanged(targetValue);
          },
        ),
        Text(
          targetValue,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: AppFonts.primaryFont,
          ),
        ),
      ],
    );
  }
}
