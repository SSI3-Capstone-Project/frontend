import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/authen/controllers/login_controller.dart';
import 'package:mbea_ssi3_front/views/mainScreen/pages/layout_page.dart';
import 'register_page.dart'; // นำเข้า LoginController

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final LoginController _loginController = Get.isRegistered<LoginController>()
      ? Get.find<LoginController>()
      : Get.put(LoginController(), permanent: true);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ใช้เพื่อทำการล้างหรือปล่อยหน่วยความจำ
  // @override
  // void dispose() {
  //   _usernameController.dispose();
  //   _passwordController.dispose();
  //   super.dispose();
  // }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Get.dialog(
      //   const Center(child: CircularProgressIndicator()),
      //   barrierDismissible: false,
      // );

      try {
        var result = await _loginController.login(
          _usernameController.text,
          _passwordController.text,
        );

        // ปิด Dialog loading หลังจาก login เสร็จ
        // Get.back();

        if (result) {
          Get.offAll(() => const RootPage());
        }
      } catch (e) {
        // Get.back(); // ปิด Dialog loading ในกรณีเกิดข้อผิดพลาด
        Get.snackbar("เกิดข้อผิดพลาด", "ไม่สามารถเข้าสู่ระบบได้");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'เข้าสู่ระบบ',
            style: TextStyle(
                color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                SizedBox(height: 60),
                _buildTextField(
                  controller: _usernameController,
                  label: 'ชื่อผู้ใช้งาน',
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  label: 'รหัสผ่าน',
                  isPassword: true,
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'เข้าสู่ระบบ',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ยังไม่มีบัญชีใช่ไหม?',
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterPage()),
                        );
                      },
                      child: Text(
                        'สมัครสมาชิก',
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        contentPadding:
            EdgeInsets.only(left: 30, right: 12, top: 14, bottom: 14),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'โปรดกรอก$label';
        }
        return null;
      },
    );
  }
}
