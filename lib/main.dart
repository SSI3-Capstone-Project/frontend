import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/authen/pages/login_page.dart';
// import 'package:mbea_ssi3_front/views/authen/pages/register_page.dart';
import 'package:mbea_ssi3_front/views/createForm/controllers/create_post_controller.dart';
// import 'package:mbea_ssi3_front/views/onboardingScreen/onboarding_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mbea_ssi3_front/views/mainScreen/pages/layout_page.dart';
import 'package:mbea_ssi3_front/views/offer/controllers/update_offer_controller.dart';
import 'package:mbea_ssi3_front/views/post/controllers/update_post_controller.dart';
// import 'package:mbea_ssi3_front/views/mainScreen/pages/layout_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // สำหรับตั้งค่าก่อน runApp
  await dotenv.load(fileName: "./.env");

  // Lazy initialization ของ Controller
  Get.lazyPut(() => TokenController());
  Get.lazyPut(() => CreatePostController());
  Get.lazyPut(() => UpdatePostController());
  Get.lazyPut(() => UpdateOfferController());

  runApp(MyApp());
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
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // เส้นทางเริ่มต้น
      getPages: [
        GetPage(
          name: '/',
          page: () => Obx(() {
            final tokenController = Get.find<TokenController>();
            return tokenController.accessToken.value == null
                ? LoginPage()
                : RootPage();
          }),
        ),
        GetPage(
          name: '/login',
          page: () => LoginPage(),
        ),
        GetPage(
          name: '/main',
          page: () => RootPage(),
        ),
      ],
    );
  }
}
