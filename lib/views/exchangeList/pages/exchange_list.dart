import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:mbea_ssi3_front/common/constants.dart';

class ExchangeList extends StatefulWidget {
  const ExchangeList({super.key});

  @override
  State<ExchangeList> createState() => _ExchangeListState();
}

class _ExchangeListState extends State<ExchangeList> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
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
                isScrollable: true,
                labelColor: Constants.secondaryColor, // ✅ สีของแท็บที่ถูกเลือก
                unselectedLabelColor: Colors.grey, // ✅ สีของแท็บที่ไม่ได้ถูกเลือก
                indicator: UnderlineTabIndicator(
                  borderRadius: BorderRadius.circular(10), // ✅ ทำให้ขอบเส้นมน
                  borderSide: BorderSide(
                    width: 3, // ✅ ความหนาของเส้น
                    color: Constants.secondaryColor, // ✅ สีของเส้น
                  ),
                  insets: const EdgeInsets.symmetric(horizontal: 16), // ✅ กำหนดระยะห่าง
                ),
                dividerColor: Colors.transparent, // ✅ ซ่อนเส้นคั่นระหว่างเมนูและหน้า
                overlayColor: MaterialStateProperty.all(Colors.transparent), // ❌ ไม่มีสีตอนกด
                tabAlignment: TabAlignment.start, // ✅ ชิดซ้าย (Flutter 3.10+)
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
        body: const TabBarView(
          children: [
            Center(child: Text("หน้าการแลกเปลี่ยนทั้งหมด")),
            Center(child: Text("หน้ากำลังแลกเปลี่ยน")),
            Center(child: Text("หน้ายืนยันแลกเปลี่ยนแล้ว")),
            Center(child: Text("หน้าแลกเปลี่ยนสำเร็จ")),
            Center(child: Text("หน้ายกเลิกการแลกเปลี่ยน")),
          ],
        ),
      ),
    );
  }
}