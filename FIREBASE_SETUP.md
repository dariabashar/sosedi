# Настройка Firebase

## 🚀 Создание проекта Firebase

### 1. Создание проекта
1. Перейдите на [Firebase Console](https://console.firebase.google.com/)
2. Нажмите "Create a project"
3. Введите название: `sosedi-app`
4. Отключите Google Analytics (опционально)
5. Нажмите "Create project"

### 2. Настройка аутентификации
1. В меню слева выберите "Authentication"
2. Нажмите "Get started"
3. Перейдите на вкладку "Sign-in method"
4. Включите "Phone" (для SMS аутентификации)
5. Нажмите "Save"

### 3. Создание веб-приложения
1. На главной странице нажмите "Web" (</>)
2. Введите название: `sosedi-web`
3. Нажмите "Register app"
4. Скопируйте конфигурацию

### 4. Получение Service Account Key
1. В настройках проекта (шестеренка) выберите "Project settings"
2. Перейдите на вкладку "Service accounts"
3. Нажмите "Generate new private key"
4. Скачайте JSON файл

## 🔧 Настройка в проекте

### 1. Обновить .env файл
```bash
# Добавить в .env (замените на ваши значения)
FIREBASE_PROJECT_ID=sosedi-app
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@sosedi-app.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your-client-id
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token
FIREBASE_AUTH_PROVIDER_X509_CERT_URL=https://www.googleapis.com/oauth2/v1/certs
FIREBASE_CLIENT_X509_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40sosedi-app.iam.gserviceaccount.com
```

### 2. Обновить Flutter приложение
В `lib/firebase_options.dart`:
```dart
// Обновите конфигурацию Firebase
static const FirebaseOptions currentPlatform = FirebaseOptions(
  apiKey: 'your-api-key',
  appId: 'your-app-id',
  messagingSenderId: 'your-sender-id',
  projectId: 'sosedi-app',
  // ... остальные параметры
);
```

## 🧪 Тестирование аутентификации

### 1. Тест в Flutter
```dart
// В любом виджете
ElevatedButton(
  onPressed: () async {
    try {
      // Отправить SMS код
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+7 999 123-45-67',
        verificationCompleted: (PhoneAuthCredential credential) {
          // Автоматическая верификация
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Error: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          // Код отправлен
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Таймаут
        },
      );
    } catch (e) {
      print('Error: $e');
    }
  },
  child: Text('Send SMS Code'),
)
```

### 2. Тест в бэкенде
```bash
# Получить токен из Flutter и проверить в бэкенде
curl -X POST http://localhost:3000/api/users/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_FIREBASE_ID_TOKEN" \
  -d '{
    "firstName": "Иван",
    "lastName": "Иванов",
    "phoneNumber": "+7 999 123-45-67"
  }'
```

## 🔒 Правила безопасности

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Пользователи могут читать/писать только свои данные
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Посты доступны всем аутентифицированным пользователям
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == resource.data.authorId;
    }
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Пользователи могут загружать файлы в свою папку
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Публичные изображения доступны всем
    match /public/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 📱 Интеграция с Flutter

### 1. Обновить pubspec.yaml
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  firebase_messaging: ^14.7.10
```

### 2. Инициализация в main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SosediApp());
}
```

### 3. Аутентификация пользователя
```dart
class AuthService {
  static Future<UserCredential?> signInWithPhone(
    String phoneNumber,
    String verificationId,
    String smsCode,
  ) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }
  
  static Future<String?> getIdToken() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }
}
```

## 🚨 Устранение проблем

### Ошибка аутентификации:
- Проверьте номер телефона
- Убедитесь, что SMS аутентификация включена
- Проверьте конфигурацию Firebase

### Ошибка подключения:
- Проверьте интернет соединение
- Убедитесь, что проект создан правильно
- Проверьте API ключи

## 📈 Мониторинг

### В Firebase Console:
- Authentication > Users
- Analytics > Events
- Performance > Monitoring
- Crashlytics > Crashes 