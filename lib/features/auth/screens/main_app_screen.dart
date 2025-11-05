import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../../../models/post.dart';
import '../../../models/event.dart';
import '../../../models/advertisement.dart';
import 'create_post_screen.dart';
import '../../events/screens/create_event_screen.dart';
import '../../marketplace/screens/create_advertisement_screen.dart';
import '../../marketplace/screens/advertisement_detail_screen.dart';
import '../../chat/screens/chats_placeholder_screen.dart';
import '../../chat/screens/chats_screen.dart';
import '../../../screens/chats_list_screen.dart';
import '../../profile/screens/user_profile_screen.dart';
import '../../marketplace/screens/marketplace_placeholder_screen.dart';
import '../../../screens/advertisements_screen.dart';
import '../../groups/screens/groups_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../../services/notification_service.dart';
import '../../../services/user_service.dart';
import '../blocs/auth_cubit.dart';
import 'auth_wrapper_screen.dart';


class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;
  final NotificationService _notificationService = NotificationService();
  final UserService _userService = UserService();
  
  // ПЕРЕКЛЮЧАТЕЛИ ДЛЯ РАЗРАБОТКИ
  static const bool _showFunctionalChats = true; // true для включения чатов

  final List<Widget> _screens = [
    const FeedScreen(), // Дом (с подразделами)
    _showFunctionalChats 
        ? const ChatsListScreen() 
        : const ChatsPlaceholderScreen(), // Чаты
    const NotificationsScreen(), // Уведомления
    const ProfileScreen(), // Профиль
  ];

  @override
  void initState() {
    super.initState();
    // Устанавливаем демо пользователя при первом запуске
    if (!_userService.isLoggedIn) {
      _userService.setDemoUser();
    }
    _notificationService.initializeDemoData();
  }

  Widget _buildNotificationIcon({required bool isSelected}) {
    final unreadCount = _notificationService.unreadCount;
    
    return Stack(
      children: [
        Icon(
          isSelected ? Icons.notifications : Icons.notifications_outlined,
        ),
        if (unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
              child: Text(
                unreadCount > 9 ? '9+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  // Метод для создания уведомления о событии (будет использоваться из FeedScreen)
  void _createEventNotification(String eventTitle, DateTime eventTime) {
    _notificationService.notifyEventReminder(eventTitle, eventTime);
    if (mounted) setState(() {});
  }

  // Метод для создания уведомления о новом посте в группе
  void _createGroupPostNotification(String groupName, String authorName, String postText) {
    _notificationService.notifyGroupPost(groupName, authorName, postText);
    if (mounted) setState(() {});
  }

  // Метод для создания уведомления о комментарии
  void _createCommentNotification(String authorName, String commentText) {
    _notificationService.notifyPostComment(authorName, commentText);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
            });
            // Обновить счетчик уведомлений при переходе на любую вкладку
            if (mounted) {
              setState(() {});
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFFF6B6B),
          unselectedItemColor: Colors.grey,
          elevation: 0,
                               items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildNotificationIcon(isSelected: false),
              activeIcon: _buildNotificationIcon(isSelected: true),
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: '',
            ),
          ],
        ),
      ),
         );
   }
 }

