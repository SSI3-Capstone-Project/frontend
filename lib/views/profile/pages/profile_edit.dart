import 'package:flutter/material.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person,
              size: 25,
            ),
            const SizedBox(width: 10), // ระยะห่างระหว่างไอคอนกับข้อความ
            const Text(
              'แก้ไขโปรไฟล์',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          color: Colors.white,
          child: Column(
            children: [_buildEditProfileForm()],
          ),
        ),
      ),
    );
  }

  Widget _buildEditProfileForm() {
    return Column(
      children: [],
    );
  }
}
