import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../common/constants.dart';
import '../controllers/card_details_get_controller.dart';
import '../controllers/card_edit_controller.dart';
import '../controllers/card_list_get_controller.dart';

class EditCardDetailsPage extends StatefulWidget {
  final String cardId;

  const EditCardDetailsPage({super.key, required this.cardId});

  @override
  State<EditCardDetailsPage> createState() => _EditCardDetailsPageState();
}

class _EditCardDetailsPageState extends State<EditCardDetailsPage> {
  final GetOmiseCustomerCardDetailController cardDetailController = Get.put(GetOmiseCustomerCardDetailController());
  final EditCardDetailsController editCardDetailsController = Get.put(EditCardDetailsController());

  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardNameController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final ValueNotifier<String?> nameError = ValueNotifier<String?>(null);

  var isSaveButtonEnabled = false.obs;
  String originalCardName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchCardDetails();
    });
    cardNameController.addListener(_validateName);
  }

  void fetchCardDetails() async {
    await cardDetailController.getOmiseCustomerCardDetail(widget.cardId);
    final card = cardDetailController.cardDetail.value;

    if (card != null) {
      setState(() {
        cardNumberController.text = "**** **** **** ${card.last4}";
        cardNameController.text = card.cardHolderName;
        expiryDateController.text = "${card.expMonth.toString().padLeft(2, '0')}/${card.expYear.toString().substring(2)}";
        cvvController.text = "***";
        originalCardName = card.cardHolderName; // บันทึกค่าเดิมของชื่อบนบัตร
        _validateName(); // ตรวจสอบตอนโหลดข้อมูลเสร็จ
      });
    }
  }

  void _validateName() {
    final newName = cardNameController.text.trim();
    if (newName.isEmpty) {
      nameError.value = "กรุณากรอกชื่อบนบัตร";
      isSaveButtonEnabled.value = false;
    } else {
      nameError.value = null;
      isSaveButtonEnabled.value = newName != originalCardName;
    }
  }

  void saveCard() async {
    final newName = cardNameController.text.trim();

    if (newName.isEmpty) {
      Get.snackbar("❌ ผิดพลาด", "กรุณากรอกชื่อบนบัตร");
      return;
    }

    await editCardDetailsController.updateCard(widget.cardId, newName);

    await cardDetailController.getOmiseCustomerCardDetail(widget.cardId);
    originalCardName = newName;
    isSaveButtonEnabled.value = false;

    Navigator.pop(context);
  }

  Widget _buildNameTextField() {
    return ValueListenableBuilder<String?>(
      valueListenable: nameError,
      builder: (context, error, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("ชื่อบนบัตร", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: cardNameController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                errorText: error,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, bool isEditable = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: !isEditable,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: isEditable ? Colors.white : Colors.grey[200],
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: isEditable ? Colors.blue : Colors.grey.shade400),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("แก้ไขข้อมูลบัตร"),
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
        if (cardDetailController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cardDetailController.cardDetail.value == null) {
          return const Center(child: Text("ไม่พบข้อมูลบัตร"));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(label: "หมายเลขบัตร", controller: cardNumberController),
              const SizedBox(height: 16),
              _buildNameTextField(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(label: "วันหมดอายุ", controller: expiryDateController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(label: "CVV", controller: cvvController)),
                ],
              ),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSaveButtonEnabled.value ? Constants.primaryColor : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isSaveButtonEnabled.value ? saveCard : null,
                  child: const Text(
                    "บันทึกการแก้ไข",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              )),
            ],
          ),
        );
      }),
    );
  }
}