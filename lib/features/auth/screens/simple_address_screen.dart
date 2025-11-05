import 'package:flutter/material.dart';

class SimpleAddressScreen extends StatefulWidget {
  const SimpleAddressScreen({super.key});

  @override
  State<SimpleAddressScreen> createState() => _SimpleAddressScreenState();
}

class _SimpleAddressScreenState extends State<SimpleAddressScreen> {
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  
  String? _selectedAddress;
  bool _isSearching = false;
  
  // Популярные города Казахстана
  final List<String> _popularCities = [
    'Алматы',
    'Нур-Султан (Астана)',
    'Шымкент',
    'Актобе',
    'Тараз',
    'Павлодар',
    'Усть-Каменогорск',
    'Семей',
    'Атырау',
    'Костанай',
    'Петропавловск',
    'Актау',
    'Темиртау',
    'Туркестан',
    'Кызылорда',
  ];

  // Популярные улицы для автодополнения
  final List<String> _popularStreets = [
    'проспект Абая',
    'проспект Назарбаева',
    'улица Толе би',
    'улица Богенбай батыра',
    'проспект Аль-Фараби',
    'улица Жибек жолы',
    'проспект Достык',
    'улица Панфилова',
    'улица Кунаева',
    'проспект Райымбека',
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _simulateSearch() async {
    if (_addressController.text.trim().isEmpty && _cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите адрес и город'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Имитация поиска
    await Future.delayed(const Duration(seconds: 2));

    final fullAddress = '${_addressController.text.trim()}, ${_cityController.text.trim()}';
    
    setState(() {
      _selectedAddress = fullAddress;
      _isSearching = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Адрес найден!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _saveAddress() {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала найдите адрес'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      value: null,
      decoration: InputDecoration(
        labelText: 'Город',
        hintText: 'Выберите или введите город',
        prefixIcon: const Icon(Icons.location_city),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: _popularCities.map((city) => 
        DropdownMenuItem(value: city, child: Text(city))
      ).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _cityController.text = value;
          });
        }
      },
    );
  }

  Widget _buildStreetSuggestions() {
    final query = _addressController.text.toLowerCase();
    if (query.isEmpty) return const SizedBox.shrink();
    
    final suggestions = _popularStreets
        .where((street) => street.toLowerCase().contains(query))
        .take(3)
        .toList();
    
    if (suggestions.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Похожие адреса:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          ...suggestions.map((street) => ListTile(
            dense: true,
            leading: const Icon(Icons.location_on, size: 16, color: Colors.grey),
            title: Text(
              street,
              style: const TextStyle(fontSize: 14),
            ),
            onTap: () {
              setState(() {
                _addressController.text = street;
              });
            },
          )),
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
          if (_selectedAddress != null)
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Информация
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.home_outlined,
                    color: Colors.blue,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Добавление адреса',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Укажите ваш точный адрес для участия в местном сообществе',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Город
            _buildCityDropdown(),
            
            const SizedBox(height: 16),
            
            // Или ввести вручную
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Или введите город вручную',
                hintText: 'Например: Алматы',
                prefixIcon: const Icon(Icons.edit_location),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Адрес
            const Text(
              'Улица и номер дома',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Например: проспект Абая, 150',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {}); // Обновляем предложения
              },
            ),
            
            // Предложения улиц
            _buildStreetSuggestions(),
            
            const SizedBox(height: 24),
            
            // Кнопка поиска
            ElevatedButton.icon(
              onPressed: _isSearching ? null : _simulateSearch,
              icon: _isSearching 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.search),
              label: Text(_isSearching ? 'Поиск...' : 'Найти адрес'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Найденный адрес
            if (_selectedAddress != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[600]),
                        const SizedBox(width: 8),
                        const Text(
                          'Адрес найден',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedAddress!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Этот адрес будет добавлен в ваш профиль',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Информация о будущей карте
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.map, color: Colors.orange[600], size: 24),
                  const SizedBox(height: 8),
                  Text(
                    'Скоро будет доступна интерактивная карта',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Вы сможете выбирать адрес прямо на карте Казахстана',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 