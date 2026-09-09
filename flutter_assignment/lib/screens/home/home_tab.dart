import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/call_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/calling_service.dart';
import '../../services/user_service.dart';
import '../call/audio_call_screen.dart';
import '../call/video_call_screen.dart';

class HomeTab extends StatelessWidget {
  final Function(int) onTabSwitch;

  const HomeTab({super.key, required this.onTabSwitch});

  void _startAudioCall(BuildContext context, UserModel user) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final callProvider = Provider.of<CallProvider>(context, listen: false);

    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    final hasPerms = await callProvider.requestCallPermissions(isVideo: false);
    if (!hasPerms && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission required for audio call')),
      );
      return;
    }

    await callProvider.startCall(
      targetUser: user,
      currentUser: currentUser,
      type: CallType.audio,
    );

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AudioCallScreen()),
      );
    }
  }

  void _startVideoCall(BuildContext context, UserModel user) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final callProvider = Provider.of<CallProvider>(context, listen: false);

    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    final hasPerms = await callProvider.requestCallPermissions(isVideo: true);
    if (!hasPerms && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera and Microphone permissions required for video call')),
      );
      return;
    }

    await callProvider.startCall(
      targetUser: user,
      currentUser: currentUser,
      type: CallType.video,
    );

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const VideoCallScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final callProvider = Provider.of<CallProvider>(context);

    final currentUser = auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recentCalls = callProvider.callHistory.take(5).toList();
    final contacts = userProvider.users;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Profile Card Header
          if (currentUser != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(currentUser.avatarUrl),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentUser.email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: currentUser.isOnline ? AppColors.online : AppColors.offline,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currentUser.isOnline ? 'Online' : 'Offline',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Quick Search Banner Button
          GestureDetector(
            onTap: () => onTabSwitch(1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.searchHint,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Call / Contacts Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Contacts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => onTabSwitch(1),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final user = contacts[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (ctx) => Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(user.avatarUrl),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    user.name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.phone_rounded),
                                        label: const Text('Audio Call'),
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                          _startAudioCall(context, user);
                                        },
                                      ),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.secondary,
                                        ),
                                        icon: const Icon(Icons.videocam_rounded),
                                        label: const Text('Video Call'),
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                          _startVideoCall(context, user);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(user.avatarUrl),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: user.isOnline ? AppColors.online : AppColors.offline,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.name.split(' ')[0],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Recent Calls Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Calls',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => onTabSwitch(2),
                child: const Text('See History'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (recentCalls.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No recent calls yet',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentCalls.length,
              itemBuilder: (context, index) {
                final call = recentCalls[index];
                final isVideo = call.type == CallType.video;
                final isMissed = call.state == CallState.missed || call.state == CallState.rejected;
                final peerName = call.isIncoming ? call.callerName : call.receiverName;
                final peerAvatar = call.isIncoming ? call.callerAvatar : call.receiverAvatar;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(peerAvatar),
                    ),
                    title: Text(
                      peerName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isMissed ? AppColors.endCall : null,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(
                          call.isIncoming
                              ? (isMissed ? Icons.call_missed_rounded : Icons.call_received_rounded)
                              : Icons.call_made_rounded,
                          size: 14,
                          color: isMissed
                              ? AppColors.endCall
                              : (call.isIncoming ? AppColors.online : AppColors.primary),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isVideo ? "Video" : "Audio"} Call • ${DateFormatter.formatCallTimestamp(call.timestamp)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Text(
                      isMissed ? 'Missed' : DateFormatter.formatDuration(call.durationSeconds),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isMissed
                            ? AppColors.endCall
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
