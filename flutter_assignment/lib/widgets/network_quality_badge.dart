import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/call_model.dart';

class NetworkQualityBadge extends StatelessWidget {
  final NetworkQuality quality;

  const NetworkQualityBadge({super.key, required this.quality});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String text;
    IconData icon;

    switch (quality) {
      case NetworkQuality.good:
        badgeColor = AppColors.qualityGood;
        text = 'HD • Excellent';
        icon = Icons.signal_cellular_alt_rounded;
        break;
      case NetworkQuality.fair:
        badgeColor = AppColors.qualityFair;
        text = 'Fair Connection';
        icon = Icons.signal_cellular_alt_2_bar_rounded;
        break;
      case NetworkQuality.poor:
        badgeColor = AppColors.qualityPoor;
        text = 'Poor Connection';
        icon = Icons.signal_cellular_alt_1_bar_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.6), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeColor, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
