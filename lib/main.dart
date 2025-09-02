import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/scanner/data/repositories/barcode_repository.dart';
import 'features/scanner/presentation/view_models/scanner_view_model.dart';
import 'features/scanner/presentation/views/simple_scanner_view.dart';
import 'services/audio_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set Brazilian locale
  Intl.defaultLocale = 'pt_BR';
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const DevolutionCalculatorApp());
}

class DevolutionCalculatorApp extends StatelessWidget {
  const DevolutionCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ScannerViewModel(
            repository: BarcodeRepository(),
            audioService: AudioService(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Devolution Calculator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SimpleScannerView(),
      ),
    );
  }
}
