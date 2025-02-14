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
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // เรียกใช้เมธอด login ของ LoginController
      var result = await _loginController.login(
        _usernameController.text,
        _passwordController.text,
      );

      Future.delayed(Duration.zero, () {
        if (!_loginController.isLoading.value) {
          Get.back(); // ปิด Dialog loading
        }

        if (result) {
          Get.offAll(() => const RootPage()); // เปลี่ยนหน้าโดยล้าง Stack
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เข้าสู่ระบบ.',
          style: TextStyle(
              color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
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
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10),
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
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding:
            EdgeInsets.only(left: 30, right: 12, top: 12, bottom: 12),
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
