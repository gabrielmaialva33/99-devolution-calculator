import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onCameraScan;
  final VoidCallback onManualInput;
  final VoidCallback onClearAll;

  const ActionButtons({
    super.key,
    required this.onCameraScan,
    required this.onManualInput,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botão principal - Escanear com Câmera
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: onCameraScan,
            icon: const Icon(Icons.camera_alt, size: 24),
            label: const Text(
              'Escanear com Câmera',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Botões secundários
        Row(
          children: [
            // Entrada Manual
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: onManualInput,
                  icon: const Icon(Icons.keyboard, size: 20),
                  label: const Text(
                    'Manual',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue[700],
                    side: BorderSide(color: Colors.blue[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Limpar Tudo
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: onClearAll,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: const Text(
                    'Limpar',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[600],
                    side: BorderSide(color: Colors.red[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
