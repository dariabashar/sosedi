import 'post.dart';

class GroupPost {
  final String id;
  final String groupId; // ID группы
  final String authorName;
  final String authorAddress;
  final String text;
  final String? imagePath;
  final DateTime createdAt;
  final List<String> likedBy;
  final List<Comment> comments;

  GroupPost({
    required this.id,
    required this.groupId,
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

  GroupPost copyWith({
    String? id,
    String? groupId,
    String? authorName,
    String? authorAddress,
    String? text,
    String? imagePath,
    DateTime? createdAt,
    List<String>? likedBy,
    List<Comment>? comments,
  }) {
    return GroupPost(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
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