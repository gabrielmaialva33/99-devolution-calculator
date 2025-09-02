import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/barcode_item.dart';
import '../view_models/scanner_view_model.dart';
import '../widgets/simple_barcode_card.dart';
import '../widgets/simple_total_summary.dart';
import '../widgets/manual_input_dialog.dart';
import '../widgets/camera_scanner_screen.dart';

class SimpleScannerView extends StatefulWidget {
  const SimpleScannerView({super.key});

  @override
  State<SimpleScannerView> createState() => _SimpleScannerViewState();
}

class _SimpleScannerViewState extends State<SimpleScannerView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ScannerViewModel>(
      builder: (context, viewModel, child) {
        return KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              final key = event.character;
              if (key != null) {
                viewModel.handleKeyboardInput(key);
              }
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Calculadora de Devoluções'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _showAboutDialog(context),
                ),
              ],
            ),
            body: Column(
              children: [
                // Total Summary
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SimpleTotalSummary(
                    totalValue: viewModel.totalValue,
                    itemCount: viewModel.itemCount,
                    onClear: viewModel.clearAll,
                  ),
                ),
                
                // Error Message
                if (viewModel.lastError != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      color: AppColors.error,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                viewModel.lastError!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18, color: Colors.white),
                              onPressed: viewModel.clearError,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                
                // Items List
                Expanded(
                  child: _buildItemsList(viewModel),
                ),
                
                // Action Buttons
                _buildActionButtons(context, viewModel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemsList(ScannerViewModel viewModel) {
    if (viewModel.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 80,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum item escaneado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use o leitor USB, câmera ou entrada manual',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: viewModel.items.length,
      itemBuilder: (context, index) {
        final item = viewModel.items[index];
        return SimpleBarcodeCard(
          key: ValueKey(item.code + item.scannedAt.toString()),
          item: item,
          index: index,
          onDismiss: () => viewModel.removeItem(index),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, ScannerViewModel viewModel) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundElevated,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05 * 255),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _openCameraScanner(context, viewModel),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Câmera'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openManualInput(context, viewModel),
                icon: const Icon(Icons.keyboard),
                label: const Text('Manual'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCameraScanner(BuildContext context, ScannerViewModel viewModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScannerScreen(
          onScan: (code) {
            viewModel.processBarcode(code, ScanMethod.camera);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _openManualInput(BuildContext context, ScannerViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => ManualInputDialog(
        onSubmit: (code) {
          viewModel.processBarcode(code, ScanMethod.manual);
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sobre o App'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Devolution Calculator v1.0.0'),
            SizedBox(height: 12),
            Text('Aplicativo para leitura de códigos de barras e cálculo de devoluções.'),
            SizedBox(height: 12),
            Text('Suporta leitores USB, câmera e entrada manual.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}