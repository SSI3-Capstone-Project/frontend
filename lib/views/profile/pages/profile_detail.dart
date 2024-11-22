import 'package:flutter/material.dart';
import 'package:mbea_ssi3_front/views/profile/pages/profile_page.dart';

class ProfileDetail extends StatefulWidget {
  const ProfileDetail({super.key});

  @override
  State<ProfileDetail> createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
            margin: EdgeInsets.symmetric(vertical: 20.0),
            color: Colors.white,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 25,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(children: [_buildProfileInfo()]),
              )
            ])));
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileHeader(),
        SizedBox(height: 25),
        _buildProfileDetails(),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/images/dimoo.png'),
        ),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "John Doe",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 7),
                GestureDetector(
                  onTap: () {
                    print("Profile Edit button pressed");
                  },
                  child: Icon(
                    Icons.edit,
                    size: 18,
                  ),
                ),
              ],
            ),
            Text(
              "Female",
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileDetailRow(Icons.person_2_outlined, "John Doe"),
        SizedBox(height: 10),
        _buildProfileDetailRow(Icons.phone_outlined, "083789603"),
        SizedBox(height: 10),
        _buildProfileDetailRow(Icons.email_outlined, "example@gmail.com"),
      ],
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
        ),
        SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
