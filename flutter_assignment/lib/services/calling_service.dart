import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/call_model.dart';
import '../models/user_model.dart';

class CallProvider with ChangeNotifier {
  CallModel? _activeCall;
  List<CallModel> _callHistory = [];
  
  // Call Controls State
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isCameraOn = true;
  bool _isFrontCamera = true;
  NetworkQuality _networkQuality = NetworkQuality.good;

  // Hardware Camera
  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = [];
  bool _isCameraInitialized = false;

  // Timers
  Timer? _callTimer;
  Timer? _stateTimer;
  Timer? _networkTimer;
  int _callDurationSeconds = 0;

  static const String _callHistoryKey = 'connect_call_history';
  final _uuid = const Uuid();

  CallModel? get activeCall => _activeCall;
  List<CallModel> get callHistory => List.unmodifiable(_callHistory);
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isCameraOn => _isCameraOn;
  bool get isFrontCamera => _isFrontCamera;
  NetworkQuality get networkQuality => _networkQuality;
  int get callDurationSeconds => _callDurationSeconds;
  CameraController? get cameraController => _cameraController;
  bool get isCameraInitialized => _isCameraInitialized;

  CallProvider() {
    _loadCallHistory();
    _initHardwareCameras();
  }

  Future<void> _loadCallHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyStr = prefs.getStringList(_callHistoryKey);

