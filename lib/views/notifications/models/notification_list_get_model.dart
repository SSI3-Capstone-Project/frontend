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

  // Convert a single notification from JSON
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      relatedEntityId: json['related_entity_id'],
      relatedType: json['related_type'],
      message: json['message'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Convert a list of notifications from JSON
  static List<Notification> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Notification.fromJson(json)).toList();
  }

  // Convert notification to JSON format
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

  // Convert from JSON response
  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      data: Notification.listFromJson(json['data']),
      message: json['message'],
      status: json['status'],
    );
  }
}
