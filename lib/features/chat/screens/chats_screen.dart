import 'package:flutter/material.dart';
import '../../../models/chat.dart';
import '../../../services/chat_service.dart';
import 'chat_conversation_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  static final GlobalKey<_ChatsScreenState> chatScreenKey = GlobalKey<_ChatsScreenState>();

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ChatService _chatService = ChatService();
  List<Chat> _chats = [];

  @override
  void initState() {
    super.initState();
    _loadDemoChats();
  }

  void _loadDemoChats() {
    _chats = [
      Chat(
        id: 'chat_1',
        otherUserName: 'Анна Петрова',
        otherUserAddress: 'ул. Советская, д. 12, кв. 45',
        lastMessage: 'Здравствуйте! Интересует ваш iPhone',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
        hasUnreadMessages: true,
        unreadCount: 2,
      ),
      Chat(
        id: 'chat_2',
        otherUserName: 'Дмитрий Сидоров',
        otherUserAddress: 'ул. Мира, д. 3, кв. 67',
        lastMessage: 'Спасибо за диван! Все отлично',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        hasUnreadMessages: false,
        unreadCount: 0,
      ),
      Chat(
        id: 'chat_3',
        otherUserName: 'Мария Иванова',
        otherUserAddress: 'ул. Ленина, д. 8, кв. 21',
        lastMessage: 'Когда можно забрать кроватку?',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
        hasUnreadMessages: false,
        unreadCount: 0,
      ),
    ];

    // Добавляем новые чаты из ChatService если они есть
    for (final serviceChat in _chatService.chats) {
      if (!_chats.any((chat) => chat.id == serviceChat.id)) {
        _chats.insert(0, serviceChat);
      }
    }
  }

  // Метод для добавления нового чата
  void addNewChat(Chat newChat) {
    setState(() {
      final existingIndex = _chats.indexWhere((chat) => chat.id == newChat.id);
      if (existingIndex != -1) {
        _chats[existingIndex] = newChat;
      } else {
        _chats.insert(0, newChat);
      }
    });
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'только что';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн';
    } else {
      return '${dateTime.day}.${dateTime.month}';
    }
  }

  void _openChat(Chat chat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatConversationScreen(
          chat: chat,
          onChatUpdated: (updatedChat) {
            setState(() {
              final index = _chats.indexWhere((c) => c.id == updatedChat.id);
              if (index != -1) {
                _chats[index] = updatedChat;
              }
              _chatService.updateChat(updatedChat);
            });
          },
        ),
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
              child: Row(
                children: [
                  const Text(
                    'Чаты',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_chats.any((chat) => chat.hasUnreadMessages))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_chats.where((chat) => chat.hasUnreadMessages).length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Список чатов
            Expanded(
              child: _chats.isEmpty ? _buildEmptyState() : _buildChatsList(),
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
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            'Пока нет чатов',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Начните общение с соседями!\nНапишите продавцу через объявления',
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

  Widget _buildChatsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _chats.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildChatCard(_chats[index]);
      },
    );
  }

  Widget _buildChatCard(Chat chat) {
    return GestureDetector(
      onTap: () => _openChat(chat),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Аватар
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    chat.otherUserName[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                if (chat.hasUnreadMessages)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF6B6B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(width: 16),
            
            // Информация о чате
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.otherUserName,
                          style: TextStyle(
                            fontWeight: chat.hasUnreadMessages ? FontWeight.bold : FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (chat.lastMessageTime != null)
                        Text(
                          _getTimeAgo(chat.lastMessageTime!),
                          style: TextStyle(
                            color: chat.hasUnreadMessages ? const Color(0xFFFF6B6B) : Colors.grey[500],
                            fontSize: 12,
                            fontWeight: chat.hasUnreadMessages ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chat.otherUserAddress,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (chat.lastMessage != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.lastMessage!,
                            style: TextStyle(
                              color: chat.hasUnreadMessages ? Colors.black87 : Colors.grey[600],
                              fontSize: 14,
                              fontWeight: chat.hasUnreadMessages ? FontWeight.w500 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (chat.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B6B),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${chat.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 