enum CallType { audio, video }

enum CallState {
  calling,
  ringing,
  connected,
  inCall,
  ended,
  rejected,
  missed,
  busy,
  failed,
  disconnected,
}

enum NetworkQuality { good, fair, poor }

class CallModel {
  final String id;
  final String callerId;
  final String callerName;
  final String callerAvatar;
  final String receiverId;
  final String receiverName;
  final String receiverAvatar;
  final CallType type;
  final CallState state;
  final int durationSeconds;
  final DateTime timestamp;
  final bool isIncoming;

  CallModel({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.callerAvatar,
    required this.receiverId,
    required this.receiverName,
    required this.receiverAvatar,
    required this.type,
    required this.state,
    this.durationSeconds = 0,
    required this.timestamp,
    required this.isIncoming,
  });

  CallModel copyWith({
    String? id,
    String? callerId,
    String? callerName,
    String? callerAvatar,
    String? receiverId,
    String? receiverName,
    String? receiverAvatar,
    CallType? type,
    CallState? state,
    int? durationSeconds,
    DateTime? timestamp,
    bool? isIncoming,
  }) {
    return CallModel(
      id: id ?? this.id,
      callerId: callerId ?? this.callerId,
      callerName: callerName ?? this.callerName,
      callerAvatar: callerAvatar ?? this.callerAvatar,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverAvatar: receiverAvatar ?? this.receiverAvatar,
      type: type ?? this.type,
      state: state ?? this.state,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      timestamp: timestamp ?? this.timestamp,
      isIncoming: isIncoming ?? this.isIncoming,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'callerId': callerId,
      'callerName': callerName,
      'callerAvatar': callerAvatar,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverAvatar': receiverAvatar,
      'type': type.name,
      'state': state.name,
      'durationSeconds': durationSeconds,
      'timestamp': timestamp.toIso8601String(),
      'isIncoming': isIncoming,
    };
  }

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: json['id'] as String,
      callerId: json['callerId'] as String,
      callerName: json['callerName'] as String,
      callerAvatar: json['callerAvatar'] as String,
      receiverId: json['receiverId'] as String,
      receiverName: json['receiverName'] as String,
      receiverAvatar: json['receiverAvatar'] as String,
      type: CallType.values.byName(json['type'] as String),
      state: CallState.values.byName(json['state'] as String),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isIncoming: json['isIncoming'] as bool? ?? false,
    );
  }
}
