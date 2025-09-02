import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/barcode_item.dart';

class ManualInputDialog extends StatefulWidget {
  const ManualInputDialog({super.key});

  @override
  State<ManualInputDialog> createState() => _ManualInputDialogState();
}

class _ManualInputDialogState extends State<ManualInputDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorMessage;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _onTextChanged() {
    String text = _controller.text;
    setState(() {
      _errorMessage = null;

      if (text.isEmpty) {
        _isComplete = false;
      } else if (text.length == 5) {
        _isComplete = RegExp(r'^\d{5}$').hasMatch(text);
        if (!_isComplete) {
          _errorMessage = 'Digite apenas números (5 dígitos)';
        }
      } else if (text.length == 11) {
        _isComplete = RegExp(r'^\d{11}$').hasMatch(text);
        if (!_isComplete) {
          _errorMessage = 'Digite apenas números (11 dígitos)';
        }
      } else {
        _isComplete = false;
        if (text.length > 11) {
          _errorMessage = 'Máximo 11 dígitos';
        } else if (text.length > 5 && text.length < 11) {
          _errorMessage =
              'Digite 5 dígitos (só valor) ou 11 dígitos (código completo)';
        }
      }
    });
  }

  void _onConfirm() {
    String barcode = _controller.text.trim();

    if (barcode.isEmpty) {
      setState(() {
        _errorMessage = 'Digite um código';
      });
      return;
    }

    if (!BarcodeItem.isValidBarcode(barcode)) {
      setState(() {
        _errorMessage = 'Código inválido';
      });
      return;
    }

    Navigator.of(context).pop(barcode);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.keyboard, color: Colors.blue),
          SizedBox(width: 8),
          Text('Entrada Manual'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Digite o código de barras:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),

          Text(
            '• 11 dígitos (código completo)\n• 5 dígitos (apenas valor)',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            decoration: InputDecoration(
              hintText: 'Ex: 00707401350 ou 01350',
              border: const OutlineInputBorder(),
              errorText: _errorMessage,
              suffixIcon: _isComplete
                  ? Icon(Icons.check_circle, color: Colors.green[600])
                  : null,
            ),
            style: const TextStyle(
              fontSize: 18,
              fontFamily: 'monospace',
              letterSpacing: 1.2,
            ),
            onSubmitted: (_) => _isComplete ? _onConfirm() : null,
          ),

          if (_controller.text.isNotEmpty && _controller.text.length >= 5) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Valor: R\$ ${(BarcodeItem.parseValue(_controller.text)).toStringAsFixed(2).replaceAll('.', ',')}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isComplete ? _onConfirm : null,
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
