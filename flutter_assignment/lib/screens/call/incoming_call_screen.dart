import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/call_model.dart';
import '../../services/calling_service.dart';
import '../../widgets/call_button.dart';
import 'audio_call_screen.dart';
import 'video_call_screen.dart';

class IncomingCallScreen extends StatelessWidget {
  const IncomingCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final callProvider = Provider.of<CallProvider>(context);
    final activeCall = callProvider.activeCall;

    if (activeCall == null || activeCall.state != CallState.ringing || !activeCall.isIncoming) {
      return const SizedBox.shrink();
    }

    final isVideo = activeCall.type == CallType.video;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          callProvider.rejectCall();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 48),
              Text(
                isVideo ? AppStrings.incomingVideoCall : AppStrings.incomingAudioCall,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                activeCall.callerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),

              // Caller Profile Picture
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 4),
                  ),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(activeCall.callerAvatar),
                  ),
                ),
              ),

              const Spacer(),

              // Accept & Decline Buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 60.0, left: 40, right: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CallButton(
                      icon: Icons.call_end_rounded,
                      label: AppStrings.decline,
                      backgroundColor: AppColors.endCall,
                      iconColor: Colors.white,
                      size: 72,
                      onPressed: () {
                        callProvider.rejectCall();
                      },
                    ),
                    CallButton(
                      icon: isVideo ? Icons.videocam_rounded : Icons.phone_rounded,
                      label: AppStrings.accept,
                      backgroundColor: AppColors.acceptCall,
                      iconColor: Colors.white,
                      size: 72,
                      onPressed: () async {
                        await callProvider.acceptCall();
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => isVideo
                                  ? const VideoCallScreen()
                                  : const AudioCallScreen(),
                            ),
                          );
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
