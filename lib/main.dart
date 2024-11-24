import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mbea_ssi3_front/views/authen/pages/register_page.dart';
import 'package:mbea_ssi3_front/views/createForm/controllers/create_post_controller.dart';
import 'package:mbea_ssi3_front/views/onboardingScreen/onboarding_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/update_offer_controller.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/update_post_controller.dart';
import 'package:mbea_ssi3_front/views/mainScreen/pages/layout_page.dart';

void main() async {
  Get.lazyPut(() => CreatePostController());
  Get.lazyPut(
      () => UpdatePostController()); // เพิ่ม UpdatePostController ที่นี่
  Get.lazyPut(() => UpdateOfferController());
  await dotenv.load(fileName: "./.env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //       title: 'My Title',
  //       home: Scaffold(
  //         appBar: AppBar(
  //           title: const Text('Capstone Project'),
  //           backgroundColor: Colors.blue,
  //           centerTitle: true,
  //         ),
  //         body: const Item(), // เปลี่ยนจาก Item() เป็น MapPage()
  //       ));
  // }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My Title',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: RegisterPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
