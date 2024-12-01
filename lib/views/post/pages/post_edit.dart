import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mbea_ssi3_front/controller/brand_controller.dart';
import 'package:mbea_ssi3_front/controller/province_controller.dart';
import 'package:mbea_ssi3_front/model/brand_model.dart';
import 'package:mbea_ssi3_front/model/post_detail_model.dart';
import 'package:mbea_ssi3_front/model/province_model.dart';
import 'package:mbea_ssi3_front/views/post/controllers/update_post_controller.dart';
import 'package:mbea_ssi3_front/views/post/models/post_update_model.dart';

class EditPostForm extends StatefulWidget {
  final PostDetail postDetail;

  const EditPostForm({super.key, required this.postDetail});

  @override
  _EditPostFormState createState() => _EditPostFormState();
}

class _EditPostFormState extends State<EditPostForm> {
  List<dynamic> mediaFiles = [];
  final BrandController brandController = Get.put(BrandController());
  final ProvinceController provinceController = Get.put(ProvinceController());
  UpdatePostController updatePostController = Get.find<UpdatePostController>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _flawController = TextEditingController();
  final TextEditingController _desiredController = TextEditingController();

  String? selectedBrand;
  String? selectedMainCategory;
  String? selectedSubCategory;

  String? selectedProvince;
  String? selectedMainDistrict;
  String? selectedSubDistrict;

  bool _mediaError = false;

