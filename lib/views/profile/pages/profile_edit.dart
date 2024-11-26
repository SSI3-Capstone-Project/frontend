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
  final genderController = RxString('ชาย');
  final updateProfileController = Get.put(UpdateProfileController());
  final userProfileController = Get.put(UserProfileController());

  String? profileImageUrl; 
  File? profileImageFile; // To hold the selected profile image

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
          genderController.value = userProfile.gender ?? 'ชาย';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("แก้ไขโปรไฟล์"),
        backgroundColor: Colors.white,
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
                        });
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                              ? (profileImageUrl!.startsWith('http') ? NetworkImage(profileImageUrl!) : FileImage(File(profileImageUrl!))) as ImageProvider
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
                    items: ['male', 'female', 'อื่นๆ']
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: (value) {
                      genderController.value = value!;
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
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        child: const Text('ยกเลิก', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final profileData = UpdateProfileRequest(
                              username: usernameController.text,
                              firstname: firstnameController.text,
                              lastname: lastnameController.text,
                              email: emailController.text,
                              phone: phoneController.text,
                              gender: genderController.value,
                              imageUrl: profileImageFile?.path, // Send the file path or null
                            );
                            updateProfileController.updateProfile(profileData);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        child: const Text('บันทึกโปรไฟล์'),
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
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      validator: validator,
    );
  }
}
