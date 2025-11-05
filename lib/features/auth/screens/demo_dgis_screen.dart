import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
// Firebase отключен для тестирования
import '../../../../services/google_maps_service.dart';
import '../repositories/user_address_repository.dart';
import '../models/user_address.dart';

class DemoDgisScreen extends StatefulWidget {
  const DemoDgisScreen({super.key});

  @override
  State<DemoDgisScreen> createState() => _DemoDgisScreenState();
}

class _DemoDgisScreenState extends State<DemoDgisScreen> {
  final _searchController = TextEditingController();
  final _googleMapsService = GoogleMapsService();
  final _addressRepository = UserAddressRepository();
  
  List<GoogleMapsPlace> _searchResults = [];
  GoogleMapsPlace? _selectedPlace;
  bool _isSearching = false;
  String? _errorMessage;
  
  // Google Maps
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  
  // Начальные координаты (центр Алматы)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(43.2380, 76.8892), // Центр Алматы
    zoom: 10.0, // Более широкий обзор
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() async {
    // Запрашиваем разрешения на геолокацию
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.whileInUse || 
        permission == LocationPermission.always) {
      try {
        Position position = await Geolocator.getCurrentPosition();
        
        // Проверяем, что позиция в Казахстане (примерные границы)
        if (position.latitude >= 40.0 && position.latitude <= 55.0 &&
            position.longitude >= 46.0 && position.longitude <= 87.0) {
          _updateMapPosition(LatLng(position.latitude, position.longitude));
        } else {
          // Если позиция не в Казахстане, устанавливаем центр Алматы
          _updateMapPosition(const LatLng(43.2380, 76.8892));
        }
      } catch (e) {
        // Если не удалось получить позицию, устанавливаем центр Алматы
        print('Не удалось получить текущую позицию: $e');
        _updateMapPosition(const LatLng(43.2380, 76.8892));
      }
    } else {
      // Если нет разрешений, устанавливаем центр Алматы
      _updateMapPosition(const LatLng(43.2380, 76.8892));
    }
  }

  void _updateMapPosition(LatLng position) {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(position));
    }
  }

  void _addMarker(LatLng position, String title) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('selected_location'),
          position: position,
          infoWindow: InfoWindow(title: title),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _searchResults.clear();
    });

    try {
      final results = await _googleMapsService.searchAddress(query);
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка поиска: $e';
        _isSearching = false;
      });
    }
  }

  void _selectPlace(GoogleMapsPlace place) {
    setState(() {
      _selectedPlace = place;
      _searchController.text = place.address;
      _searchResults.clear();
      _errorMessage = null;
    });

    // Добавляем маркер на карту
    _addMarker(LatLng(place.latitude, place.longitude), place.name);
    
    // Перемещаем карту к выбранному месту
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(place.latitude, place.longitude), 15.0),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Выбран адрес: ${place.address}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onMapTap(LatLng position) async {
    setState(() {
      _isSearching = true;
    });

    try {
      // Получаем адрес по координатам через Google Maps API
      final addressString = await _googleMapsService.reverseGeocode(
        position.latitude, 
        position.longitude
      );
      
      if (addressString != null) {
        // Создаем временный объект места
        final place = GoogleMapsPlace(
          name: 'Выбранное место',
          address: addressString,
          latitude: position.latitude,
          longitude: position.longitude,
          placeId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        _selectPlace(place);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось определить адрес для этой точки'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка определения адреса: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isSearching = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор адреса'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSearchResults(),
          _buildMap(),
          _buildSelectedAddress(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Введите адрес...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: _searchAddress,
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _searchAddress(_searchController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Найти'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final place = _searchResults[index];
          return ListTile(
            leading: const Icon(Icons.location_on, color: Colors.red),
            title: Text(
              place.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(place.address),
            onTap: () => _selectPlace(place),
          );
        },
      ),
    );
  }

  Widget _buildMap() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _initialPosition,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                markers: _markers,
                onTap: _onMapTap,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
              
              // Индикатор загрузки при клике на карту
              if (_isSearching)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Определение адреса...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Информационная панель (когда нет выбранного места)
              if (_selectedPlace == null)
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map,
                          size: 24,
                          color: Colors.blue,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Карта Google Maps',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Нажмите на карту для выбора адреса',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedAddress() {
    if (_selectedPlace == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Точные адреса и дома благодаря картам Google Maps',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                'Выбранный адрес:',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _selectedPlace!.address,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Точность: ±5м (Google Maps)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addAddressToProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add_location),
              label: const Text(
                'Добавить в профиль',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addAddressToProfile() async {
    if (_selectedPlace == null) return;

    try {
      // Получаем текущего пользователя
      // final user = FirebaseAuth.instance.currentUser; // Firebase отключен
      // if (user == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Необходимо войти в аккаунт'),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      //   return;
      // }

      // Показываем индикатор загрузки
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Создаем объект адреса пользователя
      final userAddress = UserAddress(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}', // Временный ID
        userId: 'test-user-123', // Тестовый пользователь
        name: _selectedPlace!.name,
        address: _selectedPlace!.address,
        latitude: _selectedPlace!.latitude,
        longitude: _selectedPlace!.longitude,
        placeId: _selectedPlace!.placeId,
        type: 'other',
        description: 'Добавлено через карту',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Сохраняем в Firebase
      await _addressRepository.addUserAddress(userAddress);

      // Закрываем индикатор загрузки
      Navigator.of(context).pop();

      // Показываем успешное сообщение
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Адрес "${_selectedPlace!.name}" добавлен в профиль',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Посмотреть',
            textColor: Colors.white,
            onPressed: () {
              _showProfileAddresses();
            },
          ),
        ),
      );

      // Очищаем выбранный адрес
      setState(() {
        _selectedPlace = null;
        _markers.clear();
      });

    } catch (e) {
      // Закрываем индикатор загрузки в случае ошибки
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка добавления адреса: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showProfileAddresses() async {
    try {
      final addresses = await _addressRepository.getUserAddresses();
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Мои адреса'),
          content: SizedBox(
            width: double.maxFinite,
            child: addresses.isEmpty
                ? const Center(
                    child: Text(
                      'У вас пока нет сохраненных адресов',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      return ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: _getAddressColor(address.type),
                        ),
                        title: Text(address.name),
                        subtitle: Text(address.address),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAddress(address.id),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ошибка'),
          content: Text('Не удалось загрузить адреса: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      );
    }
  }

  Color _getAddressColor(String? type) {
    switch (type) {
      case 'home':
        return Colors.red;
      case 'work':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  void _deleteAddress(String addressId) async {
    try {
      await _addressRepository.deleteUserAddress(addressId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Адрес удален'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка удаления: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 