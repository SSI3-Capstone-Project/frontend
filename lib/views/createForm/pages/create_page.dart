import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/createForm/pages/create_post.dart';
import 'package:mbea_ssi3_front/views/createForm/pages/create_offer.dart'; // Import CreateOfferForm

class CreatePostOffer extends StatefulWidget {
  const CreatePostOffer({super.key});

  @override
  State<CreatePostOffer> createState() => _CreatePostOfferState();
}

class _CreatePostOfferState extends State<CreatePostOffer> {
  List<File> mediaFiles = [];
  bool isCreatingPost = true; // Track selected tab

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mediaFiles.length < 5) {
      setState(() {
        List<File> videos =
            mediaFiles.where((file) => file.path.endsWith('.mp4')).toList();
        mediaFiles =
            mediaFiles.where((file) => !file.path.endsWith('.mp4')).toList();
        mediaFiles.add(File(pickedFile.path));
        mediaFiles.addAll(videos);
      });
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null && mediaFiles.length < 5) {
      setState(() {
        List<File> videos =
            mediaFiles.where((file) => file.path.endsWith('.mp4')).toList();
        mediaFiles =
            mediaFiles.where((file) => !file.path.endsWith('.mp4')).toList();
        mediaFiles.add(File(pickedFile.path));
        mediaFiles.addAll(videos);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 80),
          _buildTabContainer(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: isCreatingPost
                  ? CreatePostForm()
                  : CreateOfferForm(), // Switch to CreateOfferForm
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContainer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem('สร้างโพสต์', isCreatingPost, () {
            setState(() {
              isCreatingPost = true;
            });
          }),
          _buildTabItem('สร้างข้อเสนอ', !isCreatingPost, () {
            setState(() {
              isCreatingPost = false;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Constants.secondaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
