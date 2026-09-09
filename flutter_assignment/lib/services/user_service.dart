import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  List<UserModel> _users = [];
  String _searchQuery = '';
  static const String _blockedUsersKey = 'connect_call_blocked_users';

  List<UserModel> get users => _users;
  String get searchQuery => _searchQuery;

  List<UserModel> get filteredUsers {
    if (_searchQuery.trim().isEmpty) {
      return _users;
    }
    return _users
        .where((u) => u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            u.email.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<UserModel> get blockedUsers => _users.where((u) => u.isBlocked).toList();

  UserProvider() {
    _initMockUsers();
  }

  Future<void> _initMockUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> blockedIds = prefs.getStringList(_blockedUsersKey) ?? [];

    final initialUsers = [
      UserModel(
        id: 'usr_1',
        name: 'Sarah Johnson',
        email: 'sarah.j@example.com',
        phone: '+1 (555) 123-4567',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
        isOnline: true,
      ),
      UserModel(
        id: 'usr_2',
        name: 'John Smith',
        email: 'john.smith@example.com',
        phone: '+1 (555) 987-6543',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
        isOnline: false,
      ),
      UserModel(
        id: 'usr_3',
        name: 'Alex Wilson',
        email: 'alex.w@example.com',
        phone: '+1 (555) 456-7890',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        isOnline: true,
      ),
      UserModel(
        id: 'usr_4',
        name: 'Sarah Williams',
        email: 'sarah.williams@example.com',
        phone: '+1 (555) 321-7654',
        avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
        isOnline: true,
      ),
      UserModel(
        id: 'usr_5',
        name: 'Michael Brown',
        email: 'michael.b@example.com',
        phone: '+1 (555) 654-3210',
        avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=400',
        isOnline: false,
      ),
      UserModel(
        id: 'usr_6',
        name: 'Emily Davis',
        email: 'emily.davis@example.com',
        phone: '+1 (555) 890-1234',
        avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
        isOnline: true,
      ),
    ];

    _users = initialUsers.map((u) {
      return u.copyWith(isBlocked: blockedIds.contains(u.id));
    }).toList();

    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> toggleBlockUser(String userId) async {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final updated = _users[index].copyWith(isBlocked: !_users[index].isBlocked);
      _users[index] = updated;

      final prefs = await SharedPreferences.getInstance();
      final blockedIds = _users.where((u) => u.isBlocked).map((u) => u.id).toList();
      await prefs.setStringList(_blockedUsersKey, blockedIds);

      notifyListeners();
    }
  }

  UserModel? getUserById(String userId) {
    try {
      return _users.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }
}
