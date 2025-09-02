import 'package:intl/intl.dart';

class BarcodeItem {
  final String code;
  final double value;
  final DateTime scannedAt;
  final ScanMethod scanMethod;

  BarcodeItem({
    required this.code,
    required this.value,
    required this.scannedAt,
    required this.scanMethod,
  });

  String get formattedValue {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(value);
  }

  String get displayCode {
    if (code.length > 5) {
      return '${code.substring(0, 5)}...${code.substring(code.length - 5)}';
    }
    return code;
  }

  String get scanMethodIcon {
    switch (scanMethod) {
      case ScanMethod.usb:
        return '🔌';
      case ScanMethod.camera:
        return '📷';
      case ScanMethod.manual:
        return '⌨️';
    }
  }

  String get scanMethodLabel {
    switch (scanMethod) {
      case ScanMethod.usb:
        return 'USB';
      case ScanMethod.camera:
        return 'Câmera';
      case ScanMethod.manual:
        return 'Manual';
    }
  }
}

enum ScanMethod { usb, camera, manual }