  @override
  void initState() {
    super.initState();
    brandController.fetchBrands();

    // เรียก _initializeForm เมื่อ isLoading เปลี่ยนเป็น false และข้อมูลถูกโหลดเสร็จ
    ever(brandController.isLoading, (loading) {
      ever(provinceController.isLoading, (loading) {
        if (!loading) {
          _initializeForm();
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeForm();
  }

  bool isEdited = false;

  void _checkIfEdited() {
    List<String> parts =
        widget.postDetail.location.split(',').map((e) => e.trim()).toList();

    String oldSubDistrict = parts.length > 0 ? parts[0] : '';
    bool hasMediaChanged = mediaFiles.length !=
        (widget.postDetail.postImages.length +
            widget.postDetail.postVideos.length);

    bool hasTextChanged =
        _productNameController.text != widget.postDetail.title ||
            _descriptionController.text != widget.postDetail.description ||
            _flawController.text != (widget.postDetail.flaw ?? '') ||
            _desiredController.text != widget.postDetail.desiredItem;

    bool hasDropdownChanged =
        selectedSubCategory != widget.postDetail.subCollectionName ||
            selectedSubDistrict != oldSubDistrict;

    setState(() {
      isEdited = hasTextChanged || hasDropdownChanged || hasMediaChanged;
    });
  }

  void _onFieldChanged() {
    _checkIfEdited();
  }

  void _initializeForm() {
    if (brandController.brands.isEmpty) return; // ตรวจสอบว่ามีข้อมูลหรือไม่

    _productNameController.text = widget.postDetail.title;
    _descriptionController.text = widget.postDetail.description;
    _flawController.text = widget.postDetail.flaw ?? '';
    _desiredController.text = widget.postDetail.desiredItem;

    mediaFiles = [
      ...widget.postDetail.postImages.map((image) => image.imageUrl),
      ...widget.postDetail.postVideos.map((video) => video.videoUrl),
    ];

    // ค้นหาชื่อแบรนด์และคอลเลคชั่นหลักจาก subCollectionName
    for (var brand in brandController.brands) {
      for (var collection in brand.collections ?? []) {
        SubCollection? subCollection = collection.subCollections?.firstWhere(
            (sub) => sub.name == widget.postDetail.subCollectionName,
            orElse: () =>
                SubCollection(id: '', name: '')); // ใช้ default value แทน null

        if (subCollection != null && subCollection.id.isNotEmpty) {
          if (mounted) {
            setState(() {
              selectedBrand = brand.name;
              selectedMainCategory = collection.name;
              selectedSubCategory = subCollection.name;
            });
          }
        }
      }
    }

    List<String> parts =
        widget.postDetail.location.split(',').map((e) => e.trim()).toList();

    String oldSubDistrict = parts.length > 0 ? parts[0] : '';
    String oldProvince = parts.length > 1 ? parts[1] : '';
    print(
        '-----------------------------------------------------------------------------------');
    print(oldProvince);
    print(oldSubDistrict);

    for (var province in provinceController.provinces) {
      for (var district in province.districts ?? []) {
        SubDistrict? subDistrict = district.subDistricts?.firstWhere(
            (sub) => sub.name == oldSubDistrict,
            orElse: () => SubDistrict(id: 0, name: ''));

        if (subDistrict != null && subDistrict.id != 0) {
          if (mounted) {
            setState(() {
              selectedProvince = province.name;
              selectedMainDistrict = district.name;
              selectedSubDistrict = subDistrict.name;
            });
          }
        }
      }
    }
    return;
  }

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
          mediaFiles.add(File(pickedFile.path));
        });
      }
    }
    if (mounted) {
      setState(() {
        _isPickingMedia = false; // จบการเลือกสื่อ
      });
    }
    _onFieldChanged();
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
          mediaFiles.add(File(pickedFile.path));
        });
      }
    }
    if (mounted) {
      setState(() {
        _isPickingMedia = false; // จบการเลือกสื่อ
      });
    }
    _onFieldChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              _buildTextFormField(
                controller: _productNameController,
                label: 'ชื่อสินค้า',
                validator: (value) => value == null || value.isEmpty
                    ? 'โปรดระบุชื่อสินค้า'
                    : null,
              ),
              SizedBox(height: 16),
              Obx(() {
                if (!mounted) return const SizedBox();

                if (brandController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                return Container(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      _buildDropdownField(
                        label: 'เลือกแบรนด์',
                        items:
                            brandController.brands.map((b) => b.name).toList(),
                        value: selectedBrand,
                        onChanged: (newValue) {
                          if (mounted) {
                            setState(() {
                              selectedBrand = newValue;
                              selectedMainCategory = null;
                              selectedSubCategory = null;
                            });
                          }
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
                            if (mounted) {
                              setState(() {
                                selectedMainCategory = newValue;
                                selectedSubCategory = null;
                              });
                            }
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
                            if (mounted) {
                              setState(() {
                                selectedSubCategory = newValue;
                              });
                            }
                          },
                          validator: (value) =>
                              value == null ? 'โปรดเลือกคอลเลคชั่นย่อย' : null,
                        ),
                    ],
                  ),
                );
              }),
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
              ),
              SizedBox(height: 16),
              _buildTextFormField(
                controller: _desiredController,
                label: 'ระบุสิ่งที่อยากแลก',
                validator: (value) => value == null || value.isEmpty
                    ? 'โปรดระบุสิ่งที่อยากแลก'
                    : null,
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
                          if (mounted) {
                            setState(() {
                              selectedProvince = newValue;
                              selectedMainDistrict = null;
                              selectedSubDistrict = null;
                            });
                          }
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
                            if (mounted) {
                              setState(() {
                                selectedMainDistrict = newValue;
                                selectedSubDistrict = null;
                              });
                            }
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
                            if (mounted) {
                              setState(() {
                                selectedSubDistrict = newValue;
                              });
                            }
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
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    int maxLength = 45,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      onChanged: (_) => _onFieldChanged(),
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding:
            EdgeInsets.only(left: 30, right: 12, top: 16, bottom: 16),
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
            contentPadding:
                EdgeInsets.only(left: 30, right: 12, top: 16, bottom: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
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
          onChanged: (newValue) {
            onChanged(newValue);
            _onFieldChanged(); // เรียกเมื่อเปลี่ยน dropdown
          },
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

    // Separate images and videos, then concatenate them with images first
    final images = mediaFiles.where((file) {
      bool isFile = file is File;
      String filePath = isFile ? file.path : file as String;
      return filePath.endsWith('.jpg') || filePath.endsWith('.png');
    }).toList();

    final videos = mediaFiles.where((file) {
      bool isFile = file is File;
      String filePath = isFile ? file.path : file as String;
      return filePath.endsWith('.mp4') || filePath.endsWith('.mov');
    }).toList();

    final sortedMediaFiles = [...images, ...videos];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sortedMediaFiles.map((file) {
        bool isFile = file is File;
        String filePath = isFile ? file.path : file as String;
        bool isImage = filePath.endsWith('.jpg') || filePath.endsWith('.png');

        return Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              child: isImage
                  ? (isFile
                      ? Image.file(file as File, fit: BoxFit.cover)
                      : Image.network(filePath, fit: BoxFit.cover))
                  : Icon(Icons.videocam, size: 50),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () => {
                  if (mounted) {setState(() => mediaFiles.remove(file))},
                  _onFieldChanged()
                },
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
        width: 160,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade600),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey.shade800),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.black),
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
          onPressed: isEdited
              ? () async {
                  if (_formKey.currentState!.validate() &&
                      mediaFiles.isNotEmpty &&
                      mediaFiles.any((file) {
                        // ตรวจสอบว่าเป็นรูปภาพหรือไม่
                        String filePath =
                            file is File ? file.path : file as String;
                        return filePath.endsWith('.jpg') ||
                            filePath.endsWith('.jpeg') ||
                            filePath.endsWith('.png');
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('กรุณาเลือกคอลเลคชั่นย่อย')),
                      );
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

                    // ดำเนินการสร้าง UpdatePost ตามที่กำหนดไว้
                    List<PostMedia> postImages =
                        widget.postDetail.postImages.map((image) {
                      bool isDeleted = !mediaFiles.contains(image.imageUrl);
                      return PostMedia(
                        id: image.id,
                        hierarchy: image.hierarchy,
                        status: isDeleted ? "delete" : "update",
                      );
                    }).toList();

                    mediaFiles
                        .where((file) =>
                            file is File &&
                            (file.path.endsWith('.jpg') ||
                                file.path.endsWith('.jpeg') ||
                                file.path.endsWith('.png')))
                        .forEach((file) {
                      postImages.add(PostMedia(
                        id: null,
                        hierarchy: 0,
                        status: "add",
                      ));
                    });

                    List<PostMedia> postVideos =
                        widget.postDetail.postVideos.map((video) {
                      bool isDeleted = !mediaFiles.contains(video.videoUrl);
                      return PostMedia(
                        id: video.id,
                        hierarchy: video.hierarchy,
                        status: isDeleted ? "delete" : "update",
                      );
                    }).toList();

                    mediaFiles
                        .where((file) =>
                            file is File && file.path.endsWith('.mp4'))
                        .forEach((file) {
                      postVideos.add(PostMedia(
                        id: null,
                        hierarchy: 0,
                        status: "add",
                      ));
                    });

                    int imageHierarchy = 1;
                    postImages = postImages.map((media) {
                      if (media.status == "delete") {
                        return PostMedia(
                          id: media.id,
                          hierarchy: null,
                          status: media.status,
                        );
                      } else {
                        return PostMedia(
                          id: media.id,
                          hierarchy: imageHierarchy++,
                          status: media.status,
                        );
                      }
                    }).toList();

                    int videoHierarchy = 1;
                    postVideos = postVideos.map((media) {
                      if (media.status == "delete") {
                        return PostMedia(
                          id: media.id,
                          hierarchy: null,
                          status: media.status,
                        );
                      } else {
                        return PostMedia(
                          id: media.id,
                          hierarchy: videoHierarchy++,
                          status: media.status,
                        );
                      }
                    }).toList();

                    UpdatePost postToUpdate = UpdatePost(
                      id: widget.postDetail.id,
                      title: _productNameController.text,
                      subCollectionId: subCollectionId,
                      subDistrictId: subDistrictId.toString(),
                      description: _descriptionController.text,
                      flaw: _flawController.text.isNotEmpty
                          ? _flawController.text
                          : null,
                      desiredItem: _desiredController.text,
                      postImages: postImages,
                      postVideos: postVideos,
                      imageFiles: mediaFiles
                          .where((file) =>
                              file is File &&
                              (file.path.endsWith('.jpg') ||
                                  file.path.endsWith('.jpeg') ||
                                  file.path.endsWith('.png')))
                          .cast<File>()
                          .toList(),
                      videoFiles: mediaFiles
                          .where((file) =>
                              file is File && file.path.endsWith('.mp4'))
                          .cast<File>()
                          .toList(),
                    );

                    var result = await updatePostController
                        .updatePostDetails(postToUpdate);
                    if (result) {
                      bool isUpdated = true;
                      Navigator.pop(context, isUpdated);
                    }
                  } else {
                    String errorMessage = mediaFiles.any((file) {
                      String filePath =
                          file is File ? file.path : file as String;
                      return filePath.endsWith('.jpg') ||
                          filePath.endsWith('.jpeg') ||
                          filePath.endsWith('.png');
                    })
                        ? 'กรุณากรอกข้อมูลให้ครบถ้วน'
                        : 'กรุณาเลือกรูปภาพอย่างน้อย 1 รายการ';
                    Get.snackbar('แจ้งเตือน', errorMessage);
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            'บันทึกการแก้ไข',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
