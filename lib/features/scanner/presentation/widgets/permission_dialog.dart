import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../services/permission_service.dart';

class PermissionDialog extends StatefulWidget {
  final VoidCallback onPermissionsGranted;

  const PermissionDialog({
    super.key,
    required this.onPermissionsGranted,
  });

  @override
  State<PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<PermissionDialog> {
  final PermissionService _permissionService = PermissionService();
  bool _isRequesting = false;
  PermissionRequestResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final allGranted = await _permissionService.areAllPermissionsGranted();
    if (allGranted) {
      widget.onPermissionsGranted();
      Navigator.of(context).pop();
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      final result = await _permissionService.requestAllPermissions();
      
      setState(() {
        _lastResult = result;
        _isRequesting = false;
      });

      if (result.allGranted) {
        widget.onPermissionsGranted();
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isRequesting = false;
      });
    }
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Impede fechar o diálogo
      child: AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1 * 255),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.security_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Permissões Necessárias',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para funcionar corretamente, este app precisa das seguintes permissões:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            // Lista de permissões
            _buildPermissionItem(
              Icons.camera_alt_rounded,
              'Câmera',
              'Para escanear códigos de barras',
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildPermissionItem(
              Icons.folder_rounded,
              'Armazenamento',
              'Para exportar arquivos CSV',
              Colors.green,
            ),
            
            // Resultado da última tentativa
            if (_lastResult != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _lastResult!.allGranted 
                    ? Colors.green.withValues(alpha: 0.1 * 255)
                    : Colors.orange.withValues(alpha: 0.1 * 255),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _lastResult!.allGranted ? Colors.green : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _lastResult!.allGranted ? Icons.check_circle : Icons.warning,
                      color: _lastResult!.allGranted ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _lastResult!.summary,
                        style: TextStyle(
                          fontSize: 13,
                          color: _lastResult!.allGranted ? Colors.green[700] : Colors.orange[700],
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
          if (_lastResult?.hasPermanentlyDenied == true)
            TextButton(
              onPressed: _openSettings,
              child: const Text(
                'Configurações',
                style: TextStyle(color: AppColors.secondary),
              ),
            ),
          
          ElevatedButton(
            onPressed: _isRequesting ? null : _requestPermissions,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: _isRequesting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Conceder Permissões',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1 * 255),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}