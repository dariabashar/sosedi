import '../features/auth/models/user_model.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  
  String get currentUserName => _currentUser != null 
      ? '${_currentUser!.firstName} ${_currentUser!.lastName}'
      : 'Пользователь';
  String get currentUserFirstName => _currentUser?.firstName ?? '';
  String get currentUserLastName => _currentUser?.lastName ?? '';
  String get currentUserPhone => _currentUser?.phoneNumber ?? '';
  
  // Получить первую букву имени для аватара
  String get currentUserInitial {
    if (_currentUser?.firstName?.isNotEmpty == true) {
      return _currentUser!.firstName![0].toUpperCase();
    }
    return 'П';
  }

  void setCurrentUser(UserModel user) {
    _currentUser = user;
  }

  void updateCurrentUser({
    String? firstName,
    String? lastName,
    String? displayName,
    String? avatarUrl,
    String? address,
  }) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        firstName: firstName ?? _currentUser!.firstName,
        lastName: lastName ?? _currentUser!.lastName,
        displayName: displayName,
        avatarUrl: avatarUrl,
        address: address,
        updatedAt: DateTime.now(),
      );
    }
  }

  void clearCurrentUser() {
    _currentUser = null;
  }

  bool get isLoggedIn => _currentUser != null;

  // Для демо-данных - установить тестового пользователя
  void setDemoUser() {
    _currentUser = UserModel(
      id: 'demo_user_1',
      firstName: 'Алексей',
      lastName: 'Иванов',
      phoneNumber: '+7 777 123 45 67',
      email: 'alexey@example.com',
      displayName: 'Алексей Иванов',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
  }
} 