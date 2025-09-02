<h1 align="center">
  <br>
  <img src=".github/assets/calculator.png" alt="Devolution Calculator" width="200">
  <br>
  Devolution Calculator - Advanced Barcode Scanner & Return Management App 📱
  <br>
</h1>

<p align="center">
  <strong>A sophisticated Flutter application for scanning barcodes and calculating return values with USB/Camera support</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.35.1-blue?style=flat&logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.0+-blue?style=flat&logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Web-green?style=flat&logo=android" alt="Platform" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat&logo=appveyor" alt="License" />
  <img src="https://img.shields.io/badge/Made%20with-❤️%20by%20Maia-red?style=flat&logo=appveyor" alt="Made with Love" />
</p>

<br>

<p align="center">
  <a href="#sparkles-features">Features</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#rocket-scanning-methods">Scanning</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#computer-technologies">Technologies</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#package-installation">Installation</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#gear-configuration">Configuration</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#electric_plug-usage">Usage</a>&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#memo-license">License</a>
</p>

<br>

## :sparkles: Features

### Advanced Barcode Processing 📊

- **Multi-Method Scanning** - USB HID, Camera, and Manual input support
- **Smart Parsing** - Extracts last 5 digits and converts cents to currency (R$)
- **Real-Time Validation** - Validates 11-digit full codes or 5-digit partial codes
- **Live Calculation** - Automatic totalization of values and item count
- **Audio Feedback** - Different sounds for each scanning method and success/error states
- **Clean Interface** - Modern Material Design 3 with intuitive card-based layout

### USB Scanner Integration 🔌

- **HID Keyboard Emulation** - Works with professional barcode scanners
- **Auto-Detection** - Captures input automatically when scanner is connected
- **Popular Scanner Support** - Compatible with Zebra, Honeywell, Symbol scanners
- **USB OTG Required** - Connect via USB On-The-Go cable to Android device
- **Background Processing** - Maintains focus for continuous scanning
- **Instant Response** - Real-time feedback with dedicated USB scan sounds

### Camera Scanner 📷

- **Mobile Scanner** - Built-in camera barcode detection
- **Visual Overlay** - Professional scanning frame with targeting guides
- **Auto-Focus** - Automatic barcode detection and processing
- **Flashlight Support** - Toggle flash for low-light scanning
- **Multiple Formats** - Supports various barcode formats including EAN-13, UPC
- **Processing Indicator** - Visual feedback during code processing

### Manual Input System ⌨️

- **Flexible Entry** - Support for full 11-digit codes or 5-digit values only
- **Real-Time Validation** - Instant feedback on input correctness
- **Value Preview** - Shows calculated monetary value while typing
- **Error Handling** - Clear error messages for invalid inputs
- **Smart Formatting** - Monospace font for better code visibility
- **Quick Submission** - Enter key support for fast data entry

<br>

## :rocket: Scanning Methods

### 🏆 USB Scanner (Recommended)

```bash
# Setup Requirements:
- USB OTG cable
- Compatible barcode scanner (HID mode)
- Scanner configured to send Enter after scan
- Android device with USB OTG support

# Supported Scanners:
✅ Zebra DS2208, DS4608
✅ Honeywell 1900g, 1300g
✅ Symbol LS2208
✅ Any HID keyboard-emulating scanner
```

### 📸 Camera Scanner

```bash
# Features:
- Real-time barcode detection
- Support for EAN-13, UPC-A, Code 128
- Flashlight toggle
- Visual scanning guides
- Auto-capture on detection

# Requirements:
- Camera permission
- Good lighting (or flashlight)
- Clear barcode visibility
```

### ⌨️ Manual Entry

```bash
# Input Formats:
- Full Code: 00707401350 (11 digits)
- Value Only: 01350 (5 digits = R$ 13.50)
- Real-time validation
- Instant currency conversion preview
```

<br>

## :computer: Technologies

### Core Framework

