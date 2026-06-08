

class FormValidators {

  // General 

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? requiredDropdown(dynamic value, String fieldName) {
    if (value == null) return '$fieldName is required';
    return null;
  }

  static String? requiredDate(DateTime? value, String fieldName) {
    if (value == null) return '$fieldName is required';
    return null;
  }

  //  Email 

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  // Myanmar NRC (only when country == Myanmar) 

  static String? nrc(String? value, {required bool isMyanmar}) {
    if (!isMyanmar) return null; // skip for non-Myanmar
    if (value == null || value.trim().isEmpty) return 'NRC is required for Myanmar citizens';
    return null;
  }

  static String? fatherName(String? value, {required bool isMyanmar}) {
    if (!isMyanmar) return null; // skip for non-Myanmar
    if (value == null || value.trim().isEmpty) return 'Father Name is required for Myanmar citizens';
    return null;
  }

  // ── Declaration checkboxes 

  static String? declaration(String? value, String fieldName) {
    if (value == null) return 'Please answer: $fieldName';
    return null;
  }
}