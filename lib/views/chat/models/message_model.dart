class Message {
  final String content;
  final String type;
  final DateTime sendAt;
  final String username;

  Message({
    required this.content,
    required this.type,
    required this.sendAt,
    required this.username,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'],
      type: json['type'],
      sendAt: DateTime.parse(json['send_at']),
      username: json['username'],
    );
  }
}
