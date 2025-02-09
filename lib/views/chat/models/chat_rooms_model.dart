class ChatRooms {
  final String id;
  final String postTitle;
  final String offerTitle;
  final String profile;
  final String username;
  final int unreadMessageCount;
  final DateTime? lastMessageSendAt; // เปลี่ยนเป็น nullable
  final String postID;
  final String offerID;

  ChatRooms({
    required this.id,
    required this.postTitle,
    required this.offerTitle,
    required this.profile,
    required this.username,
    required this.unreadMessageCount,
    this.lastMessageSendAt, // เปลี่ยนเป็น nullable
    required this.postID,
    required this.offerID,
  });

  factory ChatRooms.fromJson(Map<String, dynamic> json) {
    return ChatRooms(
      id: json['id'] as String,
      postTitle: json['post_title'] as String,
      offerTitle: json['offer_title'] as String,
      profile: json['profile'] as String,
      username: json['username'] as String,
      unreadMessageCount: json['unread_message_count'] as int,
      lastMessageSendAt: json['last_message_send_at'] != null
          ? DateTime.tryParse(
              json['last_message_send_at']) // ใช้ tryParse เพื่อกัน error
          : null, // กำหนดค่า null ถ้าไม่มีข้อมูล
      postID: json['post_id'] as String,
      offerID: json['offer_id'] as String,
    );
  }
}
