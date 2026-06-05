import 'package:flutter/material.dart';
import 'package:smart_money/core/theme/app_colors.dart';

class NotificationService {
  NotificationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static OverlayEntry? _currentEntry;

  static void _showOverlay(
    String message,
    Color background,
    IconData icon, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    // remove existing
    try {
      _currentEntry?.remove();
    } catch (_) {}

    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 120,
          left: 24,
          right: 24,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 20.0, end: 0.0),
              duration: const Duration(milliseconds: 280),
              builder: (context, value, child) {
                final opacity = (1 - (value / 20)).clamp(0.0, 1.0);
                return Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, value),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    _currentEntry = entry;

    Future.delayed(duration, () {
      try {
        entry.remove();
      } catch (_) {}
      if (_currentEntry == entry) _currentEntry = null;
    });
  }

  static void showSuccess(String message) =>
      _showOverlay(message, AppColors.primaryContainer, Icons.check_circle);

  static void showError(String message) =>
      _showOverlay(message, AppColors.error, Icons.error_outline);

  static void showInfo(String message) =>
      _showOverlay(message, AppColors.surfaceContainerLow, Icons.info_outline);
}
