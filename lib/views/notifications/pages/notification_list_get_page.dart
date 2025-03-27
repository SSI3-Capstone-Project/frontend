import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import '../controllers/notification_list_get_controller.dart';

class NotificationListGetPage extends StatefulWidget {
  const NotificationListGetPage({super.key});

  @override
  State<NotificationListGetPage> createState() => _NotificationListGetPageState();
}

class _NotificationListGetPageState extends State<NotificationListGetPage> with SingleTickerProviderStateMixin {
  final NotificationController notificationController = Get.put(NotificationController());
  late TabController _tabController;

  final List<Map<String, String>> notificationTypes = [
    {'display': 'ทั้งหมด', 'api': ''},
    {'display': 'ข้อเสนอ', 'api': 'offer'},
    {'display': 'แชท', 'api': 'chat'},
    {'display': 'นัดรับ', 'api': 'meeting_point'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: notificationTypes.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _fetchNotificationsForTab(0); // Fetch notifications for the first tab
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _fetchNotificationsForTab(_tabController.index);
  }

  void _fetchNotificationsForTab(int index) {
    final apiType = notificationTypes[index]['api']!;
    notificationController.setNotificationType(apiType);  // ส่งค่า apiType ที่ได้จากแท็บ
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
          bottom:PreferredSize(
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
                  borderSide: BorderSide(width: 3, color: Constants.secondaryColor),
                  insets: const EdgeInsets.symmetric(horizontal: 5),
                ),
                dividerColor: Colors.transparent,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabAlignment: TabAlignment.center, // ทำให้แท็บอยู่ตรงกลาง
                labelPadding: EdgeInsets.symmetric(horizontal: 16), // เว้นระยะห่างด้านซ้ายและขวาของแต่ละแท็บ
                tabs: notificationTypes.map((type) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8), // เว้นระยะห่างให้เท่ากันระหว่างแท็บ
                    child: Tab(
                      text: type['display'],
                    ),
                  );
                }).toList(),
              ),
            ),
          )
        ),
        body: TabBarView(
          controller: _tabController,
          children: List.generate(notificationTypes.length, (index) {
            return RefreshIndicator(
              color: Colors.white,
              backgroundColor: Constants.secondaryColor,
              onRefresh: () async {
                _fetchNotificationsForTab(index); // Refresh the data for the current tab
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

      return ListView.builder(
        itemCount: notificationController.notifications.length,
        itemBuilder: (context, index) {
          final notification = notificationController.notifications[index];

          // แปลงวันที่ที่ได้รับให้เป็น DateTime และจัดรูปแบบให้ใช้งานง่าย
          DateTime createdDate = notification.createdAt;
          String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(createdDate);

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Card(
              color: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.hardEdge,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // แสดงข้อความทั้งหมด
                          Text(
                            notification.message,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          // แสดงวันที่และเวลาในรูปแบบที่ใช้งานง่าย
                          Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}