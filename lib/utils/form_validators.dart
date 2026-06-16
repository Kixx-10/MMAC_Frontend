class FormValidators {
  static String? passportExpiry({
    required DateTime? expiryDate,
    required DateTime? issuedDate,
    required bool isMyanmar,
  }) {
    if (expiryDate == null) {
      return 'Passport Expiry Date is required.';
    }

    if (!isMyanmar) {
      if (issuedDate != null && !expiryDate.isAfter(issuedDate)) {
        return 'Expiry date must be after the Passport Issue Date.';
      }
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
    if (!emailRegex.hasMatch(value.trim()))
      return 'Enter a valid email address';
    return null;
  }

  // Myanmar NRC (only when country == Myanmar)

  static String? nrc(String? value, {required bool isMyanmar}) {
    if (!isMyanmar) return null; // skip for non-Myanmar
    if (value == null || value.trim().isEmpty)
      return 'NRC is required for Myanmar citizens';
    return null;
  }

  static String? fatherName(String? value, {required bool isMyanmar}) {
    if (!isMyanmar) return null; // skip for non-Myanmar
    if (value == null || value.trim().isEmpty)
      return 'Father Name is required for Myanmar citizens';
    return null;
  }

  // ── Declaration checkboxes

  static String? declaration(String? value, String fieldName) {
    if (value == null) return 'Please answer: $fieldName';
    return null;
  }

  static String? mobileNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile Number is required';
    }

    // စာလုံးရေ အနည်းဆုံး ၇ လုံး ရှိမရှိ စစ်ဆေးခြင်း
    if (value.length < 7) {
      return 'Mobile number must be at least 7 digits';
    }

    // စာလုံးရေ အများဆုံး ၁၁ လုံးထက် ကျော်မကျော် စစ်ဆေးခြင်း (Max length ပါလို့ မလိုသော်လည်း Double Check စစ်ထားခြင်းဖြစ်ပါသည်)
    if (value.length > 11) {
      return 'Mobile number cannot exceed 11 digits';
    }

    return null; // အားလုံး ကိုက်ညီပါက Error မပြပါ
  }
}
