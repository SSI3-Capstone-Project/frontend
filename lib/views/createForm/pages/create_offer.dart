import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mbea_ssi3_front/controller/brand_controller.dart';
import 'package:mbea_ssi3_front/controller/offers_controller.dart';
import 'package:mbea_ssi3_front/controller/province_controller.dart';
import 'package:mbea_ssi3_front/controller/send_offer_controller.dart';
import 'package:mbea_ssi3_front/views/createForm/controllers/create_offer_controller.dart';
import 'package:mbea_ssi3_front/views/createForm/models/create_offer_model.dart';
// import 'package:mbea_ssi3_front/common/constants.dart';

class CreateOfferForm extends StatefulWidget {
  final bool isSendOffer;
  final String postId;
  const CreateOfferForm(
      {super.key, this.isSendOffer = false, this.postId = ''});

  @override
  _CreateOfferFormState createState() => _CreateOfferFormState();
}

class _CreateOfferFormState extends State<CreateOfferForm> {
  List<File> mediaFiles = [];

  final SendOfferController sendOfferController =
      Get.put(SendOfferController());
  final CreateOfferController createOfferController =
      Get.put(CreateOfferController());
  final BrandController brandController = Get.put(BrandController());
  final ProvinceController provinceController = Get.put(ProvinceController());

  final _formKey = GlobalKey<FormState>();
  final OffersController offerController = Get.put(OffersController());
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _flawController = TextEditingController();
  // final TextEditingController _desiredController = TextEditingController();

  String? selectedBrand;
  String? selectedMainCategory;
  String? selectedSubCategory;

  String? selectedProvince;
  String? selectedMainDistrict;
  String? selectedSubDistrict;

  bool _mediaError = false;

  bool _loadPage = false;

