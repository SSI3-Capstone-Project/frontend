import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_list_get_controller.dart';

class NotificationListGetPage extends StatefulWidget {
  const NotificationListGetPage({super.key});

  @override
  State<NotificationListGetPage> createState() => _NotificationListGetPageState();
}

class _NotificationListGetPageState extends State<NotificationListGetPage>
    with SingleTickerProviderStateMixin {
  final NotificationController notificationController = Get.put(NotificationController());
  late TabController _tabController;

  // List of notification types for the tabs (you can modify or extend this)
  final List<String> notificationTypes = ['All', 'Offer', 'Chat', 'Meeting'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: notificationTypes.length, vsync: this);

    // Fetch all notifications initially
    notificationController.fetchNotifications();

    // Listen to tab changes and update the notification type accordingly
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        String selectedType = notificationTypes[_tabController.index];

        // Map the selected tab to the appropriate type for API
        String apiType = '';
        switch (selectedType.toLowerCase()) {
          case 'offer':
            apiType = 'offer';
            break;
          case 'chat':
            apiType = 'chat';
            break;
          case 'meeting':
            apiType = 'meeting_point';
            break;
          default:
            apiType = '';
        }

        notificationController.setNotificationType(apiType);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
           backgroundColor: Colors.white,
           appBar: AppBar(
           title: const Text("การแจ้งเตือน"),
           backgroundColor: Colors.white,
           centerTitle: true,
           elevation: 0,
           leading: IconButton(
           icon: const Icon(Icons.arrow_back_ios),
           onPressed: () {
           Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: notificationTypes.map((type) => Tab(text: type)).toList(),
        ),
      ),
      body: Obx(() {
        // Display a loading indicator while notifications are being fetched
        if (notificationController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if there are no notifications
        if (notificationController.notifications.isEmpty) {
          return const Center(child: Text('ยังไม่มีการแจ้งเตือน'));
        }

        // Build the list of notifications
        return ListView.builder(
          itemCount: notificationController.notifications.length,
          itemBuilder: (context, index) {
            final notification = notificationController.notifications[index];

            // Display notification item
            return ListTile(
              title: Text(notification.message),
              subtitle: Text('Created at: ${notification.createdAt}'),
              leading: Icon(
                notification.isRead ? Icons.check_circle : Icons.circle,
                color: notification.isRead ? Colors.green : Colors.grey,
              ),
              onTap: () {
                // Handle notification tap (e.g., mark as read, navigate, etc.)
                // You can implement this action as needed
              },
            );
          },
        );
      }),
    );
  }
}
