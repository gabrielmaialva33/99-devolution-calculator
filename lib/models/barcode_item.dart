class BarcodeItem {
  final String code;
  final double value;
  final DateTime timestamp;
  final ScanMethod method;

  BarcodeItem({
    required this.code,
    required this.value,
    required this.timestamp,
    required this.method,
  });

  static double parseValue(String barcode) {
    if (barcode.length < 5) {
      throw ArgumentError('Code must have at least 5 digits');
    }

    String lastFiveDigits = barcode.substring(barcode.length - 5);
    return double.parse(lastFiveDigits) / 100;
  }

  static bool isValidBarcode(String barcode) {
    if (barcode.length == 11 || barcode.length == 5) {
      return RegExp(r'^\d+$').hasMatch(barcode);
    }
    return false;
  }

  @override
  String toString() {
    return 'BarcodeItem(code: $code, value: $value, method: $method)';
  }
}

enum ScanMethod { usb, camera, manual }

extension ScanMethodExtension on ScanMethod {
  String get displayName {
    switch (this) {
      case ScanMethod.usb:
        return 'USB';
      case ScanMethod.camera:
        return 'Câmera';
      case ScanMethod.manual:
        return 'Manual';
    }
  }

  String get icon {
    switch (this) {
      case ScanMethod.usb:
        return '🔌';
      case ScanMethod.camera:
        return '📷';
      case ScanMethod.manual:
        return '⌨️';
    }
  }
}
