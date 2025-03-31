import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../common/constants.dart';
import '../controllers/card_create_controller.dart';
import '../controllers/card_list_get_controller.dart';

class CardCreatePage extends StatefulWidget {
  const CardCreatePage({super.key});

  @override
  State<CardCreatePage> createState() => _CardCreatePageState();
}

class _CardCreatePageState extends State<CardCreatePage> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardNameController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final CardCreateController createCardController = Get.put(CardCreateController());
  final cardListController = Get.find<CardListController>();

  // FocusNodes ใช้จับเหตุการณ์เมื่อผู้ใช้กดออกจากฟิลด์
  final FocusNode cardNumberFocus = FocusNode();
  final FocusNode cardNameFocus = FocusNode();
  final FocusNode expiryDateFocus = FocusNode();
  final FocusNode cvvFocus = FocusNode();

  // เก็บ error message ของแต่ละช่อง
  String? cardNumberError;
  String? cardNameError;
  String? expiryDateError;
  String? cvvError;

  @override
  void initState() {
    super.initState();
    cardNumberFocus.addListener(() {
      if (!cardNumberFocus.hasFocus) validateCardNumber();
    });
    cardNameFocus.addListener(() {
      if (!cardNameFocus.hasFocus) validateCardName();
    });
    expiryDateFocus.addListener(() {
      if (!expiryDateFocus.hasFocus) validateExpiryDate();
    });
    cvvFocus.addListener(() {
      if (!cvvFocus.hasFocus) validateCvv();
    });
  }

  // ฟังก์ชันตรวจสอบ validation แต่ละฟิลด์
  void validateCardNumber() {
    setState(() {
      if (cardNumberController.text.isEmpty) {
        cardNumberError = "กรุณากรอกหมายเลขบัตร";
      } else if (cardNumberController.text.length < 19) {
        cardNumberError = "หมายเลขบัตรต้องมี 16 หลัก";
      } else {
        cardNumberError = null;
      }
    });
  }

  void validateCardName() {
    setState(() {
      if (cardNameController.text.isEmpty) {
        cardNameError = "กรุณากรอกชื่อบนบัตร";
      } else {
        cardNameError = null;
      }
    });
  }


  void validateExpiryDate() {
    setState(() {
      if (expiryDateController.text.isEmpty) {
        expiryDateError = "กรุณากรอกวันหมดอายุ";
      } else if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDateController.text)) {
        expiryDateError = "รูปแบบต้องเป็น MM/YY";
      } else {
        expiryDateError = null;
      }
    });
  }

  void validateCvv() {
    setState(() {
      if (cvvController.text.isEmpty) {
        cvvError = "กรุณากรอก CVV";
      } else if (cvvController.text.length < 3) {
        cvvError = "CVV ต้องมี 3 หลัก";
      } else {
        cvvError = null;
      }
    });
  }

  Future<bool> submitCard() async {
    validateCardNumber();
    validateCardName();
    validateExpiryDate();
    validateCvv();

    if (cardNumberError != null || expiryDateError != null || cvvError != null) {
      return false;
    }

    final expiryParts = expiryDateController.text.split('/');
    if (expiryParts.length != 2) {
      Get.snackbar("Error", "รูปแบบวันหมดอายุไม่ถูกต้อง");
      return false;
    }

    int status = await createCardController.createCardToken( // ✅ ใช้ instance ที่ถูกต้อง
      name: cardNameController.text,
      number: cardNumberController.text,
      expirationMonth: expiryParts[0],
      expirationYear: "20${expiryParts[1]}",
      city: "Bangkok",
      postalCode: "10200",
      securityCode: cvvController.text,
    );
    bool isSuccess = false;
    if(status == 200) {
      isSuccess = true;
    } else if (status == 400) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("ข้อมูลบัตรไม่ถูกต้อง"),
          content: Text("กรุณากรอกข้อมูลใหม่อีกครั้ง"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("ตกลง"),
            ),
          ],
        ),
      );
    }

    Get.snackbar("Error", "Failed to create token: ${status}");

    return isSuccess;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("เพิ่มวิธีการชำระเงิน"),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: cardNumberController,
              focusNode: cardNumberFocus,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // รับเฉพาะตัวเลข
                LengthLimitingTextInputFormatter(16), // รวมช่องว่างสูงสุดเป็น 19 ตัวอักษร (16+3 ช่องว่าง)
                CardNumberFormatter(), // ใช้ฟอร์แมตเตอร์ที่สร้างขึ้น
              ],
              decoration: InputDecoration(
                labelText: "หมายเลขบัตร",
                hintText: "XXXX XXXX XXXX XXXX",
                border: const OutlineInputBorder(),
                hintStyle: const TextStyle(fontSize: 14),
                errorText: cardNumberError,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: cardNameController,
              focusNode: cardNameFocus,
              decoration: InputDecoration(
                labelText: "ชื่อบนบัตร",
                hintText: "กรอกชื่อบนบัตร",
                border: const OutlineInputBorder(),
                hintStyle: const TextStyle(fontSize: 14),
                errorText: cardNameError,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: expiryDateController,
                    focusNode: expiryDateFocus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // รับเฉพาะตัวเลข
                      LengthLimitingTextInputFormatter(4), // จำกัดแค่ 4 ตัว (MMYY)
                      ExpiryDateFormatter(), // ฟอร์แมตให้เป็น MM/YY
                    ],
                    decoration: InputDecoration(
                      labelText: "วันหมดอายุ",
                      hintText: "MM/YY",
                      border: const OutlineInputBorder(),
                      hintStyle: const TextStyle(fontSize: 14),
                      errorText: expiryDateError,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    controller: cvvController,
                    focusNode: cvvFocus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // รับเฉพาะตัวเลข
                      LengthLimitingTextInputFormatter(3),
                    ],
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "CVV",
                      hintText: "XXX",
                      border: const OutlineInputBorder(),
                      hintStyle: const TextStyle(fontSize: 14),
                      errorText: cvvError,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  bool success = await submitCard();
                  if (success) {
                    await cardListController.fetchCustomerCards();
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "เพิ่มวิธีการชำระเงินนี้",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'\s+'), ''); // ลบช่องว่างทั้งหมดก่อนจัดรูปแบบ
    String formattedText = '';

    for (int i = 0; i < newText.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formattedText += ' '; // เพิ่มช่องว่างทุก 4 ตัว
      }
      formattedText += newText[i];
    }

    // คำนวณตำแหน่งเคอร์เซอร์ใหม่
    int cursorPosition = newValue.selection.baseOffset;
    int newCursorPosition = cursorPosition +
        (formattedText.length - newText.length); // ปรับตำแหน่งเคอร์เซอร์ให้เหมาะสม

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), ''); // เอาเฉพาะตัวเลข
    String formattedText = '';

    if (newText.length > 2) {
      formattedText = '${newText.substring(0, 2)}/${newText.substring(2)}';
    } else {
      formattedText = newText;
    }

    int cursorPosition = formattedText.length;

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}





