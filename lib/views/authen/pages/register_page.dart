import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/views/authen/controllers/create_user_controller.dart';
import 'package:mbea_ssi3_front/views/authen/pages/login_page.dart';
// import 'package:mbea_ssi3_front/views/mainScreen/pages/layout_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final UserCreationController _controller = Get.put(UserCreationController());

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _profileImage;

  String? _selectedGender;

// Map for displaying gender in Thai while using English values
  final Map<String, String> genderOptions = {
    'ชาย': 'male',
    'หญิง': 'female',
    'ไม่ระบุ': 'non-identify',
    'อื่น ๆ': 'other',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle errors (e.g., permission denied)
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _controller.userRequest.value
        ..username = _usernameController.text
        ..password = _passwordController.text
        ..firstname = _nameController.text
        ..lastname = _surnameController.text
        ..email = _emailController.text
        ..phone = _phoneController.text
        ..gender = _selectedGender ?? 'other';

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      var result = await _controller.registerUser(_profileImage?.path ?? '');

      if (!_controller.isLoading.value) {
        Navigator.of(context).pop();
      }

      if (result) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'สมัครสมาชิก',
          style: TextStyle(
              color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            );
          },
        ),
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
                SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Icon(Icons.person_add_alt_1,
                              size: 50, color: Colors.black54)
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _nameController,
                        label: 'ชื่อ',
                        maxLength: 30,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _surnameController,
                        label: 'นามสกุล',
                        maxLength: 45,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _usernameController,
                  label: 'ชื่อผู้ใช้งาน',
                  maxLength: 30,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  maxLength: 255,
                  isEmail: true,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  label: 'รหัสผ่าน',
                  isPassword: true,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'ยืนยันรหัสผ่าน',
                  isPassword: true,
                  isConfirmPassword: true,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _phoneController,
                  label: 'เบอร์โทร',
                  isPhone: true,
                ),
                SizedBox(height: 20),
                _buildDropdownField(
                  label: 'เพศ',
                  items: genderOptions,
                  value: _selectedGender,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
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
                    'สมัครสมาชิก',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'มีบัญชีแล้ว?',
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        );
                      },
                      child: Text(
                        'เข้าสู่ระบบ',
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
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone
              ? TextInputType.phone
              : TextInputType.text,
      inputFormatters: isPhone
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10)
            ]
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding:
            EdgeInsets.only(left: 30, right: 12, top: 12, bottom: 12),
        counterText: '',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'โปรดกรอก$label';
        if (isPassword &&
            !RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d!@#\$&*~]{8,}$')
                .hasMatch(value)) {
          return 'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร\nและประกอบด้วยตัวอักษร a-z, A-Z, และ 0-9 (อักขระพิเศษจะมีหรือไม่ก็ได้)';
        }
        if (isConfirmPassword && value != _passwordController.text) {
          return 'รหัสผ่านและยืนยันรหัสผ่านไม่ตรงกัน';
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

  Widget _buildDropdownField({
    required String label,
    required Map<String, String> items,
    String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField2<String>(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            contentPadding:
                EdgeInsets.only(left: 30, right: 12, top: 12, bottom: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade600),
            ),
          ),
          items: items.keys
              .map((displayText) => DropdownMenuItem<String>(
                    value: items[displayText], // Pass English value
                    child: Text(displayText, style: TextStyle(fontSize: 14)),
                  ))
              .toList(),
          value: value,
          onChanged: onChanged,
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            maxHeight: 200,
          ),
          validator: (value) =>
              value == null ? 'โปรดเลือก${label.toLowerCase()}' : null,
        ),
      ),
    );
  }
}
