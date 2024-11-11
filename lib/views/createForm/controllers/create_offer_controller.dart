import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/views/createForm/models/create_offer_model.dart';
import 'package:http_parser/http_parser.dart';

class OfferController extends GetxController {
  var isLoading = false.obs;

  Future<void> createOffer(Offer offer) async {
    isLoading.value = true;
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${dotenv.env['API_URL']}/offer'), // เปลี่ยน URL ตามจริง
    );

    // เพิ่มข้อมูลฟอร์มที่ไม่ใช่ไฟล์
    request.fields.addAll(
        offer.toJson().map((key, value) => MapEntry(key, value.toString())));

    // เพิ่มไฟล์สื่อ
    for (var file in offer.mediaFiles) {
      String mimeType = file.path.endsWith('.mp4')
          ? 'video/mp4'
          : 'image/png'; // กำหนด MIME type สำหรับไฟล์รูปภาพ

      request.files.add(
        await http.MultipartFile.fromPath(
          file.path.endsWith('.mp4') ? 'video_files' : 'image_files',
          file.path,
          contentType: MediaType.parse(mimeType), // กำหนดประเภท MIME
        ),
      );
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        // Handle success
        print('Offer created successfully: $responseData');
      } else {
        // อ่านและแสดงรายละเอียดข้อผิดพลาด
        var errorData = await response.stream.bytesToString();
        print(
            'Failed to create offer: ${response.statusCode}, Error: $errorData');
      }
    } catch (e) {
      // Handle exception
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
