class Advertisement {
  final String id;
  final String title;
  final String description;
  final String type; // 'sale' или 'free'
  final String authorName;
  final String authorAddress;
  final DateTime createdAt;
  final String? price;
  final String? imagePath;
  final bool isActive;
  final List<String> interestedUsers;

  const Advertisement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.authorName,
    required this.authorAddress,
    required this.createdAt,
    this.price,
    this.imagePath,
    this.isActive = true,
    this.interestedUsers = const [],
  });

  Advertisement copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? authorName,
    String? authorAddress,
    DateTime? createdAt,
    String? price,
    String? imagePath,
    bool? isActive,
    List<String>? interestedUsers,
  }) {
    return Advertisement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      authorName: authorName ?? this.authorName,
      authorAddress: authorAddress ?? this.authorAddress,
      createdAt: createdAt ?? this.createdAt,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      interestedUsers: interestedUsers ?? this.interestedUsers,
    );
  }
}

enum AdvertisementType {
  sale,
  free,
}



extension AdvertisementTypeExtension on AdvertisementType {
  String get displayName {
    switch (this) {
      case AdvertisementType.sale:
        return 'Продажа';
      case AdvertisementType.free:
        return 'Даром';
    }
  }

  String get buttonText {
    switch (this) {
      case AdvertisementType.sale:
        return 'Купить';
      case AdvertisementType.free:
        return 'Забрать';
    }
  }

  String get value {
    switch (this) {
      case AdvertisementType.sale:
        return 'sale';
      case AdvertisementType.free:
        return 'free';
    }
  }
}

 