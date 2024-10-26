import 'package:flutter/material.dart';
import 'package:mbea_ssi3_front/views/onboardingScreen/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
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
    return MaterialApp(
      title: 'My Title',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
