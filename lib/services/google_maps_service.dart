import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleMapsService {
  static const String _apiKey = 'AIzaSyDKsYoF9UC1POXgHQbfh5syxXyfhufiODU';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';

  // Поиск адреса по тексту
  Future<List<GoogleMapsPlace>> searchAddress(String query) async {
    try {
      final url = Uri.parse('$_baseUrl/geocode/json')
          .replace(queryParameters: {
        'address': '$query, Казахстан',
        'key': _apiKey,
        'language': 'ru',
        'region': 'kz', // Приоритет Казахстану
      });

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'] != null) {
          final List<GoogleMapsPlace> places = [];
          
          for (var result in data['results']) {
            final geometry = result['geometry'];
            final location = geometry['location'];
            
            places.add(GoogleMapsPlace(
              name: result['formatted_address'],
              address: result['formatted_address'],
              latitude: location['lat'].toDouble(),
              longitude: location['lng'].toDouble(),
              placeId: result['place_id'],
            ));
          }
          
          return places;
        }
      }
      
      return [];
    } catch (e) {
      print('Ошибка поиска адреса: $e');
      return [];
    }
  }

  // Обратное геокодирование (координаты → адрес)
  Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse('$_baseUrl/geocode/json')
          .replace(queryParameters: {
        'latlng': '$lat,$lng',
        'key': _apiKey,
        'language': 'ru',
      });

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'] != null) {
          final results = data['results'] as List;
          if (results.isNotEmpty) {
            return results.first['formatted_address'];
          }
        }
      }
      
      return null;
    } catch (e) {
      print('Ошибка обратного геокодирования: $e');
      return null;
    }
  }

  // Поиск места по ID
  Future<GoogleMapsPlace?> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse('$_baseUrl/place/details/json')
          .replace(queryParameters: {
        'place_id': placeId,
        'key': _apiKey,
        'language': 'ru',
        'fields': 'formatted_address,geometry,name',
      });

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['result'] != null) {
          final result = data['result'];
          final geometry = result['geometry'];
          final location = geometry['location'];
          
          return GoogleMapsPlace(
            name: result['name'] ?? result['formatted_address'],
            address: result['formatted_address'],
            latitude: location['lat'].toDouble(),
            longitude: location['lng'].toDouble(),
            placeId: placeId,
          );
        }
      }
      
      return null;
    } catch (e) {
      print('Ошибка получения деталей места: $e');
      return null;
    }
  }
}

class GoogleMapsPlace {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String placeId;

  GoogleMapsPlace({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.placeId,
  });

  @override
  String toString() {
    return address.isNotEmpty ? address : name;
  }
} 