// Экран профиля
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> _userAddresses = [];
  final UserService _userService = UserService();
  
  @override
  void initState() {
    super.initState();
    // Устанавливаем демо пользователя при первом запуске
    if (!_userService.isLoggedIn) {
      _userService.setDemoUser();
    }
  }

  void _addNewAddress() {
    // Показываем простое сообщение вместо экрана 2GIS
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Функция добавления адреса будет доступна в следующем обновлении'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text(
          'Вы уверены, что хотите выйти из аккаунта? '
          'Вам потребуется снова войти в систему.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      // Вызываем выход через AuthCubit
      context.read<AuthCubit>().signOut();
      
      // Очищаем локальные данные пользователя
      _userService.clearCurrentUser();
      
      // Показываем сообщение об успешном выходе
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вы успешно вышли из аккаунта'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Перенаправляем на экран авторизации через AuthWrapperScreen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const AuthWrapperScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при выходе: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        const Icon(Icons.edit, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _userService.currentUserName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Address section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Мои дома',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _addNewAddress,
                          icon: const Icon(
                            Icons.add,
                            color: Color(0xFFFF6B6B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (_userAddresses.isEmpty) ...[
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.home_outlined,
                              size: 60,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'У вас пока нет добавленных домов',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Добавьте свой первый дом для участия\nв жизни района',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _addNewAddress,
                              icon: const Icon(Icons.add),
                              label: const Text('Добавить новый дом'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B6B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      for (int i = 0; i < _userAddresses.length; i++) ...[
                        _buildAddressItem(
                          _userAddresses[i]['address'],
                          _userAddresses[i]['label'],
                          _userAddresses[i]['isMain'] ?? false,
                        ),
                        if (i < _userAddresses.length - 1) const SizedBox(height: 12),
                      ],
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Кнопка для демонстрации уведомлений
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Настройки',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Кнопка выхода
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      title: const Text(
                        'Выйти из аккаунта',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 16,
                      ),
                      onTap: () => _showLogoutDialog(context),
                    ),
                    
                    // Кнопка тестирования Firebase (только для разработки)
                    ListTile(
                      leading: const Icon(
                        Icons.bug_report,
                        color: Colors.orange,
                      ),
                      title: const Text(
                        'Тест Firebase',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 16,
                      ),
                      onTap: () {
                        // Показываем простое сообщение вместо тестового экрана
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Firebase подключен и работает'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              


              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildAddressItem(String address, String label, bool isMain) {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          color: isMain ? const Color(0xFFFF6B6B) : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (isMain)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Активный',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }


}

// Экран ленты постов соседей
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _selectedTab = 0;
  List<Post> _posts = [];
  final String _currentUserId = 'current_user_id';
  final UserService _userService = UserService();
  
  // ПЕРЕКЛЮЧАТЕЛИ ДЛЯ РАЗРАБОТКИ
  static const bool _showFunctionalAds = true; // true для включения объявлений
  
  // События
  int _selectedEventsTab = 0; // 0 - все события, 1 - мои события
  Set<String> _myEvents = {}; // ID событий, в которых участвует пользователь
  List<Event> _events = [];
  
  // Объявления  
  List<Advertisement> _advertisements = [];
  String? _selectedAdType; // null - все, 'sale' - продажа, 'free' - даром
  String _searchQuery = ''; // строка поиска
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Дом',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filter tabs
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedTab == 0 ? const Color(0xFFFF6B6B) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Лента',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _selectedTab == 0 ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedTab == 1 ? const Color(0xFFFF6B6B) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'События',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _selectedTab == 1 ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedTab == 2 ? const Color(0xFFFF6B6B) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Объявления',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _selectedTab == 2 ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 3),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedTab == 3 ? const Color(0xFFFF6B6B) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Группы',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _selectedTab == 3 ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedTab != 3) ...[
                    const SizedBox(height: 16),
                    // Publish button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _getPublishButtonAction(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          _getPublishButtonText(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Content based on selected tab
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  void _openCreatePost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(
          onPostCreated: _addNewPost,
        ),
      ),
    );
  }

  void _openCreateEvent() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateEventScreen(
          onEventCreated: _addNewEvent,
        ),
      ),
    );
  }

  void _openCreateAdvertisement() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateAdvertisementScreen(
          onAdvertisementCreated: _addNewAdvertisement,
        ),
      ),
    );
  }

  VoidCallback? _getPublishButtonAction() {
    switch (_selectedTab) {
      case 0: return _openCreatePost;
      case 1: return _openCreateEvent;
      case 2: return _showFunctionalAds ? _openCreateAdvertisement : _showPlaceholderMessage;
      case 3: return _showPlaceholderMessage; // Группы открываются из своего экрана
      default: return null;
    }
  }

  void _showPlaceholderMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Раздел находится в разработке'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _addNewPost(String text, String? imagePath) {
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: _userService.currentUserName,
      authorAddress: 'ул. Ленина, д. 5, кв. 32', // TODO: Использовать реальный адрес пользователя
      text: text,
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );

    setState(() {
      _posts.insert(0, newPost); // Добавляем в начало списка
    });
  }

  void _addNewEvent(String title, String date, String location, String? description, String? imagePath, String? videoPath) {
    final newEvent = Event(
      id: 'event_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      date: date,
      location: location,
      participantCount: 0, // Начальное количество участников
      description: description,
      imageUrl: imagePath, // В реальном приложении здесь был бы URL после загрузки
      videoUrl: videoPath, // В реальном приложении здесь был бы URL после загрузки
    );

    setState(() {
      _events.insert(0, newEvent); // Добавляем в начало списка
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Событие успешно создано!'),
        backgroundColor: Color(0xFFFF6B6B),
      ),
    );
  }

  void _addNewAdvertisement(Advertisement advertisement) {
    setState(() {
      _advertisements.insert(0, advertisement); // Добавляем в начало списка
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Объявление успешно создано!'),
        backgroundColor: Color(0xFFFF6B6B),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Добавляем демонстрационный пост с комментариями
    _posts.add(
      Post(
        id: 'demo_post_1',
        authorName: 'Мария Петрова',
        authorAddress: 'ул. Пушкина, д. 15, кв. 42',
        text: 'Добрый день, соседи! Завтра планирую устроить барбекю во дворе. Кто хочет присоединиться? Приносите что-нибудь вкусное! 🔥',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likedBy: ['user1', 'user2'],
        comments: [
          Comment(
            id: 'comment_1',
            authorName: 'Сергей Иванов',
            text: 'Отличная идея! Я принесу шашлык',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          Comment(
            id: 'comment_2',
            authorName: 'Анна Сидорова',
            text: 'А я салат приготовлю! 🥗',
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ],
      ),
    );

    // Инициализируем демонстрационные события
    _events = [
      Event(
        id: 'event_1',
        title: 'Музыкальный вечер',
        date: '20 ноября 19:00',
        location: 'Парк Горького',
        participantCount: 45,
        description: 'Приглашаем всех любителей музыки на уютный вечер под звездами. Будут выступать местные музыканты, можно будет послушать живую музыку разных жанров.',
        imageUrl: 'https://example.com/music_event.jpg',
      ),
      Event(
        id: 'event_2',
        title: 'Кулинарный мастер-класс',
        date: '21 ноября 14:00',
        location: 'Кулинарная студия ВкуС',
        participantCount: 30,
        description: 'Научимся готовить традиционные русские блюда. В программе: борщ, блины, пельмени. Все ингредиенты предоставляются.',
        imageUrl: 'https://example.com/cooking_class.jpg',
      ),
      Event(
        id: 'event_3',
        title: 'Фестиваль уличной еды',
        date: '22 ноября 12:00',
        location: 'Центральная площадь',
        participantCount: 100,
        description: 'Большой фестиваль с участием лучших фудтраков города. Попробуйте блюда разных кухонь мира по доступным ценам.',
        videoUrl: 'https://example.com/food_festival.mp4',
      ),
      Event(
        id: 'event_4',
        title: 'Вечер настольных игр',
        date: '23 ноября 18:00',
        location: 'Антикафе "Игроман"',
        participantCount: 25,
        description: 'Собираемся для игры в различные настольные игры. Подходит для всех возрастов. Игры предоставляются, можно принести свои.',
      ),
      Event(
        id: 'event_5',
        title: 'Занятие по йоге',
        date: '24 ноября 08:00',
        location: 'Парк у дома 15',
        participantCount: 15,
        description: 'Утренняя йога на свежем воздухе. Подходит для начинающих. Принесите коврик для йоги.',
        imageUrl: 'https://example.com/yoga_class.jpg',
      ),
    ];

    // Инициализируем демонстрационные объявления
    _advertisements = [
      Advertisement(
        id: 'ad_1',
        title: 'iPhone 13 Pro 128GB',
        description: 'Продаю iPhone 13 Pro в отличном состоянии. Покупался год назад, всегда использовался с чехлом и защитным стеклом. В комплекте оригинальная коробка, зарядное устройство.',
        type: 'sale',
        authorName: 'Анна Петрова',
        authorAddress: 'ул. Советская, д. 12, кв. 45',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        price: '75000',
      ),
      Advertisement(
        id: 'ad_2',
        title: 'Детская кроватка',
        description: 'Отдам даром детскую кроватку. Ребенок вырос, кроватка больше не нужна. В хорошем состоянии, есть матрас.',
        type: 'free',
        authorName: 'Мария Иванова',
        authorAddress: 'ул. Ленина, д. 8, кв. 21',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Advertisement(
        id: 'ad_3',
        title: 'Диван угловой серый',
        description: 'Продаю угловой диван в хорошем состоянии. Размер 240x160 см. Обивка из качественной ткани, каркас деревянный. Очень удобный для семьи.',
        type: 'sale',
        authorName: 'Дмитрий Сидоров',
        authorAddress: 'ул. Мира, д. 3, кв. 67',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        price: '25000',
      ),
      Advertisement(
        id: 'ad_4',
        title: 'Книги по программированию',
        description: 'Отдам учебники по программированию: "JavaScript. Подробное руководство", "Python для начинающих", "Алгоритмы и структуры данных". Все книги в отличном состоянии.',
        type: 'free',
        authorName: 'Алексей Николаев',
        authorAddress: 'ул. Гагарина, д. 15, кв. 89',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Advertisement(
        id: 'ad_5',
        title: 'Велосипед горный Trek',
        description: 'Продаю горный велосипед Trek в отличном состоянии. Колеса 26 дюймов, 21 скорость. Недавно проводилось техническое обслуживание.',
        type: 'sale',
        authorName: 'Сергей Романов',
        authorAddress: 'ул. Спортивная, д. 7, кв. 12',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        price: '18000',
      ),
      Advertisement(
        id: 'ad_6',
        title: 'Стиральная машина Bosch',
        description: 'Продаю стиральную машину Bosch в рабочем состоянии. Использовалась 3 года, но работает идеально. Загрузка 6 кг.',
        type: 'sale',
        authorName: 'Екатерина Волкова',
        authorAddress: 'ул. Пушкина, д. 22, кв. 15',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        price: '35000',
      ),
      Advertisement(
        id: 'ad_7',
        title: 'Учебники 9 класс',
        description: 'Отдам даром учебники за 9 класс: математика, физика, химия, русский язык, история. Все в хорошем состоянии.',
        type: 'free',
        authorName: 'Ольга Морозова',
        authorAddress: 'ул. Школьная, д. 1, кв. 33',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Advertisement(
        id: 'ad_8',
        title: 'Игровая приставка PlayStation 4',
        description: 'Продаю PS4 с двумя геймпадами и 5 играми. Состояние отличное, редко использовалась.',
        type: 'sale',
        authorName: 'Максим Козлов',
        authorAddress: 'ул. Гагарина, д. 9, кв. 78',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        price: '22000',
      ),
    ];
  }

  void _toggleLike(String postId) {
    setState(() {
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final isLiked = post.likedBy.contains(_currentUserId);
        
        List<String> newLikedBy = List.from(post.likedBy);
        if (isLiked) {
          newLikedBy.remove(_currentUserId);
        } else {
          newLikedBy.add(_currentUserId);
        }
        
        _posts[postIndex] = post.copyWith(likedBy: newLikedBy);
      }
    });
  }

  void _openPostDiscussion(Post post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PostDiscussionScreen(
          post: post,
          onPostUpdated: (updatedPost) {
            setState(() {
              final index = _posts.indexWhere((p) => p.id == updatedPost.id);
              if (index != -1) {
                _posts[index] = updatedPost;
              }
            });
          },
        ),
      ),
    );
  }

  void _showPostMenu(Post post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text('Пожаловаться'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Жалоба отправлена')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.grey),
              title: const Text('Скрыть пост'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _posts.removeWhere((p) => p.id == post.id);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Пост скрыт')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggleEventParticipation(String eventId) {
    setState(() {
      final eventIndex = _events.indexWhere((event) => event.id == eventId);
      if (eventIndex == -1) return;
      
      final event = _events[eventIndex];
      
      if (_myEvents.contains(eventId)) {
        // Отказ от участия
        _myEvents.remove(eventId);
        _events[eventIndex] = event.copyWith(
          participantCount: event.participantCount - 1,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вы больше не участвуете в событии'),
            backgroundColor: Colors.grey,
          ),
        );
      } else {
        // Участие в событии
        _myEvents.add(eventId);
        _events[eventIndex] = event.copyWith(
          participantCount: event.participantCount + 1,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вы записались на событие!'),
            backgroundColor: Color(0xFFFF6B6B),
          ),
        );
      }
    });
  }

  String _getPublishButtonText() {
    switch (_selectedTab) {
      case 0: return 'Опубликовать';
      case 1: return 'Создать событие';
      case 2: return _showFunctionalAds ? 'Создать объявление' : 'В разработке';
      case 3: return 'В разработке';
      default: return 'Опубликовать';
    }
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0: // Лента
        return _buildFeedTab();
      case 1: // События
        return _buildEventsTab();
      case 2: // Объявления
        return _buildMarketplaceTab();
      case 3: // Группы
        return _buildGroupsTab();
      default:
        return _buildFeedTab();
    }
  }

  Widget _buildFeedTab() {
    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'Пока нет постов',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Станьте первым, кто поделится новостями\nс соседями!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _posts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildPost(_posts[index]);
      },
    );
  }

  Widget _buildEventsTab() {
    return Column(
      children: [
        // Переключатель между "Все события" и "Мои события"
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedEventsTab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedEventsTab == 0 ? const Color(0xFFFF6B6B) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Все события',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _selectedEventsTab == 0 ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedEventsTab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedEventsTab == 1 ? const Color(0xFFFF6B6B) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Мои события',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _selectedEventsTab == 1 ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Контент событий
        Expanded(
          child: _selectedEventsTab == 0 ? _buildAllEventsContent() : _buildMyEventsContent(),
        ),
      ],
    );
  }

  Widget _buildMarketplaceTab() {
    // ПЕРЕКЛЮЧАТЕЛЬ ДЛЯ ПОКАЗА ЗАГЛУШКИ ИЛИ ФУНКЦИОНАЛЬНЫХ ОБЪЯВЛЕНИЙ
    if (!_showFunctionalAds) {
      return const MarketplacePlaceholderScreen();
    }
    
    // НОВЫЙ ФУНКЦИОНАЛЬНЫЙ ЭКРАН ОБЪЯВЛЕНИЙ
    return const AdvertisementsScreen();
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B6B) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }



  List<Advertisement> _getFilteredAdvertisements() {
    List<Advertisement> filtered = List.from(_advertisements);
    
    // Фильтр по типу
    if (_selectedAdType != null) {
      filtered = filtered.where((ad) => ad.type == _selectedAdType).toList();
    }
    
    // Умный поиск по названию и описанию
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((ad) {
        return _isMatchingSearch(ad, query);
      }).toList();
      
      // Сортировка по релевантности при поиске
      filtered.sort((a, b) => _getSearchRelevance(b, query).compareTo(_getSearchRelevance(a, query)));
    } else {
      // Сортировка по дате (новые сначала) когда нет поиска
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    return filtered;
  }

  bool _isMatchingSearch(Advertisement ad, String query) {
    // Поиск в названии
    if (ad.title.toLowerCase().contains(query)) {
      return true;
    }
    
    // Поиск в описании
    if (ad.description.toLowerCase().contains(query)) {
      return true;
    }
    
    // Поиск по словам (разбивка по пробелам)
    final queryWords = query.split(' ').where((word) => word.trim().isNotEmpty);
    if (queryWords.isNotEmpty) {
      final titleWords = ad.title.toLowerCase().split(' ');
      final descWords = ad.description.toLowerCase().split(' ');
      
      // Проверяем, что все слова запроса найдены
      return queryWords.every((queryWord) {
        return titleWords.any((word) => word.startsWith(queryWord)) ||
               descWords.any((word) => word.startsWith(queryWord));
      });
    }
    
    return false;
  }

  int _getSearchRelevance(Advertisement ad, String query) {
    int score = 0;
    final title = ad.title.toLowerCase();
    final description = ad.description.toLowerCase();
    
    // Точное совпадение в названии - высший приоритет
    if (title.contains(query)) {
      score += 100;
      // Дополнительные баллы если запрос в начале названия
      if (title.startsWith(query)) {
        score += 50;
      }
    }
    
    // Совпадение в описании
    if (description.contains(query)) {
      score += 30;
    }
    
    // Частичные совпадения по словам
    final queryWords = query.split(' ').where((word) => word.trim().isNotEmpty);
    for (final queryWord in queryWords) {
      // Поиск в словах названия
      final titleWords = title.split(' ');
      for (final word in titleWords) {
        if (word.startsWith(queryWord)) {
          score += 20;
        }
        if (word == queryWord) {
          score += 10; // дополнительно за точное совпадение слова
        }
      }
      
      // Поиск в словах описания
      final descWords = description.split(' ');
      for (final word in descWords) {
        if (word.startsWith(queryWord)) {
          score += 5;
        }
      }
    }
    
    return score;
  }

  Widget _buildAdvertisementsList() {
    final filteredAds = _getFilteredAdvertisements();
    
    if (filteredAds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'Нет объявлений',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Создайте первое объявление\nили измените фильтры',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredAds.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildAdvertisementCard(filteredAds[index]);
      },
    );
  }

  Widget _buildAdvertisementCard(Advertisement ad) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AdvertisementDetailScreen(
              advertisement: ad,
              onContactSeller: () {
                // TODO: Добавить чат в список чатов
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение товара или placeholder
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: ad.imagePath != null && ad.imagePath!.startsWith('/')
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.file(
                      File(ad.imagePath!),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                                 : Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(
                           Icons.shopping_bag,
                           size: 50,
                           color: Colors.grey[400],
                         ),
                         const SizedBox(height: 8),
                         Text(
                           'Товар',
                           style: TextStyle(
                             color: Colors.grey[600],
                             fontSize: 14,
                           ),
                         ),
                       ],
                     ),
                   ),
          ),
          
          // Информация о товаре
          Padding(
            padding: const EdgeInsets.all(16),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ad.type == 'free' 
                            ? Colors.green[100] 
                            : const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getTypeDisplayName(ad.type),
                        style: TextStyle(
                          color: ad.type == 'free' 
                              ? Colors.green[700] 
                              : const Color(0xFFFF6B6B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Цена
                                 if (ad.price != null) ...[
                   Text(
                     '${ad.price} ₸',
                     style: const TextStyle(
                       fontSize: 24,
                       fontWeight: FontWeight.bold,
                       color: Color(0xFFFF6B6B),
                     ),
                   ),
                  const SizedBox(height: 8),
                ] else ...[
                  const Text(
                    'ДАРОМ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Описание
                Text(
                  ad.description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // Автор и дата
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        ad.authorName[0],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ad.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            ad.authorAddress,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _getTimeAgo(ad.createdAt),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
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





  Widget _buildGroupsTab() {
    return const GroupsScreen();
  }

  Widget _buildAllEventsContent() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildEventCard(_events[index]);
      },
    );
  }

  Widget _buildMyEventsContent() {
    final myEventsList = _events.where((event) => _myEvents.contains(event.id)).toList();
    
    if (myEventsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              'Пока нет событий',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Присоединяйтесь к событиям соседей\nи они появятся здесь!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: myEventsList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildEventCard(myEventsList[index]),
    );
  }

  Widget _buildEventCard(Event event) {
    final isParticipating = _myEvents.contains(event.id);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение или видео
          if (event.imageUrl != null || event.videoUrl != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  // Изображение или видео
                  if (event.imageUrl != null && event.imageUrl!.startsWith('/'))
                    // Локальное изображение
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.file(
                        File(event.imageUrl!),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else if (event.videoUrl != null && event.videoUrl!.startsWith('/'))
                    // Локальное видео - показываем превью
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Нажмите для просмотра видео',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // Placeholder для удаленных файлов
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            event.videoUrl != null ? Icons.play_circle_fill : Icons.image,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event.videoUrl != null ? 'Видео' : 'Фото',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Кнопка воспроизведения для видео
                  if (event.videoUrl != null)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          
          // Контент события
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Информация о событии
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      event.date,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Участников: ${event.participantCount}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                // Описание события
                if (event.description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    event.description!,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Кнопка участия
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _toggleEventParticipation(event.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isParticipating 
                          ? Colors.grey[600] 
                          : const Color(0xFFFF6B6B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isParticipating ? 'Не участвовать' : 'Участвовать',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(String name, String price) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          // Product info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.favorite_border,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildPost(Post post) {
    final isLiked = post.likedBy.contains(_currentUserId);
    final timeAgo = _getTimeAgo(post.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and menu
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(
                          userName: post.authorName,
                          userAddress: post.authorAddress,
                          context: 'поста',
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          post.authorName[0],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.authorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  post.authorAddress,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  ' • $timeAgo',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showPostMenu(post),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_horiz,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Post text
          Text(
            post.text,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
          if (post.imagePath != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(post.imagePath!),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Actions
          Row(
            children: [
              // Like button
              GestureDetector(
                onTap: () => _toggleLike(post.id),
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 22,
                      color: isLiked ? Colors.red : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${post.likesCount}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Comments button
              GestureDetector(
                onTap: () => _openPostDiscussion(post),
                child: Row(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 22,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${post.commentsCount}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}д';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}м';
    } else {
      return 'только что';
    }
  }
}



// Заглушка экрана чатов


// Экран обсуждения поста
class PostDiscussionScreen extends StatefulWidget {
  final Post post;
  final Function(Post) onPostUpdated;

  const PostDiscussionScreen({
    super.key,
    required this.post,
    required this.onPostUpdated,
  });

  @override
  State<PostDiscussionScreen> createState() => _PostDiscussionScreenState();
}

class _PostDiscussionScreenState extends State<PostDiscussionScreen> {
  late Post _post;
  final TextEditingController _commentController = TextEditingController();
  final String _currentUserId = 'current_user_id';
  final UserService _userService = UserService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _commentController.addListener(() {
      setState(() {}); // Обновляем UI для изменения цвета кнопки
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: _userService.currentUserName,
      text: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    setState(() {
      _post = _post.copyWith(
        comments: [..._post.comments, newComment],
      );
    });

    widget.onPostUpdated(_post);
    _commentController.clear();
    
    // Скролл вниз к новому комментарию
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleLike() {
    setState(() {
      final isLiked = _post.likedBy.contains(_currentUserId);
      List<String> newLikedBy = List.from(_post.likedBy);
      
      if (isLiked) {
        newLikedBy.remove(_currentUserId);
      } else {
        newLikedBy.add(_currentUserId);
      }
      
      _post = _post.copyWith(likedBy: newLikedBy);
    });
    
    widget.onPostUpdated(_post);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Обсуждение',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Пост
          Container(
            color: Colors.white,
            child: _buildFullPost(),
          ),
          const Divider(height: 1, color: Colors.grey),
          // Комментарии
          Expanded(
            child: _post.comments.isEmpty
                ? _buildEmptyComments()
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _post.comments.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildComment(_post.comments[index]);
                    },
                  ),
          ),
          // Поле ввода комментария
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildFullPost() {
    final isLiked = _post.likedBy.contains(_currentUserId);
    final timeAgo = _getTimeAgo(_post.createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Информация об авторе
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: Text(
                  _post.authorName[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _post.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _post.authorAddress,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          ' • $timeAgo',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Текст поста
          Text(
            _post.text,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
          // Изображение если есть
          if (_post.imagePath != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_post.imagePath!),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Лайки и комментарии
          Row(
            children: [
              GestureDetector(
                onTap: _toggleLike,
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 22,
                      color: isLiked ? Colors.red : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_post.likesCount}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 22,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_post.commentsCount}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyComments() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.comment_outlined,
            size: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Пока нет комментариев',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Станьте первым, кто оставит комментарий!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComment(Comment comment) {
    final timeAgo = _getTimeAgo(comment.createdAt);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[300],
            child: Text(
              comment.authorName[0],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[300],
              child: const Text(
                'А',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Написать комментарий...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                  return null; // Скрыть счетчик символов
                },
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _commentController.text.trim().isNotEmpty ? _addComment : null,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _commentController.text.trim().isEmpty 
                      ? Colors.grey[300] 
                      : const Color(0xFFFF6B6B),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send,
                  color: _commentController.text.trim().isEmpty 
                      ? Colors.grey[600] 
                      : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}д';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}м';
    } else {
      return 'только что';
    }
  }
}