    if (historyStr != null && historyStr.isNotEmpty) {
      try {
        _callHistory = historyStr
            .map((item) => CallModel.fromJson(jsonDecode(item)))
            .toList();
      } catch (e) {
        _callHistory = [];
      }
    } else {
      // Pre-populate realistic mock call history
      _callHistory = [
        CallModel(
          id: _uuid.v4(),
          callerId: 'usr_1',
          callerName: 'Sarah Johnson',
          callerAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
          receiverId: 'user_me',
          receiverName: 'Alex Rivers',
          receiverAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
          type: CallType.video,
          state: CallState.inCall,
          durationSeconds: 155,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isIncoming: true,
        ),
        CallModel(
          id: _uuid.v4(),
          callerId: 'user_me',
          callerName: 'Alex Rivers',
          callerAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
          receiverId: 'usr_2',
          receiverName: 'John Smith',
          receiverAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
          type: CallType.audio,
          state: CallState.missed,
          durationSeconds: 0,
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
          isIncoming: false,
        ),
        CallModel(
          id: _uuid.v4(),
          callerId: 'usr_3',
          callerName: 'Alex Wilson',
          callerAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
          receiverId: 'user_me',
          receiverName: 'Alex Rivers',
          receiverAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
          type: CallType.video,
          state: CallState.inCall,
          durationSeconds: 412,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isIncoming: true,
        ),
      ];
      _saveCallHistory();
    }
    notifyListeners();
  }

  Future<void> _saveCallHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyStr = _callHistory.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_callHistoryKey, historyStr);
  }

  Future<void> _initHardwareCameras() async {
    try {
      _availableCameras = await availableCameras();
    } catch (e) {
      _availableCameras = [];
    }
  }

  Future<bool> requestCallPermissions({required bool isVideo}) async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted && !micStatus.isLimited) {
      return false;
    }

    if (isVideo) {
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted && !cameraStatus.isLimited) {
        return false;
      }
    }
    return true;
  }

  Future<void> initializeCameraStream() async {
    if (_availableCameras.isEmpty) {
      try {
        _availableCameras = await availableCameras();
      } catch (e) {
        _isCameraInitialized = false;
        notifyListeners();
        return;
      }
    }

    if (_availableCameras.isEmpty) return;

    final targetLens = _isFrontCamera
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    CameraDescription? camera = _availableCameras.firstWhere(
      (c) => c.lensDirection == targetLens,
      orElse: () => _availableCameras.first,
    );

    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }

    try {
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      _isCameraInitialized = true;
    } catch (e) {
      _isCameraInitialized = false;
    }
    notifyListeners();
  }

  Future<void> startCall({
    required UserModel targetUser,
    required UserModel currentUser,
    required CallType type,
  }) async {
    // Reset controls
    _isMuted = false;
    _isSpeakerOn = true;
    _isCameraOn = type == CallType.video;
    _isFrontCamera = true;
    _callDurationSeconds = 0;
    _networkQuality = NetworkQuality.good;

    if (type == CallType.video) {
      await initializeCameraStream();
    }

    _activeCall = CallModel(
      id: _uuid.v4(),
      callerId: currentUser.id,
      callerName: currentUser.name,
      callerAvatar: currentUser.avatarUrl,
      receiverId: targetUser.id,
      receiverName: targetUser.name,
      receiverAvatar: targetUser.avatarUrl,
      type: type,
      state: CallState.calling,
      timestamp: DateTime.now(),
      isIncoming: false,
    );
    notifyListeners();

    // Transition calling -> ringing -> connected / inCall
    _stateTimer?.cancel();
    _stateTimer = Timer(const Duration(seconds: 2), () {
      if (_activeCall != null && _activeCall!.state == CallState.calling) {
        _activeCall = _activeCall!.copyWith(state: CallState.ringing);
        notifyListeners();

        _stateTimer = Timer(const Duration(seconds: 2), () {
          if (_activeCall != null && _activeCall!.state == CallState.ringing) {
            _connectActiveCall();
          }
        });
      }
    });
  }

  void receiveIncomingCall({
    required UserModel caller,
    required UserModel currentUser,
    required CallType type,
  }) {
    _isMuted = false;
    _isSpeakerOn = true;
    _isCameraOn = type == CallType.video;
    _callDurationSeconds = 0;

    _activeCall = CallModel(
      id: _uuid.v4(),
      callerId: caller.id,
      callerName: caller.name,
      callerAvatar: caller.avatarUrl,
      receiverId: currentUser.id,
      receiverName: currentUser.name,
      receiverAvatar: currentUser.avatarUrl,
      type: type,
      state: CallState.ringing,
      timestamp: DateTime.now(),
      isIncoming: true,
    );
    notifyListeners();
  }

  Future<void> acceptCall() async {
    if (_activeCall == null) return;
    if (_activeCall!.type == CallType.video) {
      await initializeCameraStream();
    }
    _connectActiveCall();
  }

  void rejectCall() {
    if (_activeCall == null) return;

    final endedCall = _activeCall!.copyWith(
      state: CallState.rejected,
      durationSeconds: 0,
    );

    _addCallToHistory(endedCall);
    _cleanupCallState();
  }

  void _connectActiveCall() {
    if (_activeCall == null) return;

    _activeCall = _activeCall!.copyWith(state: CallState.inCall);
    _startCallTimer();
    _startNetworkMonitor();
    notifyListeners();
  }

  void _startCallTimer() {
    _callTimer?.cancel();
    _callDurationSeconds = 0;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _callDurationSeconds++;
      if (_activeCall != null) {
        _activeCall = _activeCall!.copyWith(durationSeconds: _callDurationSeconds);
      }
      notifyListeners();
    });
  }

  void _startNetworkMonitor() {
    _networkTimer?.cancel();
    // Periodically simulate realistic network variance
    _networkTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      final qualities = [NetworkQuality.good, NetworkQuality.good, NetworkQuality.fair, NetworkQuality.good];
      _networkQuality = qualities[timer.tick % qualities.length];
      notifyListeners();
    });
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  void toggleSpeaker() {
    _isSpeakerOn = !_isSpeakerOn;
    notifyListeners();
  }

  Future<void> toggleCamera() async {
    _isCameraOn = !_isCameraOn;
    if (_isCameraOn) {
      await initializeCameraStream();
    } else {
      if (_cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
        _isCameraInitialized = false;
      }
    }
    notifyListeners();
  }

  Future<void> switchCameraFacing() async {
    _isFrontCamera = !_isFrontCamera;
    if (_isCameraOn) {
      await initializeCameraStream();
    }
    notifyListeners();
  }

  Future<void> endCall() async {
    if (_activeCall == null) return;

    final endedCall = _activeCall!.copyWith(
      state: CallState.ended,
      durationSeconds: _callDurationSeconds,
    );

    _addCallToHistory(endedCall);
    _cleanupCallState();
  }

  void _addCallToHistory(CallModel call) {
    _callHistory.insert(0, call);
    _saveCallHistory();
  }

  Future<void> _cleanupCallState() async {
    _callTimer?.cancel();
    _stateTimer?.cancel();
    _networkTimer?.cancel();
    _callTimer = null;
    _stateTimer = null;
    _networkTimer = null;

    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
      _isCameraInitialized = false;
    }

    _activeCall = null;
    notifyListeners();
  }

  void clearHistory() {
    _callHistory.clear();
    _saveCallHistory();
    notifyListeners();
  }
}
