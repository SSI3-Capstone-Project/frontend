import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/chat/controllers/chat_room_controller.dart';
import 'package:mbea_ssi3_front/views/chat/controllers/websocket_controller.dart';
import 'package:mbea_ssi3_front/views/chat/pages/chat_room_page.dart';
import 'package:mbea_ssi3_front/views/exchange/controllers/exchange_product_detail_controller.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ExchangeProductDetailController productDetailController =
      Get.put(ExchangeProductDetailController());
  final ChatController chatController = Get.put(ChatController());
  final ChatRoomController chatRoomController = Get.put(ChatRoomController());
  final TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'แชท',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
          bottom: false,
          child: Obx(() {
            if (chatRoomController.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }
            if (!chatRoomController.chatRoomList.isEmpty) {
              final filteredChatRoom =
                  chatRoomController.chatRoomList.where((chatRoom) {
                final query = searchQuery.value.toLowerCase();
                return chatRoom.username.toLowerCase().contains(query) ||
                    chatRoom.postTitle.toLowerCase().contains(query) ||
                    chatRoom.offerTitle.toLowerCase().contains(query);
              }).toList();
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, right: 15, left: 15),
                    child: searchField(),
                  ),
                  buildOfferList(filteredChatRoom),
                ],
              );
            } else {
              return RefreshIndicator(
                onRefresh: () async {
                  // Call the refresh function in ProductController
                  await chatRoomController.fetchChatRooms();
                },
                color: Colors.white, // Refresh icon color
                backgroundColor: Constants.secondaryColor,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ยังไม่มีห้องสนทนาในตอนนี้',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
          })),
    );
  }

  Widget buildOfferList(List<dynamic> items) {
    return RefreshIndicator(
      onRefresh: () async {
        await chatRoomController.fetchChatRooms();
      },
      color: Colors.white,
      backgroundColor: Constants.secondaryColor,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.71, // กำหนดความสูง
              child: StaggeredGridView.countBuilder(
                padding: const EdgeInsets.all(15),
                crossAxisCount: 1,
                mainAxisSpacing: 5,
                crossAxisSpacing: 22,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onTap: () async {
                      // await offerDetailController.fetchOfferDetail(
                      //     widget.postId, item.id);
                      // _offerDetailDialog();
                    },
                    child: chatRoomCard(item, () async {
                      await chatController.fetchMessages(item.id.toString());
                      await productDetailController.fetchPostAndOfferDetail(
                          chatController.postID.value,
                          chatController.offerID.value);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoom(
                            roomID: item.id.toString(),
                          ),
                        ),
                      );
                    }),
                  );
                },
                staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget chatRoomCard(dynamic item, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100, // กำหนดความสูงให้กับการ์ด
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(item.profile),
            ),
            SizedBox(width: 10),
            // User Info & Offer Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        // item.postTitle,
                        item.postTitle.length > 15
                            ? '${item.postTitle.substring(0, 15)}...'
                            : item.postTitle,
                        style: TextStyle(
                            color: Constants.secondaryColor, fontSize: 11),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.swap_horiz, size: 16, color: Colors.grey),
                      SizedBox(width: 5),
                      Text(
                        item.offerTitle.length > 15
                            ? '${item.offerTitle.substring(0, 15)}...'
                            : item.offerTitle,
                        style: TextStyle(
                            color: Constants.primaryColor, fontSize: 11),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.assignment_outlined,
                          size: 20, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
            // Time and Notification Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.lastMessageSendAt != null
                      ? DateFormat('HH:mm')
                          .format(item.lastMessageSendAt.toLocal())
                      : '',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 6),
                if (item.unreadMessageCount.toString() != '0')
                  Container(
                    padding: EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Constants.secondaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      item.unreadMessageCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget searchField() {
    return TextField(
      controller: searchController,
      onChanged: (value) => searchQuery.value = value,
      decoration: InputDecoration(
        hintText: 'ค้นหา',
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: const Icon(
          Icons.search,
          size: 25,
          color: Colors.grey,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
