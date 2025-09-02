import 'dart:async';
import '../../domain/models/barcode_item.dart';

class BarcodeRepository {
  final List<BarcodeItem> _items = [];
  final _itemsController = StreamController<List<BarcodeItem>>.broadcast();

  Stream<List<BarcodeItem>> get itemsStream => _itemsController.stream;
  List<BarcodeItem> get items => List.unmodifiable(_items);

  double get totalValue => _items.fold(0, (sum, item) => sum + item.value);
  int get itemCount => _items.length;

  void addItem(BarcodeItem item) {
    _items.add(item);
    _notifyChanges();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      _notifyChanges();
    }
  }

  void clearAll() {
    _items.clear();
    _notifyChanges();
  }

  void _notifyChanges() {
    _itemsController.add(List.unmodifiable(_items));
  }

  void dispose() {
    _itemsController.close();
  }
}