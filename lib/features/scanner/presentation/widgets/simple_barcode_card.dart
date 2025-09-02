import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/barcode_item.dart';

class SimpleBarcodeCard extends StatelessWidget {
  final BarcodeItem item;
  final VoidCallback onDismiss;
  final int index;

  const SimpleBarcodeCard({
    super.key,
    required this.item,
    required this.onDismiss,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(item.code + item.scannedAt.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismiss(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          color: AppColors.error,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Scan method icon with personality
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getMethodColor(),
                      _getMethodColor().withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: _getMethodColor().withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getScanIcon(),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              
              // Item info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Código: ${item.displayCode}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.scanMethodLabel} • Item #${index + 1}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              
              // Value
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.formattedValue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getScanIcon() {
    switch (item.scanMethod) {
      case ScanMethod.usb:
        return Icons.usb_rounded;
      case ScanMethod.camera:
        return Icons.camera_alt_rounded;
      case ScanMethod.manual:
        return Icons.keyboard_rounded;
    }
  }

  Color _getMethodColor() {
    switch (item.scanMethod) {
      case ScanMethod.usb:
        return AppColors.primary;        // Quantum Blue for USB
      case ScanMethod.camera:
        return AppColors.secondary;      // Digital Sage for Camera
      case ScanMethod.manual:
        return AppColors.accent;         // Matrix Sage for Manual
    }
  }
}