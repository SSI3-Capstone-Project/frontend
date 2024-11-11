import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mbea_ssi3_front/common/constants.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedGender;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission
      print("Form submitted");
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
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person_add_alt_1,
                          size: 40, color: Colors.black54),
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
                        ),
                      ),
                      SizedBox(width: 16), // เพิ่มระยะห่างระหว่างฟิลด์
                      Expanded(
                        child: _buildTextField(
                          controller: _surnameController,
                          label: 'นามสกุล',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _usernameController,
                    label: 'ชื่อผู้ใช้งาน',
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
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
                    items: ['ชาย', 'หญิง', 'อื่นๆ'],
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
                      'ต่อไป',
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
                          // Navigate to login
                        },
                        child: Text(
                          'เข้าสู่ระบบ',
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ),
                    ],
                  )
                ],
              ),
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
    String? Function(String?)? validator,
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
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding:
            EdgeInsets.only(left: 30, right: 12, top: 12, bottom: 12),
        counterText: '', // Hides the character counter
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'โปรดกรอก$label';
            }
            if (isPassword &&
                value.isNotEmpty &&
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
            if (isPhone && value.isNotEmpty) {
              if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                return 'เบอร์โทรต้องเป็นตัวเลข 10 หลัก';
              }
            }
            return null;
          },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    String? value,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
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
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(fontSize: 14),
                    ),
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
          validator: validator ??
              (value) =>
                  value == null ? 'โปรดเลือก${label.toLowerCase()}' : null,
        ),
      ),
    );
  }
}
