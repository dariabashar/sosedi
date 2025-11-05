# 🔗 Интеграция Flutter с Node.js Backend

## 📋 Что нужно сделать:

### **1. Обновить URL в Flutter приложении**

В файле `lib/services/api_service.dart` (создайте, если не существует):

```dart
class ApiService {
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
  
  // Получить токен из Firebase
  static Future<String?> _getFirebaseToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
    } catch (e) {
      print('Error getting Firebase token: $e');
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
}
```

### **2. Добавить HTTP зависимость**

В `pubspec.yaml` добавьте:

```yaml
dependencies:
  http: ^1.1.0
```

Затем выполните:
```bash
flutter pub get
```

### **3. Обновить экраны**

Пример обновления экрана постов:

```dart
class PostsScreen extends StatefulWidget {
  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<dynamic> posts = [];
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadPosts();
  }
  
  Future<void> _loadPosts() async {
    setState(() => isLoading = true);
    
    try {
      final postsData = await ApiService.getNearbyPosts();
      setState(() {
        posts = postsData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки постов: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Лента района')),
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(post['text'] ?? ''),
                      subtitle: Text(post['createdAt'] ?? ''),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createPost(),
        child: Icon(Icons.add),
      ),
    );
  }
  
  Future<void> _createPost() async {
    // Показать диалог создания поста
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Новый пост'),
        content: TextField(
          decoration: InputDecoration(hintText: 'Что у вас нового?'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Текст поста'),
            child: Text('Опубликовать'),
          ),
        ],
      ),
    );
    
    if (text != null && text.isNotEmpty) {
      try {
        await ApiService.createPost(text: text);
        _loadPosts(); // Перезагрузить посты
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Пост опубликован!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }
}
```

### **4. Настройка для мобильных устройств**

Для тестирования на физическом устройстве измените URL:

```dart
// Для эмулятора Android
static const String baseUrl = 'http://10.0.2.2:3000/api';

// Для физического устройства (замените на IP вашего компьютера)
static const String baseUrl = 'http://192.168.1.100:3000/api';
```

### **5. Проверка подключения**

Добавьте в `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Проверить подключение к бэкенду
  final isBackendAvailable = await ApiService.checkHealth();
  print('Backend available: $isBackendAvailable');
  
  runApp(MyApp());
}
```

## 🚀 Готово!

Теперь ваше Flutter приложение будет работать с Node.js бэкендом!

**Следующие шаги:**
1. Создайте `ApiService` класс
2. Обновите экраны для использования API
3. Протестируйте интеграцию 