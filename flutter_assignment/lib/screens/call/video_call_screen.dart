import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/call_model.dart';
import '../../services/calling_service.dart';
import '../../widgets/call_button.dart';
import '../../widgets/network_quality_badge.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key});

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
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Remote Video Background
            Positioned.fill(
              child: Container(
                color: AppColors.darkSurface,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      peerAvatar,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        color: AppColors.darkBackground,
                        child: const Icon(Icons.person_rounded, size: 100, color: Colors.white24),
                      ),
                    ),
                    Container(
                      color: Colors.black.withOpacity(0.4),
                    ),
                    if (activeCall.state != CallState.inCall)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(peerAvatar),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            peerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stateText,
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Top Header Overlay (Peer Info & Network Quality)
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: NetworkImage(peerAvatar),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              peerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              stateText,
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (activeCall.state == CallState.inCall)
                    NetworkQualityBadge(quality: callProvider.networkQuality),
                ],
              ),
            ),

            // Local Camera Picture-in-Picture Preview (Top Right)
            Positioned(
              top: 110,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 110,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white30, width: 1.5),
                  ),
                  child: callProvider.isCameraOn && callProvider.isCameraInitialized
                      ? CameraPreview(callProvider.cameraController!)
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.videocam_off_rounded, color: Colors.white54, size: 28),
                              SizedBox(height: 4),
                              Text(
                                'Camera Off',
                                style: TextStyle(color: Colors.white54, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),

            // Bottom Video Call Controls Overlay
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute / Unmute mic
                    CallButton(
                      icon: callProvider.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      label: callProvider.isMuted ? AppStrings.unmute : AppStrings.mute,
                      isActive: !callProvider.isMuted,
                      onPressed: () => callProvider.toggleMute(),
                    ),

                    // Camera On / Off toggle
                    CallButton(
                      icon: callProvider.isCameraOn
                          ? Icons.videocam_rounded
                          : Icons.videocam_off_rounded,
                      label: AppStrings.camera,
                      isActive: callProvider.isCameraOn,
                      onPressed: () => callProvider.toggleCamera(),
                    ),

                    // Switch Front / Rear Camera
                    CallButton(
                      icon: Icons.cameraswitch_rounded,
                      label: AppStrings.switchCamera,
                      isActive: true,
                      onPressed: () => callProvider.switchCameraFacing(),
                    ),

                    // End Call button
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
            ),
          ],
        ),
      ),
    );
  }
}
