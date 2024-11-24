import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/controller/province_controller.dart';
import 'package:mbea_ssi3_front/views/address/controllers/address_controller.dart';
import 'package:mbea_ssi3_front/views/address/models/address_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final AddressController addressController = Get.put(AddressController());
  final ProvinceController provinceController = Get.put(ProvinceController());
  final TextEditingController _mainAddress = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedProvince;
  String? selectedMainDistrict;
  String? selectedSubDistrict;

  bool isDefault = false;

  // @override
  // void initState() {
  //   super.initState();
  //   // ดึงข้อมูลที่อยู่จาก API เมื่อเริ่มต้น
  //   addressController.fetchAddresses();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          'จัดการที่อยู่',
          style: TextStyle(
              color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        // const Text(
        //   'จัดการที่อยู่',
        //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
        // ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        if (addressController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (addressController.addressList.isEmpty) {
          return Container(
            color: Colors.white,
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 90),
                child: ElevatedButton(
                  onPressed: _createAddress,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                    backgroundColor: Constants.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'เพิ่มที่อยู่ใหม่',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            addressController.fetchAddresses();
          },
          color: Colors.white,
          backgroundColor: Constants.secondaryColor,
          child: Container(
            color: Colors.white,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // แสดงรายการที่อยู่
                ...addressController.addressList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildAddressCard(item, index);
                }).toList(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 120),
                  child: ElevatedButton(
                    onPressed: _createAddress,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Constants.secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      'เพิ่มที่อยู่ใหม่',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAddressCard(Address item, int index) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                size: 35,
                Icons.location_on,
                color: Colors.black54,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'สถานที่อยู่',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      if (item.isDefault == true)
                        Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Constants.primaryColor, // สีพื้นหลัง
                              borderRadius:
                                  BorderRadius.circular(8.0), // มุมโค้ง
                            ),
                            child: const Text(
                              "ที่อยู่หลัก",
                              style: TextStyle(
                                  color: Colors.white, // สีข้อความ
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold // ขนาดข้อความ
                                  ),
                            ))
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.fullAddress, // ดึงข้อมูล fullAddress จาก Address
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Constants.primaryColor),
                  onPressed: () =>
                      _editAddress(item.fullAddress, item.id, item.isDefault),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Constants.secondaryColor),
                  onPressed: () => _deleteAddress(item.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editAddress(String address, String id, bool selectDefault) {
    _resetAddressForm();

    List<String> parts = address.split(' ');

    // List<String> lastFourParts = parts.sublist(parts.length - 4);

    String province = parts[parts.length - 2];
    String district = parts[parts.length - 3];
    String subDistrict = parts[parts.length - 4];
    String mainaddress = parts[parts.length - 5];

    if (mounted) {
      setState(() {
        selectedProvince = province;
        selectedMainDistrict = district;
        selectedSubDistrict = subDistrict;
        _mainAddress.text = mainaddress;
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Text(
                              'แก้ไขที่อยู่',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildTextFormField(
                              controller: _mainAddress,
                              label: 'ที่อยู่',
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'โปรดระบุที่อยู่'
                                      : null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildDropdownField(
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
                          ),
                          if (selectedProvince != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _buildDropdownField(
                                label: 'เลือกเขต / อำเภอ',
                                items: provinceController.provinces
                                        .firstWhere(
                                            (b) => b.name == selectedProvince)
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
                                validator: (value) => value == null
                                    ? 'โปรดเลือกเขต / อำเภอ'
                                    : null,
                              ),
                            ),
                          if (selectedMainDistrict != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _buildDropdownField(
                                label: 'เลือกตำบล',
                                items: provinceController.provinces
                                        .firstWhere(
                                            (b) => b.name == selectedProvince)
                                        .districts
                                        ?.firstWhere((c) =>
                                            c.name == selectedMainDistrict)
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
                            ),
                          if (!addressController.addressList.isEmpty &&
                              !selectDefault)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isDefault = !isDefault;
                                      });
                                    },
                                    child: Checkbox(
                                      value: isDefault,
                                      onChanged: (value) {
                                        setState(() {
                                          isDefault = value!;
                                        });
                                      },
                                      activeColor: Constants.secondaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'ตั้งเป็นสถานที่อยู่หลัก',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 15),
                          if (selectDefault) _buildSubmitEditButton(id, true),
                          if (!selectDefault) _buildSubmitEditButton(id, false),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  // ปุ่ม X ที่มุมขวาบน
                  Positioned(
                    right: 15,
                    top: 15,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context); // ปิด Dialog
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Constants.secondaryColor),
                        child: Icon(
                          Icons.close,
                          size: 21,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _resetAddressForm() {
    // รีเซ็ตค่าของ TextController และ Dropdown fields
    _mainAddress.clear();
    setState(() {
      isDefault = false;
      selectedProvince = null;
      selectedMainDistrict = null;
      selectedSubDistrict = null;
    });
  }

  void _createAddress() {
    if (addressController.addressList.length >= 5) {
      Get.snackbar(
          'แจ้งเตือน', 'สามารถมี่ที่อยู่ในรายชื่อได้ไม่เกิน 5 สถานที่');
      return;
    }
    _resetAddressForm();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Text(
                              'เพิ่มที่อยู่ใหม่',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildTextFormField(
                              controller: _mainAddress,
                              label: 'ที่อยู่',
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'โปรดระบุที่อยู่'
                                      : null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildDropdownField(
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
                          ),
                          if (selectedProvince != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _buildDropdownField(
                                label: 'เลือกเขต / อำเภอ',
                                items: provinceController.provinces
                                        .firstWhere(
                                            (b) => b.name == selectedProvince)
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
                                validator: (value) => value == null
                                    ? 'โปรดเลือกเขต / อำเภอ'
                                    : null,
                              ),
                            ),
                          if (selectedMainDistrict != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _buildDropdownField(
                                label: 'เลือกตำบล',
                                items: provinceController.provinces
                                        .firstWhere(
                                            (b) => b.name == selectedProvince)
                                        .districts
                                        ?.firstWhere((c) =>
                                            c.name == selectedMainDistrict)
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
                            ),
                          if (!addressController.addressList.isEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isDefault = !isDefault;
                                      });
                                    },
                                    child: Checkbox(
                                      value: isDefault,
                                      onChanged: (value) {
                                        setState(() {
                                          isDefault = value!;
                                        });
                                      },
                                      activeColor: Constants.secondaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'ตั้งเป็นสถานที่อยู่หลัก',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 15),
                          _buildSubmitAddButton(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  // ปุ่ม X ที่มุมขวาบน
                  Positioned(
                    right: 15,
                    top: 15,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context); // ปิด Dialog
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Constants.secondaryColor),
                        child: Icon(
                          Icons.close,
                          size: 21,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // void _deleteAddress(String id) {
  //   // การทำงานเมื่อกดปุ่มลบ
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text(
  //         'ยืนยันการลบ',
  //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
  //       ),
  //       content: const Text("คุณต้องการลบที่อยู่นี้ใช่หรือไม่?"),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("ยกเลิก"),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             var result = await addressController.deleteAddress(id: id);
  //             if (mounted) {
  //               if (result) {
  //                 Get.snackbar('สำเร็จ', 'ที่อยู่ถูกลบออกไปแล้ว');
  //               } else {
  //                 Get.snackbar('ล้มเหลว', 'เกิดข้อผิดพลาดในการลบที่อยู่');
  //               }
  //             }
  //             Navigator.pop(context);
  //           },
  //           child: const Text("ยืนยัน"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _deleteAddress(String id) {
    // การทำงานเมื่อกดปุ่มลบ
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Text(
                              'ยืนยันการลบ',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                          ),
                          Text(
                            'คุณต้องการลบที่อยู่นี้ใช่หรือไม่?',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.normal),
                          ),
                          const SizedBox(height: 30),
                          _buildSubmitDeleteButton(id),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  // ปุ่ม X ที่มุมขวาบน
                  Positioned(
                    right: 15,
                    top: 15,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context); // ปิด Dialog
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Constants.secondaryColor),
                        child: Icon(
                          Icons.close,
                          size: 21,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    int maxLength = 75,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      style: TextStyle(fontSize: 14),
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField2<String>(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            contentPadding:
                EdgeInsets.only(left: 30, right: 12, top: 16, bottom: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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

  Widget _buildSubmitAddButton() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 150,
        child: ElevatedButton(
          onPressed: () async {
            int subDistrictId = 0;
            if (selectedSubDistrict != null) {
              subDistrictId = provinceController.provinces
                      .firstWhere((b) => b.name == selectedProvince)
                      .districts
                      ?.firstWhere((c) => c.name == selectedMainDistrict)
                      .subDistricts
                      ?.firstWhere((sc) => sc.name == selectedSubDistrict)
                      .id ??
                  0;
            }
            if (_formKey.currentState!.validate()) {
              var result = await addressController.addAddress(
                  subDistrictId: subDistrictId,
                  address: _mainAddress.text,
                  isDefault:
                      addressController.addressList.isEmpty ? true : isDefault);
              print('Result from addAddress: $result');
              if (mounted) {
                if (result) {
                  Get.snackbar('สำเร็จ', 'คุณได้เพิ่มที่อยู่ใหม่แล้ว');
                  Navigator.pop(context);
                } else {
                  Get.snackbar('ล้มเหลว', 'เกิดข้อผิดพลาดในการเพิ่มที่อยู่');
                }
              }
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Constants.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            'เพิ่มที่อยู่',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitEditButton(String id, bool selectDefault) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 150,
        child: ElevatedButton(
          onPressed: () async {
            int subDistrictId = 0;
            if (selectedSubDistrict != null) {
              subDistrictId = provinceController.provinces
                      .firstWhere((b) => b.name == selectedProvince)
                      .districts
                      ?.firstWhere((c) => c.name == selectedMainDistrict)
                      .subDistricts
                      ?.firstWhere((sc) => sc.name == selectedSubDistrict)
                      .id ??
                  0;
            }
            // if (subDistrictId == 0) {
            //   Get.snackbar('แจ้งเตือน', 'กรุณากรอกที่อยู่ให้ครบ');
            //   return;
            // }
            if (_formKey.currentState!.validate()) {
              var result = await addressController.editAddress(
                  id: id,
                  subDistrictId: subDistrictId,
                  address: _mainAddress.text,
                  isDefault:
                      addressController.addressList.isEmpty || selectDefault
                          ? true
                          : isDefault);
              print('Result from addAddress: $result');
              if (mounted) {
                if (result) {
                  Get.snackbar('สำเร็จ', 'คุณได้แก้ไขที่อยู่แล้ว');
                  Navigator.pop(context);
                } else {
                  Get.snackbar('ล้มเหลว', 'เกิดข้อผิดพลาดในการแก้ไขที่อยู่');
                }
              }
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Constants.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            'เพิ่มที่อยู่',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitDeleteButton(
    String id,
  ) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 100,
        child: ElevatedButton(
          onPressed: () async {
            var result = await addressController.deleteAddress(id: id);
            if (mounted) {
              if (result) {
                Get.snackbar('สำเร็จ', 'ที่อยู่ถูกลบออกไปแล้ว');
              } else {
                Get.snackbar('ล้มเหลว', 'เกิดข้อผิดพลาดในการลบที่อยู่');
              }
            }
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Constants.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(
            'ยื่นยัน',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
