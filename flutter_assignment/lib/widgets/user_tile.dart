import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/user_model.dart';

class UserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onAudioCall;
  final VoidCallback onVideoCall;
  final VoidCallback? onBlockToggle;
  final VoidCallback? onSimulateIncomingCall;

  const UserTile({
    super.key,
    required this.user,
    required this.onAudioCall,
    required this.onVideoCall,
    this.onBlockToggle,
    this.onSimulateIncomingCall,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(user.avatarUrl),
              backgroundColor: AppColors.primary.withOpacity(0.1),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: user.isBlocked
                      ? AppColors.endCall
                      : (user.isOnline ? AppColors.online : AppColors.offline),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          user.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            decoration: user.isBlocked ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          user.isBlocked
              ? 'Blocked'
              : (user.isOnline ? 'Online' : 'Offline'),
          style: TextStyle(
            fontSize: 13,
            color: user.isBlocked
                ? AppColors.endCall
                : (user.isOnline ? AppColors.online : AppColors.offline),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.phone_rounded, color: AppColors.primary),
              tooltip: 'Start Audio Call',
              onPressed: user.isBlocked ? null : onAudioCall,
            ),
            IconButton(
              icon: const Icon(Icons.videocam_rounded, color: AppColors.secondary),
              tooltip: 'Start Video Call',
              onPressed: user.isBlocked ? null : onVideoCall,
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              onSelected: (value) {
                if (value == 'block' && onBlockToggle != null) {
                  onBlockToggle!();
                } else if (value == 'simulate' && onSimulateIncomingCall != null) {
                  onSimulateIncomingCall!();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'simulate',
                  child: Row(
                    children: const [
                      Icon(Icons.call_received_rounded, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Simulate Incoming Call'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'block',
                  child: Row(
                    children: [
                      Icon(
                        user.isBlocked ? Icons.check_circle_outline : Icons.block_rounded,
                        size: 18,
                        color: user.isBlocked ? AppColors.online : AppColors.endCall,
                      ),
                      const SizedBox(width: 8),
                      Text(user.isBlocked ? 'Unblock User' : 'Block User'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
