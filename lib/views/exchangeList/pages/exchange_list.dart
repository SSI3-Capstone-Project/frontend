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
            return _buildExchangeList();
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
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Image.network(exchange.imageUrl),
              title: Text("Exchange ID: ${exchange.id}"),
              subtitle: Text("User: ${exchange.username}"),
              trailing: Text("${exchange.postPriceDiff} / ${exchange.offerPriceDiff}"),
              onTap: () {},
            ),
          );
        },
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}