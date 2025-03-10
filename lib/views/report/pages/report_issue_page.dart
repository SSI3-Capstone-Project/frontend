import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/report/controllers/report_controller.dart';

class ReportIssuePage extends StatefulWidget {
  final String exchangeId;

  const ReportIssuePage({super.key, required this.exchangeId});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final ReportController _reportController = Get.put(ReportController());

  int maxCharacters = 200;

  ReportType? _selectedReportType;

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    String? value,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField2<String>(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              fontSize: 14, // ปรับขนาดฟอนต์ของ labelText
              fontWeight: FontWeight.w500,
            ),
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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
          validator: validator ??
              (value) =>
                  value == null ? 'โปรดเลือก${label.toLowerCase()}' : null,
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate() && _selectedReportType != null) {
      final success = await _reportController.createExchangeReport(
        widget.exchangeId,
        _selectedReportType!,
        _reasonController.text,
      );

      if (success) {
        Get.snackbar('สำเร็จ', 'รายงานของคุณถูกส่งเรียบร้อยแล้ว');
        Navigator.of(context).pop();
      } else {
        Get.snackbar('ผิดพลาด', 'เกิดปัญหาระหว่างการส่งรายงาน');
      }
    }
  }

  void limitTextLength() {
    String text = _reasonController.text;
    if (text.runes.length > maxCharacters) {
      // ตัดข้อความให้ไม่เกิน 200 ตัวอักษร
      _reasonController.text =
          String.fromCharCodes(text.runes.take(maxCharacters));
      _reasonController.selection = TextSelection.fromPosition(
        TextPosition(offset: _reasonController.text.length),
      );
    }
    setState(() {}); // อัปเดตตัวนับ
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            size: 80,
                            Icons.error_outline,
                            color: Constants.secondaryColor,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Text(
                        'รายงานปัญหาการแลกเปลี่ยน',
                        style: TextStyle(
                            fontSize: 16,
                            color: Constants.secondaryColor,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Text(
                        'แอดมินจะทำการตรวจสอบและตอบกลับ',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'รายงานปัญหาผ่านทางอีเมลของท่าน เพื่อแก้ไขปัญหาที่เกิดขึ้น',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                    ],
                  )
                ],
              ),
              _buildDropdownField(
                label: 'ประเภทปัญหา',
                items:
                    ReportType.values.map((type) => type.displayName).toList(),
                value: _selectedReportType?.displayName,
                onChanged: (value) => setState(() => _selectedReportType =
                    ReportType.values
                        .firstWhere((type) => type.displayName == value)),
              ),
              // TextFormField(
              //   controller: _reasonController,
              //   maxLines: 3,
              //   decoration: const InputDecoration(
              //     labelText: 'รายละเอียดปัญหา',
              //     border: OutlineInputBorder(),
              //   ),
              //   validator: (value) => value == null || value.isEmpty
              //       ? 'โปรดระบุรายละเอียดปัญหา'
              //       : null,
              // ),
              TextField(
                controller: _reasonController,
                maxLines: 3,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: "รายละเอียดปัญหา...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Colors.grey.shade300), // กำหนดสี border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Colors.grey.shade300), // border เมื่อไม่ได้โฟกัส
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 2), // border เมื่อโฟกัส
                  ),
                  contentPadding: EdgeInsets.all(12),
                ),
                onChanged: (text) {
                  limitTextLength(); // ตรวจสอบและตัดข้อความ
                },
              ),
              SizedBox(height: 5),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${_reasonController.text.runes.length}/$maxCharacters",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: _submitReport,
              //   child: const Text('ส่งรายงาน'),
              // ),

              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 120), // ปรับแต่งตามต้องการ
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _submitReport,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "ส่งรายงาน",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
