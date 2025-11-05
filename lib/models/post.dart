class Post {
  final String id;
  final String authorName;
  final String authorAddress;
  final String text;
  final String? imagePath;
  final DateTime createdAt;
  final List<String> likedBy;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.authorName,
    required this.authorAddress,
    required this.text,
    this.imagePath,
    required this.createdAt,
    List<String>? likedBy,
    List<Comment>? comments,
  }) : likedBy = likedBy ?? [],
       comments = comments ?? [];

  int get likesCount => likedBy.length;
  int get commentsCount => comments.length;

  Post copyWith({
    String? id,
    String? authorName,
    String? authorAddress,
    String? text,
    String? imagePath,
    DateTime? createdAt,
    List<String>? likedBy,
    List<Comment>? comments,
  }) {
    return Post(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAddress: authorAddress ?? this.authorAddress,
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      likedBy: likedBy ?? this.likedBy,
      comments: comments ?? this.comments,
    );
  }
}

class Comment {
  final String id;
  final String authorName;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });
} 