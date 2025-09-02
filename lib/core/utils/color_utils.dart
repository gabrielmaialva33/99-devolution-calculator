import 'package:flutter/material.dart';

extension ColorUtils on Color {
  /// Modern replacement for withOpacity - uses withValues for better precision
  Color withAlpha(double alpha) {
    return withValues(alpha: alpha);
  }
}