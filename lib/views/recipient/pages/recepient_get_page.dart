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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("รายละเอียดบัญชีรับเงิน"),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        if (bankController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final bank = bankController.recipient.value;
        if (bank == null) {
          return const Center(child: Text("ยังไม่มีบัญชีรับเงิน"));
        }

        var bankAccountBrand = bank.bankAccount.brand;
        if (bankAccountBrand?.trim() == "Bangkok Bank") {
          bankAccountBrand = "ธนาคารกรุงเทพ จำกัด (มหาชน)";
        }


        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReadOnlyField("ธนาคาร", bankAccountBrand),
              const SizedBox(height: 16),
              _buildReadOnlyField("ชื่อบัญชี", bank.bankAccount.name),
              const SizedBox(height: 16),
              _buildReadOnlyField("เลขบัญชี 4 หลักท้าย", bank.bankAccount.lastDigits),
              const SizedBox(height: 16),
              _buildReadOnlyField("รหัสธนาคาร", bank.bankAccount.bankCode),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
