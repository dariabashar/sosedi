import '../models/user_address.dart';

class UserAddressRepository {
  // Временно используем in-memory хранилище для тестирования
  static final List<UserAddress> _addresses = [];

  UserAddressRepository();

  // Получить все адреса пользователя
  Future<List<UserAddress>> getUserAddresses() async {
    return _addresses;
  }

  // Добавить новый адрес
  Future<void> addUserAddress(UserAddress address) async {
    _addresses.add(address);
  }

  // Обновить адрес
  Future<void> updateUserAddress(String addressId, Map<String, dynamic> updates) async {
    final index = _addresses.indexWhere((addr) => addr.id == addressId);
    if (index != -1) {
      final updatedAddress = _addresses[index].copyWith(
        description: updates['description'] as String?,
        updatedAt: DateTime.now(),
      );
      _addresses[index] = updatedAddress;
    }
  }

  // Удалить адрес
  Future<void> deleteUserAddress(String addressId) async {
    _addresses.removeWhere((addr) => addr.id == addressId);
  }

  // Установить основной адрес
  Future<void> setMainAddress(String addressId) async {
    // Просто обновляем время для выбранного адреса
    final index = _addresses.indexWhere((addr) => addr.id == addressId);
    if (index != -1) {
      _addresses[index] = _addresses[index].copyWith(
        updatedAt: DateTime.now(),
      );
    }
  }
} 