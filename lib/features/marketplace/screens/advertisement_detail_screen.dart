import 'package:flutter/material.dart';
import 'dart:io';
import '../../../models/advertisement.dart';
import '../../../services/chat_service.dart';
import '../../chat/screens/chat_conversation_screen.dart';

class AdvertisementDetailScreen extends StatefulWidget {
  final Advertisement advertisement;
  final VoidCallback? onContactSeller;

  const AdvertisementDetailScreen({
    super.key,
    required this.advertisement,
    this.onContactSeller,
  });

  @override
  State<AdvertisementDetailScreen> createState() => _AdvertisementDetailScreenState();
}

class _AdvertisementDetailScreenState extends State<AdvertisementDetailScreen> {

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'только что';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч назад';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн назад';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }

  String _getTypeDisplayName(String typeValue) {
    switch (typeValue) {
      case 'sale':
        return 'Продажа';
      case 'free':
        return 'Даром';
      default:
        return 'Неизвестно';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.advertisement;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // App Bar с фото
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Фото товара или placeholder
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey[100],
                    child: ad.imagePath != null && ad.imagePath!.startsWith('/')
                        ? Image.file(
                            File(ad.imagePath!),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Фото товара',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  // Градиент для читаемости текста
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Контент
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Основная информация
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Заголовок и тип
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ad.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: ad.type == 'free' 
                                    ? Colors.green[100] 
                                    : const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _getTypeDisplayName(ad.type),
                                style: TextStyle(
                                  color: ad.type == 'free' 
                                      ? Colors.green[700] 
                                      : const Color(0xFFFF6B6B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Цена
                        if (ad.price != null) ...[
                          Text(
                            '${ad.price} ₸',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B6B),
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'ДАРОМ',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // Описание
                        const Text(
                          'Описание',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ad.description,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // Информация о продавце
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Продавец',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey[300],
                              child: Text(
                                ad.authorName[0],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ad.authorName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    ad.authorAddress,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Опубликовано ${_getTimeAgo(ad.createdAt)}',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Отступ для кнопки
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Кнопка "Написать продавцу"
      bottomNavigationBar: Container(
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
               onPressed: () {
                 // Создаем или получаем чат с продавцом
                 final chatService = ChatService();
                 final chat = chatService.createOrGetChat(
                   otherUserName: ad.authorName,
                   otherUserAddress: ad.authorAddress,
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
                 
                 if (widget.onContactSeller != null) {
                   widget.onContactSeller!();
                 }
               },
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
                'Написать продавцу',
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
    );
  }
} 