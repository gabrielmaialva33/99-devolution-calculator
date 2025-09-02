import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/services/barcode_validation_service.dart';

class ManualInputDialog extends StatefulWidget {
  final Function(String) onSubmit;

  const ManualInputDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<ManualInputDialog> createState() => _ManualInputDialogState();
}

class _ManualInputDialogState extends State<ManualInputDialog> {
  final _controller = TextEditingController();
  String? _error;
  String? _previewValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Focus on text field when dialog opens
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateAndPreview(String value) {
    setState(() {
      if (value.isEmpty) {
        _error = null;
        _previewValue = null;
        return;
      }

      if (!RegExp(r'^\d+$').hasMatch(value)) {
        _error = 'Apenas números são permitidos';
        _previewValue = null;
        return;
      }

      if (value.length != 5 && value.length != 11) {
        _error = 'Digite 5 dígitos (valor) ou 11 dígitos (código completo)';
        _previewValue = null;
        return;
      }

      _error = null;
      final extractedValue = BarcodeValidationService.extractValue(value);
      if (extractedValue != null) {
        _previewValue = 'R\$ ${extractedValue.toStringAsFixed(2)}';
      }
    });
  }

  void _submit() {
    final code = _controller.text.trim();
    if (BarcodeValidationService.isValidCode(code)) {
      widget.onSubmit(code);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.keyboard, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Entrada Manual'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instructions
          Card(
            color: AppColors.info.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Digite o código completo (11 dígitos) ou apenas o valor (5 dígitos)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Input Field
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            maxLength: 11,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 18,
              letterSpacing: 1,
            ),
            decoration: InputDecoration(
              labelText: 'Código de Barras',
              hintText: '00707401350 ou 01350',
              errorText: _error,
              counterText: '${_controller.text.length}/11',
              prefixIcon: const Icon(Icons.qr_code),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _validateAndPreview('');
                      },
                    )
                  : null,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            onChanged: _validateAndPreview,
            onSubmitted: (_) => _submit(),
          ),
          
          // Value Preview
          if (_previewValue != null) ...[
            const SizedBox(height: 16),
            Card(
              color: AppColors.success.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _previewValue!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: _error == null && _controller.text.isNotEmpty
              ? _submit
              : null,
          child: const Text('CONFIRMAR'),
        ),
      ],
    );
  }
}