import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class AddressVerificationScreen extends StatefulWidget {
  const AddressVerificationScreen({super.key});

  @override
  State<AddressVerificationScreen> createState() => _AddressVerificationScreenState();
}

class _AddressVerificationScreenState extends State<AddressVerificationScreen> {
  final _addressController = TextEditingController();
  GoogleMapController? _mapController;
  
  // Координаты центра Казахстана (Алматы)
  static const LatLng _initialPosition = LatLng(43.2220, 76.8512);
  LatLng? _selectedLocation;
  String? _selectedAddress;
  Set<Marker> _markers = {};
  
  bool _isSearching = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    final query = _addressController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      // Добавляем "Казахстан" к запросу для лучших результатов
      final locations = await locationFromAddress('$query, Казахстан');
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        final position = LatLng(location.latitude, location.longitude);
        
        setState(() {
          _selectedLocation = position;
          _selectedAddress = query;
          _markers = {
            Marker(
              markerId: const MarkerId('selected_location'),
              position: position,
              infoWindow: InfoWindow(title: query),
            ),
          };
        });

        // Перемещаем камеру к найденному месту
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(position, 16.0),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Адрес не найден. Попробуйте другой запрос.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка поиска. Проверьте интернет соединение.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _onMapTap(LatLng position) async {
    setState(() {
      _isSearching = true;
      _selectedLocation = position;
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          infoWindow: const InfoWindow(title: 'Выбранное место'),
        ),
      };
    });

    try {
      // Получаем адрес по координатам
      final placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude,
        localeIdentifier: 'ru_RU',
      );
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = _buildAddressFromPlacemark(placemark);
        
        setState(() {
          _selectedAddress = address;
          _addressController.text = address;
          _markers = {
            Marker(
              markerId: const MarkerId('selected_location'),
              position: position,
              infoWindow: InfoWindow(title: address),
            ),
          };
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось определить адрес'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  String _buildAddressFromPlacemark(Placemark placemark) {
    final parts = <String>[];
    
    if (placemark.street?.isNotEmpty == true) {
      parts.add(placemark.street!);
    }
    if (placemark.subThoroughfare?.isNotEmpty == true) {
      parts.add('д. ${placemark.subThoroughfare}');
    }
    if (placemark.locality?.isNotEmpty == true) {
      parts.add(placemark.locality!);
    }
    
    return parts.isNotEmpty ? parts.join(', ') : 'Выбранный адрес';
  }

  void _saveAddress() {
    if (_selectedLocation == null || _selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите адрес на карте или найдите его'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Сохранить адрес в базу данных
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Адрес добавлен'),
        content: Text('Адрес "$_selectedAddress" успешно добавлен в ваш профиль.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Закрыть диалог
              Navigator.pop(context); // Вернуться к профилю
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Добавить адрес',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: _saveAddress,
              child: const Text(
                'Сохранить',
                style: TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Поле поиска
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: 'Введите адрес (например: пр. Абая 150, Алматы)',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _searchAddress(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSearching ? null : _searchAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B6B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSearching 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Найти'),
                ),
              ],
            ),
          ),
          
          // Информация
          if (_selectedLocation == null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Найдите адрес через поиск или нажмите на карту',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Карта
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              clipBehavior: Clip.antiAlias,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _initialPosition,
                  zoom: 10.0,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                onTap: _onMapTap,
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
          ),
          
          // Выбранный адрес
          if (_selectedAddress != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Выбранный адрес:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedAddress!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
} 