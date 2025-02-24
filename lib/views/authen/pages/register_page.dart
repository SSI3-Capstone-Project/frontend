import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/views/authen/controllers/create_user_controller.dart';
import 'package:mbea_ssi3_front/views/authen/controllers/otp_controller.dart';
import 'package:mbea_ssi3_front/views/authen/pages/login_page.dart';
// import 'package:mbea_ssi3_front/views/mainScreen/pages/layout_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final UserCreationController _controller = Get.put(UserCreationController());
  final OTPController otpController = Get.put(OTPController());

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

  int selectedIndex = 0;

// Map for displaying gender in Thai while using English values
  final Map<String, String> genderOptions = {
    'ชาย': 'male',
    'หญิง': 'female',
    'ไม่ระบุ': 'non-identify',
    'อื่น ๆ': 'other',
  };

  // List ของ FocusNode สำหรับแต่ละช่อง OTP
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  // List ของ TextEditingController สำหรับแต่ละช่อง OTP
  List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController());

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
        // title: Text(
        //   'สมัครสมาชิก',
        //   style: TextStyle(
        //       color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
        // ),
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
              child: selectedIndex == 1
                  ? ListView(
                      children: [
                        // SizedBox(height: 20),
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
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 8),
                          child: Text(
                            'รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษรและประกอบด้วย\nตัวอักษร a-z, A-Z, และ 0-9',
                            style: TextStyle(fontSize: 12),
                          ),
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
                                  MaterialPageRoute(
                                      builder: (_) => LoginPage()),
                                );
                              },
                              child: Text(
                                'เข้าสู่ระบบ',
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : selectedIndex == 0
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Image (Placeholder for now)
                            // Container(
                            //   height: 150,
                            //   width: 150,
                            //   decoration: BoxDecoration(
                            //     image: DecorationImage(
                            //       image: AssetImage(
                            //           "assets/images/verification.png"), // Replace with your image asset
                            //       fit: BoxFit.contain,
                            //     ),
                            //   ),
                            // ),
                            SizedBox(height: 20),
                            // Title
                            Text(
                              "ยืนยันอีเมลผ่านรหัส OTP",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            // Subtitle
                            Text(
                              "ระบบจะส่งรหัสผ่านแบบใช้ครั้งเดียว (OTP) ไปยังที่อยู่อีเมลนี้",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            SizedBox(height: 30),
                            // Email Input Field
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: "mail@gmail.com",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: Icon(Icons.email),
                              ),
                            ),
                            SizedBox(height: 30),
                            // Send OTP Button
                            ElevatedButton(
                              onPressed: () async {
                                String email = _emailController.text;
                                if (!email.isNotEmpty) {
                                  Get.snackbar(
                                      'แจ้งเตือน', 'กรุณากรอกอีเมลของคุณ');
                                } else {
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                      .hasMatch(email)) {
                                    Get.snackbar(
                                        'แจ้งเตือน', 'โปรดกรอกอีเมลที่ถูกต้อง');
                                  } else {
                                    print("Sending OTP to: $email");
                                    var result =
                                        await otpController.sendOTP(email);
                                    if (result) {
                                      setState(() {
                                        selectedIndex =
                                            2; // อัพเดต state หลัง Dialog ปิด
                                      });
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Constants.secondaryColor, // Button color
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "ยืนยัน",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            // กำหนดขนาดของ Dialog
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 16),
                                // Title
                                Text(
                                  "กรอกรหัสยืนยัน OTP ของท่าน",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                // Description
                                Text(
                                  "ระบบจะส่งรหัสผ่านแบบใช้ครั้งเดียวไปยังอีเมล ${_emailController.text} ของท่าน",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                SizedBox(height: 24),
                                // OTP Input Fields
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(6, (index) {
                                    return Container(
                                      width: 40,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: RawKeyboardListener(
                                        focusNode:
                                            FocusNode(), // FocusNode แยกสำหรับ RawKeyboardListener
                                        onKey: (RawKeyEvent event) {
                                          if (event is RawKeyDownEvent &&
                                              event.logicalKey ==
                                                  LogicalKeyboardKey
                                                      .backspace &&
                                              otpControllers[index]
                                                  .text
                                                  .isEmpty &&
                                              index > 0) {
                                            // ย้อนกลับไปยังช่องก่อนหน้าหากกด backspace และช่องปัจจุบันว่าง
                                            FocusScope.of(context).requestFocus(
                                                focusNodes[index - 1]);
                                          }
                                        },
                                        child: TextField(
                                          controller: otpControllers[index],
                                          focusNode: focusNodes[index],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          keyboardType: TextInputType.number,
                                          maxLength: 1,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          decoration: InputDecoration(
                                            counterText: "", // ซ่อนตัวนับอักขระ
                                            border: InputBorder.none,
                                          ),
                                          onChanged: (value) {
                                            if (value.isNotEmpty) {
                                              if (index < 5) {
                                                // เลื่อนไปยังช่องถัดไป
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        focusNodes[index + 1]);
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  }),
                                ),

                                SizedBox(height: 5),
                                // Resend Code and Switch Account Links
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        // Resend code functionality
                                        await otpController
                                            .reSendOTP(_emailController.text);
                                      },
                                      child: Text(
                                        "ส่งรหัสใหม่อีกครั้ง",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                // Verify Button
                                ElevatedButton(
                                  onPressed: () async {
                                    String otp = otpControllers
                                        .map((controller) => controller.text)
                                        .join();
                                    if (otp.length != 6) {
                                      Get.snackbar('แจ้งเตือน',
                                          'กรุณากรอก OTP ให้ครบ 6 หลัก');
                                    }
                                    var result = await otpController.verifyOTP(
                                        _emailController.text, otp);
                                    if (result) {
                                      if (mounted) {
                                        setState(() {
                                          selectedIndex =
                                              1; // อัพเดต state หลัง Dialog ปิด
                                        });
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Constants.secondaryColor,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    "Verify OTP",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
            )),
      ),
    );
  }

  Widget sendOTPPage() {
    return Column(
      children: [
        // Image (Placeholder for now)
        Container(
          height: 150,
          width: 150,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  "assets/images/verification.png"), // Replace with your image asset
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 20),
        // Title
        Text(
          "OTP Verification",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        // Subtitle
        Text(
          "We will send you an One Time Passcode\nvia this email address",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        SizedBox(height: 20),
        // Email Input Field
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "mail@gmail.com",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            prefixIcon: Icon(Icons.email),
          ),
        ),
        SizedBox(height: 20),
        // Send OTP Button
        ElevatedButton(
          onPressed: () {
            String email = _emailController.text;
            if (email.isNotEmpty) {
              // TODO: Add functionality to send OTP
              print("Sending OTP to: $email");
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please enter a valid email address")),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple, // Button color
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            "Send OTP",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey.shade500, // สีของกรอบเมื่อปิดการใช้งาน
          ),
        ),
      ),
      enabled: !isEmail,
      validator: (value) {
        if (value == null || value.isEmpty) return 'โปรดกรอก$label';
        if (isPassword &&
            !RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)[A-Za-z\d!@#\$&*~]{8,}$')
                .hasMatch(value)) {
          return 'โปรดตรวจสอบรูปแบบรหัสผ่านไม่ถูกต้อง';
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

  // void verifyOTP() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           // List ของ FocusNode สำหรับแต่ละช่อง OTP
  //           List<FocusNode> focusNodes =
  //               List.generate(6, (index) => FocusNode());
  //           // List ของ TextEditingController สำหรับแต่ละช่อง OTP
  //           List<TextEditingController> otpControllers =
  //               List.generate(6, (index) => TextEditingController());

  //           return Dialog(
  //             child: Stack(
  //               children: [
  //                 // กำหนดขนาดของ Dialog
  //                 Container(
  //                   width: MediaQuery.of(context).size.width * 0.8,
  //                   height: 350,
  //                   padding: EdgeInsets.all(16),
  //                   child: Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       SizedBox(height: 16),
  //                       // Title
  //                       Text(
  //                         "กรอกรหัสยืนยัน OTP ของท่าน",
  //                         style: TextStyle(
  //                             fontSize: 20, fontWeight: FontWeight.bold),
  //                       ),
  //                       SizedBox(height: 8),
  //                       // Description
  //                       Text(
  //                         "ระบบจะส่งรหัสผ่านแบบใช้ครั้งเดียวไปยังอีเมล ${_emailController.text} ของท่าน",
  //                         textAlign: TextAlign.center,
  //                         style: TextStyle(fontSize: 14, color: Colors.grey),
  //                       ),
  //                       SizedBox(height: 24),
  //                       // OTP Input Fields
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                         children: List.generate(6, (index) {
  //                           return Container(
  //                             width: 40,
  //                             height: 45,
  //                             decoration: BoxDecoration(
  //                               border: Border.all(color: Colors.grey),
  //                               borderRadius: BorderRadius.circular(8),
  //                             ),
  //                             child: TextField(
  //                               controller: otpControllers[index],
  //                               focusNode: focusNodes[index],
  //                               textAlign: TextAlign.center,
  //                               style: TextStyle(
  //                                   fontSize: 18, fontWeight: FontWeight.bold),
  //                               // keyboardType: TextInputType.number,
  //                               maxLength: 1,
  //                               decoration: InputDecoration(
  //                                 counterText: "", // Hide the character counter
  //                                 border: InputBorder.none,
  //                               ),
  //                               onChanged: (value) {
  //                                 if (value.isNotEmpty) {
  //                                   if (index < 5) {
  //                                     // เลื่อนโฟกัสไปยังช่องถัดไป
  //                                     FocusScope.of(context)
  //                                         .requestFocus(focusNodes[index + 1]);
  //                                   }
  //                                 }
  //                               },
  //                             ),
  //                           );
  //                         }),
  //                       ),
  //                       SizedBox(height: 5),
  //                       // Resend Code and Switch Account Links
  //                       Row(
  //                         mainAxisAlignment: MainAxisAlignment.end,
  //                         children: [
  //                           TextButton(
  //                             onPressed: () async {
  //                               // Resend code functionality
  //                               await otpController
  //                                   .reSendOTP(_emailController.text);
  //                             },
  //                             child: Text(
  //                               "ส่งรหัสใหม่อีกครั้ง",
  //                               style: TextStyle(color: Colors.blue),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       SizedBox(height: 16),
  //                       // Verify Button
  //                       ElevatedButton(
  //                         onPressed: () async {
  //                           String otp = otpControllers
  //                               .map((controller) => controller.text)
  //                               .join();
  //                           if (otp.length != 6) {
  //                             Get.snackbar(
  //                                 'แจ้งเตือน', 'กรุณากรอก OTP ให้ครบ 6 หลัก');
  //                           }
  //                           var result = await otpController.verifyOTP(
  //                               _emailController.text, otp);
  //                           if (result) {
  //                             Navigator.pop(context); // ปิด Dialog
  //                             Future.delayed(Duration(milliseconds: 100), () {
  //                               if (mounted) {
  //                                 setState(() {
  //                                   selectedIndex =
  //                                       1; // อัพเดต state หลัง Dialog ปิด
  //                                 });
  //                               }
  //                             });
  //                           }
  //                         },
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Constants.secondaryColor,
  //                           padding: EdgeInsets.symmetric(
  //                               horizontal: 40, vertical: 12),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                         ),
  //                         child: Text(
  //                           "Verify OTP",
  //                           style: TextStyle(fontSize: 16, color: Colors.white),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),

  //                 // ปุ่ม X ที่มุมขวาบน
  //                 Positioned(
  //                   right: 15,
  //                   top: 15,
  //                   child: InkWell(
  //                     onTap: () {
  //                       Navigator.pop(context); // ปิด Dialog
  //                     },
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                         shape: BoxShape.circle,
  //                         color: Colors.redAccent,
  //                       ),
  //                       child: Icon(
  //                         Icons.close,
  //                         size: 21,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
}
