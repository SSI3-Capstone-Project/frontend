import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../controllers/card_delete_controller.dart';
import '../controllers/card_details_get_controller.dart';
import '../controllers/card_list_get_controller.dart';
import 'card_edit_page.dart';

class CardDetailsPage extends StatefulWidget {
  final String cardId;

  const CardDetailsPage({super.key, required this.cardId});

  @override
  State<CardDetailsPage> createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  final GetOmiseCustomerCardDetailController cardDetailController =
      Get.put(GetOmiseCustomerCardDetailController());
  final cardListController = Get.find<CardListController>();

  @override
  void initState() {
    super.initState();
    cardDetailController.getOmiseCustomerCardDetail(widget.cardId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "รายละเอียดบัตร",
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
        final card = cardDetailController.cardDetail.value;
        if (cardDetailController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (card == null) {
          return const Center(child: Text("ไม่พบข้อมูลบัตร"));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 220,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      spreadRadius: 1,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBrandIcon(card.brand),
                    const SizedBox(height: 8),
                    Text(
                      card.cardHolderName,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "**** **** **** ${card.last4}",
                      style: const TextStyle(
                        fontSize: 20,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "EXPIRY DATE",
                              style: TextStyle(fontSize: 10),
                            ),
                            Text(
                              "${card.expMonth.toString().padLeft(2, '0')}/${card.expYear.toString().substring(2)}",
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.credit_card,
                          size: 36,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
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
                          showDeleteConfirmationDialog(context, card.cardId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // ปรับขอบมน
                          ),
                        ),
                        child: const Text(
                          "ลบ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditCardDetailsPage(cardId: card.cardId),
                            ),
                          );
                          print("แก้ไขบัตร ${card.cardHolderName}");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // ปรับขอบมน
                          ),
                        ),
                        child: const Text(
                          "แก้ไข",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  void showDeleteConfirmationDialog(BuildContext context, String cardId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // กรอบมนน้อยลง
          ),
          backgroundColor: Colors.white,
          title: const Text("ยืนยันการลบ"),
          content: const Text("คุณแน่ใจหรือไม่ว่าต้องการลบบัตรนี้?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด popup
              },
              child: Text(
                "ยกเลิก",
                style: TextStyle(color: Colors.indigo),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // ปุ่มขอบมนเล็กน้อย
                ),
              ),
              onPressed: () async {
                final deleteCardController = Get.put(DeleteCardController());
                await deleteCardController.deleteCard(cardId);
                await cardListController.fetchCustomerCards();
                Navigator.of(context).pop(); // ปิด popup
                Navigator.of(context).pop(); // กลับไปหน้าก่อนหน้า
              },
              child: const Text(
                "ยืนยัน",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBrandIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return SvgPicture.asset('assets/icons/visa.svg', width: 50, height: 50);
      case 'mastercard':
        return SvgPicture.asset('assets/icons/mastercard.svg', width: 50, height: 50);
      case 'amex':
        return SvgPicture.asset('assets/icons/amex.svg', width: 50, height: 50);
      default:
        return const Icon(Icons.credit_card, size: 40, color: Colors.grey);
    }
  }

}
