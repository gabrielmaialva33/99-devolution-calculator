import 'dart:async';

import '../models/barcode_item.dart';
import 'audio_service.dart';

class BarcodeService {
  static final BarcodeService _instance = BarcodeService._internal();

  factory BarcodeService() => _instance;

  BarcodeService._internal();

  final List<BarcodeItem> _scannedItems = [];
  final AudioService _audioService = AudioService();

  final StreamController<List<BarcodeItem>> _itemsController =
      StreamController<List<BarcodeItem>>.broadcast();

  final StreamController<BarcodeItem> _lastItemController =
      StreamController<BarcodeItem>.broadcast();

  Stream<List<BarcodeItem>> get itemsStream => _itemsController.stream;

  Stream<BarcodeItem> get lastItemStream => _lastItemController.stream;

  List<BarcodeItem> get allItems => List.unmodifiable(_scannedItems);

  double get totalValue =>
      _scannedItems.fold(0.0, (sum, item) => sum + item.value);

  int get totalItems => _scannedItems.length;

  Future<bool> addBarcode(String barcode, ScanMethod method) async {
    try {
      // Validar código
      if (!BarcodeItem.isValidBarcode(barcode)) {
        await _audioService.playErrorSound();
        return false;
      }

      // Calcular valor
      double value = BarcodeItem.parseValue(barcode);

      // Criar item
      BarcodeItem item = BarcodeItem(
        code: barcode,
        value: value,
        timestamp: DateTime.now(),
        method: method,
      );

      // Adicionar à lista
      _scannedItems.add(item);

      // Notificar listeners
      _itemsController.add(List.unmodifiable(_scannedItems));
      _lastItemController.add(item);

      // Tocar som de sucesso baseado no método
      switch (method) {
        case ScanMethod.usb:
          await _audioService.playUsbScanSound();
          break;
        case ScanMethod.camera:
          await _audioService.playCameraScanSound();
          break;
        case ScanMethod.manual:
          await _audioService.playSuccessSound();
          break;
      }

      return true;
    } catch (e) {
      await _audioService.playErrorSound();
      return false;
    }
  }

  void clearAll() {
    _scannedItems.clear();
    _itemsController.add(List.unmodifiable(_scannedItems));
  }

  void dispose() {
    _itemsController.close();
    _lastItemController.close();
    _audioService.dispose();
  }
}
