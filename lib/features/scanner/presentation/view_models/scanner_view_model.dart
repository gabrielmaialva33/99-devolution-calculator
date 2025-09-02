import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../services/audio_service.dart';
import '../../../../services/csv_export_service.dart';
import '../../data/repositories/barcode_repository.dart';
import '../../domain/models/barcode_item.dart';
import '../../domain/services/barcode_validation_service.dart';

class ScannerViewModel extends ChangeNotifier {
  final BarcodeRepository _repository;
  final AudioService _audioService;

  StreamSubscription<List<BarcodeItem>>? _itemsSubscription;

  List<BarcodeItem> _items = [];
  bool _isProcessing = false;
  bool _isExporting = false;
  String? _lastError;
  String _currentInput = '';
  Timer? _usbInputTimer;

  // Getters
  List<BarcodeItem> get items => _items;

  bool get isProcessing => _isProcessing;

  bool get isExporting => _isExporting;

  String? get lastError => _lastError;

  double get totalValue => _repository.totalValue;

  int get itemCount => _repository.itemCount;

  bool get hasItems => _items.isNotEmpty;

  bool get canExport => _items.isNotEmpty && !_isExporting;

  ScannerViewModel({
    required BarcodeRepository repository,
    required AudioService audioService,
  }) : _repository = repository,
       _audioService = audioService {
    _initialize();
  }

  void _initialize() {
    _audioService.initialize();
    _initializeRepository();
    _itemsSubscription = _repository.itemsStream.listen((items) {
      _items = items;
      notifyListeners();
    });
  }

  Future<void> _initializeRepository() async {
    try {
      await _repository.initialize();
    } catch (e) {
      print('Erro ao inicializar repositório: $e');
    }
  }

  // USB Scanner Input Handler
  void handleKeyboardInput(String key) {
    if (key == '\n' || key == '\r') {
      _processUsbInput();
    } else if (RegExp(r'\d').hasMatch(key)) {
      _currentInput += key;
      _resetUsbTimer();
    }
  }

  void _resetUsbTimer() {
    _usbInputTimer?.cancel();
    _usbInputTimer = Timer(const Duration(milliseconds: 100), () {
      _currentInput = '';
    });
  }

  void _processUsbInput() {
    if (_currentInput.isNotEmpty) {
      processBarcode(_currentInput, ScanMethod.usb);
      _currentInput = '';
    }
    _usbInputTimer?.cancel();
  }

  // Barcode Processing
  Future<void> processBarcode(String code, ScanMethod method) async {
    if (_isProcessing) return;

    _isProcessing = true;
    _lastError = null;
    notifyListeners();

    try {
      final cleanCode = code.trim();

      if (!BarcodeValidationService.isValidCode(cleanCode)) {
        throw Exception('Código inválido: $cleanCode');
      }

      final value = BarcodeValidationService.extractValue(cleanCode);
      if (value == null || value <= 0) {
        throw Exception('Valor inválido no código');
      }

      final item = BarcodeItem(
        code: cleanCode,
        value: value,
        scannedAt: DateTime.now(),
        scanMethod: method,
      );

      await _repository.addItem(item);
      await _playSuccessSound(method);
    } catch (e) {
      _lastError = e.toString();
      await _audioService.playError();
      notifyListeners();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> _playSuccessSound(ScanMethod method) async {
    switch (method) {
      case ScanMethod.usb:
        await _audioService.playUsbScan();
        break;
      case ScanMethod.camera:
        await _audioService.playCameraScan();
        break;
      case ScanMethod.manual:
        await _audioService.playSuccess();
        break;
    }
  }

  // Item Management
  Future<void> removeItem(int index) async {
    await _repository.removeItem(index);
  }

  Future<void> clearAll() async {
    await _repository.clearAll();
    _lastError = null;
    notifyListeners();
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  // CSV Export Methods
  Future<void> shareCSV() async {
    if (!canExport) return;

    _isExporting = true;
    _lastError = null;
    notifyListeners();

    try {
      await CSVExportService.shareCSV(_items);
      await _audioService.playSuccess();
    } catch (e) {
      _lastError =
          'Erro ao compartilhar: ${e.toString().replaceAll('Exception: ', '')}';
      await _audioService.playError();
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  Future<String?> saveCSV() async {
    if (!canExport) return null;

    _isExporting = true;
    _lastError = null;
    notifyListeners();

    try {
      final filePath = await CSVExportService.saveCSVToDownloads(_items);
      await _audioService.playSuccess();
      return filePath;
    } catch (e) {
      _lastError =
          'Erro ao salvar: ${e.toString().replaceAll('Exception: ', '')}';
      await _audioService.playError();
      return null;
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  String getExportPreview() {
    return CSVExportService.generatePreview(_items);
  }

  @override
  void dispose() {
    _usbInputTimer?.cancel();
    _itemsSubscription?.cancel();
    _audioService.dispose();
    _repository.dispose();
    super.dispose();
  }
}
