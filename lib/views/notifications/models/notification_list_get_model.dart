import 'dart:convert';

class Notification {
  String id;
  String relatedEntityId;
  String relatedType;
  String message;
  bool isRead;
  DateTime createdAt;

  Notification({
    required this.id,
    required this.relatedEntityId,
    required this.relatedType,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  /// **แก้ไขการป้องกันค่า `null`**
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? "",
      relatedEntityId: json['related_entity_id'] ?? "",
      relatedType: json['related_type'] ?? "",
      message: json['message'] ?? "No message",
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'related_entity_id': relatedEntityId,
      'related_type': relatedType,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static List<Notification> listFromJson(List<dynamic>? jsonList) {
    return jsonList != null
        ? jsonList.map((json) => Notification.fromJson(json ?? {})).toList()
        : [];
  }
}

class NotificationResponse {
  List<Notification> data;
  String message;
  int status;

  NotificationResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  /// **แก้ไข: ป้องกัน `null` ใน response**
  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      data: Notification.listFromJson(json['data']),
      message: json['message'] ?? "No message",
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': List<dynamic>.from(data.map((x) => x.toJson())),
      'message': message,
      'status': status,
    };
  }
}
