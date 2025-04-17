import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/chat/pages/chat_room_page.dart';
import 'package:mbea_ssi3_front/views/exchange/controllers/exchange_controller.dart';
import 'package:mbea_ssi3_front/views/exchange/pages/meet_up_page.dart';
import 'package:mbea_ssi3_front/views/exchangeList/pages/exchange_detail.dart';
import 'package:mbea_ssi3_front/views/notifications/controllers/notification_update_controller.dart';
import '../../post/pages/post_detail.dart';
import '../../profile/controllers/get_profile_controller.dart';
import '../controllers/notification_list_get_controller.dart';

class NotificationListGetPage extends StatefulWidget {
  const NotificationListGetPage({super.key});

  @override
  State<NotificationListGetPage> createState() =>
      _NotificationListGetPageState();
}

class _NotificationListGetPageState extends State<NotificationListGetPage>
    with SingleTickerProviderStateMixin {
  final NotificationController notificationController =
      Get.put(NotificationController());
  final UserProfileController userProfileController =
      Get.put(UserProfileController());
  final ExchangeController exchangeController = Get.put(ExchangeController());
  final NotificationUpdateController notificationUpdateController = Get.put(NotificationUpdateController());
  late TabController _tabController;

  final List<Map<String, String>> notificationTypes = [
    {'display': 'ทั้งหมด', 'api': ''},
    {'display': 'ข้อเสนอ', 'api': 'offer'},
    {'display': 'แชท', 'api': 'chat'},
    {'display': 'นัดหมาย', 'api': 'meeting_point'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: notificationTypes.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _fetchNotificationsForTab(0); // Fetch notifications for the first tab
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _fetchNotificationsForTab(_tabController.index);
  }

  void _fetchNotificationsForTab(int index) {
    final apiType = notificationTypes[index]['api']!;
    notificationController
        .setNotificationType(apiType); // ส่งค่า apiType ที่ได้จากแท็บ
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: notificationTypes.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: const Text("การแจ้งเตือน"),
            backgroundColor: Colors.white,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Constants.secondaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicator: UnderlineTabIndicator(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(width: 3, color: Constants.secondaryColor),
                    insets: const EdgeInsets.symmetric(horizontal: 5),
                  ),
                  dividerColor: Colors.transparent,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  tabAlignment: TabAlignment.center, // ทำให้แท็บอยู่ตรงกลาง
                  labelPadding: EdgeInsets.symmetric(
                      horizontal: 16), // เว้นระยะห่างด้านซ้ายและขวาของแต่ละแท็บ
                  tabs: notificationTypes.map((type) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 13), // เว้นระยะห่างให้เท่ากันระหว่างแท็บ
                      child: Tab(
                        text: type['display'],
                      ),
                    );
                  }).toList(),
                ),
              ),
            )),
        body: TabBarView(
          controller: _tabController,
          children: List.generate(notificationTypes.length, (index) {
            return RefreshIndicator(
              color: Colors.white,
              backgroundColor: Constants.secondaryColor,
              onRefresh: () async {
                _fetchNotificationsForTab(
                    index); // Refresh the data for the current tab
              },
              child: _buildNotificationList(),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    return Obx(() {
      if (notificationController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (notificationController.notifications.isEmpty) {
        return const Center(child: Text("ยังไม่มีการแจ้งเตือน"));
      }

      final userProfile = userProfileController.userProfile.value;
      if (userProfile == null) {
        // กรณีข้อมูลเป็น null หรือไม่ได้รับข้อมูลจาก API
        return Center(child: Text("Failed to load user profile"));
      }

      return ListView.builder(
        itemCount: notificationController.notifications.length,
        itemBuilder: (context, index) {
          final notification = notificationController.notifications[index];

          // Check if the notification is of type 'offer' and has a related post ID
          if (notification.relatedType == 'offer' &&
              notification.relatedPostId != "") {
            return GestureDetector(
              onTap: () {
                notificationUpdateController.markNotificationAsRead(notification.id);
                Get.snackbar('postId', notification.relatedPostId);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailPage(
                      postId: notification.relatedPostId,
                      username: userProfile.username,
                      userImageUrl:
                          userProfile.imageUrl.toString(), // Pass relatePostId
                    ),
                  ),
                );
              },
              child: _buildNotificationItem(notification),
            );
          }

          // Check if the notification is of type 'chat'
          if (notification.relatedType == 'chat' &&
              notification.relatedEntityId != "") {
            return GestureDetector(
              onTap: () {
                notificationUpdateController.markNotificationAsRead(notification.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoom(
                      roomID: notification.relatedEntityId,
                    ),
                  ),
                );
              },
              child: _buildNotificationItem(notification),
            );
          }

          if (notification.relatedType == 'meeting_point' &&
              notification.relatedEntityId != "") {
            return GestureDetector(
              onTap: () async {
                notificationUpdateController.markNotificationAsRead(notification.id);
                await exchangeController
                    .fetchExchangeDetails(notification.relatedEntityId);
                switch (exchangeController.exchange.value!.exchangeStage) {
                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MeetUpPage(
                          exchangeID: notification.relatedEntityId,
                          currentStep: 1,
                          user: exchangeController.exchange.value!.isOwnerPost
                              ? Payer.post
                              : Payer.offer,
                          postID: exchangeController.exchange.value!.postId,
                          offerID: exchangeController.exchange.value!.offerId,
                        ),
                      ),
                    );
                    break;
                  case 3:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MeetUpPage(
                          exchangeID: notification.relatedEntityId,
                          currentStep: 2,
                          user: exchangeController.exchange.value!.isOwnerPost
                              ? Payer.post
                              : Payer.offer,
                          postID: exchangeController.exchange.value!.postId,
                          offerID: exchangeController.exchange.value!.offerId,
                        ),
                      ),
                    );
                    break;
                  case 4:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MeetUpPage(
                          exchangeID: notification.relatedEntityId,
                          currentStep: 3,
                          user: exchangeController.exchange.value!.isOwnerPost
                              ? Payer.post
                              : Payer.offer,
                          postID: exchangeController.exchange.value!.postId,
                          offerID: exchangeController.exchange.value!.offerId,
                        ),
                      ),
                    );
                    break;
                  case 5:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExchangeDetail(
                          exchangeID: notification.relatedEntityId,
                          status: true,
                        ),
                      ),
                    );
                    break;
                  case 6:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExchangeDetail(
                          exchangeID: notification.relatedEntityId,
                          status: false,
                        ),
                      ),
                    );
                    break;
                  default:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MeetUpPage(
                          exchangeID: notification.relatedEntityId,
                          currentStep: 1,
                          user: exchangeController.exchange.value!.isOwnerPost
                              ? Payer.post
                              : Payer.offer,
                          postID: exchangeController.exchange.value!.postId,
                          offerID: exchangeController.exchange.value!.offerId,
                        ),
                      ),
                    );
                }
              },
              child: _buildNotificationItem(notification),
            );
          }

          return _buildNotificationItem(notification);
        },
      );
    });
  }

  // Helper method to build notification item
  Widget _buildNotificationItem(notification) {
    DateTime createdDate = notification.createdAt;
    String formattedDate =
        DateFormat('dd MMM yyyy, hh:mm a').format(createdDate);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Stack(
        children: [
          // ตัวการ์ดการแจ้งเตือน
          Card(
            color: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.message,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // จุดกลมเล็กๆ สำหรับแสดงว่า unread
          if (!notification.isRead)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
