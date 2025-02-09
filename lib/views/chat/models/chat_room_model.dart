import 'package:mbea_ssi3_front/views/chat/models/message_model.dart';

class ChatRoom {
  final String date;
  final List<Message> messages;

  ChatRoom({
    required this.date,
    required this.messages,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    var list = json['messages'] as List;
    List<Message> messagesList = list.map((i) => Message.fromJson(i)).toList();

    return ChatRoom(
      date: json['date'],
      messages: messagesList,
    );
  }
}
