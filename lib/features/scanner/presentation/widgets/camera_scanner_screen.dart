import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

class CameraScannerScreen extends StatefulWidget {
  final Function(String) onScan;

  const CameraScannerScreen({
    super.key,
    required this.onScan,
  });

  @override
  State<CameraScannerScreen> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends State<CameraScannerScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController _controller;
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _scanLineAnimation = Tween<double>(
      begin: 0.1,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() => _isProcessing = true);
        widget.onScan(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera View
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          
          // Scanning Overlay
          _buildScanningOverlay(),
          
          // Top Controls
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const Spacer(),
                _buildBottomControls(),
              ],
            ),
          ),
          
          // Processing Indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return AnimatedBuilder(
      animation: _scanLineAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ScannerOverlayPainter(
            scanLinePosition: _scanLineAnimation.value,
          ),
          child: Container(),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Escaneando',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Posicione o código de barras dentro da área de leitura',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Flash Toggle
              ValueListenableBuilder(
                valueListenable: _controller.torchState,
                builder: (context, state, child) {
                  return IconButton(
                    onPressed: () => _controller.toggleTorch(),
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: state == TorchState.on
                            ? AppColors.warning.withOpacity(0.2)
                            : Colors.black54,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: state == TorchState.on
                              ? AppColors.warning
                              : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        state == TorchState.on
                            ? Icons.flash_on
                            : Icons.flash_off,
                        color: state == TorchState.on
                            ? AppColors.warning
                            : Colors.white,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 24),
              // Camera Switch
              IconButton(
                onPressed: () => _controller.switchCamera(),
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.cameraswitch,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final double scanLinePosition;

  _ScannerOverlayPainter({required this.scanLinePosition});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint darkPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Paint cornerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    final Paint scanLinePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.primary.withOpacity(0.5),
          AppColors.primary,
          AppColors.primary.withOpacity(0.5),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 2));

    // Calculate scanner area
    final double scanAreaSize = size.width * 0.7;
    final Rect scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize * 0.6,
    );

    // Draw dark overlay
    final Path overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(20)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(overlayPath, darkPaint);

    // Draw border
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(20)),
      borderPaint,
    );

    // Draw corners
    const double cornerLength = 30;
    final List<List<Offset>> corners = [
      // Top-left
      [
        Offset(scanRect.left, scanRect.top + cornerLength),
        Offset(scanRect.left, scanRect.top + 20),
        Offset(scanRect.left + 20, scanRect.top),
        Offset(scanRect.left + cornerLength, scanRect.top),
      ],
      // Top-right
      [
        Offset(scanRect.right - cornerLength, scanRect.top),
        Offset(scanRect.right - 20, scanRect.top),
        Offset(scanRect.right, scanRect.top + 20),
        Offset(scanRect.right, scanRect.top + cornerLength),
      ],
      // Bottom-left
      [
        Offset(scanRect.left, scanRect.bottom - cornerLength),
        Offset(scanRect.left, scanRect.bottom - 20),
        Offset(scanRect.left + 20, scanRect.bottom),
        Offset(scanRect.left + cornerLength, scanRect.bottom),
      ],
      // Bottom-right
      [
        Offset(scanRect.right - cornerLength, scanRect.bottom),
        Offset(scanRect.right - 20, scanRect.bottom),
        Offset(scanRect.right, scanRect.bottom - 20),
        Offset(scanRect.right, scanRect.bottom - cornerLength),
      ],
    ];

    for (final corner in corners) {
      final Path cornerPath = Path()
        ..moveTo(corner[0].dx, corner[0].dy)
        ..lineTo(corner[1].dx, corner[1].dy)
        ..arcToPoint(
          corner[2],
          radius: const Radius.circular(20),
        )
        ..lineTo(corner[3].dx, corner[3].dy);
      canvas.drawPath(cornerPath, cornerPaint);
    }

    // Draw scan line
    final double scanLineY = scanRect.top + (scanRect.height * scanLinePosition);
    canvas.drawLine(
      Offset(scanRect.left + 20, scanLineY),
      Offset(scanRect.right - 20, scanLineY),
      scanLinePaint..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_ScannerOverlayPainter oldDelegate) =>
      oldDelegate.scanLinePosition != scanLinePosition;
}