import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/update_profile_controller.dart';
import 'package:mbea_ssi3_front/views/profile/models/profile_get_model.dart';
import 'package:mbea_ssi3_front/views/profile/models/profile_update_model.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/get_profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfilePage({super.key, required this.userProfile});

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
  bool isEdited = false;
  final Map<String, bool> _isFieldModified = {
    'image': false,
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
          profileImageUrl = widget.userProfile.imageUrl;
          usernameController.text = widget.userProfile.username ?? '';
          firstnameController.text = widget.userProfile.firstname ?? '';
          lastnameController.text = widget.userProfile.lastname ?? '';
          emailController.text = widget.userProfile.email ?? '';
          phoneController.text = widget.userProfile.phone ?? '';
          genderController.value = widget.userProfile.gender ?? 'non-identify';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "แก้ไขโปรไฟล์",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
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
                        _onFieldChanged("");
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
                  IgnorePointer(
                    ignoring: true, // ทำให้ฟิลด์ไม่สามารถแก้ไขได้
                    child: _buildTextFormField(
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
                  IgnorePointer(
                    ignoring: true,
                    child: _buildTextFormField(
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
                  DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButtonFormField<String>(
                        value: ['male', 'female', 'other', 'non-identify']
                            .contains(genderController.value)
                            ? genderController.value
                            : 'non-identify',
                        decoration: InputDecoration(
                          labelText: 'เพศ',
                          labelStyle: const TextStyle(
                            fontSize: 14,
                          ),
                          contentPadding: EdgeInsets.only(left: 30, right: 12, top: 14, bottom: 14),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        menuMaxHeight: 200,
                        items: ['male', 'female', 'other', 'non-identify']
                            .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(
                            gender == 'male'
                                ? 'ชาย'
                                : gender == 'female'
                                ? 'หญิง'
                                : gender == 'other'
                                ? 'อื่น ๆ'
                                : 'ไม่ระบุ',
                          ),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            genderController.value = value!;
                            _onFieldChanged(genderController.value);
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                Navigator.of(context)
                                    .pop(); // ย้อนกลับไปหน้าเดิม
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Constants.secondaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "ยกเลิก",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: ElevatedButton(
                            onPressed: isEdited
                                ? () async {
                                    if (_formKey.currentState!.validate()) {
                                      final profileData = UpdateProfileRequest(
                                        username: usernameController.text,
                                        firstname: firstnameController.text,
                                        lastname: lastnameController.text,
                                        email: emailController.text,
                                        phone: phoneController.text,
                                        gender: genderController.value,
                                        imageUrl: profileImageFile?.path,
                                      );

                                      await updateProfileController
                                          .updateProfile(profileData);
                                      Navigator.pop(context);
                                    } else if (_isUsernameValid) {
                                      setState(() {
                                        _usernameError = 'ชื่อนี้ถูกใช้งานแล้ว';
                                        _isUsernameValid = false;
                                      });
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isEdited
                                  ? Constants.primaryColor
                                  : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "แก้ไข",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
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
        labelStyle: const TextStyle(
          fontSize: 14,
        ),
        contentPadding:
            EdgeInsets.only(left: 30, right: 12, top: 14, bottom: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
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
    bool hasTextChanged =
        usernameController.text != widget.userProfile.username ||
            firstnameController.text != widget.userProfile.firstname ||
            lastnameController.text != widget.userProfile.lastname ||
            emailController.text != widget.userProfile.email ||
            phoneController.text != widget.userProfile.phone;

    bool hasDropdownChanged =
        genderController.value != widget.userProfile.gender;

    setState(() {
      isEdited = hasTextChanged ||
          hasDropdownChanged ||
          _isFieldModified['image'] == true;
    });
  }
}
