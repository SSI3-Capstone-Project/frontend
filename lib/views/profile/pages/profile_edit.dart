import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/update_profile_controller.dart';
import 'package:mbea_ssi3_front/views/profile/models/profile_update_model.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/get_profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final genderController = RxString(''); // RxString for reactive gender
  final updateProfileController = Get.put(UpdateProfileController());
  final userProfileController = Get.put(UserProfileController());

  String? profileImageUrl;
  File? profileImageFile; // To hold the selected profile image
  final Map<String, bool> _isFieldModified = {
    'image': false,
    'username': false,
    'firstname': false,
    'lastname': false,
    'email': false,
    'phone': false,
    'gender': false, // Track gender modification
  };

  Map<String, String> _initialValues = {
    'username': '',
    'firstname': '',
    'lastname': '',
    'email': '',
    'phone': '',
    'gender': '',
  };

  String? _usernameError;
  bool _isUsernameValid = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfile = userProfileController.userProfile.value;
      if (userProfile != null) {
        setState(() {
          profileImageUrl = userProfile.imageUrl;
          usernameController.text = userProfile.username ?? '';
          firstnameController.text = userProfile.firstname ?? '';
          lastnameController.text = userProfile.lastname ?? '';
          emailController.text = userProfile.email ?? '';
          phoneController.text = userProfile.phone ?? '';
          genderController.value = userProfile.gender ?? '';
          // Store initial values for comparison
          _initialValues['username'] = userProfile.username ?? '';
          _initialValues['firstname'] = userProfile.firstname ?? '';
          _initialValues['lastname'] = userProfile.lastname ?? '';
          _initialValues['email'] = userProfile.email ?? '';
          _initialValues['phone'] = userProfile.phone ?? '';
          _initialValues['gender'] = userProfile.gender ?? '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("แก้ไขโปรไฟล์"),
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
      body: Obx(() {
        if (userProfileController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile != null) {
                        setState(() {
                          profileImageUrl = pickedFile.path;
                          profileImageFile = File(pickedFile.path);
                          _isFieldModified['image'] =
                              true; // Force marking a field as modified
                        });
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: profileImageUrl != null &&
                                  profileImageUrl!.isNotEmpty
                              ? (profileImageUrl!.startsWith('http')
                                      ? NetworkImage(profileImageUrl!)
                                      : FileImage(File(profileImageUrl!)))
                                  as ImageProvider
                              : const AssetImage('assets/images/dimoo.png'),
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: usernameController,
                    label: 'ชื่อผู้ใช้งาน',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกชื่อผู้ใช้งาน';
                      }
                      return null;
                    },
                    maxLength: 30,
                    field: 'username',
                    onChanged: _onFieldChanged,
                    errorText: _usernameError,
                  ),
                  const SizedBox(height: 10),
                  _buildTextFormField(
                    controller: firstnameController,
                    label: 'ชื่อจริง',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกชื่อจริง';
                      }
                      return null;
                    },
                    maxLength: 30,
                    field: 'firstname',
                    onChanged: _onFieldChanged,
                  ),
                  const SizedBox(height: 10),
                  _buildTextFormField(
                    controller: lastnameController,
                    label: 'นามสกุล',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกนามสกุล';
                      }
                      return null;
                    },
                    maxLength: 45,
                    field: 'lastname',
                    onChanged: _onFieldChanged,
                  ),
                  const SizedBox(height: 10),
                  _buildTextFormField(
                    controller: emailController,
                    label: 'อีเมล',
                    validator: (value) {
                      if (value == null || !GetUtils.isEmail(value)) {
                        return 'กรุณากรอกอีเมลที่ถูกต้อง';
                      }
                      return null;
                    },
                    maxLength: 255,
                    field: 'email',
                    onChanged: _onFieldChanged,
                  ),
                  const SizedBox(height: 10),
                  _buildTextFormField(
                    controller: phoneController,
                    label: 'เบอร์โทร',
                    validator: (value) {
                      if (value == null || !GetUtils.isPhoneNumber(value)) {
                        return 'กรุณากรอกเบอร์โทรที่ถูกต้อง';
                      }
                      return null;
                    },
                    maxLength: 10,
                    field: 'phone',
                    onChanged: _onFieldChanged,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: genderController.value,
                    decoration: InputDecoration(
                      labelText: 'เพศ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    items: ['male', 'female', 'other', 'non-identify']
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: (value) {
                      genderController.value = value!;
                      _onFieldChanged(genderController.value);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.secondaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
                        child: const Text('ยกเลิก',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _canSubmit()
                            ? () async {
                                if (_formKey.currentState!.validate()) {
                                  // สร้างข้อมูลโปรไฟล์ที่อัปเดต
                                  final profileData = UpdateProfileRequest(
                                    username: usernameController.text,
                                    firstname: firstnameController.text,
                                    lastname: lastnameController.text,
                                    email: emailController.text,
                                    phone: phoneController.text,
                                    gender: genderController.value,
                                    imageUrl: profileImageFile
                                        ?.path, // ส่ง path ของไฟล์หรือ null
                                  );

                                  // เรียกใช้งานฟังก์ชัน updateProfile ใน Controller
                                  await updateProfileController
                                      .updateProfile(profileData);

                                  // หลังจากอัปเดตสำเร็จกลับไปที่หน้าก่อนหน้า
                                  Navigator.pop(
                                      context); // เพิ่มการเรียก pop เพื่อกลับไปหน้าเดิม

                                  // สามารถใช้ Snackbar หรือ Dialog เพื่อแจ้งผลการอัปเดต
                                  Get.snackbar('สำเร็จ',
                                      'โปรไฟล์ของคุณได้รับการอัปเดตแล้ว',
                                      snackPosition: SnackPosition.BOTTOM);
                                } else if (_isUsernameValid) {
                                  setState(() {
                                    _usernameError = 'ชื่อนี้ถูกใช้งานแล้ว';
                                    _isUsernameValid = false;
                                  });
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canSubmit()
                              ? Constants.primaryColor
                              : Colors.grey,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
                        child: const Text('แก้ไข',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?)? validator,
    required int maxLength,
    required String field,
    required Function(String) onChanged,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: _isFieldModified[field] == true ? Colors.green : Colors.grey,
          ),
        ),
        errorText: errorText,
      ),
      maxLength: maxLength,
      validator: validator,
      onChanged: (value) {
        onChanged(value);
      },
    );
  }

  void _onFieldChanged(String value) {
    setState(() {
      _isFieldModified['image'] = true;
      _isFieldModified['username'] =
          usernameController.text != _initialValues['username'];
      _isFieldModified['firstname'] =
          firstnameController.text != _initialValues['firstname'];
      _isFieldModified['lastname'] =
          lastnameController.text != _initialValues['lastname'];
      _isFieldModified['email'] =
          emailController.text != _initialValues['email'];
      _isFieldModified['phone'] =
          phoneController.text != _initialValues['phone'];
      _isFieldModified['gender'] =
          genderController.value != _initialValues['gender'];
    });
  }

  bool _canSubmit() {
    return _isFieldModified.values.contains(true);
  }
}
