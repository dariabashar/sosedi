import 'package:flutter/material.dart';
import 'dart:io';
import '../../../models/group.dart';
import '../../../models/group_post.dart';
import '../../../models/post.dart';
import '../services/group_service.dart';
import 'create_group_post_screen.dart';
import '../../profile/screens/user_profile_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;
  final Function(Group) onGroupUpdated;

  const GroupDetailScreen({
    super.key,
    required this.group,
    required this.onGroupUpdated,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late Group _group;
  final GroupService _groupService = GroupService();
  final String _currentUserId = 'current_user_id';

  @override
  void initState() {
    super.initState();
    _group = widget.group;
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'только что';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч назад';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн назад';
    } else {
      return '${(difference.inDays / 7).floor()} нед назад';
    }
  }

  void _toggleMembership() {
    setState(() {
      if (_group.isMyGroup) {
        _groupService.leaveGroup(_group.id);
        _group = _group.copyWith(
          isMyGroup: false,
          memberCount: _group.memberCount - 1,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вы покинули группу'),
            backgroundColor: Colors.grey,
          ),
        );
      } else {
        _groupService.joinGroup(_group.id);
        _group = _group.copyWith(
          isMyGroup: true,
          memberCount: _group.memberCount + 1,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вы присоединились к группе!'),
            backgroundColor: Color(0xFFFF6B6B),
          ),
        );
      }
    });
    widget.onGroupUpdated(_group);
  }

  void _toggleLike(String postId) {
    setState(() {
      final posts = _groupService.getGroupPosts(_group.id);
      final postIndex = posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = posts[postIndex];
        final isLiked = post.likedBy.contains(_currentUserId);
        
        List<String> newLikedBy = List.from(post.likedBy);
        if (isLiked) {
          newLikedBy.remove(_currentUserId);
        } else {
          newLikedBy.add(_currentUserId);
        }
        
        final updatedPost = post.copyWith(likedBy: newLikedBy);
        _groupService.updateGroupPost(updatedPost);
      }
    });
  }

  void _openPostDiscussion(GroupPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupPostDiscussionScreen(
          post: post,
          onPostUpdated: (updatedPost) {
            setState(() {
              _groupService.updateGroupPost(updatedPost);
            });
          },
        ),
      ),
    );
  }

  void _showPostMenu(GroupPost post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text('Пожаловаться'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Жалоба отправлена')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.grey),
              title: const Text('Скрыть пост'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  // В реальном приложении бы удаляли из списка
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Пост скрыт')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addNewPost(String text, String? imagePath) {
    final newPost = GroupPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: _group.id,
      authorName: 'Алексей Иванов',
      authorAddress: 'ул. Ленина, д. 5, кв. 32',
      text: text,
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );

    setState(() {
      _groupService.addGroupPost(newPost);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Пост опубликован в группе!'),
        backgroundColor: Color(0xFFFF6B6B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final posts = _groupService.getGroupPosts(_group.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          _group.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Информация о группе
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.group,
                        color: Color(0xFFFF6B6B),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _group.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_group.memberCount} участников',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '• ${_getTimeAgo(_group.createdAt)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _group.description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _toggleMembership,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _group.isMyGroup 
                              ? Colors.grey[300] 
                              : const Color(0xFFFF6B6B),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _group.isMyGroup ? 'Покинуть группу' : 'Присоединиться',
                          style: TextStyle(
                            color: _group.isMyGroup ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (_group.isMyGroup) ...[
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CreateGroupPostScreen(
                                groupName: _group.name,
                                onPostCreated: _addNewPost,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Разделитель
          Container(
            height: 8,
            color: const Color(0xFFF5F5F5),
          ),
          // Посты группы
          Expanded(
            child: posts.isEmpty
                ? _buildEmptyPosts()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: posts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildPost(posts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPosts() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            'Пока нет постов',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _group.isMyGroup
                ? 'Станьте первым, кто поделится\nновостями в группе!'
                : 'Присоединитесь к группе, чтобы\nвидеть посты и участвовать в обсуждениях',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPost(GroupPost post) {
    final isLiked = post.likedBy.contains(_currentUserId);
    final timeAgo = _getTimeAgo(post.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and menu
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(
                          userName: post.authorName,
                          userAddress: post.authorAddress,
                          context: 'поста в группе',
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          post.authorName[0],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.authorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  post.authorAddress,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  ' • $timeAgo',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showPostMenu(post),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_horiz,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Post text
          Text(
            post.text,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
          if (post.imagePath != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(post.imagePath!),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Actions
          Row(
            children: [
              // Like button
              GestureDetector(
                onTap: () => _toggleLike(post.id),
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 22,
                      color: isLiked ? Colors.red : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${post.likesCount}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Comments button
              GestureDetector(
                onTap: () => _openPostDiscussion(post),
                child: Row(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 22,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${post.commentsCount}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Экран обсуждения поста группы (упрощенная версия)
class GroupPostDiscussionScreen extends StatefulWidget {
  final GroupPost post;
  final Function(GroupPost) onPostUpdated;

  const GroupPostDiscussionScreen({
    super.key,
    required this.post,
    required this.onPostUpdated,
  });

  @override
  State<GroupPostDiscussionScreen> createState() => _GroupPostDiscussionScreenState();
}

class _GroupPostDiscussionScreenState extends State<GroupPostDiscussionScreen> {
  late GroupPost _post;
  final TextEditingController _commentController = TextEditingController();
  final String _currentUserId = 'current_user_id';

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: 'Алексей Иванов',
      text: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    setState(() {
      _post = _post.copyWith(
        comments: [..._post.comments, newComment],
      );
    });

    widget.onPostUpdated(_post);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Обсуждение',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Пост (упрощенная версия)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Text(
              _post.text,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
          const Divider(height: 1),
          // Комментарии
          Expanded(
            child: _post.comments.isEmpty
                ? const Center(
                    child: Text(
                      'Пока нет комментариев',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _post.comments.length,
                    itemBuilder: (context, index) {
                      final comment = _post.comments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.authorName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(comment.text),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // Поле ввода комментария
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Написать комментарий...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addComment,
                  icon: const Icon(
                    Icons.send,
                    color: Color(0xFFFF6B6B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 