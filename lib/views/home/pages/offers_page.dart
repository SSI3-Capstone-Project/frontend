import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/controller/websocket_controller.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  final ChatController chatController = Get.put(ChatController());
  final TextEditingController messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
        actions: [
          IconButton(
            icon: const Icon(Icons.connect_without_contact),
            onPressed: () {
              chatController
                  .connectToRoom('50f98d4a-3edf-4644-9893-5fc6fba37116');
            },
          ),
          Obx(() => chatController.isConnected.value
              ? Icon(Icons.link, color: Colors.green)
              : Icon(Icons.link_off, color: Colors.red)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (chatController.messages.isEmpty) {
                return Center(child: Text('No messages yet.'));
              }
              return ListView.builder(
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatController.messages[index];
                  return ListTile(
                    title: Text(message['message'] ?? ''),
                    subtitle: Text('Type: ${message['type'] ?? ''}'),
                  );
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      chatController.sendMessage(messageController.text,
                          '50f98d4a-3edf-4644-9893-5fc6fba37116');
                      messageController.clear();
                    }
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
