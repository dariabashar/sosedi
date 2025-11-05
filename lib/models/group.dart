class Group {
  final String id;
  final String name;
  final String description;
  final String authorName;
  final String authorAddress;
  final DateTime createdAt;
  final int memberCount;
  final bool isMyGroup; // входит ли текущий пользователь в группу
  final List<String> members; // ID участников

  const Group({
    required this.id,
    required this.name,
    required this.description,
    required this.authorName,
    required this.authorAddress,
    required this.createdAt,
    required this.memberCount,
    this.isMyGroup = false,
    this.members = const [],
  });

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? authorName,
    String? authorAddress,
    DateTime? createdAt,
    int? memberCount,
    bool? isMyGroup,
    List<String>? members,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      authorName: authorName ?? this.authorName,
      authorAddress: authorAddress ?? this.authorAddress,
      createdAt: createdAt ?? this.createdAt,
      memberCount: memberCount ?? this.memberCount,
      isMyGroup: isMyGroup ?? this.isMyGroup,
      members: members ?? this.members,
    );
  }
} 