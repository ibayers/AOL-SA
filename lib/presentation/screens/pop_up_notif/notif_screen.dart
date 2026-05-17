import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/core/theme/app_text_styles.dart';

class SmartAlertDialog extends StatelessWidget {
  const SmartAlertDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: AppColors.onSurface.withValues(alpha: 0.4),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 112, left: 24, right: 24),
              child: Material(
                color: Colors.transparent,
                child: const SmartAlertDialog(),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2 * animation.value, sigmaY: 2 * animation.value),
          child: FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 50,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Amber blur circle top right
              Positioned(
                top: -48,
                right: -48,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber[200]!.withValues(alpha: 0.4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber[200]!.withValues(alpha: 0.4),
                        blurRadius: 40,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  Colors.teal[500]!.withValues(alpha: 0.1),
                                  Colors.amber[500]!.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.psychology_rounded,
                                color: Colors.teal[700],
                                size: 36,
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: -4,
                            right: -4,
                            child: Text('😢', style: TextStyle(fontSize: 24)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Smart Alert',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: Colors.teal[900],
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Wait, '),
                          TextSpan(text: 'Bryan! ', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const TextSpan(text: 'Past data shows you usually regret this type of purchase. '),
                          TextSpan(text: 'Rethink?', style: TextStyle(color: Colors.teal[800], fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Buttons
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => Navigator.pop(context, false), // cancel purchase
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.teal[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              elevation: 8,
                              shadowColor: Colors.teal[800]!.withValues(alpha: 0.2),
                            ),
                            child: Text(
                              'Stay Committed (Cancel Purchase)',
                              style: AppTextStyles.headlineSmall.copyWith(fontSize: 14, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, true), // save anyway
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.teal[800],
                              side: BorderSide(color: Colors.teal[800]!.withValues(alpha: 0.3), width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: Text(
                              'Save Anyway',
                              style: AppTextStyles.headlineSmall.copyWith(fontSize: 14, color: Colors.teal[800]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
