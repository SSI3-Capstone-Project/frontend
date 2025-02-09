import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/chat/controllers/chat_room_controller.dart';
import 'package:mbea_ssi3_front/views/chat/controllers/websocket_controller.dart';
import 'package:mbea_ssi3_front/views/chat/models/message_model.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/get_profile_controller.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ChatRoom extends StatefulWidget {
  final String roomID;
  final String anotherUsername;
  final String anotherUserImage;
  const ChatRoom(
      {Key? key,
      required this.roomID,
      required this.anotherUsername,
      required this.anotherUserImage})
      : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final ChatRoomController chatRoomController = Get.put(ChatRoomController());
  final ChatController chatController = Get.put(ChatController());
  final UserProfileController userProfileController =
      Get.put(UserProfileController());
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('th');
    chatController.fetchMessages(widget.roomID);
    chatController.connectWebSocket(widget.roomID);
    chatController.updateChatMessageStatus(widget.roomID);
  }

  @override
  void dispose() {
    chatController.closeWebSocket();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(125, 242, 242, 242),
        surfaceTintColor: Color.fromARGB(125, 242, 242, 242),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            chatController.closeWebSocket();
            chatController.closeChatRoom();
            await chatRoomController.fetchChatRooms();
            Get.back();
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.anotherUserImage),
            ),
            const SizedBox(width: 10),
            Text(widget.anotherUsername,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            const Text("• กำลังพุดคุย",
                style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF5BD207),
                    fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Container(
              decoration: BoxDecoration(
                color: Constants.primaryColor, // พื้นหลังสีฟ้า
                borderRadius: BorderRadius.circular(100), // ขอบมน 20px ทุกมุม
              ),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
              child: Text("ดูรายละเอียด",
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20), // มุมซ้ายบนโค้ง 30px
                bottomRight: Radius.circular(20), // มุมขวาล่างโค้ง 30px
              ),
              color: Color.fromARGB(125, 242, 242, 242),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    leaveChatRoom();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Constants.secondaryColor, // พื้นหลังสีฟ้า
                      borderRadius:
                          BorderRadius.circular(10), // ขอบมน 20px ทุกมุม
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Text("ปฏิเสธการแลกเปลี่ยน",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      color: Constants.primaryColor, // พื้นหลังสีฟ้า
                      borderRadius:
                          BorderRadius.circular(10), // ขอบมน 20px ทุกมุม
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text("ยืนยันแลกเปลี่ยน",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              var allMessages = chatController.chatRooms
                  .expand((room) => room.messages)
                  .toList();

              // เรียงตามเวลา (จากเก่าไปใหม่)
              allMessages.sort((a, b) => a.sendAt.compareTo(b.sendAt));

              // กลับลำดับข้อความให้ใหม่อยู่ล่างสุด
              allMessages = allMessages.reversed.toList();

              return ListView.builder(
                reverse: true, // ทำให้ ListView กลับหัว
                itemCount: allMessages.length,
                itemBuilder: (context, index) {
                  final message = allMessages[index];
                  bool isMe = message.username ==
                      userProfileController.userProfile.value!.username;
                  String messageDate =
                      DateFormat('yyyy-MM-dd').format(message.sendAt.toLocal());

                  // ปรับเงื่อนไขแสดงวันที่ โดยเทียบกับข้อความถัดไป
                  bool showDateHeader = index == allMessages.length - 1 ||
                      DateFormat('yyyy-MM-dd').format(
                              allMessages[index + 1].sendAt.toLocal()) !=
                          messageDate;

                  return Column(
                    children: [
                      if (showDateHeader) _buildDateHeader(message.sendAt),
                      _buildMessageBubble(message, isMe),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  );
                },
              );
            }),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  /// แสดงวันที่คั่นกลางระหว่างข้อความ
  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            DateFormat('d MMM yy', 'th').format(date.toLocal()), // 20 ม.ค. 68
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ),
      ),
    );
  }

  /// แสดงข้อความในรูปแบบ Bubble (แยกฝั่งซ้าย-ขวา)
  Widget _buildMessageBubble(Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? Constants.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 5),
            Text(
              DateFormat('HH:mm')
                  .format(message.sendAt.toLocal()), // เวลา HH:MM
              style: TextStyle(
                  fontSize: 12, color: isMe ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  /// แสดงช่องพิมพ์ข้อความ
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color.fromARGB(125, 242, 242, 242),
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.camera_alt), onPressed: () {}),
          IconButton(icon: const Icon(Icons.image), onPressed: () {}),
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100), // กำหนดขอบมน
                  borderSide: BorderSide(color: Colors.grey.shade300), // สีขอบ
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100), // ขอบมนตอนโฟกัส
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                hintText: "ข้อความ",
                hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Constants.primaryColor),
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                chatController.sendMessage(
                    messageController.text, widget.roomID);
                messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  void leaveChatRoom() {
    // การทำงานเมื่อกดปุ่มลบ
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Form(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Text(
                              'ยืนยันการปฏิเสธ',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                          ),
                          Text(
                            'คุณต้องการยกเลิกการแลกเปลี่ยนครั้งนี้ใช่หรือไม่?',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.normal),
                          ),
                          const SizedBox(height: 30),
                          _buildSubmitLeaveChatRoom(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  // ปุ่ม X ที่มุมขวาบน
                  Positioned(
                    right: 15,
                    top: 15,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context); // ปิด Dialog
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Constants.secondaryColor),
                        child: Icon(
                          Icons.close,
                          size: 21,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubmitLeaveChatRoom() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 100,
        child: ElevatedButton(
          onPressed: () async {
            await chatController.leaveChatRoom(widget.roomID);
            await chatRoomController.fetchChatRooms();
            Navigator.pop(context);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Constants.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(
            'ยื่นยัน',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
