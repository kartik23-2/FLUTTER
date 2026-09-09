import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, String currentName) {
    final nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Provider.of<AuthProvider>(context, listen: false).updateProfile(
                  name: nameController.text.trim(),
                );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blockedList = userProvider.blockedUsers;

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 54,
                backgroundImage: NetworkImage(currentUser.avatarUrl),
                backgroundColor: AppColors.primary.withOpacity(0.1),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                  onPressed: () => _showEditProfileDialog(context, currentUser.name),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            currentUser.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentUser.email,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          if (currentUser.phone.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              currentUser.phone,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Online / Offline status toggle tile
          Card(
            child: SwitchListTile(
              secondary: Icon(
                Icons.circle,
                color: currentUser.isOnline ? AppColors.online : AppColors.offline,
                size: 20,
              ),
              title: const Text('Online Status'),
              subtitle: Text(currentUser.isOnline ? 'Available for calls' : 'Appear Offline'),
              value: currentUser.isOnline,
              onChanged: (_) => auth.toggleOnlineStatus(),
            ),
          ),
          const SizedBox(height: 10),

          // Dark mode toggle tile (Bonus 3)
          Card(
            child: SwitchListTile(
              secondary: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: isDark ? Colors.amber : AppColors.primary,
              ),
              title: const Text('Dark Mode'),
              subtitle: const Text('Support light and dark themes'),
              value: auth.isDarkMode,
              onChanged: (_) => auth.toggleDarkMode(),
            ),
          ),
          const SizedBox(height: 10),

          // Blocked users management (Bonus 4)
          Card(
            child: ListTile(
              leading: const Icon(Icons.block_rounded, color: AppColors.endCall),
              title: const Text('Blocked Contacts'),
              subtitle: Text('${blockedList.length} users blocked'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (ctx) => Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Blocked Contacts',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: blockedList.isEmpty
                              ? const Center(child: Text('No blocked users'))
                              : ListView.builder(
                                  itemCount: blockedList.length,
                                  itemBuilder: (c, i) {
                                    final u = blockedList[i];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(u.avatarUrl),
                                      ),
                                      title: Text(u.name),
                                      trailing: TextButton(
                                        onPressed: () {
                                          userProvider.toggleBlockUser(u.id);
                                          Navigator.of(ctx).pop();
                                        },
                                        child: const Text('Unblock'),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),

          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.endCall,
                side: const BorderSide(color: AppColors.endCall, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                AppStrings.logout,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
