import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ExportOptionsDialog extends StatelessWidget {
  final String previewText;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const ExportOptionsDialog({
    super.key,
    required this.previewText,
    required this.onShare,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.download_rounded, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text('Exportar CSV'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              previewText,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Escolha como exportar os dados:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onSave();
          },
          icon: const Icon(Icons.save_alt),
          label: const Text('Salvar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.secondary,
            side: BorderSide(color: AppColors.secondary),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onShare();
          },
          icon: const Icon(Icons.share),
          label: const Text('Compartilhar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
