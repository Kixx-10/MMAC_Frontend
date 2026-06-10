// lib/ui/views/pages/update_application/update_application_page.dart

// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/data/controllers/update_application_provider.dart';
import 'package:mmac/ui/views/widgets/footer.dart'; // Senior's standard footer

class UpdateApplication extends ConsumerStatefulWidget {
  final VoidCallback? onUpdateWorkflow;
  const UpdateApplication({super.key, this.onUpdateWorkflow});

  @override
  ConsumerState<UpdateApplication> createState() => _UpdateApplicationState();
}

class _UpdateApplicationState extends ConsumerState<UpdateApplication>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // --- Form Key ---
  final GlobalKey<FormState> _searchFormKey = GlobalKey<FormState>();

  // --- Map of Controllers (Senior's Reusable Style) ---
  final Map<String, TextEditingController> _searchControllers = {
    'qrReference': TextEditingController(),
    'email': TextEditingController(),
    'passportNumber': TextEditingController(),
  };

  @override
  void dispose() {
    _searchControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // --- Text Extraction Helper ---
  String _text(String key) => _searchControllers[key]?.text.trim() ?? '';

  // --- Logic Execution Gate ---
  // --- Inside _UpdateApplicationState ---

  // void _handleFindApplication() {
  //   if (_searchFormKey.currentState?.validate() ?? false) {
  //     // Read the provider and call the search logic
  //     ref
  //         .read(updateApplicationProvider.notifier)
  //         .findApplication(
  //           qrReference: _text('qrReference'),
  //           email: _text('email'),
  //           passportNumber: _text('passportNumber'),
  //           onError: (errorMessage) {
  //             // Show error banner if not found or network error
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               SnackBar(
  //                 content: Text(errorMessage),
  //                 backgroundColor: Colors.red.shade700,
  //               ),
  //             );
  //           },
  //           onSuccess: () {
  //             // Show success message
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(
  //                 content: Text("Application successfully retrieved!"),
  //                 backgroundColor: Colors.green,
  //               ),
  //             );
  //           },
  //         );
  //   }
  // }

  //Test
  // --- Inside _UpdateApplicationState ---

  void _handleFindApplication() {
    if (_searchFormKey.currentState?.validate() ?? false) {
      ref
          .read(updateApplicationProvider.notifier)
          .findApplication(
            qrReference: _text('qrReference'),
            email: _text('email'),
            passportNumber: _text('passportNumber'),
            onError: (errorMessage) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            },
            onSuccess: () {
              // ---------------------------------------------------------
              // 🧪 TEMPORARY TEST CODE (စမ်းသပ်ပြီးပါက ပြန်ဖျက်ရန်)
              // ---------------------------------------------------------
              final fetchedData = ref.read(updateApplicationProvider).value;

              if (fetchedData != null) {
                print("==================================================");
                print("🎉 [TEST LOG] DATABASE CONNECTION SUCCESS!");
                print("👤 Name:          ${fetchedData.fullName}");
                print("🛂 Passport:      ${fetchedData.passportNo}");
                print("📧 Email:         ${fetchedData.email}");
                print("📅 DOB:           ${fetchedData.dob}");
                print("🌍 Country Code:  ${fetchedData.countryOfBirthCode}");
                print("📦 Full JSON:     ${fetchedData.toJson()}");
                print("==================================================");
              }
              // ---------------------------------------------------------

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Application found! Check terminal console."),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 4),
                ),
              );
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(updateApplicationProvider);
    final isLoading = searchState.isLoading;
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 48),
                // Core Heading Section
                const Text(
                  'Application Modification Portal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please declare your references to safely fetch and modify your records.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),

                // Senior-Style 950px Center Container Layout Block
                Container(
                  width: 950,
                  padding: const EdgeInsets.all(32),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.01),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _searchFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Verify Identity Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Field 1: QR Reference (Max 20 Chars)
                        const Text(
                          "QR Reference Number",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _searchControllers['qrReference'],
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(100),
                          ],
                          decoration: InputDecoration(
                            hintText: "e.g., QR-2026-987654",
                            prefixIcon: const Icon(
                              Icons.qr_code_scanner_outlined,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'QR Reference is mandatory'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Field 2: Email (Regex Validation)
                        const Text(
                          "Account Email Address",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _searchControllers['email'],
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "e.g., identity@domain.com",
                            prefixIcon: const Icon(
                              Icons.alternate_email_rounded,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty)
                              return 'Email verification string required';
                            final emailPattern = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );
                            if (!emailPattern.hasMatch(value.trim()))
                              return 'Provide a syntactically correct email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Field 3: Passport Number (Max 20 Chars)
                        const Text(
                          "Passport Number",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _searchControllers['passportNumber'],
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(20),
                          ],
                          decoration: InputDecoration(
                            hintText: "e.g., MD123456",
                            prefixIcon: const Icon(
                              Icons.badge_outlined,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Passport verification value required'
                              : null,
                        ),
                        const SizedBox(height: 32),

                        // Control Action Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _handleFindApplication,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 36,
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Find Application',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                const FormFooter(), // Senior's shared footer widget component
              ],
            ),
          ),
        ),
      ),
    );
  }
}
