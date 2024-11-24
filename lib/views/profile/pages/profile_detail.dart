import 'package:flutter/material.dart';
import 'package:mbea_ssi3_front/views/profile/pages/profile_edit.dart';
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
                        Icons.arrow_back_ios,
                        size: 25,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(children: [_buildProfileInfo()]),
              ),
              SizedBox(height: 40),
              _buildMenuTab()
            ])));
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileHeader(),
        SizedBox(height: 30),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileEditPage(),
                      ),
                    );
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
        Icon(icon, size: 22, color: Colors.grey[600]),
        SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(fontSize: 17, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildMenuTab() {
    // รายการเมนูตัวอย่าง
    List<IconData> iconList = [
      Icons.location_on,
      Icons.credit_card_outlined,
      Icons.history_outlined,
      Icons.report_problem,
      Icons.logout_outlined
    ];
    List<String> menuItems = [
      "ที่อยู๋ของคุณ",
      "ช่องทางชำระเงิน",
      "ประวัติการแลก",
      "รายงานปัญหา",
      "ออกจากระบบ"
    ];

    return Column(
      children: List.generate(menuItems.length, (index) {
        // สลับสีพื้นหลัง: ขาวและเทา
        Color backgroundColor =
            index % 2 == 0 ? Colors.grey[200]! : Colors.white;

        return InkWell(
          onTap: () {
            // กำหนดการทำงานเมื่อกดปุ่มแต่ละอัน
            print("คุณกด: ${menuItems[index]}");
          },
          child: Container(
            color: backgroundColor,
            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (index == 4) ...[
                      Icon(iconList[index], color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        menuItems[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ] else ...[
                      Icon(iconList[index]),
                      SizedBox(width: 10),
                      Text(
                        menuItems[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                if (index != 4)
                  Icon(Icons.arrow_forward_ios,
                      size: 16), // ลูกศรย้อนกลับเมื่อ index = 4
              ],
            ),
          ),
        );
      }),
    );
  }
}
