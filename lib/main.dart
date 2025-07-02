import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/authen/controllers/login_controller.dart';
import 'package:mbea_ssi3_front/views/authen/pages/login_page.dart';
// import 'package:mbea_ssi3_front/views/authen/pages/register_page.dart';
import 'package:mbea_ssi3_front/views/createForm/controllers/create_post_controller.dart';
// import 'package:mbea_ssi3_front/views/onboardingScreen/onboarding_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mbea_ssi3_front/views/mainScreen/pages/layout_page.dart';
import 'package:mbea_ssi3_front/views/offer/controllers/update_offer_controller.dart';
import 'package:mbea_ssi3_front/views/post/controllers/update_post_controller.dart';

import 'common/constants.dart';
// import 'package:mbea_ssi3_front/views/mainScreen/pages/layout_page.dart';

// void main() async {
//   Get.lazyPut(() => TokenController());
//   // await tokenController.loadTokens(); // โหลด token ก่อนเริ่มแอป
//   Get.lazyPut(() => CreatePostController());
//   Get.lazyPut(
//       () => UpdatePostController()); // เพิ่ม UpdatePostController ที่นี่
//   Get.lazyPut(() => UpdateOfferController());
//   await dotenv.load(fileName: "./.env");
//   runApp(MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ เรียกก่อนโหลด async function
  await dotenv.load(fileName: "./.env");

  // ✅ สร้าง TokenController และโหลด Token ก่อนเริ่มแอป
  final TokenController tokenController = Get.put(TokenController());
  // await tokenController.loadTokens();

  Get.put(LoginController());

  // ✅ ใช้ Get.lazyPut() สำหรับ Controller อื่น ๆ หลังจาก runApp()
  Get.lazyPut(() => CreatePostController());
  Get.lazyPut(() => UpdatePostController());
  Get.lazyPut(() => UpdateOfferController());

  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My Title',
      theme: ThemeData(
          fontFamily: 'Sarabun',
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Constants.primaryColor, width: 2),
             ),
        ),),
      home: Obx(() {
        final tokenController = Get.find<TokenController>();
        return tokenController.accessToken.value != null
            ? RootPage() // ถ้ามี token
            : LoginPage(); // ถ้าไม่มี token
      }), // ถ้าไม่มี token
      debugShowCheckedModeBanner: false,
    );
  }
}
