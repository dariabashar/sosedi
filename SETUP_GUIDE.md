# 🚀 Полная настройка Sosedi Backend

## 📋 Что у нас есть

✅ **Работающий Node.js сервер** с API endpoints  
✅ **Документация** по настройке MongoDB и Firebase  
✅ **Готовые модели данных** для всех функций приложения  
✅ **Геолокационные запросы** для поиска поблизости  

## 🗄️ Шаг 1: Настройка MongoDB Atlas

### 1.1 Создание аккаунта
1. Перейдите на [MongoDB Atlas](https://www.mongodb.com/atlas)
2. Нажмите "Try Free"
3. Заполните форму регистрации

### 1.2 Создание кластера
1. Выберите "Build a Database"
2. Выберите "FREE" план (M0)
3. Выберите провайдера (AWS/Google Cloud/Azure)
4. Выберите регион (ближайший к вам)
5. Нажмите "Create"

### 1.3 Настройка безопасности
1. **Database Access** - создайте пользователя:
   - Username: `sosedi_admin`
   - Password: `your_secure_password`
   - Role: `Atlas admin`

2. **Network Access** - разрешите доступ:
   - Нажмите "Add IP Address"
   - Выберите "Allow Access from Anywhere" (0.0.0.0/0)

### 1.4 Получение строки подключения
1. Нажмите "Connect"
2. Выберите "Connect your application"
3. Скопируйте строку подключения

## 🔥 Шаг 2: Настройка Firebase

### 2.1 Создание проекта
1. Перейдите на [Firebase Console](https://console.firebase.google.com/)
2. Нажмите "Create a project"
3. Введите название: `sosedi-app`
4. Отключите Google Analytics (опционально)
5. Нажмите "Create project"

### 2.2 Настройка аутентификации
1. В меню слева выберите "Authentication"
2. Нажмите "Get started"
3. Перейдите на вкладку "Sign-in method"
4. Включите "Phone" (для SMS аутентификации)
5. Нажмите "Save"

### 2.3 Получение Service Account Key
1. В настройках проекта (шестеренка) выберите "Project settings"
2. Перейдите на вкладку "Service accounts"
3. Нажмите "Generate new private key"
4. Скачайте JSON файл

## ⚙️ Шаг 3: Настройка проекта

### 3.1 Обновить .env файл
```bash
# Скопируйте env.example
cp env.example .env

# Отредактируйте .env с вашими данными
nano .env
```

Содержимое `.env`:
```env
# Server Configuration
PORT=3000
NODE_ENV=development

# MongoDB Configuration (замените на вашу строку подключения)
MONGODB_URI=mongodb+srv://sosedi_admin:your_password@cluster0.xxxxx.mongodb.net/sosedi?retryWrites=true&w=majority

# Firebase Configuration (замените на ваши данные из JSON файла)
FIREBASE_PROJECT_ID=sosedi-app
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@sosedi-app.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your-client-id
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token
FIREBASE_AUTH_PROVIDER_X509_CERT_URL=https://www.googleapis.com/oauth2/v1/certs
FIREBASE_CLIENT_X509_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40sosedi-app.iam.gserviceaccount.com

# File Upload Configuration
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=5242880
```

### 3.2 Запуск сервера
```bash
# Простой режим (без базы данных)
node working-server.js

# Полный режим (с MongoDB и Firebase)
node src/server.js
```

## 🧪 Шаг 4: Тестирование

### 4.1 Проверка здоровья сервера
```bash
curl http://localhost:3000/api/health
```

Ожидаемый ответ:
```json
{
  "success": true,
  "message": "Sosedi API is running (Full Mode)",
  "timestamp": "2025-07-31T14:00:00.000Z",
  "database": "connected",
  "firebase": "configured"
}
```

### 4.2 Создание пользователя
```bash
curl -X POST http://localhost:3000/api/users/profile \
  -H "Content-Type: application/json" \
  -d '{
    "firebaseUid": "test_user_123",
    "firstName": "Иван",
    "lastName": "Иванов",
    "phoneNumber": "+7 999 123-45-67",
    "address": "ул. Ленина, 1",
    "location": {
      "type": "Point",
      "coordinates": [37.6176, 55.7558]
    }
  }'
```

### 4.3 Создание поста
```bash
curl -X POST http://localhost:3000/api/posts \
  -H "Content-Type: application/json" \
  -d '{
    "authorId": "test_user_123",
    "text": "Привет, соседи! Кто знает, где можно купить хороший хлеб?",
    "location": {
      "type": "Point",
      "coordinates": [37.6176, 55.7558]
    }
  }'
```

### 4.4 Поиск постов поблизости
```bash
curl "http://localhost:3000/api/posts?lat=55.7558&lng=37.6176&radius=1000"
```

## 📱 Шаг 5: Интеграция с Flutter

### 5.1 Обновить URL API
В Flutter приложении обновить URL:
```dart
const String baseUrl = 'http://localhost:3000/api';
```

### 5.2 Обновить Firebase конфигурацию
В `lib/firebase_options.dart`:
```dart
static const FirebaseOptions currentPlatform = FirebaseOptions(
  apiKey: 'your-api-key',
  appId: 'your-app-id',
  messagingSenderId: 'your-sender-id',
  projectId: 'sosedi-app',
  // ... остальные параметры
);
```

### 5.3 Пример использования в Flutter
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Получить посты поблизости
  static Future<List<dynamic>> getNearbyPosts(double lat, double lng) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts?lat=$lat&lng=$lng&radius=1000')
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load posts');
    }
  }
  
  // Создать пост
  static Future<Map<String, dynamic>> createPost(String authorId, String text, Map<String, dynamic> location) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'authorId': authorId,
        'text': text,
        'location': location,
      }),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create post');
    }
  }
}
```

## 🔧 Доступные API Endpoints

### Пользователи
- `GET /api/users` - получить всех пользователей
- `POST /api/users/profile` - создать/обновить профиль

### Посты
- `GET /api/posts` - получить посты (с фильтрацией по геолокации)
- `POST /api/posts` - создать новый пост

### Группы
- `GET /api/groups` - получить группы (с фильтрацией по геолокации)
- `POST /api/groups` - создать новую группу

### Объявления
- `GET /api/advertisements` - получить объявления (с фильтрацией)
- `POST /api/advertisements` - создать новое объявление

### События
- `GET /api/events` - получить события (с фильтрацией по геолокации)
- `POST /api/events` - создать новое событие

### Чаты
- `GET /api/chats` - получить чаты пользователя
- `POST /api/chats/private` - создать приватный чат

## 🚨 Устранение проблем

### MongoDB не подключается:
- Проверьте строку подключения в .env
- Убедитесь, что IP адрес добавлен в Network Access
- Проверьте username/password

### Firebase не работает:
- Проверьте Service Account Key
- Убедитесь, что все переменные окружения заполнены
- Проверьте права доступа в Firebase Console

### Сервер не запускается:
- Проверьте, что все зависимости установлены: `npm install`
- Проверьте синтаксис .env файла
- Убедитесь, что порт 3000 свободен

## 🎯 Результат

После выполнения всех шагов у вас будет:

✅ **Полнофункциональный бэкенд** с MongoDB и Firebase  
✅ **API для всех функций** приложения "Соседи"  
✅ **Геолокационные запросы** для поиска контента поблизости  
✅ **Готовность к интеграции** с Flutter приложением  
✅ **Масштабируемая архитектура** для дальнейшего развития  

**Следующий шаг:** Интегрировать с Flutter приложением и протестировать все функции! 