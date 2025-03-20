import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  Future<bool> submitCard() async {
    final expiryParts = expiryDateController.text.split('/');
    if (expiryParts.length != 2) {
      Get.snackbar("Error", "รูปแบบวันหมดอายุไม่ถูกต้อง");
      return false;
    }

    bool isSuccess = await createCardController.createCardToken( // ✅ ใช้ instance ที่ถูกต้อง
      name: cardNameController.text,
      number: cardNumberController.text,
      expirationMonth: expiryParts[0],
      expirationYear: "20${expiryParts[1]}",
      city: "Bangkok",
      postalCode: "10200",
      securityCode: cvvController.text,
    );

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
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "หมายเลขบัตร",
                hintText: "กรอกหมายเลขบัตรของคุณ",
                border: OutlineInputBorder(),
                hintStyle: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cardNameController,
              decoration: const InputDecoration(
                labelText: "ชื่อบนบัตร",
                hintText: "กรอกชื่อบนบัตร",
                border: OutlineInputBorder(),
                hintStyle: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: expiryDateController,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(
                      labelText: "วันหมดอายุ",
                      hintText: "MM/YY",
                      border: OutlineInputBorder(),
                      hintStyle: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: cvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "CVV",
                      hintText: "XXX",
                      border: OutlineInputBorder(),
                      hintStyle: TextStyle(fontSize: 14),
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

