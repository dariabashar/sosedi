import '../models/notification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => 
      List.unmodifiable(_notifications..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  
  List<AppNotification> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  
  int get unreadCount => unreadNotifications.length;

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
  }

  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
  }

  void clearAll() {
    _notifications.clear();
  }

  // Метод для создания уведомления о событии
  void notifyEventReminder(String eventTitle, DateTime eventTime) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.event,
      title: 'Напоминание о событии',
      message: 'Не забудьте о событии "$eventTitle" сегодня в ${_formatTime(eventTime)}',
      createdAt: DateTime.now(),
      data: {'eventTitle': eventTitle, 'eventTime': eventTime.toIso8601String()},
    );
    addNotification(notification);
  }

  // Метод для создания уведомления о новом посте в группе
  void notifyGroupPost(String groupName, String authorName, String postText) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.group,
      title: 'Новый пост в группе',
      message: '$authorName написал в "$groupName": ${_truncateText(postText, 50)}',
      createdAt: DateTime.now(),
      data: {'groupName': groupName, 'authorName': authorName},
    );
    addNotification(notification);
  }

  // Метод для создания уведомления о комментарии
  void notifyPostComment(String authorName, String commentText) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.post,
      title: 'Новый комментарий',
      message: '$authorName прокомментировал ваш пост: ${_truncateText(commentText, 50)}',
      createdAt: DateTime.now(),
      data: {'authorName': authorName, 'commentText': commentText},
    );
    addNotification(notification);
  }

  // Метод для создания уведомления о новом сообщении
  void notifyChatMessage(String senderName, String messageText) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.chat,
      title: 'Новое сообщение',
      message: '$senderName: ${_truncateText(messageText, 50)}',
      createdAt: DateTime.now(),
      data: {'senderName': senderName, 'messageText': messageText},
    );
    addNotification(notification);
  }

  // Метод для создания уведомления о новом объявлении
  void notifyNewAdvertisement(String title, String type, String location) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.advertisement,
      title: 'Новое объявление рядом',
      message: '$title ${type == 'sale' ? '(продажа)' : '(даром)'} в $location',
      createdAt: DateTime.now(),
      data: {'adTitle': title, 'adType': type, 'location': location},
    );
    addNotification(notification);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Инициализация демо данных
  void initializeDemoData() {
    // Убираем демо данные - уведомления будут пустыми
  }
} 