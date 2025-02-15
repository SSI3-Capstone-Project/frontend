import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/exchangeList/controllers/get_exchange_list_controller.dart';
import 'package:mbea_ssi3_front/views/exchangeList/models/get_exchange_list_model.dart';

class ExchangeList extends StatefulWidget {
  const ExchangeList({super.key});

  @override
  State<ExchangeList> createState() => _ExchangeListState();
}

class _ExchangeListState extends State<ExchangeList> with SingleTickerProviderStateMixin {
  final ExchangeListController exchangeListController = Get.put(ExchangeListController());
  late TabController _tabController;

  final List<String?> statusList = [null, "inprogress", "confirmed", "completed", "cancelled"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: statusList.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _fetchExchangesForTab(0); // โหลดข้อมูลของแท็บแรก
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _fetchExchangesForTab(_tabController.index);
  }

  void _fetchExchangesForTab(int index) {
    exchangeListController.fetchExchangeList(status: statusList[index] ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: statusList.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("รายการแลกเปลี่ยน"),
          backgroundColor: Colors.white,
          centerTitle: true,
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
                  borderSide: BorderSide(width: 3, color: Constants.secondaryColor),
                  insets: const EdgeInsets.symmetric(horizontal: 16),
                ),
                dividerColor: Colors.transparent,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: "การแลกเปลี่ยนทั้งหมด"),
                  Tab(text: "กำลังแลกเปลี่ยน"),
                  Tab(text: "ยืนยันแลกเปลี่ยนแล้ว"),
                  Tab(text: "แลกเปลี่ยนสำเร็จ"),
                  Tab(text: "ยกเลิกการแลกเปลี่ยน"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: List.generate(statusList.length, (index) {
            return RefreshIndicator(
              color: Colors.white,
              backgroundColor: Constants.secondaryColor,
              onRefresh: () async {
                _fetchExchangesForTab(index); // รีเฟรชข้อมูลของแท็บที่กำลังแสดง
              },
              child: _buildExchangeList(),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildExchangeList() {
    return Obx(() {
      if (exchangeListController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (exchangeListController.exchangeList.isEmpty) {
        return const Center(child: Text("ไม่มีข้อมูล"));
      }

      return ListView.builder(
        itemCount: exchangeListController.exchangeList.length,
        itemBuilder: (context, index) {
          final ExchangeListModel exchange = exchangeListController.exchangeList[index];

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white, // พื้นหลังสีขาว
              borderRadius: BorderRadius.circular(12), // ขอบโค้งมน
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // เงาสีดำจาง ๆ
                  spreadRadius: 1, // กระจายเงาออกเล็กน้อย
                  blurRadius: 6, // ทำให้เงาดูนุ่มนวล
                  offset: const Offset(0, 4), // เงาตกลงด้านล่าง
                ),
              ],
            ),
            child: Card(
              color: Colors.transparent, // ให้ Card ไม่มีสี (ใช้สีจาก Container แทน)
              elevation: 0, // ปิดเงาของ Card เอง
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // ขอบโค้งมนให้ตรงกับ Container
              ),
              clipBehavior: Clip.hardEdge, // ป้องกันเนื้อหาล้นขอบ
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ฝั่งซ้าย (Other user)
                    Flexible(
                      flex: 2,
                      child: Row(
                        children: [
                          ClipOval(
                            child: Image.network(
                              exchange.otherImageUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exchange.otherUsername,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  exchange.isPostOwner ? exchange.offerTitle : exchange.postTitle,
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    getStatusIcon(exchange.status),

                    Flexible(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "ฉัน",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  exchange.isPostOwner ? exchange.postTitle : exchange.offerTitle,
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ClipOval(
                            child: Image.network(
                              exchange.ownImageUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
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

  Widget getStatusIcon(String status) {
    IconData iconData;
    Color iconColor;

    switch (status) {
      case "inprogress":
        iconData = Icons.swap_horiz_sharp; // กำลังแลกเปลี่ยน
        iconColor = Constants.primaryColor;
        break;
      case "confirmed":
        iconData = Icons.done_all_outlined; // ยืนยันแลกเปลี่ยนแล้ว
        iconColor = Constants.primaryColor;
        break;
      case "completed":
        iconData = Icons.check_circle_outline; // แลกเปลี่ยนสำเร็จ
        iconColor = Colors.green;
        break;
      case "cancelled":
        iconData = Icons.cancel_outlined; // ยกเลิกการแลกเปลี่ยน
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.swap_horiz_sharp; // ค่าเริ่มต้น (การแลกเปลี่ยนทั้งหมด)
        iconColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15), // เพิ่มระยะห่างจากขวา
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}