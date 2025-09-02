import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
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

class _ManualInputDialogState extends State<ManualInputDialog>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _error;
  String? _previewValue;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.keyboard,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Entrada Manual',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Instructions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                    width: 1,
                  ),
                ),
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
              const SizedBox(height: 20),
              
              // Input Field
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                maxLength: 11,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 20,
                  color: AppColors.textPrimary,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  labelText: 'Código de Barras',
                  hintText: '00707401350 ou 01350',
                  errorText: _error,
                  counterText: '${_controller.text.length}/11',
                  prefixIcon: const Icon(Icons.qr_code, color: AppColors.accentPrimary),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textMuted),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success.withOpacity(0.1),
                        AppColors.success.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCELAR'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _error == null && _controller.text.isNotEmpty
                        ? _submit
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                      disabledBackgroundColor: AppColors.textMuted.withOpacity(0.3),
                    ),
                    child: const Text('CONFIRMAR'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}