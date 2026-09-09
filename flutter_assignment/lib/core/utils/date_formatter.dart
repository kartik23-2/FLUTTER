import 'package:intl/intl.dart';

class DateFormatter {
  static String formatCallTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final callDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    final timeStr = DateFormat('h:mm a').format(timestamp);

    if (callDate == today) {
      return 'Today, $timeStr';
    } else if (callDate == yesterday) {
      return 'Yesterday, $timeStr';
    } else {
      return '${DateFormat('MMM d').format(timestamp)}, $timeStr';
    }
  }

  static String formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }
}
