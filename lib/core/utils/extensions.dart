import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  double get width => screenSize.width;
  double get height => screenSize.height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  void hapticLight() => HapticFeedback.lightImpact();
  void hapticMedium() => HapticFeedback.mediumImpact();
  void hapticHeavy() => HapticFeedback.heavyImpact();
  void hapticSelection() => HapticFeedback.selectionClick();
}

extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

extension IntExtensions on int {
  String get formatted => toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
}

extension DoubleExtensions on double {
  String get oneDecimal => toStringAsFixed(1);
}
