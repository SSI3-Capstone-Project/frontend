import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  Widget buildSectionTitle(String emoji, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32, thickness: 1),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14.5,
          height: 1.6,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          'เงื่อนไขการใช้บริการ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          buildSectionTitle("📌", "1. ภาพรวมของบริการ"),
          buildParagraph(
              "แอปพลิเคชันนี้เป็นแพลตฟอร์มสำหรับให้ผู้ใช้งานสามารถแลกเปลี่ยนสินค้าประเภทกล่องสุ่ม (Blind Box) หรือสินค้าสะสมต่าง ๆ ได้อย่างปลอดภัย โดยมีระบบเสนอแลก (Offer) และโพสต์สินค้าของตนเอง (Post)"),
          buildSectionTitle("👤", "2. การเป็นสมาชิกและการใช้งาน"),
          buildParagraph(
              "• ผู้ใช้งานต้องสมัครสมาชิกและยืนยันตัวตนก่อนใช้งานระบบ"),
          buildParagraph(
              "• ข้อมูลส่วนตัว เช่น ชื่อ ที่อยู่ หมายเลขโทรศัพท์ ต้องเป็นความจริงและเป็นปัจจุบัน"),
          buildParagraph("• ห้ามใช้บัญชีปลอม หรือแอบอ้างบุคคลอื่น"),
          buildSectionTitle("🔁", "3. การแลกเปลี่ยนสินค้า"),
          buildParagraph("• ผู้ใช้งานสามารถสร้างโพสต์ และเสนอแลกได้ไม่จำกัด"),
          buildParagraph(
              "• สินค้าต้องเป็นของแท้ ถูกต้องตามกฎหมาย และอยู่ในสภาพที่ระบุไว้"),
          buildParagraph("• ต้องนัดพบหรือจัดส่งภายในเวลาที่ตกลง"),
          buildParagraph("• หากเกิดการฉ้อโกง แอปจะระงับบัญชีผู้กระทำผิดทันที"),
          buildSectionTitle("💸", "4. ราคาส่วนต่างสินค้า"),
          buildParagraph(
              "• ผู้ใช้งานสามารถตกลงร่วมกันได้ว่าใครจะเป็นผู้จ่ายส่วนต่าง (โพสต์ หรือ ข้อเสนอ)"),
          buildParagraph("• ค่าบริการแพลตฟอร์มคิดคงที่ 40 บาท/ครั้ง"),
          buildParagraph("• มี VAT ดังนี้:"),
          buildParagraph("   - หัก 3.65% จากยอดชำระ"),
          buildParagraph("   - หักเพิ่ม 7% จากยอด 3.65%"),
          buildParagraph("   - รวม VAT โดยประมาณ ≈ 4%"),
          buildSectionTitle("❌", "5. การยกเลิกและคืนเงิน"),
          buildParagraph("• ยกเลิกได้หากยังไม่ยืนยันนัดพบ"),
          buildParagraph("• หลังยืนยันแล้ว อาจไม่สามารถคืนค่าบริการได้"),
          buildParagraph("• สามารถแจ้งเจ้าหน้าที่ให้พิจารณากรณีเฉพาะ"),
          buildSectionTitle("📍", "6. การนัดพบและความปลอดภัย"),
          buildParagraph("• นัดพบในสถานที่สาธารณะที่ปลอดภัย"),
          buildParagraph("• ตรวจสอบสินค้าก่อนยืนยันการแลก"),
          buildParagraph("• แอปไม่รับผิดชอบต่ออุบัติเหตุหรือความเสียหายใด ๆ"),
          buildSectionTitle("⚠️", "7. ข้อจำกัดความรับผิดชอบ"),
          buildParagraph("• แอปเป็นเพียงตัวกลางในการแลกเปลี่ยนสินค้า"),
          buildParagraph("• ไม่รับผิดชอบต่อการฉ้อโกงหรือความเสียหายของสินค้า"),
          buildParagraph("• บัญชีผู้กระทำผิดอาจถูกแบนถาวร"),
          buildSectionTitle("🔄", "8. การเปลี่ยนแปลงเงื่อนไข"),
          buildParagraph("• เงื่อนไขอาจเปลี่ยนแปลงได้โดยไม่แจ้งล่วงหน้า"),
          buildParagraph("• ผู้ใช้งานควรตรวจสอบเงื่อนไขล่าสุดก่อนใช้งาน"),
          buildSectionTitle("📬", "9. การติดต่อ"),
          buildParagraph("• อีเมล: support@yourappname.com"),
          buildParagraph("• Line Official: @yourapp"),
          buildParagraph("• แบบฟอร์มแจ้งปัญหาในแอป"),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              "การใช้งานแอปถือว่าผู้ใช้งานยอมรับเงื่อนไขเหล่านี้โดยปริยาย",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
