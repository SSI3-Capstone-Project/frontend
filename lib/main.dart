import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/authen/pages/login_page.dart'; // Import TokenController
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mbea_ssi3_front/views/createForm/controllers/create_post_controller.dart';
import 'package:mbea_ssi3_front/views/mainScreen/pages/layout_page.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/update_offer_controller.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/update_post_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "./.env");

  // ลงทะเบียน TokenController และโหลด token
  final tokenController = Get.put(TokenController());
  await tokenController.loadTokens(); // โหลด token ก่อนเริ่มแอป

  // ลงทะเบียน controller อื่น ๆ
  Get.lazyPut(() => CreatePostController());
  Get.lazyPut(() => UpdatePostController());
  Get.lazyPut(() => UpdateOfferController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My Title',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Obx(() {
        final tokenController = Get.find<TokenController>();
        return tokenController.accessToken.value != null
            ? const RootPage() // ถ้ามี token
            : LoginPage(); // ถ้าไม่มี token
      }),
      debugShowCheckedModeBanner: false,
    );
  }
}
