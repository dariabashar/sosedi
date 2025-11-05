import 'package:flutter/material.dart';
import '../../../services/chat_service.dart';
import '../../chat/screens/chat_conversation_screen.dart';

class UserProfileScreen extends StatelessWidget {
  final String userName;
  final String userAddress;
  final String? context; // откуда пришли - "объявление", "пост" и т.д.

  const UserProfileScreen({
    super.key,
    required this.userName,
    required this.userAddress,
    this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Профиль соседа',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Информация о пользователе
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    userName[0],
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      userAddress,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (this.context != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Автор ${this.context}',
                      style: const TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Информация о соседе
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'О соседе',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoItem(
                  Icons.home,
                  'Проживает в районе',
                  _getDistrictFromAddress(userAddress),
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  Icons.access_time,
                  'На платформе',
                  'Около месяца',
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                  Icons.star,
                  'Рейтинг соседа',
                  '4.8 ★★★★★',
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Кнопка написать
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _startChat(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.message,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Написать соседу',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDistrictFromAddress(String address) {
    // Простая логика извлечения района из адреса
    if (address.contains('ул. Ленина')) {
      return 'Центральный район';
    } else if (address.contains('ул. Советская')) {
      return 'Советский район';
    } else if (address.contains('ул. Мира')) {
      return 'Мирный район';
    } else {
      return 'Жилой район';
    }
  }

  void _startChat(BuildContext context) {
    // Создаем или получаем чат с пользователем
    final chatService = ChatService();
    final chat = chatService.createOrGetChat(
      otherUserName: userName,
      otherUserAddress: userAddress,
    );
    
    // Переходим в чат
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatConversationScreen(
          chat: chat,
          onChatUpdated: (updatedChat) {
            chatService.updateChat(updatedChat);
          },
        ),
      ),
    );
  }
} 