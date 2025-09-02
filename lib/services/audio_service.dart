import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();

  factory AudioService() => _instance;

  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playSuccessSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      // Error playing success sound: $e
    }
  }

  Future<void> playErrorSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/error.mp3'));
    } catch (e) {
      // Error playing error sound: $e
    }
  }

  Future<void> playUsbScanSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/usb_scan.mp3'));
    } catch (e) {
      // Error playing USB sound: $e
    }
  }

  Future<void> playCameraScanSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/camera_scan.mp3'));
    } catch (e) {
      // Error playing camera sound: $e
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
