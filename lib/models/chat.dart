class Chat {
  final String id;
  final String otherUserName;
  final String otherUserAddress;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool hasUnreadMessages;
  final int unreadCount;

  const Chat({
    required this.id,
    required this.otherUserName,
    required this.otherUserAddress,
    this.lastMessage,
    this.lastMessageTime,
    this.hasUnreadMessages = false,
    this.unreadCount = 0,
  });

  Chat copyWith({
    String? id,
    String? otherUserName,
    String? otherUserAddress,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? hasUnreadMessages,
    int? unreadCount,
  }) {
    return Chat(
      id: id ?? this.id,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserAddress: otherUserAddress ?? this.otherUserAddress,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class Message {
  final String id;
  final String chatId;
  final String text;
  final bool isFromCurrentUser;
  final DateTime createdAt;
  final bool isRead;

  const Message({
    required this.id,
    required this.chatId,
    required this.text,
    required this.isFromCurrentUser,
    required this.createdAt,
    this.isRead = false,
  });

  Message copyWith({
    String? id,
    String? chatId,
    String? text,
    bool? isFromCurrentUser,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      text: text ?? this.text,
      isFromCurrentUser: isFromCurrentUser ?? this.isFromCurrentUser,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
} 