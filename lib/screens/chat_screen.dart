import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String participantName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.participantName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  WebSocketChannel? _channel;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToChat();
    _loadMessages();
  }

  void _connectToChat() {
    try {
      // Подключаемся к WebSocket серверу
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:3000'),
      );

      _channel!.stream.listen(
        (data) {
          final message = json.decode(data);
          if (message['type'] == 'chat_message' && 
              message['chatId'] == widget.chatId) {
            setState(() {
              _messages.add(ChatMessage(
                id: message['id'],
                text: message['text'],
                senderId: message['senderId'],
                senderName: message['senderName'],
                timestamp: DateTime.parse(message['timestamp']),
                isMe: message['senderId'] == 'current_user', // Временно
              ));
            });
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          setState(() => _isConnected = false);
        },
        onDone: () {
          print('WebSocket connection closed');
          setState(() => _isConnected = false);
        },
      );

      setState(() => _isConnected = true);
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      setState(() => _isConnected = false);
    }
  }

  Future<void> _loadMessages() async {
    try {
      // Загружаем историю сообщений
      final messages = await ApiService.getChatMessages(widget.chatId);
      setState(() {
        _messages.clear();
        _messages.addAll(messages.map((msg) => ChatMessage(
          id: msg['id'],
          text: msg['text'],
          senderId: msg['senderId'],
          senderName: msg['senderName'],
          timestamp: DateTime.parse(msg['timestamp']),
          isMe: msg['senderId'] == 'current_user', // Временно
        )));
      });
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = {
      'type': 'chat_message',
      'chatId': widget.chatId,
      'text': _messageController.text.trim(),
      'senderId': 'current_user', // Временно
      'senderName': 'Вы',
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Отправляем через WebSocket
    if (_channel != null) {
      _channel!.sink.add(json.encode(message));
    }

    // Добавляем локально
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: _messageController.text.trim(),
        senderId: 'current_user',
        senderName: 'Вы',
        timestamp: DateTime.now(),
        isMe: true,
      ));
    });

    _messageController.clear();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                widget.participantName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.participantName),
                Text(
                  _isConnected ? 'Онлайн' : 'Офлайн',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isConnected ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Меню чата
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Сообщения
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'Начните разговор!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[_messages.length - 1 - index];
                      return MessageBubble(message: message);
                    },
                  ),
          ),
          // Поле ввода
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Введите сообщение...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: message.isMe
              ? Theme.of(context).primaryColor
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isMe)
              Text(
                message.senderName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            Text(
              message.text,
              style: TextStyle(
                color: message.isMe ? Colors.white : Colors.black,
              ),
            ),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: message.isMe 
                    ? Colors.white.withOpacity(0.7)
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    required this.isMe,
  });
} 