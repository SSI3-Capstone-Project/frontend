import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/chat/controllers/chat_room_controller.dart';
import 'package:mbea_ssi3_front/views/chat/controllers/websocket_controller.dart';
import 'package:mbea_ssi3_front/views/chat/models/message_model.dart';
import 'package:mbea_ssi3_front/views/exchange/controllers/exchange_controller.dart';
import 'package:mbea_ssi3_front/views/exchange/controllers/exchange_product_detail_controller.dart';
import 'package:mbea_ssi3_front/views/exchange/pages/exchange_page.dart'
    as exchange;
import 'package:mbea_ssi3_front/views/exchange/pages/exchange_product_detail_page.dart';
import 'package:mbea_ssi3_front/views/exchange/pages/meet_up_page.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/get_profile_controller.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mbea_ssi3_front/views/exchange/pages/exchange_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ChatRoom extends StatefulWidget {
  final String roomID;
  const ChatRoom({
    Key? key,
    required this.roomID,
  }) : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final ExchangeController exchangeController = Get.put(ExchangeController());
  final ExchangeProductDetailController productDetailController =
      Get.put(ExchangeProductDetailController());
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
        title: Obx(() {
          return Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage:
                    NetworkImage(chatController.otherUerImageProfile.string),
              ),
              const SizedBox(width: 10),
              Text(chatController.otherUername.string,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Text(
                  productDetailController.postDetail.value?.username ==
                          chatController.otherUername.string
                      ? "• เจ้าของโพสต์"
                      : "• เจ้าของข้อเสนอ",
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold)),
            ],
          );
        }),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExchangeProductDetailPage(
                    offerID: chatController.offerID.value,
                    postID: chatController.postID.value,
                  ),
                ),
              );
            },
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
      body: SafeArea(
        child: Column(
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 45, vertical: 10),
                      child: Text("ลบห้องแชท",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      exchangeController.exchange.value = null;
                      await chatController.fetchMessages(widget.roomID);
                      if (chatController.isExchanged.value) {
                        await exchangeController.fetchExchangeDetails(
                            chatController.exchangeID.value);
                      }
                      if (productDetailController.postDetail.value != null &&
                          productDetailController.postDetail.value?.username ==
                              chatController.otherUername.string) {
                        // เราเป็นเจ้าของ Offer
                        if (chatController.isExchanged.value) {
                          if (exchangeController
                                  .exchange.value?.exchangeStage ==
                              4) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MeetUpPage(
                                  exchangeID: chatController.exchangeID.value,
                                  currentStep: 3,
                                  user: Payer.offer,
                                  postID: chatController.postID.value,
                                  offerID: chatController.offerID.value,
                                ),
                              ),
                            );
                          } else if (exchangeController
                                  .exchange.value?.exchangeStage ==
                              3) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MeetUpPage(
                                  exchangeID: chatController.exchangeID.value,
                                  currentStep: 2,
                                  user: Payer.offer,
                                  postID: chatController.postID.value,
                                  offerID: chatController.offerID.value,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MeetUpPage(
                                  exchangeID: chatController.exchangeID.value,
                                  currentStep: 1,
                                  user: Payer.offer,
                                  postID: chatController.postID.value,
                                  offerID: chatController.offerID.value,
                                ),
                              ),
                            );
                          }
                        } else {
                          Get.snackbar("แจ้งเตือน",
                              "กรุณาแจ้งให้เจ้าของโพสต์เป็นผู้เริ่มสร้างการแลกเปลี่ยน");
                        }
                      } else {
                        // เราเป็นเจ้าของ Post
                        if (chatController.isExchanged.value) {
                          if (exchangeController.exchange.value != null &&
                              exchangeController.exchange.value?.status ==
                                  'confirmed') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MeetUpPage(
                                  exchangeID: chatController.exchangeID.value,
                                  currentStep: 3,
                                  user: Payer.post,
                                  postID: chatController.postID.value,
                                  offerID: chatController.offerID.value,
                                ),
                              ),
                            );
                          } else if (exchangeController
                                  .exchange.value?.exchangeStage ==
                              3) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MeetUpPage(
                                  exchangeID: chatController.exchangeID.value,
                                  currentStep: 2,
                                  user: Payer.post,
                                  postID: chatController.postID.value,
                                  offerID: chatController.offerID.value,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MeetUpPage(
                                  exchangeID: chatController.exchangeID.value,
                                  currentStep: 1,
                                  user: Payer.post,
                                  postID: chatController.postID.value,
                                  offerID: chatController.offerID.value,
                                ),
                              ),
                            );
                          }
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExchangePage(
                                postID: chatController.postID.value,
                                offerID: chatController.offerID.value,
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Constants.primaryColor, // พื้นหลังสีฟ้า
                        borderRadius:
                            BorderRadius.circular(10), // ขอบมน 20px ทุกมุม
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                          chatController.isExchanged.value ||
                                  productDetailController
                                          .postDetail.value?.username ==
                                      chatController.otherUername.string
                              ? "ยืนยันการแลกเปลี่ยน"
                              : "สร้างการแลกเปลี่ยน",
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
                        userProfileController.userProfile.value?.username;
                    String messageDate = DateFormat('yyyy-MM-dd')
                        .format(message.sendAt.toLocal());

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
    bool isVideo = message.content.toLowerCase().endsWith('.mp4') ||
        message.content.toLowerCase().endsWith('.mov') ||
        message.content.toLowerCase().endsWith('.avi') ||
        message.content.toLowerCase().contains("video");

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
            if (message.type == 'file')
              isVideo
                  ? FutureBuilder<String?>(
                      future: _generateThumbnail(message.content),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            width: 200,
                            height: 200,
                            color: Colors.grey[300],
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else if (snapshot.hasError || snapshot.data == null) {
                          return _buildErrorThumbnail();
                        }

                        return GestureDetector(
                          onTap: () {
                            // TODO: เปิดวิดีโอด้วย VideoPlayerPage หรือ player อื่น
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenVideoPlayer(
                                    videoUrl: message.content),
                              ),
                            );
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.file(
                                File(snapshot
                                    .data!), // แสดง Thumbnail จากไฟล์ชั่วคราว
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              Icon(Icons.play_circle_fill,
                                  color: Colors.white, size: 50),
                            ],
                          ),
                        );
                      })
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.content,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
            if (message.type == 'text')
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  message.content,
                  style: TextStyle(color: isMe ? Colors.white : Colors.black),
                ),
              ),
            const SizedBox(height: 5),
            Text(
              DateFormat('HH:mm').format(message.sendAt.toLocal()),
              style: TextStyle(
                fontSize: 12,
                color: isMe ? Colors.white : Colors.black,
              ),
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
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () async {
              await pickMediaAndSend(ImageSource.camera, widget.roomID);
            },
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () async {
              pickMedia(widget.roomID);
            },
          ),
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

  Future<void> pickMediaAndSend(ImageSource source, String roomID) async {
    final ImagePicker picker = ImagePicker();
    XFile? pickedFile;

    if (source == ImageSource.camera) {
      // 🔸 แสดง dialog ให้ผู้ใช้เลือกว่าจะถ่ายภาพหรือวิดีโอ
      final selected = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("เลือกประเภทสื่อ"),
          content: const Text("ต้องการถ่ายภาพหรือวิดีโอ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'image'),
              child: const Text("📷 ถ่ายภาพ"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'video'),
              child: const Text("🎥 ถ่ายวิดีโอ"),
            ),
          ],
        ),
      );

      if (selected == 'image') {
        pickedFile = await picker.pickImage(source: ImageSource.camera);
      } else if (selected == 'video') {
        pickedFile = await picker.pickVideo(source: ImageSource.camera);
      }
    } else {
      // 🔹 เลือกจากแกลเลอรี: ลอง pick รูปก่อน ถ้าไม่เลือกค่อย pick วิดีโอ
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        pickedFile = await picker.pickVideo(source: ImageSource.gallery);
      }
    }

    if (pickedFile == null) return;

    final File file = File(pickedFile.path);
    final String path = file.path.toLowerCase();

    final bool isVideo =
        path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.avi');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        content: isVideo
            ? FutureBuilder<VideoPlayerController>(
                future: _initializeVideoController(file),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    final controller = snapshot.data!;

                    return SizedBox(
                      width: 300,
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: FittedBox(
                              fit: BoxFit.cover, // ✅ ให้วิดีโอเต็มกรอบแบบครอบ
                              child: SizedBox(
                                width: 300,
                                height: 300,
                                child: VideoPlayer(controller),
                              ),
                            ),
                          ),

                          // ปุ่ม Pause / Play
                          GestureDetector(
                            onTap: () {
                              controller.value.isPlaying
                                  ? controller.pause()
                                  : controller.play();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  file,
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                bool success = isVideo
                    ? await chatController.sendVideo(file, roomID)
                    : await chatController.sendImage(file, roomID);
                if (!success) {
                  print("❌ การส่งไฟล์ล้มเหลว");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.send),
                  const SizedBox(width: 8),
                  Text(isVideo ? 'ส่งวิดีโอ' : 'ส่งรูปภาพ'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pickMedia(String roomID) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickMedia(); // ต้องใช้ image_picker >= 1.0.0
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      final bool isVideo = pickedFile.path.toLowerCase().endsWith('.mp4');

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          content: isVideo
              ? Container(
                  width: 300,
                  height: 300,
                  color: Colors.black12,
                  child: Center(child: Icon(Icons.videocam, size: 60)),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    file,
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  bool success = isVideo
                      ? await chatController.sendVideo(file, widget.roomID)
                      : await chatController.sendImage(file, widget.roomID);
                  if (!success) {
                    print("❌ การส่งไฟล์ล้มเหลว");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.send),
                    SizedBox(width: 8),
                    Text(isVideo ? 'ส่งวิดีโอ' : 'ส่งรูปภาพ'),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> pickImageAndSend(ImageSource source, String roomID) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image == null) return; // หากผู้ใช้ไม่เลือกไฟล์ ให้หยุดทำงาน

    File imageFile = File(image.path);

    // แสดง Dialog ให้ผู้ใช้กดยืนยันก่อนส่งรูป
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(imageFile,
                    width: 300, height: 300, fit: BoxFit.cover),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context); // ปิด Dialog
                  bool success =
                      await chatController.sendImage(imageFile, roomID);
                  if (success) {
                    print("📷 รูปภาพถูกส่งสำเร็จ!");
                  } else {
                    print("⚠️ เกิดข้อผิดพลาดในการอัปโหลดรูป");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.send, color: Colors.white),
                    SizedBox(width: 8),
                    Text('ส่งรูปภาพ'),
                  ],
                ),
              ),
            ),
          ],
        );
      },
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

  Widget _buildErrorThumbnail() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: Icon(Icons.video_library, color: Colors.grey[600]),
    );
  }

// ฟังก์ชันสร้าง Thumbnail จากวิดีโอ URL
  Future<String?> _generateThumbnail(String videoUrl) async {
    return await VideoThumbnail.thumbnailFile(
      video: videoUrl,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 80, // กำหนดขนาด Thumbnail
      quality: 75,
    );
  }
}

class FullScreenVideoPlayer extends StatelessWidget {
  final String videoUrl;
  const FullScreenVideoPlayer({Key? key, required this.videoUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: exchange.VideoPlayerWidget(videoUrl: videoUrl),
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  const FullScreenImageViewer({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

Future<VideoPlayerController> _initializeVideoController(File file) async {
  final controller = VideoPlayerController.file(file);
  await controller.initialize();
  controller.setLooping(true); // วนลูป
  return controller;
}
