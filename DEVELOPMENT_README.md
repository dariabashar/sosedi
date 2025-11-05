# Инструкции для разработки

## Включение/выключение функций

В файле `lib/features/auth/screens/main_app_screen.dart` есть переключатели для включения функций:

```dart
// ПЕРЕКЛЮЧАТЕЛИ ДЛЯ РАЗРАБОТКИ
static const bool _showFunctionalChats = false; // true для включения чатов
static const bool _showFunctionalAds = false; // true для включения объявлений
```

### Как включить чаты:
1. Измените `_showFunctionalChats = true`
2. Перезапустите приложение
3. Вкладка "Чаты" покажет полнофункциональные чаты

### Как включить объявления:
1. Измените `_showFunctionalAds = true`
2. Перезапустите приложение  
3. Раздел "Объявления" в "Доме" покажет полнофункциональные объявления

## Сохраненный код

Весь функциональный код сохранен:

### Чаты:
- `lib/features/chat/screens/chats_screen.dart` - список чатов
- `lib/features/chat/screens/chat_conversation_screen.dart` - экран переписки
- `lib/models/chat.dart` - модели чатов и сообщений
- `lib/services/chat_service.dart` - сервис управления чатами

### Объявления:
- `lib/features/marketplace/screens/advertisement_detail_screen.dart` - детальный просмотр
- `lib/features/marketplace/screens/create_advertisement_screen.dart` - создание объявлений
- `lib/models/advertisement.dart` - модель объявления

### Заглушки (текущие экраны):
- `lib/features/chat/screens/chats_placeholder_screen.dart`
- `lib/features/marketplace/screens/marketplace_placeholder_screen.dart`

## Быстрое включение всех функций

Для включения всех функций сразу:
```dart
static const bool _showFunctionalChats = true;
static const bool _showFunctionalAds = true;
```

Функции полностью протестированы и готовы к использованию! 