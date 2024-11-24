import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/createForm/models/create_post_model.dart';
import 'package:http_parser/http_parser.dart';

class CreatePostController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var isLoading = false.obs;

  // จำเป็นต้องตั้ง accessToken ที่ได้รับจากการ login หรืออื่นๆ
  String? accessToken;

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    accessToken = tokenController.accessToken.value;
  }

  Future<void> createPost(Post post) async {
    isLoading.value = true;
    if (accessToken == null) {
      Get.snackbar('Error', 'No access token found.');
      return;
    }
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${dotenv.env['API_URL']}/post'), // เปลี่ยน URL ตามจริง
    );

    // แนบ accessToken ลงบน header ของ MultipartRequest
    request.headers['Authorization'] = 'Bearer $accessToken';

    // เพิ่มข้อมูลฟอร์มที่ไม่ใช่ไฟล์
    request.fields.addAll(
        post.toJson().map((key, value) => MapEntry(key, value.toString())));

    // เพิ่มไฟล์สื่อ
    for (var file in post.mediaFiles) {
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
        print('Post created successfully: $responseData');
      } else {
        // อ่านและแสดงรายละเอียดข้อผิดพลาด
        var errorData = await response.stream.bytesToString();
        print(
            'Failed to create post: ${response.statusCode}, Error: $errorData');
      }
    } catch (e) {
      // Handle exception
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
