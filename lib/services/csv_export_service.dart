import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../features/scanner/domain/models/barcode_item.dart';

class CSVExportService {
  static const String _filePrefix = 'devolucoes';

  /// Gera nome do arquivo com timestamp
  static String _generateFileName() {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd_HHmm');
    return '${_filePrefix}_${dateFormat.format(now)}.csv';
  }

  /// Converte lista de itens para formato CSV com metadados
  static List<List<dynamic>> _generateCSVData(List<BarcodeItem> items) {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    // Calcula estatísticas
    final totalValue = items.fold(0.0, (sum, item) => sum + item.value);
    final totalItems = items.length;

    // Conta itens por método
    final usbCount = items
        .where((item) => item.scanMethod == ScanMethod.usb)
        .length;
    final cameraCount = items
        .where((item) => item.scanMethod == ScanMethod.camera)
        .length;
    final manualCount = items
        .where((item) => item.scanMethod == ScanMethod.manual)
        .length;

    List<List<dynamic>> csvData = [];

    // Cabeçalho com metadados
    csvData.add([
      '# Relatório de Devoluções - Gerado em ${dateFormat.format(now)} às ${timeFormat.format(now)}',
    ]);
    csvData.add([
      '# Total Geral: ${currencyFormat.format(totalValue)} ($totalItems itens)',
    ]);
    csvData.add([
      '# USB: $usbCount itens | Câmera: $cameraCount itens | Manual: $manualCount item${manualCount != 1 ? 's' : ''}',
    ]);
    csvData.add([]); // Linha vazia

    // Cabeçalho das colunas
    csvData.add(['Data/Hora', 'Código', 'Valor', 'Método', 'Valor_Bruto']);

    // Dados dos itens
    for (final item in items) {
      final itemDateFormat = DateFormat('dd/MM/yyyy HH:mm');
      csvData.add([
        itemDateFormat.format(item.scannedAt),
        item.code,
        item.formattedValue,
        item.scanMethodLabel,
        item.value.toString(),
      ]);
    }

    return csvData;
  }

  /// Exporta dados e compartilha via apps do dispositivo
  static Future<void> shareCSV(List<BarcodeItem> items) async {
    if (items.isEmpty) {
      throw Exception('Não há itens para exportar');
    }

    try {
      final csvData = _generateCSVData(items);
      final csvString = const ListToCsvConverter(
        fieldDelimiter: ',',
        textDelimiter: '"',
        eol: '\n',
      ).convert(csvData);

      // Salva arquivo temporário
      final tempDir = await getTemporaryDirectory();
      final fileName = _generateFileName();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(csvString, encoding: utf8);

      // Compartilha o arquivo
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Relatório de Devoluções - ${items.length} itens',
        subject: 'Relatório de Devoluções CSV',
      );
    } catch (e) {
      throw Exception('Erro ao compartilhar CSV: ${e.toString()}');
    }
  }

  /// Verifica e solicita permissões de armazenamento
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Para Android 13+ (API 33+), não precisamos de permissões especiais para Downloads
      if (await Permission.storage.isGranted) {
        return true;
      }

      // Solicita permissão
      final status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }

      // Se negado permanentemente, mostra informações
      if (status.isPermanentlyDenied) {
        throw Exception(
          'Permissão de armazenamento negada. Ative nas configurações do app.',
        );
      }

      throw Exception(
        'Permissão de armazenamento necessária para salvar arquivo',
      );
    }

    return true; // iOS não precisa de permissões especiais
  }

  /// Salva CSV na pasta Downloads do dispositivo
  static Future<String> saveCSVToDownloads(List<BarcodeItem> items) async {
    if (items.isEmpty) {
      throw Exception('Não há itens para exportar');
    }

    try {
      // Verifica permissões
      await _requestStoragePermission();

      final csvData = _generateCSVData(items);
      final csvString = const ListToCsvConverter(
        fieldDelimiter: ',',
        textDelimiter: '"',
        eol: '\n',
      ).convert(csvData);

      // Obtém diretório de downloads
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        // Tenta o diretório público Downloads primeiro
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          // Fallback para diretório da aplicação
          downloadsDir = await getExternalStorageDirectory();
        }
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null) {
        throw Exception('Não foi possível acessar o diretório de downloads');
      }

      // Salva o arquivo
      final fileName = _generateFileName();
      final file = File('${downloadsDir.path}/$fileName');
      await file.writeAsString(csvString, encoding: utf8);

      return file.path;
    } catch (e) {
      throw Exception('Erro ao salvar CSV: ${e.toString()}');
    }
  }

  /// Gera preview dos dados para mostrar antes da exportação
  static String generatePreview(List<BarcodeItem> items) {
    if (items.isEmpty) return 'Nenhum item para exportar';

    final totalValue = items.fold(0.0, (sum, item) => sum + item.value);
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    final usbCount = items
        .where((item) => item.scanMethod == ScanMethod.usb)
        .length;
    final cameraCount = items
        .where((item) => item.scanMethod == ScanMethod.camera)
        .length;
    final manualCount = items
        .where((item) => item.scanMethod == ScanMethod.manual)
        .length;

    return '''Preview do Relatório:
• Total: ${currencyFormat.format(totalValue)}
• Itens: ${items.length}
• USB: $usbCount | Câmera: $cameraCount | Manual: $manualCount

Arquivo: ${_generateFileName()}
Primeiro item: ${items.first.code} - ${items.first.formattedValue}
${items.length > 1 ? 'Último item: ${items.last.code} - ${items.last.formattedValue}' : ''}''';
  }
}
