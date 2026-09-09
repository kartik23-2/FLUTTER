import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/call_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/calling_service.dart';
import '../../services/user_service.dart';
import '../../widgets/user_tile.dart';
import '../call/audio_call_screen.dart';
import '../call/video_call_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startCall(BuildContext context, UserModel targetUser, CallType type) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final callProvider = Provider.of<CallProvider>(context, listen: false);

    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    final isVideo = type == CallType.video;
    final hasPerms = await callProvider.requestCallPermissions(isVideo: isVideo);
    if (!context.mounted) return;

    if (!hasPerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isVideo
                ? 'Camera & Microphone permissions required for video call'
                : 'Microphone permission required for audio call',
          ),
        ),
      );
      return;
    }

    await callProvider.startCall(
      targetUser: targetUser,
      currentUser: currentUser,
      type: type,
    );

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => isVideo ? const VideoCallScreen() : const AudioCallScreen(),
      ),
    );
  }

  void _simulateIncomingCall(BuildContext context, UserModel callerUser) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    final currentUser = auth.currentUser;

    if (currentUser == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Simulate Call from ${callerUser.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.phone_rounded),
              label: const Text('Simulate Incoming Audio Call'),
              onPressed: () {
                Navigator.of(ctx).pop();
                callProvider.receiveIncomingCall(
                  caller: callerUser,
                  currentUser: currentUser,
                  type: CallType.audio,
                );
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              icon: const Icon(Icons.videocam_rounded),
              label: const Text('Simulate Incoming Video Call'),
              onPressed: () {
                Navigator.of(ctx).pop();
                callProvider.receiveIncomingCall(
                  caller: callerUser,
                  currentUser: currentUser,
                  type: CallType.video,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final users = userProvider.filteredUsers;

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => userProvider.setSearchQuery(val),
            decoration: InputDecoration(
              hintText: AppStrings.searchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        userProvider.setSearchQuery('');
                      },
                    )
                  : null,
            ),
          ),
        ),

        // User list
        Expanded(
          child: users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off_rounded,
                        size: 64,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No contacts found',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return UserTile(
                      user: user,
                      onAudioCall: () => _startCall(context, user, CallType.audio),
                      onVideoCall: () => _startCall(context, user, CallType.video),
                      onBlockToggle: () => userProvider.toggleBlockUser(user.id),
                      onSimulateIncomingCall: () => _simulateIncomingCall(context, user),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
