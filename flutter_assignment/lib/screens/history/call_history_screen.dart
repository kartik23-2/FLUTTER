import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/call_model.dart';
import '../../services/calling_service.dart';

class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final callProvider = Provider.of<CallProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final history = callProvider.callHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.historyTitle),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Clear Call History',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear History'),
                    content: const Text('Are you sure you want to clear all call history logs?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          callProvider.clearHistory();
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Clear', style: TextStyle(color: AppColors.endCall)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No call history yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final call = history[index];
                final isVideo = call.type == CallType.video;
                final isMissed = call.state == CallState.missed || call.state == CallState.rejected;
                final peerName = call.isIncoming ? call.callerName : call.receiverName;
                final peerAvatar = call.isIncoming ? call.callerAvatar : call.receiverAvatar;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(peerAvatar),
                    ),
                    title: Text(
                      peerName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isMissed ? AppColors.endCall : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              call.isIncoming
                                  ? (isMissed ? Icons.call_missed_rounded : Icons.call_received_rounded)
                                  : Icons.call_made_rounded,
                              size: 16,
                              color: isMissed
                                  ? AppColors.endCall
                                  : (call.isIncoming ? AppColors.online : AppColors.primary),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${isVideo ? "Video Call" : "Audio Call"} • ${call.isIncoming ? "Incoming" : "Outgoing"}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormatter.formatCallTimestamp(call.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          isVideo ? Icons.videocam_rounded : Icons.phone_rounded,
                          size: 20,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isMissed ? 'Missed' : DateFormatter.formatDuration(call.durationSeconds),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isMissed ? AppColors.endCall : AppColors.online,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
