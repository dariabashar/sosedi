import '../models/chat.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final List<Chat> _chats = [];

  List<Chat> get chats => List.unmodifiable(_chats);

  // Создание или получение чата с пользователем
  Chat createOrGetChat({
    required String otherUserName,
    required String otherUserAddress,
  }) {
    // Ищем существующий чат
    final existingChat = _chats.firstWhere(
      (chat) => chat.otherUserName == otherUserName,
      orElse: () => Chat(
        id: '',
        otherUserName: '',
        otherUserAddress: '',
      ),
    );

    if (existingChat.id.isNotEmpty) {
      return existingChat;
    }

    // Создаем новый чат
    final newChat = Chat(
      id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
      otherUserName: otherUserName,
      otherUserAddress: otherUserAddress,
      lastMessage: null,
      lastMessageTime: null,
      hasUnreadMessages: false,
      unreadCount: 0,
    );

    _chats.insert(0, newChat);
    return newChat;
  }

  // Обновление чата
  void updateChat(Chat updatedChat) {
    final index = _chats.indexWhere((chat) => chat.id == updatedChat.id);
    if (index != -1) {
      _chats[index] = updatedChat;
      // Перемещаем обновленный чат в начало списка
      if (index != 0) {
        _chats.removeAt(index);
        _chats.insert(0, updatedChat);
      }
    }
  }

  // Инициализация демо данных
  void initializeDemoChats() {
    if (_chats.isEmpty) {
      _chats.addAll([
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
      ]);
    }
  }

  // Получить количество непрочитанных чатов
  int get unreadChatsCount {
    return _chats.where((chat) => chat.hasUnreadMessages).length;
  }
} 