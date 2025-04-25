import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../common/constants.dart';
import '../controllers/card_list_get_controller.dart';
import 'card_create_page.dart';
import 'card_details_page.dart';

class CardListPage extends StatefulWidget {
  const CardListPage({super.key});

  @override
  State<CardListPage> createState() => _CardListPageState();
}

class _CardListPageState extends State<CardListPage> {
  final CardListController cardListController = Get.put(CardListController());

  @override
  void initState() {
    super.initState();
    cardListController.fetchCustomerCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "วิธีการชำระเงินของฉัน",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
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
        if (cardListController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: cardListController.cards.isEmpty
                  ? const Center(
                      child: Text(
                          "ยังไม่มีช่องทางการชำระเงิน กรุณาเพิ่มช่องทางการชำระเงิน"))
                  : Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: _buildCardList(),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: cardListController.cards.length < 5
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CardCreatePage(),
                            ),
                          );
                        }
                      : null,
                  child: const Text(
                    "เพิ่มวิธีการชำระเงิน",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCardList() {
    return ListView.builder(
      itemCount: cardListController.cards.length,
      itemBuilder: (context, index) {
        final card = cardListController.cards[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                spreadRadius: 1,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            title: Text(
              "${card.brand} **** ${card.last4}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardDetailsPage(cardId: card.cardId),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
