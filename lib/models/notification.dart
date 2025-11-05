import 'package:flutter/material.dart';

enum NotificationType {
  event,        // Уведомления о событиях
  group,        // Уведомления из групп  
  post,         // Комментарии к постам
  chat,         // Личные сообщения
  advertisement, // Объявления
  system,       // Системные уведомления
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data; // Дополнительные данные для навигации

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.event:
        return Icons.event;
      case NotificationType.group:
        return Icons.group;
      case NotificationType.post:
        return Icons.comment;
      case NotificationType.chat:
        return Icons.message;
      case NotificationType.advertisement:
        return Icons.shopping_bag;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.event:
        return Colors.blue;
      case NotificationType.group:
        return const Color(0xFFFF6B6B);
      case NotificationType.post:
        return Colors.orange;
      case NotificationType.chat:
        return Colors.green;
      case NotificationType.advertisement:
        return Colors.purple;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'только что';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч назад';
    } else if (difference.inDays == 1) {
      return 'вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн назад';
    } else {
      return '${(difference.inDays / 7).floor()} нед назад';
    }
  }
} 