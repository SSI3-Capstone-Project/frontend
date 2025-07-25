import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/exchange/controllers/exchange_controller.dart';
import 'package:mbea_ssi3_front/views/exchange/pages/meet_up_page.dart';
import 'package:mbea_ssi3_front/views/exchangeList/controllers/get_exchange_list_controller.dart';
import 'package:mbea_ssi3_front/views/exchangeList/models/get_exchange_list_model.dart';
import 'package:mbea_ssi3_front/views/exchangeList/pages/exchange_detail.dart';

class ExchangeList extends StatefulWidget {
  const ExchangeList({super.key});

  @override
  State<ExchangeList> createState() => _ExchangeListState();
}

class _ExchangeListState extends State<ExchangeList>
    with SingleTickerProviderStateMixin {
  final ExchangeListController exchangeListController =
      Get.put(ExchangeListController());
  late TabController _tabController;
  final ExchangeController exchangeController = Get.put(ExchangeController());
  final TextEditingController searchController = TextEditingController();
  final RxString searchText = ''.obs;

  final List<String?> statusList = [
    null,
    "inprogress",
    "waiting_payment",
    "confirmed",
    "completed",
    "cancelled"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: statusList.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _fetchExchangesForTab(0); // โหลดข้อมูลของแท็บแรก

    // debounce: ค้นหาเมื่อหยุดพิมพ์เกิน 500ms
    debounce(searchText, (val) {
      final currentStatus = statusList[_tabController.index] ?? "";
      fetchExchangeList(status: currentStatus, username: val.trim());
    }, time: const Duration(milliseconds: 500));
  }

  Future<void> fetchExchangeList({String status = "", String? username}) async {
    await exchangeListController.fetchExchangeList(status: status, username: username);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    searchController.clear();      // ล้างช่องค้นหาเมื่อเปลี่ยนแท็บ
    searchText.value = '';         // ล้างค่า searchText เพื่อไม่ให้ debounce ทำงานต่อ
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
          title: const Text(
            "รายการแลกเปลี่ยน",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Constants.secondaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicator: UnderlineTabIndicator(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(width: 3, color: Constants.secondaryColor),
                      insets: EdgeInsets.zero, // <-- ตรงนี้
                    ),
                    dividerColor: Colors.transparent,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    tabAlignment: TabAlignment.start,
                    tabs: const [
                      Tab(text: "รายการทั้งหมด"),
                      Tab(text: "แลกเปลี่ยนอยู่"),
                      Tab(text: "ระหว่างชำระเงิน"),
                      Tab(text: "ยืนยันนัดหมายแล้ว"),
                      Tab(text: "แลกเปลี่ยนสำเร็จ"),
                      Tab(text: "ยกเลิกแลกเปลี่ยน"),
                    ],
                  ),
                ),
                const SizedBox(height: 8), // <-- เพิ่มระยะห่างระหว่าง tab กับ search box
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'ค้นหารายการแลกเปลี่ยน...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 25,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onChanged: (value) {
                        searchText.value = value;
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List.generate(statusList.length, (index) {
                  return RefreshIndicator(
                    color: Colors.white,
                    backgroundColor: Constants.secondaryColor,
                    onRefresh: () async {
                      _fetchExchangesForTab(index);
                    },
                    child: _buildExchangeList(),
                  );
                }),
              ),
            ),
          ],
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

      return Column(
        children: [
          // รายการแลกเปลี่ยน
          Expanded(
            child: ListView.builder(
              itemCount: exchangeListController.exchangeList.length,
              itemBuilder: (context, index) {
                final ExchangeListModel exchange = exchangeListController.exchangeList[index];

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
                  child: InkWell(
                    onTap: () async {
                      await exchangeController.fetchExchangeDetails(exchange.id);
                      switch (exchange.status) {
                        case "inprogress":
                        case "waiting_payment":
                        case "confirmed":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MeetUpPage(
                                exchangeID: exchange.id,
                                currentStep: exchange.status == "inprogress"
                                    ? 1
                                    : exchange.status == "waiting_payment"
                                    ? 2
                                    : 3,
                                user: exchange.isPostOwner ? Payer.post : Payer.offer,
                                postID: exchange.postId,
                                offerID: exchange.offerId,
                              ),
                            ),
                          );
                          break;
                        case "completed":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExchangeDetail(
                                exchangeID: exchange.id,
                                status: true,
                              ),
                            ),
                          );
                          break;
                        case "cancelled":
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExchangeDetail(
                                exchangeID: exchange.id,
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
                                exchangeID: exchange.id,
                                currentStep: 1,
                                user: exchange.isPostOwner ? Payer.post : Payer.offer,
                                postID: exchange.postId,
                                offerID: exchange.offerId,
                              ),
                            ),
                          );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
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
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          exchange.isPostOwner
                                              ? exchange.offerTitle
                                              : exchange.postTitle,
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
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
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          exchange.isPostOwner
                                              ? exchange.postTitle
                                              : exchange.offerTitle,
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
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
                  ),
                );
              },
            ),
          ),
        ],
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
      case "waiting_payment":
        iconData = Icons.payments_outlined; // รอการชำระเงิน
        iconColor = Colors.green;
        break;
      case "confirmed":
        iconData = Icons.location_on_outlined; // ยืนยันแลกเปลี่ยนแล้ว
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
      padding:
          const EdgeInsets.symmetric(horizontal: 15), // เพิ่มระยะห่างจากขวา
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
