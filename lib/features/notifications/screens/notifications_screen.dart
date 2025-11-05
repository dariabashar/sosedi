import 'package:flutter/material.dart';
import '../../../models/notification.dart';
import '../../../models/chat.dart';
import '../../../services/notification_service.dart';
import '../../chat/screens/chats_screen.dart';
import '../../chat/screens/chat_conversation_screen.dart';
import '../../groups/screens/groups_screen.dart';
import '../../profile/screens/user_profile_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<AppNotification> _notifications = [];
  bool _showOnlyUnread = false;

  @override
  void initState() {
    super.initState();
    _notificationService.initializeDemoData();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notifications = _showOnlyUnread 
          ? _notificationService.unreadNotifications
          : _notificationService.notifications;
    });
  }

  void _markAsRead(String notificationId) {
    _notificationService.markAsRead(notificationId);
    _loadNotifications();
  }

  void _markAllAsRead() {
    _notificationService.markAllAsRead();
    _loadNotifications();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Все уведомления отмечены как прочитанные'),
        backgroundColor: Color(0xFFFF6B6B),
      ),
    );
  }

  void _removeNotification(String notificationId) {
    _notificationService.removeNotification(notificationId);
    _loadNotifications();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Уведомление удалено'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить все уведомления?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              _notificationService.clearAll();
              _loadNotifications();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Все уведомления удалены'),
                  backgroundColor: Colors.grey,
                ),
              );
            },
            child: const Text(
              'Удалить',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // Пометить как прочитанное при клике
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // Навигация в зависимости от типа уведомления
    switch (notification.type) {
      case NotificationType.chat:
        _navigateToChat(notification);
        break;
      case NotificationType.group:
        _navigateToGroups();
        break;
      case NotificationType.post:
        _navigateToUserProfile(notification);
        break;
      case NotificationType.event:
        _showEventDetails(notification);
        break;
      case NotificationType.advertisement:
        _showAdvertisementDetails(notification);
        break;
      case NotificationType.system:
        _showSystemNotificationDetails(notification);
        break;
    }
  }

  void _navigateToChat(AppNotification notification) {
    final senderName = notification.data?['senderName'] ?? 'Неизвестный';
    final chat = Chat(
      id: 'chat_with_${senderName.toLowerCase().replaceAll(' ', '_')}',
      otherUserName: senderName,
      otherUserAddress: 'ул. Пушкина, д. 15, кв. 42', // В реальном приложении получим из данных
      lastMessage: notification.message,
      lastMessageTime: notification.createdAt,
      hasUnreadMessages: false,
      unreadCount: 0,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatConversationScreen(
          chat: chat,
          onChatUpdated: (updatedChat) {
            // В реальном приложении здесь обновим чат в сервисе
          },
        ),
      ),
    );
  }

  void _navigateToGroups() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GroupsScreen()),
    );
  }

  void _navigateToUserProfile(AppNotification notification) {
    final authorName = notification.data?['authorName'] ?? 'Неизвестный';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          userName: authorName,
          userAddress: 'ул. Примерная, д. 1, кв. 1', // В реальном приложении получим из данных
          context: 'уведомления',
        ),
      ),
    );
  }

  void _showEventDetails(AppNotification notification) {
    final eventTitle = notification.data?['eventTitle'] ?? 'Событие';
    final eventTime = notification.data?['eventTime'] ?? 'время не указано';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(eventTitle),
        content: Text('Время: $eventTime'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showAdvertisementDetails(AppNotification notification) {
    final adTitle = notification.data?['adTitle'] ?? 'Объявление';
    final adType = notification.data?['adType'] ?? 'неизвестно';
    final location = notification.data?['location'] ?? 'место не указано';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(adTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Тип: ${adType == 'sale' ? 'Продажа' : 'Даром'}'),
            const SizedBox(height: 8),
            Text('Местоположение: $location'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showSystemNotificationDetails(AppNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Text(notification.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Уведомления',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_notificationService.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B6B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_notificationService.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          switch (value) {
                            case 'mark_all_read':
                              _markAllAsRead();
                              break;
                            case 'clear_all':
                              _clearAllNotifications();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'mark_all_read',
                            child: Text('Отметить все как прочитанные'),
                          ),
                          const PopupMenuItem(
                            value: 'clear_all',
                            child: Text('Очистить все'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Фильтр
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showOnlyUnread = false;
                            });
                            _loadNotifications();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !_showOnlyUnread ? const Color(0xFFFF6B6B) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Все',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !_showOnlyUnread ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showOnlyUnread = true;
                            });
                            _loadNotifications();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _showOnlyUnread ? const Color(0xFFFF6B6B) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Непрочитанные',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _showOnlyUnread ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Notifications list
            Expanded(
              child: _notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _buildNotificationCard(_notifications[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showOnlyUnread ? Icons.mark_email_read : Icons.notifications_none,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            _showOnlyUnread ? 'Нет непрочитанных уведомлений' : 'Нет уведомлений',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showOnlyUnread 
                ? 'Все уведомления прочитаны'
                : 'Когда появятся новые события,\nвы получите уведомления здесь',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _removeNotification(notification.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: GestureDetector(
        onTap: () => _handleNotificationTap(notification),
        child: Container(
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : const Color(0xFFFFF5F5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: notification.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          notification.timeAgo,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!notification.isRead) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B6B),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 