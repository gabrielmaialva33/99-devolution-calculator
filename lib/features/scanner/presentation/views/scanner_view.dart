import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animated_gradient_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/barcode_item.dart';
import '../view_models/scanner_view_model.dart';
import '../widgets/animated_barcode_card.dart';
import '../widgets/animated_total_summary.dart';
import '../widgets/manual_input_dialog.dart';
import '../widgets/camera_scanner_screen.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScannerViewModel>(
      builder: (context, viewModel, child) {
        return RawKeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKey: (event) {
            if (event is RawKeyDownEvent) {
              final key = event.character;
              if (key != null) {
                viewModel.handleKeyboardInput(key);
              }
            }
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: _buildAppBar(),
            body: Stack(
              children: [
                // Animated Background
                _buildAnimatedBackground(),
                // Main Content
                SafeArea(
                  child: Column(
                    children: [
                      // Total Summary
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AnimatedTotalSummary(
                          totalValue: viewModel.totalValue,
                          itemCount: viewModel.itemCount,
                          onClear: viewModel.clearAll,
                        ),
                      ),
                      // Error Message
                      if (viewModel.lastError != null)
                        _buildErrorMessage(viewModel),
                      // Items List
                      Expanded(
                        child: _buildItemsList(viewModel),
                      ),
                      // Action Buttons
                      _buildActionButtons(context, viewModel),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DEVOLUTION',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Calculator Pro',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showAboutDialog(context),
        ),
      ],
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                -1 + _backgroundAnimation.value * 2,
                -1 + _backgroundAnimation.value,
              ),
              end: Alignment(
                1 - _backgroundAnimation.value * 2,
                1 - _backgroundAnimation.value,
              ),
              colors: const [
                AppColors.backgroundDark,
                AppColors.primaryDark,
                AppColors.primaryMedium,
                AppColors.backgroundDark,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: _GridPainter(
              animationValue: _backgroundAnimation.value,
            ),
            child: Container(),
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage(ScannerViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderColor: AppColors.error.withOpacity(0.3),
        gradient: LinearGradient(
          colors: [
            AppColors.error.withOpacity(0.1),
            AppColors.error.withOpacity(0.05),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                viewModel.lastError!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 14,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: AppColors.error,
              onPressed: viewModel.clearError,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(ScannerViewModel viewModel) {
    if (viewModel.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 80,
              color: AppColors.textMuted.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum item escaneado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use o leitor USB, câmera ou entrada manual',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: viewModel.items.length,
      itemBuilder: (context, index) {
        final item = viewModel.items[index];
        return AnimatedBarcodeCard(
          key: ValueKey(item.code + item.scannedAt.toString()),
          item: item,
          index: index,
          onDismiss: () => viewModel.removeItem(index),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, ScannerViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundDark.withOpacity(0),
            AppColors.backgroundDark,
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedGradientButton(
              onPressed: () => _openCameraScanner(context, viewModel),
              label: 'Câmera',
              icon: Icons.camera_alt_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedGradientButton(
              onPressed: () => _openManualInput(context, viewModel),
              label: 'Manual',
              icon: Icons.keyboard_rounded,
            ),
          ),
        ],
      ),
    );
  }

  void _openCameraScanner(BuildContext context, ScannerViewModel viewModel) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CameraScannerScreen(
          onScan: (code) {
            viewModel.processBarcode(code, ScanMethod.camera);
            Navigator.pop(context);
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(0, 1), end: Offset.zero).chain(
                CurveTween(curve: Curves.easeOutCubic),
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _openManualInput(BuildContext context, ScannerViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => ManualInputDialog(
        onSubmit: (code) {
          viewModel.processBarcode(code, ScanMethod.manual);
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Sobre o App',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Devolution Calculator v1.0.0',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.accentPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Aplicativo para leitura de códigos de barras e cálculo de devoluções.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            const Text(
              'Suporta leitores USB, câmera e entrada manual.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double animationValue;

  _GridPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.glassBorder.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridSize = 50.0;
    final offset = animationValue * gridSize;

    for (double x = -gridSize + offset; x < size.width + gridSize; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = -gridSize + offset; y < size.height + gridSize; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}