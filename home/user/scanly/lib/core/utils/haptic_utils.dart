import 'package:flutter/services.dart';

class HapticUtils {
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void success() {
    HapticFeedback.selectionClick();
  }

  static void error() {
    HapticFeedback.vibrate();
  }
}