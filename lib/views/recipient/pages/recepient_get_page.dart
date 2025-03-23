import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/recipient_get_controller.dart';

class RecipientGetPage extends StatefulWidget {
  const RecipientGetPage({super.key});

  @override
  State<RecipientGetPage> createState() => _RecipientGetPageState();
}

class _RecipientGetPageState extends State<RecipientGetPage> {
  final RecipientController bankController = Get.put(RecipientController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('รายละเอียดบัญชีรับเงิน')),
      body: Obx(
            () {
          if (bankController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          final bank = bankController.recipient.value;
          if (bank == null) {
            return Center(child: Text('ยังไม่มีบัญชีรับเงิน'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bank: ${bank.bankAccount.brand}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Account Name: ${bank.bankAccount.name}'),
                SizedBox(height: 8),
                Text('Last Digits: ${bank.bankAccount.lastDigits}'),
                SizedBox(height: 8),
                Text('Bank Code: ${bank.bankAccount.bankCode}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
