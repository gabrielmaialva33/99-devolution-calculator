import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

class AnimatedTotalSummary extends StatefulWidget {
  final double totalValue;
  final int itemCount;
  final VoidCallback onClear;

  const AnimatedTotalSummary({
    super.key,
    required this.totalValue,
    required this.itemCount,
    required this.onClear,
  });

  @override
  State<AnimatedTotalSummary> createState() => _AnimatedTotalSummaryState();
}

class _AnimatedTotalSummaryState extends State<AnimatedTotalSummary>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _countController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _countAnimation;
  
  double _previousValue = 0;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _countController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _countAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _countController,
      curve: Curves.elasticOut,
    ));

    _previousValue = widget.totalValue;
    _previousCount = widget.itemCount;
  }

  @override
  void didUpdateWidget(AnimatedTotalSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.totalValue != widget.totalValue ||
        oldWidget.itemCount != widget.itemCount) {
      _previousValue = oldWidget.totalValue;
      _previousCount = oldWidget.itemCount;
      _countController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _countAnimation]),
      builder: (context, child) {
        final displayValue = _previousValue +
            (_countAnimation.value * (widget.totalValue - _previousValue));
        final displayCount = (_previousCount +
                (_countAnimation.value * (widget.itemCount - _previousCount)))
            .round();

        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GlassContainer(
            padding: const EdgeInsets.all(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDark.withOpacity(0.8),
                AppColors.primaryMedium.withOpacity(0.6),
              ],
            ),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
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
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'TOTAL DEVOLUÇÕES',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppColors.textSecondary,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    if (widget.itemCount > 0)
                      IconButton(
                        onPressed: widget.onClear,
                        icon: const Icon(Icons.clear_all_rounded),
                        color: AppColors.textMuted,
                        tooltip: 'Limpar tudo',
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                // Total Value with Gradient Text
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.accentGradient
                      .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: Text(
                    formatter.format(displayValue),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                // Item Count with Animation
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentPrimary.withOpacity(0.1),
                        AppColors.accentSecondary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.rotate(
                        angle: _countAnimation.value * math.pi * 2,
                        child: Icon(
                          Icons.inventory_2_rounded,
                          size: 20,
                          color: AppColors.accentPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$displayCount ${displayCount == 1 ? 'item' : 'itens'}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                if (widget.itemCount == 0) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Escaneie ou digite um código',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}