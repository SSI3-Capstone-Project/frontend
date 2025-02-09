import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MeetUpPage extends StatefulWidget {
  final int currentStep;
  const MeetUpPage({super.key, required this.currentStep});

  @override
  State<MeetUpPage> createState() => _MeetUpPageState();
}

class _MeetUpPageState extends State<MeetUpPage> {
  int _currentStage = 2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60, // ลดความสูงให้พอดี
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(), // ดันให้ title อยู่กลางจริง ๆ
            Text(
              "นัดรับ",
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
            Spacer(), // ดันให้ icon ปฏิทินชิดขวา
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.assignment_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 16), // ระยะห่างก่อน Step Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: _buildStepIndicator(),
          ),
          // Expanded(
          //   child: Center(child: Text("เนื้อหาของหน้านัดรับ")),
          // ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        int stepNumber = index + 1;
        bool isActive = stepNumber == _currentStage;

        return Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 2,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentStage = stepNumber; // อัปเดตค่าเมื่อกด
                  });
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Colors.deepOrangeAccent
                        : Colors.grey.shade800,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$stepNumber",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