  Future<void> _pickImage() async {
    if (mounted) {
      setState(() {
        _isPickingMedia = true; // เริ่มเลือกสื่อ
      });
    }
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mediaFiles.length < 5) {
      if (mounted) {
        setState(() {
          List<File> videos =
              mediaFiles.where((file) => file.path.endsWith('.mp4')).toList();
          mediaFiles =
              mediaFiles.where((file) => !file.path.endsWith('.mp4')).toList();
          mediaFiles.add(File(pickedFile.path));
          mediaFiles.addAll(videos);
        });
      }
    }
    if (mounted) {
      setState(() {
        _isPickingMedia = false; // จบการเลือกสื่อ
      });
    }
  }

  Future<void> _pickVideo() async {
    if (mounted) {
      setState(() {
        _isPickingMedia = true; // เริ่มเลือกสื่อ
      });
    }
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null && mediaFiles.length < 5) {
      if (mounted) {
        setState(() {
          List<File> videos =
              mediaFiles.where((file) => file.path.endsWith('.mp4')).toList();
          mediaFiles =
              mediaFiles.where((file) => !file.path.endsWith('.mp4')).toList();
          mediaFiles.add(File(pickedFile.path));
          mediaFiles.addAll(videos);
        });
      }
    }
    if (mounted) {
      setState(() {
        _isPickingMedia = false; // จบการเลือกสื่อ
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadPage) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 1, vertical: 0),
          children: [
            SizedBox(height: 16),
            _buildTextFormField(
              controller: _productNameController,
              label: 'ชื่อสินค้า',
              validator: (value) =>
                  value == null || value.isEmpty ? 'โปรดระบุชื่อสินค้า' : null,
            ),
            SizedBox(height: 16),

            Obx(() {
              if (!mounted) return const SizedBox();

              if (brandController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              return Container(
                constraints:
                    BoxConstraints(maxHeight: 300), // Set a maximum height
                child: ListView(
                  padding: EdgeInsets.only(top: 0),
                  shrinkWrap:
                      true, // This allows the ListView to take only as much height as it needs
                  physics:
                      NeverScrollableScrollPhysics(), // Prevents it from scrolling separately
                  children: [
                    _buildDropdownField(
                      label: 'เลือกแบรนด์',
                      items: brandController.brands.map((b) => b.name).toList(),
                      value: selectedBrand,
                      onChanged: (newValue) {
                        setState(() {
                          selectedBrand = newValue;
                          selectedMainCategory = null;
                          selectedSubCategory = null;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'โปรดเลือกแบรนด์' : null,
                    ),
                    if (selectedBrand != null)
                      _buildDropdownField(
                        label: 'เลือกคอลเลคชั่น',
                        items: brandController.brands
                                .firstWhere((b) => b.name == selectedBrand)
                                .collections
                                ?.map((c) => c.name)
                                .toList() ??
                            [],
                        value: selectedMainCategory,
                        onChanged: (newValue) {
                          setState(() {
                            selectedMainCategory = newValue;
                            selectedSubCategory = null;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'โปรดเลือกคอลเลคชั่น' : null,
                      ),
                    if (selectedMainCategory != null)
                      _buildDropdownField(
                        label: 'เลือกคอลเลคชั่นย่อย',
                        items: brandController.brands
                                .firstWhere((b) => b.name == selectedBrand)
                                .collections
                                ?.firstWhere(
                                    (c) => c.name == selectedMainCategory)
                                .subCollections
                                ?.map((sc) => sc.name)
                                .toList() ??
                            [],
                        value: selectedSubCategory,
                        onChanged: (newValue) {
                          setState(() {
                            selectedSubCategory = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'โปรดเลือกคอลเลคชั่นย่อย' : null,
                      ),
                  ],
                ),
              );
            }),
            // SizedBox(height: 30),
            _buildTextFormField(
              controller: _descriptionController,
              label: 'รายละเอียดสินค้า',
              maxLength: 200,
              maxLines: 4,
              validator: (value) => value == null || value.isEmpty
                  ? 'โปรดระบุรายละเอียดของสินค้า'
                  : null,
            ),
            SizedBox(height: 16),
            _buildTextFormField(
              controller: _flawController,
              label: 'ตำหนิ',
              maxLength: 50,
            ),
            SizedBox(height: 16),
            Obx(() {
              if (!mounted) return const SizedBox();

              if (provinceController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              return Container(
                constraints:
                    BoxConstraints(maxHeight: 300), // Set a maximum height
                child: ListView(
                  padding: EdgeInsets.only(top: 0),
                  shrinkWrap:
                      true, // This allows the ListView to take only as much height as it needs
                  physics:
                      NeverScrollableScrollPhysics(), // Prevents it from scrolling separately
                  children: [
                    _buildDropdownField(
                      label: 'เลือกจังหวัด',
                      items: provinceController.provinces
                          .map((b) => b.name)
                          .toList(),
                      value: selectedProvince,
                      onChanged: (newValue) {
                        setState(() {
                          selectedProvince = newValue;
                          selectedMainDistrict = null;
                          selectedSubDistrict = null;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'โปรดเลือกจังหวัด' : null,
                    ),
                    if (selectedProvince != null)
                      _buildDropdownField(
                        label: 'เลือกเขต / อำเภอ',
                        items: provinceController.provinces
                                .firstWhere((b) => b.name == selectedProvince)
                                .districts
                                ?.map((c) => c.name)
                                .toList() ??
                            [],
                        value: selectedMainDistrict,
                        onChanged: (newValue) {
                          setState(() {
                            selectedMainDistrict = newValue;
                            selectedSubDistrict = null;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'โปรดเลือกเขต / อำเภอ' : null,
                      ),
                    if (selectedMainDistrict != null)
                      _buildDropdownField(
                        label: 'เลือกตำบล',
                        items: provinceController.provinces
                                .firstWhere((b) => b.name == selectedProvince)
                                .districts
                                ?.firstWhere(
                                    (c) => c.name == selectedMainDistrict)
                                .subDistricts
                                ?.map((sc) => sc.name)
                                .toList() ??
                            [],
                        value: selectedSubDistrict,
                        onChanged: (newValue) {
                          setState(() {
                            selectedSubDistrict = newValue;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'โปรดเลือกตำบล' : null,
                      ),
                  ],
                ),
              );
            }),
            // SizedBox(height: 30),
            _buildMediaPreview(),
            SizedBox(height: 30),
            _buildMediaButtons(),
            SizedBox(height: 30),
            _buildSubmitButton(),
            SizedBox(height: 30),
          ],
        ),
      );
    }
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    int maxLength = 45,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: widget.isSendOffer
              ? BorderRadius.circular(12)
              : BorderRadius.circular(20),
        ),
        contentPadding: widget.isSendOffer
            ? EdgeInsets.only(left: 30, right: 12, top: 12, bottom: 12)
            : EdgeInsets.only(left: 30, right: 12, top: 16, bottom: 16),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    String? value,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator, // Added validator parameter
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 30), // Added margin at the bottom
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField2<String>(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            contentPadding: widget.isSendOffer
                ? EdgeInsets.only(left: 30, right: 12, top: 12, bottom: 12)
                : EdgeInsets.only(left: 30, right: 12, top: 16, bottom: 16),
            border: OutlineInputBorder(
              borderRadius: widget.isSendOffer
                  ? BorderRadius.circular(12)
                  : BorderRadius.circular(20),
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
              borderRadius: BorderRadius.circular(14),
              color: Colors.white,
            ),
            maxHeight: 200,
          ),
          validator: validator ?? // Use the provided validator or default
              (value) =>
                  value == null ? 'โปรดเลือก${label.toLowerCase()}' : null,
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (mediaFiles.isEmpty) return Container();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: mediaFiles.map((file) {
        bool isImage = file.path.endsWith('.jpg') || file.path.endsWith('.png');
        return Stack(
          children: [
            Container(
              width: widget.isSendOffer ? 80 : 100,
              height: widget.isSendOffer ? 80 : 100,
              child: isImage
                  ? Image.file(file, fit: BoxFit.cover)
                  : Icon(Icons.videocam, size: 50),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () => setState(() => mediaFiles.remove(file)),
                child: Icon(Icons.close, color: Colors.red),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  bool _isPickingMedia = false;

  Widget _buildMediaButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (_mediaError)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'โปรดเลือกรูปภาพหรือวีดีโออย่างน้อย 1 รายการ',
              style: TextStyle(color: Colors.red.shade900, fontSize: 12),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCustomButton(
              onPressed: (!_isPickingMedia && mediaFiles.length < 5)
                  ? _pickImage
                  : () {
                      Get.snackbar(
                          'แจ้งเตือน', 'ถึงขีดจำกัดจำนวนไฟล์สูงสุดแล้ว');
                    },
              icon: Icons.photo_library,
              label: 'เลือกรูปภาพ',
            ),
            SizedBox(width: 16),
            _buildCustomButton(
              onPressed: (!_isPickingMedia && mediaFiles.length < 5)
                  ? _pickVideo
                  : () {
                      Get.snackbar(
                          'แจ้งเตือน', 'ถึงขีดจำกัดจำนวนไฟล์สูงสุดแล้ว');
                    },
              icon: Icons.video_library,
              label: 'เลือกวีดีโอ',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: widget.isSendOffer ? 120 : 160, // ความกว้างของปุ่ม
        height: 50, // ความสูงของปุ่ม
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade600),
          borderRadius: BorderRadius.circular(14), // มุมมน
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey.shade800),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 150,
        child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate() &&
                mediaFiles.isNotEmpty &&
                mediaFiles.any((file) {
                  // ตรวจสอบว่าเป็นไฟล์รูปภาพหรือไม่
                  return file.path.endsWith('.jpg') ||
                      file.path.endsWith('.jpeg') ||
                      file.path.endsWith('.png');
                })) {
              String? subCollectionId;

              if (selectedSubCategory != null) {
                subCollectionId = brandController.brands
                    .firstWhere((b) => b.name == selectedBrand)
                    .collections
                    ?.firstWhere((c) => c.name == selectedMainCategory)
                    .subCollections
                    ?.firstWhere((sc) => sc.name == selectedSubCategory)
                    .id;
              }

              if (subCollectionId == null) {
                Get.snackbar('แจ้งเตือน', 'กรุณาเลือกคอลเลคชั่นย่อย');
                return;
              }

              int? subDistrictId = 0;

              if (selectedSubDistrict != null) {
                subDistrictId = provinceController.provinces
                    .firstWhere((b) => b.name == selectedProvince)
                    .districts
                    ?.firstWhere((c) => c.name == selectedMainDistrict)
                    .subDistricts
                    ?.firstWhere((sc) => sc.name == selectedSubDistrict)
                    .id;
              }

              if (subCollectionId == 0) {
                Get.snackbar('แจ้งเตือน', 'กรุณาเลือกคอลเลคชั่นย่อย');
                return;
              }

              // สร้าง Post object พร้อมข้อมูลทั้งหมด
              Offer post = Offer(
                title: _productNameController.text,
                description: _descriptionController.text,
                flaw: _flawController.text,
                subCollectionId: subCollectionId,
                subDistrictId: subDistrictId ?? 0,
                mediaFiles: mediaFiles,
              );

              // ส่งไปยัง Controller เพื่อสร้างโพสต์ใหม่
              if (mounted) {
                setState(() {
                  _loadPage = true;
                });
              }

              // ส่งไปยัง Controller เพื่อสร้างโพสต์ใหม่
              var result = await createOfferController.createOffer(post);
              if (mounted) {
                if (result != null) {
                  Get.snackbar('สำเร็จ', 'ข้อเสนอใหม่ของคุณถูกสร้างขึ้นแล้ว');
                  await offerController.fetchOffers();
                  // send Offer
                  if (widget.isSendOffer) {
                    sendOfferController.addOffer(
                        postId: widget.postId, offerId: result);
                    Navigator.pop(context);
                  }
                  Navigator.pop(context);
                }
              }
              if (mounted) {
                setState(() {
                  _loadPage = false;
                });
              }
            } else {
              // แสดงข้อความแจ้งเตือนเมื่อไม่มีรูปภาพใน mediaFiles
              String errorMessage = mediaFiles.any((file) {
                return file.path.endsWith('.jpg') ||
                    file.path.endsWith('.jpeg') ||
                    file.path.endsWith('.png');
              })
                  ? 'กรุณากรอกข้อมูลให้ครบถ้วน'
                  : 'กรุณาเลือกรูปภาพอย่างน้อย 1 รูป';
              Get.snackbar('แจ้งเตือน', errorMessage);
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            'ยืนยัน',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
