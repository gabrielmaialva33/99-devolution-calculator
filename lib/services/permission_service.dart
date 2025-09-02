import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Lista de todas as permissões necessárias para o app
  List<Permission> get _requiredPermissions => [
    Permission.camera,
    // Removido storage permissions para evitar problemas de loading infinito
  ];

  /// Verifica se todas as permissões estão concedidas
  Future<bool> areAllPermissionsGranted() async {
    for (final permission in _requiredPermissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        return false;
      }
    }
    return true;
  }

  /// Solicita todas as permissões necessárias
  Future<PermissionRequestResult> requestAllPermissions() async {
    final List<Permission> deniedPermissions = [];
    final List<Permission> permanentlyDeniedPermissions = [];
    final List<Permission> grantedPermissions = [];

    // Verifica status atual de cada permissão
    for (final permission in _requiredPermissions) {
      final status = await permission.status;
      
      if (status.isGranted) {
        grantedPermissions.add(permission);
      } else if (status.isPermanentlyDenied) {
        permanentlyDeniedPermissions.add(permission);
      } else {
        deniedPermissions.add(permission);
      }
    }

    // Solicita permissões que ainda não foram negadas permanentemente
    if (deniedPermissions.isNotEmpty) {
      final Map<Permission, PermissionStatus> results = await deniedPermissions.request();
      
      results.forEach((permission, status) {
        if (status.isGranted) {
          grantedPermissions.add(permission);
        } else if (status.isPermanentlyDenied) {
          permanentlyDeniedPermissions.add(permission);
        } else {
          // Permissão negada mas não permanentemente
        }
      });
    }

    return PermissionRequestResult(
      allGranted: permanentlyDeniedPermissions.isEmpty && 
                 grantedPermissions.length == _requiredPermissions.length,
      grantedPermissions: grantedPermissions,
      deniedPermissions: _requiredPermissions
          .where((p) => !grantedPermissions.contains(p) && !permanentlyDeniedPermissions.contains(p))
          .toList(),
      permanentlyDeniedPermissions: permanentlyDeniedPermissions,
    );
  }

  /// Abre as configurações do sistema para permissões negadas permanentemente
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Retorna mensagem explicativa para cada permissão
  String getPermissionExplanation(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Câmera é necessária para escanear códigos de barras';
      case Permission.storage:
        return 'Armazenamento é necessário para exportar arquivos CSV';
      case Permission.manageExternalStorage:
        return 'Acesso completo a arquivos é necessário para salvar CSV';
      default:
        return 'Permissão necessária para o funcionamento do app';
    }
  }

  /// Verifica se uma permissão específica está concedida
  Future<bool> isPermissionGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  /// Solicita uma permissão específica
  Future<PermissionStatus> requestPermission(Permission permission) async {
    return await permission.request();
  }
}

class PermissionRequestResult {
  final bool allGranted;
  final List<Permission> grantedPermissions;
  final List<Permission> deniedPermissions;
  final List<Permission> permanentlyDeniedPermissions;

  PermissionRequestResult({
    required this.allGranted,
    required this.grantedPermissions,
    required this.deniedPermissions,
    required this.permanentlyDeniedPermissions,
  });

  bool get hasPermanentlyDenied => permanentlyDeniedPermissions.isNotEmpty;
  bool get hasDenied => deniedPermissions.isNotEmpty;
  
  String get summary {
    if (allGranted) {
      return 'Todas as permissões foram concedidas';
    } else if (hasPermanentlyDenied) {
      return 'Algumas permissões foram negadas permanentemente. Ative-as nas configurações do sistema.';
    } else if (hasDenied) {
      return 'Algumas permissões foram negadas. O app pode não funcionar corretamente.';
    } else {
      return 'Verificando permissões...';
    }
  }
}