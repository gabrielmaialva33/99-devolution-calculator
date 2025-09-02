import 'dart:async';

import 'package:flutter/material.dart';

import '../models/barcode_item.dart';
import '../services/barcode_service.dart';
import '../widgets/action_buttons.dart';
import '../widgets/barcode_info_card.dart';
import '../widgets/camera_scanner_screen.dart';
import '../widgets/manual_input_dialog.dart';
import '../widgets/total_summary_card.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final BarcodeService _barcodeService = BarcodeService();
  final TextEditingController _hiddenController = TextEditingController();
  final FocusNode _hiddenFocusNode = FocusNode();

  BarcodeItem? _lastScannedItem;
  double _totalValue = 0.0;
  int _totalItems = 0;
  String _lastUsbInput = '';

  @override
  void initState() {
    super.initState();

    _hiddenController.addListener(_onUsbInput);

    _barcodeService.lastItemStream.listen((item) {
      setState(() {
        _lastScannedItem = item;
      });
    });

    _barcodeService.itemsStream.listen((items) {
      setState(() {
        _totalValue = _barcodeService.totalValue;
        _totalItems = _barcodeService.totalItems;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hiddenFocusNode.requestFocus();
    });
  }

  void _onUsbInput() {
    String input = _hiddenController.text;

    if (input.contains('\n') || input.contains('\r') || input.contains('\t')) {
      String barcode = input.replaceAll(RegExp(r'[\r\n\t]'), '').trim();

      if (barcode.isNotEmpty && barcode != _lastUsbInput) {
        _lastUsbInput = barcode;
        _barcodeService.addBarcode(barcode, ScanMethod.usb);
      }

      _hiddenController.clear();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _hiddenFocusNode.requestFocus();
        }
      });
    }
  }

  void _onCameraScan() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const CameraScannerScreen()),
    );

    if (result != null && result.isNotEmpty) {
      await _barcodeService.addBarcode(result, ScanMethod.camera);
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _hiddenFocusNode.requestFocus();
      }
    });
  }

  void _onManualInput() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const ManualInputDialog(),
    );

    if (result != null && result.isNotEmpty) {
      await _barcodeService.addBarcode(result, ScanMethod.manual);
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _hiddenFocusNode.requestFocus();
      }
    });
  }

  void _onClearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Tudo'),
        content: const Text(
          'Tem certeza que deseja limpar todos os itens escaneados?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              _barcodeService.clearAll();
              setState(() {
                _lastScannedItem = null;
                _totalValue = 0.0;
                _totalItems = 0;
                _lastUsbInput = '';
              });
              Navigator.of(context).pop();
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hiddenController.dispose();
    _hiddenFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Sendo Devolvido',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 2,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BarcodeInfoCard(lastItem: _lastScannedItem),

                const SizedBox(height: 16),

                TotalSummaryCard(
                  totalValue: _totalValue,
                  totalItems: _totalItems,
                ),

                const SizedBox(height: 24),

                ActionButtons(
                  onCameraScan: _onCameraScan,
                  onManualInput: _onManualInput,
                  onClearAll: _onClearAll,
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.usb, color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Leitor USB ativo - escaneie códigos automaticamente',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: -1000,
            top: -1000,
            child: SizedBox(
              width: 1,
              height: 1,
              child: TextField(
                controller: _hiddenController,
                focusNode: _hiddenFocusNode,
                autofocus: true,
                keyboardType: TextInputType.none,
                showCursor: false,
                style: const TextStyle(color: Colors.transparent),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
