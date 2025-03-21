import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controllers/card_details_get_controller.dart';

class CardDetailsPage extends StatefulWidget {
  final String cardId;

  const CardDetailsPage({super.key, required this.cardId});

  @override
  State<CardDetailsPage> createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  final GetOmiseCustomerCardDetailController cardDetailController = Get.put(GetOmiseCustomerCardDetailController());

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
        title: const Text("รายละเอียดบัตร"),
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
          child: Container(
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
                Text(
                  card.brand,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
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
                    fontSize: 20, // ลดขนาดลง
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
        );
      }),
    );
  }
}

