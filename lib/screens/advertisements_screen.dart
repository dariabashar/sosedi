import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/advertisement.dart';
import 'create_advertisement_screen.dart';

class AdvertisementsScreen extends StatefulWidget {
  const AdvertisementsScreen({super.key});

  @override
  State<AdvertisementsScreen> createState() => _AdvertisementsScreenState();
}

class _AdvertisementsScreenState extends State<AdvertisementsScreen> {
  List<Advertisement> _advertisements = [];
  bool _isLoading = true;
  String _selectedCategory = 'Все';
  String _selectedSort = 'По дате';

  final List<String> _categories = [
    'Все',
    'Электроника',
    'Одежда',
    'Мебель',
    'Спорт',
    'Книги',
    'Другое',
  ];

  final List<String> _sortOptions = [
    'По дате',
    'По цене (дешевле)',
    'По цене (дороже)',
    'По расстоянию',
  ];

  @override
  void initState() {
    super.initState();
    _loadAdvertisements();
  }

  Future<void> _loadAdvertisements() async {
    setState(() => _isLoading = true);
    
    try {
      final ads = await ApiService.getNearbyAdvertisements();
      setState(() {
        _advertisements = ads.map((ad) => Advertisement(
          id: ad['id'] ?? 'unknown',
          title: ad['title'] ?? 'Без названия',
          description: ad['description'] ?? '',
          type: ad['type'] ?? 'sale',
          authorName: ad['authorName'] ?? 'Неизвестный',
          authorAddress: ad['authorAddress'] ?? 'Не указано',
          price: ad['price']?.toString(),
          imagePath: ad['imagePath'],
          createdAt: ad['createdAt'] != null 
              ? DateTime.parse(ad['createdAt'])
              : DateTime.now(),
          isActive: ad['isActive'] ?? true,
        )).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading advertisements: $e');
      // Добавляем тестовые объявления
      setState(() {
        _advertisements = [
          Advertisement(
            id: '1',
            title: 'iPhone 12 Pro',
            description: 'Отличное состояние, все работает. Продаю из-за покупки новой модели.',
            type: 'sale',
            authorName: 'Алексей',
            authorAddress: 'ЖК Энергетик',
            price: '45000 ₽',
            imagePath: 'https://via.placeholder.com/300x200?text=iPhone',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            isActive: true,
          ),
          Advertisement(
            id: '2',
            title: 'Диван угловой',
            description: 'Угловой диван, мягкий, удобный. Отдам даром, нужно вывезти.',
            type: 'free',
            authorName: 'Мария',
            authorAddress: 'ЖК Солнечный',
            price: null,
            imagePath: 'https://via.placeholder.com/300x200?text=Диван',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            isActive: true,
          ),
          Advertisement(
            id: '3',
            title: 'Велосипед горный',
            description: 'Горный велосипед, 21 скорость, тормоза дисковые. Состояние отличное.',
            type: 'sale',
            authorName: 'Дмитрий',
            authorAddress: 'ЖК Центральный',
            price: '15000 ₽',
            imagePath: 'https://via.placeholder.com/300x200?text=Велосипед',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            isActive: true,
          ),
          Advertisement(
            id: '4',
            title: 'Книги по программированию',
            description: 'Коллекция книг по Python, JavaScript, Flutter. Все в хорошем состоянии.',
            type: 'sale',
            authorName: 'Елена',
            authorAddress: 'ЖК Академический',
            price: '3000 ₽',
            imagePath: 'https://via.placeholder.com/300x200?text=Книги',
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
            isActive: true,
          ),
        ];
        _isLoading = false;
      });
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _sortAdvertisements(String sort) {
    setState(() {
      _selectedSort = sort;
      switch (sort) {
        case 'По цене (дешевле)':
          _advertisements.sort((a, b) {
            final priceA = double.tryParse(a.price?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0;
            final priceB = double.tryParse(b.price?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0;
            return priceA.compareTo(priceB);
          });
          break;
        case 'По цене (дороже)':
          _advertisements.sort((a, b) {
            final priceA = double.tryParse(a.price?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0;
            final priceB = double.tryParse(b.price?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0;
            return priceB.compareTo(priceA);
          });
          break;
        case 'По расстоянию':
          // Сортировка по адресу (упрощенно)
          _advertisements.sort((a, b) => a.authorAddress.compareTo(b.authorAddress));
          break;
        default:
          _advertisements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    });
  }

  List<Advertisement> get _filteredAdvertisements {
    if (_selectedCategory == 'Все') {
      return _advertisements;
    }
    // Фильтрация по типу объявления
    return _advertisements.where((ad) {
      switch (_selectedCategory) {
        case 'Электроника':
          return ad.title.toLowerCase().contains('iphone') || 
                 ad.title.toLowerCase().contains('телефон') ||
                 ad.title.toLowerCase().contains('компьютер');
        case 'Одежда':
          return ad.title.toLowerCase().contains('одежда') ||
                 ad.title.toLowerCase().contains('куртка') ||
                 ad.title.toLowerCase().contains('платье');
        case 'Мебель':
          return ad.title.toLowerCase().contains('диван') ||
                 ad.title.toLowerCase().contains('стол') ||
                 ad.title.toLowerCase().contains('кровать');
        case 'Спорт':
          return ad.title.toLowerCase().contains('велосипед') ||
                 ad.title.toLowerCase().contains('лыжи') ||
                 ad.title.toLowerCase().contains('мяч');
        case 'Книги':
          return ad.title.toLowerCase().contains('книг') ||
                 ad.title.toLowerCase().contains('учебник');
        case 'Другое':
          return !ad.title.toLowerCase().contains('iphone') &&
                 !ad.title.toLowerCase().contains('диван') &&
                 !ad.title.toLowerCase().contains('велосипед') &&
                 !ad.title.toLowerCase().contains('книг');
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Объявления'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Поиск объявлений
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Категории
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => _filterByCategory(category),
                    backgroundColor: Colors.grey[200],
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                );
              },
            ),
          ),
          
          // Список объявлений
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAdvertisements.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.store_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Нет объявлений',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Попробуйте изменить фильтры',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAdvertisements,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredAdvertisements.length,
                          itemBuilder: (context, index) {
                            final ad = _filteredAdvertisements[index];
                            return AdvertisementCard(advertisement: ad);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Создание нового объявления
          _showCreateAdDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сортировка'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _sortOptions.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _selectedSort,
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  _sortAdvertisements(value);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCreateAdDialog() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateAdvertisementScreen(),
      ),
    );
    
    // Обновляем список, если объявление было создано
    if (result == true) {
      _loadAdvertisements();
    }
  }
}

class AdvertisementCard extends StatelessWidget {
  final Advertisement advertisement;

  const AdvertisementCard({
    super.key,
    required this.advertisement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение
          if (advertisement.imagePath != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                advertisement.imagePath!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок и цена
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        advertisement.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: advertisement.type == 'free'
                            ? Colors.green 
                            : Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        advertisement.type == 'free'
                            ? 'Даром'
                            : advertisement.price ?? 'Цена не указана',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Описание
                Text(
                  advertisement.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                // Информация о продавце и местоположении
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      advertisement.authorName,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      advertisement.authorAddress,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Время публикации
                Text(
                  _formatTime(advertisement.createdAt),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} мин. назад';
    } else {
      return 'Только что';
    }
  }
}

 