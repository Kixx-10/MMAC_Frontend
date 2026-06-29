// lib/utils/form_validators.dart

class FormValidators {
  // 🎯 Private constructor prevents instantiation of this utility class
  FormValidators._();

  // 🎯 Compiled Regex for performance (Prevents recompiling on every keystroke)
  static final RegExp _emailRegex = RegExp(
    r'^[\w\-.]{3,}@([\w\-]+\.)+[\w]{2,4}$',
  );

  /// Validates passport expiry strictly for foreign nationals
  static String? passportExpiry({
    required DateTime? expiryDate,
    required DateTime? issuedDate,
    required bool isMyanmar,
  }) {
    if (expiryDate == null) {
      return 'Passport Expiry Date is required.';
    }

    if (!isMyanmar) {
      // 1. Expiry must be after Issue Date
      if (issuedDate != null && !expiryDate.isAfter(issuedDate)) {
        return 'Expiry date must be after the Passport Issue Date.';
      }

      // 2. Must have at least 6 months validity
      final DateTime today = DateTime.now();
      final DateTime sixMonthsFromToday = DateTime(
        today.year,
        today.month + 6,
        today.day,
      );

      if (expiryDate.isBefore(sixMonthsFromToday)) {
        return 'This passport cannot be used because it has expired or has less than 6 months of validity remaining from today.';
      }
    }

    return null;
  }

  /// Ensures a standard text field is not empty
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Ensures a dropdown item is selected
  static String? requiredDropdown(dynamic value, String fieldName) {
    if (value == null) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Ensures a date is picked
  static String? requiredDate(DateTime? value, String fieldName) {
    if (value == null) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates email format (requires at least 3 chars before @)
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  /// Validates NRC strictly for Myanmar citizens
  static String? nrc(String? value, {required bool isMyanmar}) {
    if (!isMyanmar) return null;

    if (value == null || value.trim().isEmpty) {
      return 'NRC is required for Myanmar citizens';
    }

    return null;
  }

  /// Validates Father's Name strictly for Myanmar citizens
  static String? fatherName(String? value, {required bool isMyanmar}) {
    if (!isMyanmar) return null;

    if (value == null || value.trim().isEmpty) {
      return 'Father Name is required for Myanmar citizens';
    }

    return null;
  }

  /// Ensures radio buttons/checkboxes are answered
  static String? declaration(String? value, String fieldName) {
    if (value == null) {
      return 'Please answer: $fieldName';
    }
    return null;
  }

  /// Validates mobile number length constraints
  static String? mobileNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile Number is required';
    }

    final trimmedValue = value.trim();

    // Must be at least 7 digits
    if (trimmedValue.length < 7) {
      return 'Mobile number must be at least 7 digits';
    }

    // Must not exceed 11 digits
    if (trimmedValue.length > 11) {
      return 'Mobile number cannot exceed 11 digits';
    }

    return null;
  }
}
