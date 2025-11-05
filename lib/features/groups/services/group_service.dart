import '../../../models/group.dart';
import '../../../models/group_post.dart';

class GroupService {
  static final GroupService _instance = GroupService._internal();
  factory GroupService() => _instance;
  GroupService._internal();

  final List<Group> _groups = [];
  final List<GroupPost> _groupPosts = [];
  final String _currentUserId = 'current_user_id';

  List<Group> get allGroups => List.unmodifiable(_groups);
  List<Group> get myGroups => _groups.where((group) => group.isMyGroup).toList();
  
  List<GroupPost> getGroupPosts(String groupId) {
    return _groupPosts.where((post) => post.groupId == groupId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Новые сначала
  }

  void addGroup(Group group) {
    _groups.insert(0, group); // Добавляем в начало списка
  }

  void joinGroup(String groupId) {
    final index = _groups.indexWhere((group) => group.id == groupId);
    if (index != -1) {
      final group = _groups[index];
      _groups[index] = group.copyWith(
        isMyGroup: true,
        memberCount: group.memberCount + 1,
        members: [...group.members, _currentUserId],
      );
    }
  }

  void leaveGroup(String groupId) {
    final index = _groups.indexWhere((group) => group.id == groupId);
    if (index != -1) {
      final group = _groups[index];
      _groups[index] = group.copyWith(
        isMyGroup: false,
        memberCount: group.memberCount - 1,
        members: group.members.where((id) => id != _currentUserId).toList(),
      );
    }
  }

  void addGroupPost(GroupPost post) {
    _groupPosts.insert(0, post); // Добавляем в начало списка
  }

  void updateGroupPost(GroupPost updatedPost) {
    final index = _groupPosts.indexWhere((post) => post.id == updatedPost.id);
    if (index != -1) {
      _groupPosts[index] = updatedPost;
    }
  }

  // Инициализация демо данных
  void initializeDemoData() {
    if (_groups.isEmpty) {
      _groups.addAll([
        Group(
          id: 'group_1',
          name: 'Футбол ЖК Энергетик',
          description: 'Играем каждые выходные в футбол на поле за домом. Присоединяйтесь!',
          authorName: 'Дмитрий Козлов',
          authorAddress: 'ул. Энергетиков, д. 12, кв. 45',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          memberCount: 15,
          isMyGroup: true,
          members: ['current_user_id', 'user1', 'user2'],
        ),
        Group(
          id: 'group_2',
          name: 'Молодые мамы',
          description: 'Общение мам с детьми до 3 лет. Делимся опытом, организуем прогулки и встречи.',
          authorName: 'Анна Петрова',
          authorAddress: 'ул. Солнечная, д. 8, кв. 23',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          memberCount: 12,
          isMyGroup: false,
        ),
        Group(
          id: 'group_3',
          name: 'Шахматы в парке',
          description: 'Любители шахмат собираемся по вечерам в парке. Уровень любой!',
          authorName: 'Владимир Смирнов',
          authorAddress: 'ул. Парковая, д. 3, кв. 67',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          memberCount: 8,
          isMyGroup: true,
          members: ['current_user_id', 'user3', 'user4'],
        ),
        Group(
          id: 'group_4',
          name: 'Йога на рассвете',
          description: 'Утренняя йога в 7:00 на детской площадке. Коврики приносим свои.',
          authorName: 'Елена Васильева',
          authorAddress: 'ул. Мирная, д. 15, кв. 89',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          memberCount: 6,
          isMyGroup: false,
        ),
        Group(
          id: 'group_5',
          name: 'Выгуливание собак',
          description: 'Группа владельцев собак для совместных прогулок и общения питомцев.',
          authorName: 'Игорь Волков',
          authorAddress: 'ул. Дружбы, д. 7, кв. 12',
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          memberCount: 20,
          isMyGroup: false,
        ),
      ]);

      // Добавляем демо-посты для группы футбола
      _groupPosts.addAll([
        GroupPost(
          id: 'group_post_1',
          groupId: 'group_1',
          authorName: 'Дмитрий Козлов',
          authorAddress: 'ул. Энергетиков, д. 12, кв. 45',
          text: 'Завтра в 18:00 играем! Кто идет? Нужно еще 2 человека для полного состава.',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          likedBy: ['user1', 'user2'],
        ),
        GroupPost(
          id: 'group_post_2',
          groupId: 'group_1',
          authorName: 'Сергей Иванов',
          authorAddress: 'ул. Энергетиков, д. 14, кв. 78',
          text: 'Я буду! Принесу новый мяч.',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          likedBy: ['current_user_id'],
        ),
        // Для группы шахмат
        GroupPost(
          id: 'group_post_3',
          groupId: 'group_3',
          authorName: 'Владимир Смирнов',
          authorAddress: 'ул. Парковая, д. 3, кв. 67',
          text: 'Сегодня в 19:00 турнир по блицу! Приз - шоколадка 🍫',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          likedBy: ['current_user_id', 'user3'],
        ),
      ]);
    }
  }
} 