- **[Flutter](https://flutter.dev/)** 3.35.1 - Cross-platform UI framework
- **[Dart](https://dart.dev/)** 3.0+ - Programming language
- **[Material Design 3](https://m3.material.io/)** - Modern UI components

### Barcode Scanning

- **[mobile_scanner](https://pub.dev/packages/mobile_scanner)** 4.0.1 - Camera barcode scanning
- **USB HID Integration** - Custom implementation for USB scanner support
- **RegExp Validation** - Pattern matching for barcode format validation

### Audio & Feedback

- **[audioplayers](https://pub.dev/packages/audioplayers)** 5.0.0 - Cross-platform audio playback
- **Custom Sound System** - Different audio feedback for each scanning method
- **Error Handling** - Graceful fallback when audio files are unavailable

### Internationalization

- **[intl](https://pub.dev/packages/intl)** 0.19.0 - Internationalization and localization
- **Brazilian Locale** - Currency formatting in Brazilian Real (R$)
- **Number Formatting** - Proper decimal and thousand separators

### Permissions & Platform

- **[permission_handler](https://pub.dev/packages/permission_handler)** 11.0.0 - Runtime permissions
- **Android Platform** - Native Android integration
- **Web Support** - Flutter web for testing and development

<br>

## :package: Installation

### Prerequisites

- **[Flutter SDK](https://flutter.dev/docs/get-started/install)** 3.35.1+
- **[Android Studio](https://developer.android.com/studio)** or *
  *[VS Code](https://code.visualstudio.com/)**
- **[Git](https://git-scm.com/)**
- **Android Device** with USB OTG support (for USB scanning)

### Quick Start

1. **Clone the repository**

```bash
git clone https://github.com/your-username/devolution_calculator.git
cd devolution_calculator
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Check Flutter setup**

```bash
flutter doctor
```

4. **Run on device/emulator**

```bash
# Android device/emulator
flutter run

# Web browser (for testing UI only)
flutter run -d chrome

# Specific device
flutter devices
flutter run -d [device-id]
```

5. **Build for production**

```bash
# Debug APK
flutter build apk --debug

# Release APK (single file)
flutter build apk --release

# Release APK (optimized per architecture)
flutter build apk --release --split-per-abi
```

<br>

## :gear: Configuration

### Android Permissions

The app automatically requests these permissions:

```xml
<!-- Required for camera scanning -->
<uses-permission android:name="android.permission.CAMERA" />

    <!-- Optional for flashlight -->
<uses-permission android:name="android.permission.FLASHLIGHT" />
```

### USB Scanner Setup

1. **Configure Scanner**:
    - Set to HID (keyboard emulation) mode
    - Configure suffix: Add "Enter" character after each scan
    - Test on computer first to ensure proper output

2. **Connect to Android**:
    - Use USB OTG cable
    - Connect scanner to Android device
    - Allow USB device when prompted
    - Scanner should be recognized as keyboard input

3. **Test Connection**:
    - Open any text input on Android
    - Scan a barcode
    - Should see barcode digits appear with Enter at the end

### Audio Files

The app includes placeholder audio files. For production:

1. **Download Real MP3 Files**:
    - Visit [Mixkit Free Sound Effects](https://mixkit.co/free-sound-effects/beep/)
    - Download appropriate beep sounds
    - Rename and replace files in `assets/sounds/`

2. **Required Files**:
    - `success.mp3` - General success sound
    - `error.mp3` - Error/invalid code sound
    - `usb_scan.mp3` - USB scanner specific sound
    - `camera_scan.mp3` - Camera scanner specific sound

<br>

## :electric_plug: Usage

### Basic Workflow

1. **Launch App** - Open Devolution Calculator
2. **Choose Scanning Method**:
    - USB: Connect scanner and scan directly
    - Camera: Tap "Escanear com Câmera" button
    - Manual: Tap "Manual" for keyboard input

3. **Scan/Enter Barcodes** - Process return items
4. **Monitor Totals** - View real-time value and item count
5. **Clear When Done** - Reset totals for next batch

### Barcode Format

The app expects Brazilian product barcodes with this structure:

```
Full Code: 00707401350 (11 digits)
├── Product Code: 00707 (first 5 digits)
├── Size Variant: 4 (6th digit - represents 4 sizes)  
└── Value in Cents: 01350 (last 5 digits = R$ 13.50)
```

**Manual Entry Options**:

- Full code: `00707401350` → Extracts R$ 13.50
- Value only: `01350` → Directly converts to R$ 13.50

### Scanning Tips

**USB Scanner**:

- Keep scanner connected during entire session
- Scan quickly - app processes automatically
- Listen for audio confirmation of each scan
- Red light on scanner indicates successful read

**Camera Scanner**:

- Ensure good lighting
- Hold steady until auto-detection
- Use flashlight in low light
- Position barcode within scanning frame

**Manual Entry**:

- Use for damaged/unreadable barcodes
- Enter either full code or just value portion
- Watch for real-time validation feedback
- Press Enter or "Confirmar" to submit

<br>

## :memo: License

This project is under the **MIT** license. See [LICENSE](./LICENSE) for details.

<br>

## :handshake: Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<br>

## :star: Support

If you find this project helpful, please give it a star ⭐ to help others discover it!

**For support or questions**:

- 📧 Email: [gabrielmaialva33@gmail.com](mailto:gabrielmaialva33@gmail.com)
- 💬 Telegram: [@mrootx](https://t.me/mrootx)
- 🐙 GitHub Issues: [Create an issue](https://github.com/your-username/devolution_calculator/issues)

<br>

## :busts_in_silhouette: Author

<p align="center">
  <img src=".github/assets/accounting.png" alt="Accounting" width="100">
</p>

Made with ❤️ by **Maia** - Passionate about creating efficient business solutions!

- 📧 Email: [gabrielmaialva33@gmail.com](mailto:gabrielmaialva33@gmail.com)
- 💬 Telegram: [@mrootx](https://t.me/mrootx)
- 🐙 GitHub: [@gabrielmaialva33](https://github.com/gabrielmaialva33)

<br>

<p align="center">
  <img src="https://raw.githubusercontent.com/gabrielmaialva33/gabrielmaialva33/master/assets/gray0_ctp_on_line.svg?sanitize=true" />
</p>

<p align="center">
  &copy; 2025-present <a href="https://github.com/gabrielmaialva33/" target="_blank">Maia</a>
</p>