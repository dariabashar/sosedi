import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  // URL для локальной разработки
  static const String baseUrl = 'http://localhost:3000/api';
  
  // HTTP клиент
  static final http.Client _client = http.Client();
  
  // Headers для аутентификации
  static Map<String, String> _getHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  // Получение Firebase токена для аутентификации
  static Future<String?> _getFirebaseToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        return token;
      }
    } catch (e) {
      print('Error getting Firebase token: $e');
      // Возвращаем null если Firebase не работает
    }
    return null;
  }
  
  // Health check
  static Future<bool> checkHealth() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }
  
  // Пользователи
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final token = await _getFirebaseToken();
      final response = await _client.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: _getHeaders(token),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error getting user profile: $e');
    }
    return null;
  }
  
  static Future<Map<String, dynamic>?> createUser({
    required String firstName,
    required String lastName,
    required String address,
  }) async {
    try {
      final token = await _getFirebaseToken();
      final response = await _client.post(
        Uri.parse('$baseUrl/users'),
        headers: _getHeaders(token),
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'address': address,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error creating user: $e');
    }
    return null;
  }
  
  // Посты
  static Future<List<dynamic>> getNearbyPosts() async {
    try {
      final token = await _getFirebaseToken();
      final response = await _client.get(
        Uri.parse('$baseUrl/posts/nearby'),
        headers: _getHeaders(token),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print('Error getting posts: $e');
    }
    return [];
  }
  
  static Future<Map<String, dynamic>?> createPost({
    required String text,
    String? imagePath,
    Map<String, dynamic>? location,
  }) async {
    try {
      final token = await _getFirebaseToken();
      final response = await _client.post(
        Uri.parse('$baseUrl/posts'),
        headers: _getHeaders(token),
        body: json.encode({
          'text': text,
          'imagePath': imagePath,
          'location': location,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error creating post: $e');
    }
    return null;
  }
  
  // Группы
  static Future<List<dynamic>> getNearbyGroups() async {
    try {
      final token = await _getFirebaseToken();
      final response = await _client.get(
        Uri.parse('$baseUrl/groups/nearby'),
        headers: _getHeaders(token),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print('Error getting groups: $e');
    }
    return [];
  }
  
  static Future<Map<String, dynamic>?> createGroup({
    required String name,
    required String description,
    Map<String, dynamic>? location,
  }) async {
    try {
      final token = await _getFirebaseToken();
      final response = await _client.post(
        Uri.parse('$baseUrl/groups'),
        headers: _getHeaders(token),
        body: json.encode({
          'name': name,
          'description': description,
          'location': location,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error creating group: $e');
    }
    return null;
  }
  
  // Объявления
  static Future<List<dynamic>> getNearbyAdvertisements() async {
    try {
      final token = await _getFirebaseToken();
      final response = await _client.get(
        Uri.parse('$baseUrl/advertisements/nearby'),
        headers: _getHeaders(token),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print('Error getting advertisements: $e');
    }
    return [];
  }
  
  static Future<Map<String, dynamic>?> createAdvertisement({
    required String title,
    required String description,
    required String type,
    double? price,
    String? imagePath,
    Map<String, dynamic>? location,
  }) async {
    try {
      final token = await _getFirebaseToken();
      final response = await _client.post(
        Uri.parse('$baseUrl/advertisements'),
        headers: _getHeaders(token),
        body: json.encode({
          'title': title,
          'description': description,
          'type': type,
          'price': price,
          'imagePath': imagePath,
          'location': location,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error creating advertisement: $e');
    }
    return null;
  }
  
  // События
  static Future<List<dynamic>> getNearbyEvents() async {
    try {
      final token = await _getFirebaseToken();
      final response = await _client.get(
        Uri.parse('$baseUrl/events/nearby'),
        headers: _getHeaders(token),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print('Error getting events: $e');
    }
    return [];
  }
  
  static Future<Map<String, dynamic>?> createEvent({
    required String title,
    required DateTime date,
    required String location,
    String? description,
  }) async {
    try {
      final token = await _getFirebaseToken();
      final response = await _client.post(
        Uri.parse('$baseUrl/events'),
        headers: _getHeaders(token),
        body: json.encode({
          'title': title,
          'date': date.toIso8601String(),
          'location': location,
          'description': description,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error creating event: $e');
    }
    return null;
  }
  
  // Чаты
  static Future<List<dynamic>> getUserChats() async {
    try {
      final token = await _getFirebaseToken();
      final response = await _client.get(
        Uri.parse('$baseUrl/chats'),
        headers: _getHeaders(token),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print('Error getting chats: $e');
    }
    return [];
  }
  
  static Future<Map<String, dynamic>?> sendMessage({
    required String participantId,
    required String message,
  }) async {
    try {
      final token = await _getFirebaseToken();
      final response = await _client.post(
        Uri.parse('$baseUrl/chats'),
        headers: _getHeaders(token),
        body: json.encode({
          'participantId': participantId,
          'message': message,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error sending message: $e');
    }
    return null;
  }

  // Получить сообщения чата
  static Future<List<dynamic>> getChatMessages(String chatId) async {
    try {
      final token = await _getFirebaseToken();
      final response = await _client.get(
        Uri.parse('$baseUrl/chats/$chatId/messages'),
        headers: _getHeaders(token),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
    } catch (e) {
      print('Error getting chat messages: $e');
    }
    return [];
  }

  // Создать новый чат
  static Future<Map<String, dynamic>?> createChat({
    required String participantId,
    String? initialMessage,
  }) async {
    try {
      final token = await _getFirebaseToken();
      final response = await _client.post(
        Uri.parse('$baseUrl/chats/create'),
        headers: _getHeaders(token),
        body: json.encode({
          'participantId': participantId,
          'initialMessage': initialMessage,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error creating chat: $e');
    }
    return null;
  }
} 