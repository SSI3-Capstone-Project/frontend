import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_svg/svg.dart';
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
  final _personalFormKey = GlobalKey<FormState>();

  final UserCreationController _controller = Get.put(UserCreationController());
  final OTPController otpController = Get.put(OTPController());

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bankAccountNumber = TextEditingController();
  final TextEditingController _bankAccountName = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _profileImage;

  String? _selectedGender;

  String? _selectedBankCode;

  int selectedIndex = 0;

// Map for displaying gender in Thai while using English values
  final Map<String, String> genderOptions = {
    'ชาย': 'male',
    'หญิง': 'female',
    'ไม่ระบุ': 'non-identify',
    'อื่น ๆ': 'other',
  };

  final Map<String, Map<String, String>> bankItems = {
    'ธนาคารกรุงเทพ': {
      'value': 'bbl',
      'icon': 'assets/icons/bbl.svg',
      'background': '#1A237E'
    },
    'ธนาคารกสิกรไทย': {
      'value': 'kbank',
      'icon': 'assets/icons/kbank.svg',
      'background': '#4CAF50'
    },
    'ธนาคารไทยพาณิชย์': {
      'value': 'scb',
      'icon': 'assets/icons/scb.svg',
      'background': '#4A148C'
    },
    'ธนาคารกรุงศรี': {
      'value': 'krungsri',
      'icon': 'assets/icons/bay.svg',
      'background': '#FFB300'
    },
    'ธนาคารทหารไทยธนชาต': {
      'value': 'ttb',
      'icon': 'assets/icons/ttb.svg',
      'background': '#0D47A1'
    },
    'ธนาคารธหารไทย': {
      'value': 'tmb',
      'icon': 'assets/icons/tmb.svg',
      'background': '#1976D2'
    },
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
        ..gender = _selectedGender ?? 'other'
        ..bankCode = _selectedBankCode ?? 'kbank'
        ..bankAccountNumber = _bankAccountNumber.text
        ..bankAccountName = _bankAccountName.text;

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
    } else {
      Get.snackbar('แจ้งเตือน', 'กรุณากรอกข้อมูลให้ครบถ้วน');
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
          child: selectedIndex == 2
              ? Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    children: [
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          'โปรดกรอกข้อมูลธนาคารของท่านให้ครบถ้วนและถูกต้อง เพื่อความสะดวกในการคืนเงินค่าส่วนต่างหลังจากการแลกเปลี่ยน',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center, // จัดเรียงข้อความตรงกลาง
                        ),
                      ),
                      SizedBox(height: 30),
                      _buildBankDropdownField(
                        label: 'เลือกธนาคาร',
                        items: bankItems,
                        value: 'kbank', // ตัวอย่างค่าที่ถูกเลือกเริ่มต้น
                        onChanged: (newValue) {
                          setState(() {
                            _selectedBankCode = newValue;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        controller: _bankAccountNumber,
                        label: 'เลขบัญชี',
                        isBankAccountNumber: true,
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        controller: _bankAccountName,
                        label: 'ชื่อผู้ใช้',
                        maxLength: 30,
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
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : selectedIndex == 1
                  ? Form(
                      key: _personalFormKey,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                            onPressed: () {
                              if (_personalFormKey.currentState!.validate()) {
                                setState(() {
                                  selectedIndex = 2;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              backgroundColor: Constants.secondaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'ยืนยัน',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
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
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                              "กรุณากรอกอีเมลเพื่อสมัครและยืนยันตัวตน",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.normal),
                            ),
                            SizedBox(height: 15),
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
                                hintStyle: TextStyle(
                                  color: Colors.grey, // สีจางเองได้
                                  fontSize: 14, // หรือปรับขนาดด้วย
                                ),
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
                                            3; // อัพเดต state หลัง Dialog ปิด
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
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
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
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal),
                                ),
                                SizedBox(height: 15),
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
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
        ),
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
    bool isBankAccountNumber = false,
    bool isConfirmPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      obscureText: isPassword,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone || isBankAccountNumber
              ? TextInputType.phone
              : TextInputType.text,
      inputFormatters: isPhone || isBankAccountNumber
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10)
            ]
          : null,
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
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
        if (isBankAccountNumber && value.length != 10) {
          return 'เลขบัญชีต้องเป็นตัวเลข 10 หลัก';
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
            labelStyle: const TextStyle(
              fontSize: 14,
            ),
            contentPadding:
                EdgeInsets.only(left: 30, right: 12, top: 14, bottom: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
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

  Widget _buildBankDropdownField({
    required String label,
    required Map<String, Map<String, String>> items,
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
            floatingLabelBehavior:
                FloatingLabelBehavior.always, // แสดง label ตลอดเวลา
            contentPadding: EdgeInsets.fromLTRB(30, 16, 16, 16),
            // contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade600),
            ),
          ),
          items: items.entries
              .map((entry) => DropdownMenuItem<String>(
                    value: entry.value['value'],
                    child: Row(
                      children: [
                        Container(
                          width: 28, // ลดขนาด Container ให้เล็กลง
                          height: 28,
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse(
                                  '0xFF${(entry.value['background'] ?? '#FFFFFF').substring(1)}'),
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: SvgPicture.asset(
                              entry.value['icon']!,
                              width: 20, // ลดขนาด Icon ลงเล็กน้อย
                              height: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 8), // ลดระยะห่างระหว่างไอคอนกับข้อความ
                        Text(entry.key, style: TextStyle(fontSize: 14)),
                      ],
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
          validator: (value) =>
              value == null ? 'โปรดเลือก${label.toLowerCase()}' : null,
        ),
      ),
    );
  }
}
