import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_money/application/notifications.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/core/theme/app_text_styles.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifications',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Recent activity from your finance actions',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                  if (notifications.isNotEmpty)
                    TextButton(
                      onPressed: () =>
                          ref.read(notificationsProvider.notifier).clear(),
                      child: const Text('Clear all'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              color: AppColors.primary,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications yet',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Successful savings, income, expenses, and profile updates will show here.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _NotificationCard(notification: notification);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  const _NotificationCard({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = _styleForType(notification.type);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      onDismissed: (_) =>
          ref.read(notificationsProvider.notifier).remove(notification.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: style.color.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: style.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(style.icon, color: style.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(notification.createdAt),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _NotificationStyle _styleForType(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.success:
        return const _NotificationStyle(
          Icons.check_circle_rounded,
          AppColors.secondary,
        );
      case AppNotificationType.warning:
        return const _NotificationStyle(
          Icons.warning_rounded,
          Color(0xFFB86E00),
        );
      case AppNotificationType.error:
        return const _NotificationStyle(Icons.error_rounded, AppColors.error);
      case AppNotificationType.info:
        return const _NotificationStyle(
          Icons.notifications_rounded,
          AppColors.primary,
        );
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _NotificationStyle {
  const _NotificationStyle(this.icon, this.color);

  final IconData icon;
  final Color color;
}
