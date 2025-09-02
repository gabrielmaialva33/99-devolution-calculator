# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter application for barcode scanning and return value calculation. Supports USB HID scanners, camera scanning, and manual input. Built with Flutter 3.35.2 and Dart 3.9.0, using Material Design 3.

## Development Commands

### Running & Building
```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices
flutter run -d [device-id]

# Build APK
flutter build apk --debug           # Debug build
flutter build apk --release         # Release build (single file)
flutter build apk --release --split-per-abi  # Optimized per architecture

# Web (for UI testing only - barcode features won't work)
flutter run -d chrome
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Run tests
flutter test

# Format code
dart format lib/

# Check dependencies
flutter pub outdated
flutter pub upgrade
```

## Architecture

### Core Structure
- **lib/main.dart**: App entry point, theme configuration, Brazilian locale setup
- **lib/screens/main_screen.dart**: Primary UI with barcode scanning orchestration
- **lib/services/**:
  - `barcode_service.dart`: Barcode validation, parsing (extracts last 5 digits for value)
  - `audio_service.dart`: Sound feedback for different scan methods
- **lib/widgets/**:
  - `camera_scanner_screen.dart`: Camera-based barcode scanning implementation
  - `manual_input_dialog.dart`: Manual barcode entry with validation
  - `action_buttons.dart`: USB/Camera/Manual scan triggers
  - `barcode_info_card.dart`: Individual item display
  - `total_summary_card.dart`: Running total calculation
- **lib/models/barcode_item.dart**: Data model for scanned items

### Barcode Processing Logic
- **Expected format**: 11-digit Brazilian product codes (e.g., `00707401350`)
- **Value extraction**: Last 5 digits represent cents (01350 = R$ 13.50)
- **USB scanning**: Captures keyboard input ending with Enter key
- **Validation**: RegExp patterns for 11-digit full codes or 5-digit value-only input

### State Management
- Stateful widgets with `setState()` for UI updates
- List<BarcodeItem> maintains scanned items
- Real-time total calculation in MainScreen

### Dependencies
Key packages from pubspec.yaml:
- `mobile_scanner: ^4.0.1` - Camera barcode detection
- `audioplayers: ^5.0.0` - Audio feedback
- `permission_handler: ^11.0.0` - Camera permissions
- `intl: ^0.19.0` - Brazilian Real (R$) formatting

### Platform-Specific
- **Android**: Requires camera permission, USB OTG support for scanners
- **Assets**: Audio files in `assets/sounds/` (success.mp3, error.mp3, usb_scan.mp3, camera_scan.mp3)
- **Minimum SDK**: Dart 3.9.0+, Flutter 3.35.1+