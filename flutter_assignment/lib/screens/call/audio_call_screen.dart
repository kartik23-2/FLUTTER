import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/call_model.dart';
import '../../services/calling_service.dart';
import '../../widgets/call_button.dart';
import '../../widgets/network_quality_badge.dart';

class AudioCallScreen extends StatelessWidget {
  const AudioCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final callProvider = Provider.of<CallProvider>(context);
    final activeCall = callProvider.activeCall;

    if (activeCall == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      });
      return const Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final peerName = activeCall.isIncoming ? activeCall.callerName : activeCall.receiverName;
    final peerAvatar = activeCall.isIncoming ? activeCall.callerAvatar : activeCall.receiverAvatar;

    String stateText;
    switch (activeCall.state) {
      case CallState.calling:
        stateText = AppStrings.calling;
        break;
      case CallState.ringing:
        stateText = AppStrings.ringing;
        break;
      case CallState.connected:
      case CallState.inCall:
        stateText = DateFormatter.formatDuration(callProvider.callDurationSeconds);
        break;
      case CallState.ended:
        stateText = AppStrings.callEnded;
        break;
      case CallState.rejected:
        stateText = AppStrings.callRejected;
        break;
      default:
        stateText = 'Connecting...';
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          callProvider.endCall();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar with Network Quality
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
                      onPressed: () {
                        callProvider.endCall();
                      },
                    ),
                    if (activeCall.state == CallState.inCall)
                      NetworkQualityBadge(quality: callProvider.networkQuality),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const Spacer(),

              // Caller Avatar & Details
              Center(
                child: Column(
                  children: [
                    Text(
                      peerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stateText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 36),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 4),
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(peerAvatar),
                        backgroundColor: AppColors.darkSurface,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Audio Control Buttons (Mute, Speaker, End)
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CallButton(
                      icon: callProvider.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      label: callProvider.isMuted ? AppStrings.unmute : AppStrings.mute,
                      isActive: !callProvider.isMuted,
                      onPressed: () => callProvider.toggleMute(),
                    ),
                    CallButton(
                      icon: callProvider.isSpeakerOn
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      label: AppStrings.speaker,
                      isActive: callProvider.isSpeakerOn,
                      onPressed: () => callProvider.toggleSpeaker(),
                    ),
                    CallButton(
                      icon: Icons.call_end_rounded,
                      label: AppStrings.endCall,
                      backgroundColor: AppColors.endCall,
                      iconColor: Colors.white,
                      onPressed: () async {
                        await callProvider.endCall();
                        if (context.mounted && Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
