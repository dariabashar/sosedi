import 'dart:convert';
import 'package:http/http.dart' as http;

class DgisService {
  // API ключ от Urbi
  static const String _apiKey = '520c5d75-a792-4fee-bc3f-f6f8acb6aef0';
  
  // Базовый URL для Urbi API (используют тот же формат что и 2ГИС)
  static const String _baseUrl = 'https://catalog.api.2gis.com';

  // Поиск по адресу с подсказками
  Future<List<DgisPlace>> searchPlaces(String query) async {
    try {
      final url = Uri.parse('$_baseUrl/3.0/items')
          .replace(queryParameters: {
        'q': '$query, Казахстан',
        'key': _apiKey,
        'fields': 'items.point',
        'type': 'building',
        'page_size': '10',
      });

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<DgisPlace> places = [];
        
        if (data['result'] != null && data['result']['items'] != null) {
          for (var item in data['result']['items']) {
            if (item['point'] != null) {
              places.add(DgisPlace(
                name: item['name'] ?? item['address_name'] ?? 'Безымянный адрес',
                address: item['full_name'] ?? item['address_name'] ?? '',
                latitude: item['point']['lat'].toDouble(),
                longitude: item['point']['lon'].toDouble(),
              ));
            }
          }
        }
        
        return places;
      }
      
      return [];
    } catch (e) {
      print('Ошибка поиска мест: $e');
      return [];
    }
  }

  // Обратное геокодирование координат в адрес
  Future<String?> reverseGeocode(double lat, double lon) async {
    try {
      final url = Uri.parse('$_baseUrl/3.0/items/geocode')
          .replace(queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'key': _apiKey,
        'fields': 'items.point',
      });

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['result'] != null && data['result']['items'] != null) {
          final items = data['result']['items'] as List;
          if (items.isNotEmpty) {
            final item = items.first;
            return item['full_name'] ?? item['address_name'] ?? 'Адрес не определен';
          }
        }
      }
      
      return null;
    } catch (e) {
      print('Ошибка обратного геокодирования: $e');
      return null;
    }
  }
}

// Модель места из 2ГИС
class DgisPlace {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  DgisPlace({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory DgisPlace.fromJson(Map<String, dynamic> json) {
    final point = json['point'];
    final lat = (point?['lat'] as num?)?.toDouble() ?? 0.0;
    final lon = (point?['lon'] as num?)?.toDouble() ?? 0.0;
    
    return DgisPlace(
      name: json['name'] ?? json['address_name'] ?? 'Безымянный адрес',
      address: json['full_name'] ?? json['address_name'] ?? '',
      latitude: lat,
      longitude: lon,
    );
  }

  @override
  String toString() {
    return address.isNotEmpty ? address : name;
  }
}

// Модель для сохранения выбранного адреса
class SelectedAddress {
  final String address;
  final double lat;
  final double lon;
  final DateTime selectedAt;

  SelectedAddress({
    required this.address,
    required this.lat,
    required this.lon,
    required this.selectedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'lat': lat,
      'lon': lon,
      'selected_at': selectedAt.toIso8601String(),
    };
  }

  factory SelectedAddress.fromJson(Map<String, dynamic> json) {
    return SelectedAddress(
      address: json['address'] ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      selectedAt: DateTime.parse(json['selected_at'] ?? DateTime.now().toIso8601String()),
    );
  }
} 