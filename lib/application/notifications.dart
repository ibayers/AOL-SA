import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppNotificationType { success, info, warning, error }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final AppNotificationType type;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: AppNotificationType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => AppNotificationType.info,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotification>>(
      NotificationsNotifier.new,
    );

class NotificationsNotifier extends Notifier<List<AppNotification>> {
  static const _storageKey = 'smart_money_notifications';
  static const int _maxItems = 30;

  @override
  List<AppNotification> build() {
    _loadNotifications();
    return const [];
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final rawItems = prefs.getStringList(_storageKey);

    if (rawItems == null) {
      state = const [];
      return;
    }

    state = rawItems
        .map(
          (item) => AppNotification.fromJson(
            jsonDecode(item) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      state.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  void push({
    required String title,
    required String message,
    AppNotificationType type = AppNotificationType.info,
  }) {
    final notification = AppNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      createdAt: DateTime.now(),
    );

    state = [notification, ...state].take(_maxItems).toList();
    _persist();
  }

  void success({required String title, required String message}) {
    push(title: title, message: message, type: AppNotificationType.success);
  }

  void info({required String title, required String message}) {
    push(title: title, message: message, type: AppNotificationType.info);
  }

  void warning({required String title, required String message}) {
    push(title: title, message: message, type: AppNotificationType.warning);
  }

  void error({required String title, required String message}) {
    push(title: title, message: message, type: AppNotificationType.error);
  }

  void remove(String id) {
    state = state.where((notification) => notification.id != id).toList();
    _persist();
  }

  void clear() {
    state = const [];
    _persist();
  }
}
