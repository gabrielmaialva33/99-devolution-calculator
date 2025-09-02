class BarcodeValidationService {
  static const int fullCodeLength = 11;
  static const int valueCodeLength = 5;

  static bool isValidFullCode(String code) {
    if (code.length != fullCodeLength) return false;
    return RegExp(r'^\d{11}$').hasMatch(code);
  }

  static bool isValidValueCode(String code) {
    if (code.length != valueCodeLength) return false;
    return RegExp(r'^\d{5}$').hasMatch(code);
  }

  static bool isValidCode(String code) {
    return isValidFullCode(code) || isValidValueCode(code);
  }

  static double? extractValue(String code) {
    if (!isValidCode(code)) return null;

    String valueStr;
    if (code.length == fullCodeLength) {
      valueStr = code.substring(6); // Last 5 digits
    } else {
      valueStr = code;
    }

    final cents = int.tryParse(valueStr);
    if (cents == null) return null;

    return cents / 100.0;
  }

  static String? extractProductCode(String code) {
    if (!isValidFullCode(code)) return null;
    return code.substring(0, 5);
  }

  static String? extractSizeVariant(String code) {
    if (!isValidFullCode(code)) return null;
    return code[5];
  }
}
