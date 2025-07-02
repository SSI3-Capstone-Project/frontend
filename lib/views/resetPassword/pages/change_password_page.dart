import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/resetPassword/controllers/change_password_controller.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final ChangePasswordController controller =
      Get.put(ChangePasswordController());
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'แก้ไขรหัสผ่าน',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                SizedBox(height: 30),
                _buildTextField(
                  controller: _passwordController,
                  label: 'รหัสผ่าน *',
                  isPassword: true,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _newPasswordController,
                  label: 'รหัสผ่านใหม่ *',
                  isPassword: true,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _confirmNewPasswordController,
                  label: 'ยืนยันรหัสผ่านใหม่ *',
                  isPassword: true,
                  isConfirmPassword: true,
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'เปลี่ยนรหัสผ่าน',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 16),
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
    String? hint,
    int maxLength = 45,
    int maxLines = 1,
    bool isPassword = false,
    bool isEmail = false,
    bool isPhone = false,
    bool isConfirmPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      obscureText: isPassword,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 14,
        ),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        contentPadding:
            EdgeInsets.only(left: 30, right: 12, top: 14, bottom: 14),
        counterText: '',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'โปรดกรอก$label';
        if (isPassword &&
            !RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d!@#\$&*~]{8,}$')
                .hasMatch(value)) {
          return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร\nและประกอบด้วยตัวอักษร a-z, A-Z, และ 0-9';
        }
        if (isConfirmPassword && value != _newPasswordController.text) {
          return 'รหัสผ่านใหม่และยืนยันรหัสผ่านใหม่ไม่ตรงกัน';
        }
        if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'โปรดกรอกอีเมลที่ถูกต้อง';
        }
        if (isPhone && value.length != 10) {
          return 'เบอร์โทรต้องเป็นตัวเลข 10 หลัก';
        }
        return null;
      },
    );
  }

  void _submitForm() async {
    if (_passwordController.value == _newPasswordController.value &&
        _newPasswordController.value == _confirmNewPasswordController.value) {
      Get.snackbar(
        'แจ้งเตือน',
        'รหัสผ่านใหม่ต้องไม่ตรงกับรหัสผ่านเดิม',
        backgroundColor: Colors.grey.shade200,
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      var result = await controller.changePassword(
          _passwordController.text, _newPasswordController.text);
      if (mounted) {
        if (result) {
          Navigator.pop(context);
        }
      }
    }
  }
}
