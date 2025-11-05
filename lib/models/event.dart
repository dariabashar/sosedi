class Event {
  final String id;
  final String title;
  final String date;
  final String location;
  final int participantCount;
  final String? description;
  final String? imageUrl;
  final String? videoUrl;
  final List<String> participants;

  const Event({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.participantCount,
    this.description,
    this.imageUrl,
    this.videoUrl,
    this.participants = const [],
  });

  Event copyWith({
    String? id,
    String? title,
    String? date,
    String? location,
    int? participantCount,
    String? description,
    String? imageUrl,
    String? videoUrl,
    List<String>? participants,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      location: location ?? this.location,
      participantCount: participantCount ?? this.participantCount,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      participants: participants ?? this.participants,
    );
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      location: json['location'] as String,
      participantCount: json['participant_count'] as int,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      participants: (json['participants'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'location': location,
      'participant_count': participantCount,
      'description': description,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'participants': participants,
    };
  }
} 