import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  List<ChatPreview> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);
    
    try {
      // Проверяем доступность бэкенда
      final isBackendAvailable = await ApiService.checkHealth();
      
      if (isBackendAvailable) {
        final chats = await ApiService.getUserChats();
        setState(() {
          _chats = chats.map((chat) => ChatPreview(
            id: chat['id'] ?? 'unknown',
            participantName: chat['participantName'] ?? 'Неизвестный',
            lastMessage: chat['lastMessage'] ?? '',
            timestamp: chat['timestamp'] != null 
                ? DateTime.parse(chat['timestamp'])
                : DateTime.now(),
            unreadCount: chat['unreadCount'] ?? 0,
          )).toList();
          _isLoading = false;
        });
      } else {
        // Бэкенд недоступен, показываем демо-данные
        _loadDemoChats();
      }
    } catch (e) {
      print('Error loading chats: $e');
      // Добавляем тестовые чаты для демонстрации
      _loadDemoChats();
    }
  }

  void _loadDemoChats() {
    setState(() {
      _chats = [
        ChatPreview(
          id: 'chat-1',
          participantName: 'Иван Иванов',
          lastMessage: 'Привет! Как дела?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          unreadCount: 2,
        ),
        ChatPreview(
          id: 'chat-2',
          participantName: 'Мария Петрова',
          lastMessage: 'Спасибо за помощь!',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          unreadCount: 0,
        ),
        ChatPreview(
          id: 'chat-3',
          participantName: 'Алексей Сидоров',
          lastMessage: 'Встречаемся завтра?',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          unreadCount: 1,
        ),
      ];
      _isLoading = false;
    });
  }

  void _createNewChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новый чат'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Введите имя пользователя:'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Имя пользователя',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (name) {
                Navigator.pop(context);
                if (name.isNotEmpty) {
                  _startChat(name);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // Простое решение - создаем чат с тестовым именем
              Navigator.pop(context);
              _startChat('Новый пользователь');
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  void _startChat(String participantName) {
    final chatId = 'chat-${DateTime.now().millisecondsSinceEpoch}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chatId,
          participantName: participantName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чаты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Поиск чатов
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Меню
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Нет чатов',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Начните новый разговор',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadChats,
                  child: ListView.builder(
                    itemCount: _chats.length,
                    itemBuilder: (context, index) {
                      final chat = _chats[index];
                      return ChatListTile(
                        chat: chat,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatId: chat.id,
                                participantName: chat.participantName,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewChat,
        child: const Icon(Icons.chat),
      ),
    );
  }
}

class ChatListTile extends StatelessWidget {
  final ChatPreview chat;
  final VoidCallback onTap;

  const ChatListTile({
    super.key,
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          chat.participantName[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        chat.participantName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: chat.unreadCount > 0 ? Colors.black87 : Colors.grey[600],
          fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(chat.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          if (chat.unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                chat.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}д';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}м';
    } else {
      return 'сейчас';
    }
  }
}

class ChatPreview {
  final String id;
  final String participantName;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;

  ChatPreview({
    required this.id,
    required this.participantName,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
  });
} 