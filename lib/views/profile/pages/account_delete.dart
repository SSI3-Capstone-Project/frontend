import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/authen/pages/login_page.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/delete_account_controller.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  final DeleteAccountController deleteAccountController =
      Get.put(DeleteAccountController());
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

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
    String? passwordError;
    String? confirmPasswordError;
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("ยืนยันการลบบัญชี"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        "คุณแน่ใจหรือไม่ว่าต้องการลบบัญชี? การกระทำนี้ไม่สามารถย้อนกลับได้"),
                    SizedBox(height: 20),
                    _buildPasswordField(
                      controller: _passwordController,
                      label: "รหัสผ่าน",
                      field: "passwordField",
                      errorText: passwordError,
                    ),
                    SizedBox(height: 10),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: "ยืนยันรหัสผ่าน",
                      field: "confirmPasswordField",
                      errorText: confirmPasswordError,
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิดกล่องยืนยัน
              },
              child: Text("ยกเลิก"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _deleteAccount(_passwordController
                      .text); // ส่งรหัสผ่านไปยังฟังก์ชันลบบัญชี
                  Navigator.of(context).pop(); // ปิดกล่องยืนยัน
                }
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String field,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true, // ซ่อนรหัสผ่านที่กรอก
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        errorText: errorText,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'กรุณากรอก$label';
        if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d!@#\$&*~]{8,}$')
            .hasMatch(value)) {
          return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร\nและประกอบด้วยตัวอักษร a-z, A-Z, และ 0-9';
        }
        if (field == "confirmPasswordField" &&
            _confirmPasswordController.text != _passwordController.text)
          return 'กรุณากรอกรหัสผ่านให้ตรงกัน';
        return null;
      },
    );
  }

  Future<void> _deleteAccount(String password) async {
    var result = await deleteAccountController.deleteAccount(password);
    if (result) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }
}
