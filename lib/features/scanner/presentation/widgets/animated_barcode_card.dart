import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/models/barcode_item.dart';

class AnimatedBarcodeCard extends StatefulWidget {
  final BarcodeItem item;
  final VoidCallback onDismiss;
  final int index;

  const AnimatedBarcodeCard({
    super.key,
    required this.item,
    required this.onDismiss,
    required this.index,
  });

  @override
  State<AnimatedBarcodeCard> createState() => _AnimatedBarcodeCardState();
}

class _AnimatedBarcodeCardState extends State<AnimatedBarcodeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Dismissible(
                key: Key(widget.item.code + widget.item.scannedAt.toString()),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => widget.onDismiss(),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.error.withOpacity(0.1),
                        AppColors.error.withOpacity(0.3),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.delete_sweep_rounded,
                    color: AppColors.error,
                    size: 32,
                  ),
                ),
                child: GlassContainer(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Scan Method Icon with Pulse Animation
                      _buildScanMethodIcon(),
                      const SizedBox(width: 16),
                      // Item Information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Código: ',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.textMuted),
                                ),
                                Text(
                                  widget.item.displayCode,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontFamily: 'monospace',
                                        color: AppColors.accentPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.item.scanMethodLabel,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      // Value with Animation
                      _buildValueDisplay(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScanMethodIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPrimary.withOpacity(0.3 + value * 0.2),
                blurRadius: 10 + value * 5,
                spreadRadius: value * 2,
              ),
            ],
          ),
          child: Center(
            child: Transform.scale(
              scale: 1 + (math.sin(value * math.pi * 2) * 0.1),
              child: Text(
                widget.item.scanMethodIcon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildValueDisplay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.1),
            AppColors.success.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            widget.item.formattedValue,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Item #${widget.index + 1}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
