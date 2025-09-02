import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  void initialize() {
    // Initialize audio player if needed
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playSuccess() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      // Error playing success sound: $e
    }
  }

  Future<void> playError() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/error.mp3'));
    } catch (e) {
      // Error playing error sound: $e
    }
  }

  Future<void> playUsbScan() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/usb_scan.mp3'));
    } catch (e) {
      // Error playing USB sound: $e
    }
  }

  Future<void> playCameraScan() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/camera_scan.mp3'));
    } catch (e) {
      // Error playing camera sound: $e
    }
  }
  
  // Legacy method names for compatibility
  Future<void> playSuccessSound() => playSuccess();
  Future<void> playErrorSound() => playError();
  Future<void> playUsbScanSound() => playUsbScan();
  Future<void> playCameraScanSound() => playCameraScan();

  void dispose() {
    _audioPlayer.dispose();
  }
}
