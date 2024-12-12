import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:mbea_ssi3_front/common/constants.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ลบบัญชี"),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 18),
              child: Column(
                children: [_buildDeleteConfirmationMessage()],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildDeleteConfirmationMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "หากคุณลบบัญชีของคุณ ข้อมูลทั้งหมดของคุณจะถูกลบอย่างถาวร และไม่สามารถกู้คืนได้",
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        SizedBox(height: 16), // เพิ่มระยะห่างระหว่างข้อความกับปุ่ม
        SizedBox(
          width: double.infinity, // ขยายปุ่มให้เต็มพื้นที่
          child: ElevatedButton(
            onPressed: () {
              _showConfirmationDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Constants.secondaryColor, // กำหนดสีของปุ่มเป็นสีส้ม
              padding:
                  EdgeInsets.symmetric(vertical: 10), // เพิ่มความสูงของปุ่ม
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "ลบบัญชี",
              style: TextStyle(
                color: Colors.white, // สีข้อความเป็นสีขาว
                fontSize: 16, // ขนาดข้อความ
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("ยืนยันการลบบัญชี"),
          content: Text(
              "คุณแน่ใจหรือไม่ว่าต้องการลบบัญชี? การกระทำนี้ไม่สามารถย้อนกลับได้"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิดกล่องยืนยัน
              },
              child: Text("ยกเลิก"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิดกล่องยืนยัน
                _deleteAccount(); // เรียกฟังก์ชันเพื่อลบบัญชี
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.secondaryColor,
              ),
              child: Text("ยืนยัน", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount() {
    // ฟังก์ชันสำหรับการลบบัญชี
    print("Account deleted");
  }
}
