import '../constants/app_strings.dart';

class Validators {
  Validators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.requiredField;
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.requiredField;
    final regex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return AppStrings.invalidEmail;
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.requiredField;
    final regex = RegExp(r'^\d{10}$');
    if (!regex.hasMatch(value.trim())) return AppStrings.invalidPhone;
    return null;
  }

  /// Combines multiple validators — returns first error found
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final v in validators) {
        final result = v(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
