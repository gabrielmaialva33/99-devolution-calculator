import 'dart:async';

import '../../../../services/database_service.dart';
import '../../domain/models/barcode_item.dart';

class BarcodeRepository {
  final DatabaseService _databaseService = DatabaseService();
  final List<BarcodeItem> _items = [];
  final _itemsController = StreamController<List<BarcodeItem>>.broadcast();
  bool _isInitialized = false;

  Stream<List<BarcodeItem>> get itemsStream => _itemsController.stream;

  List<BarcodeItem> get items => List.unmodifiable(_items);

  double get totalValue => _items.fold(0, (sum, item) => sum + item.value);

  int get itemCount => _items.length;

  /// Inicializa o repositório carregando dados do banco
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final savedItems = await _databaseService.getAllBarcodeItems();
      _items.clear();
      _items.addAll(savedItems);
      _notifyChanges();
      _isInitialized = true;
    } catch (e) {
      // Em caso de erro, continua com lista vazia
      // Em caso de erro ao carregar, continua com lista vazia
      _isInitialized = true;
    }
  }

  Future<void> addItem(BarcodeItem item) async {
    await _ensureInitialized();
    
    try {
      // Salva no banco primeiro
      await _databaseService.insertBarcodeItem(item);
      
      // Adiciona na memória
      _items.add(item);
      _notifyChanges();
    } catch (e) {
      // Em caso de erro ao salvar, continua com item na memória
      // Em caso de erro, ainda adiciona na memória para UX
      _items.add(item);
      _notifyChanges();
    }
  }

  Future<void> removeItem(int index) async {
    await _ensureInitialized();
    
    if (index >= 0 && index < _items.length) {
      final item = _items[index];
      
      try {
        // Remove do banco primeiro
        await _databaseService.deleteBarcodeItem(item.code, item.scannedAt);
        
        // Remove da memória
        _items.removeAt(index);
        _notifyChanges();
      } catch (e) {
        // Em caso de erro ao remover do banco, continua operação
        // Em caso de erro, ainda remove da memória para UX
        _items.removeAt(index);
        _notifyChanges();
      }
    }
  }

  Future<void> clearAll() async {
    await _ensureInitialized();
    
    try {
      // Limpa o banco primeiro
      await _databaseService.clearAllBarcodeItems();
      
      // Limpa a memória
      _items.clear();
      _notifyChanges();
    } catch (e) {
      // Em caso de erro ao limpar banco, continua operação
      // Em caso de erro, ainda limpa a memória para UX
      _items.clear();
      _notifyChanges();
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  void _notifyChanges() {
    _itemsController.add(List.unmodifiable(_items));
  }

  void dispose() {
    _itemsController.close();
  }
}
