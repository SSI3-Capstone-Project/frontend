import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/address/controllers/address_controller.dart';
import 'package:mbea_ssi3_front/views/address/pages/address_page.dart';
import 'package:mbea_ssi3_front/views/authen/pages/login_page.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/get_profile_controller.dart';
import 'package:mbea_ssi3_front/views/profile/models/profile_get_model.dart';
import 'package:mbea_ssi3_front/views/profile/pages/account_delete.dart';
import 'package:mbea_ssi3_front/views/profile/pages/profile_edit.dart';
import 'package:mbea_ssi3_front/views/profile/pages/profile_page.dart';
import 'package:mbea_ssi3_front/views/resetPassword/pages/change_password_page.dart';

class ProfileDetail extends StatefulWidget {
  const ProfileDetail({super.key});

  @override
  State<ProfileDetail> createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetail> {
  final TokenController tokenController = Get.put(TokenController());
  final AddressController addressController = Get.put(AddressController());
  final UserProfileController userProfileController =
      Get.put(UserProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          // ตรวจสอบว่า isLoading เป็น true หรือไม่
          if (userProfileController.isLoading.value) {
            // หากกำลังโหลดข้อมูลให้แสดง CircularProgressIndicator
            return Center(child: CircularProgressIndicator());
          }

          // ดึงข้อมูล userProfile
          final userProfile = userProfileController.userProfile.value;

          // หากไม่มีข้อมูล userProfile ให้แสดงข้อความ error
          if (userProfile == null) {
            return Center(child: Text("Failed to load user profile"));
          }

          // หากได้ข้อมูล userProfile มาแล้ว
          return Container(
            // margin: EdgeInsets.symmetric(vertical: 10.0),
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
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
                  child: Column(
                    children: [
                      _buildProfileInfo(userProfile), // ส่ง userProfile ไป
                    ],
                  ),
                ),
                SizedBox(height: 40),
                _buildMenuTab()
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProfileInfo(UserProfile user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileHeader(user),
        SizedBox(height: 30),
        _buildProfileDetails(user),
      ],
    );
  }

  Widget _buildProfileHeader(UserProfile user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: user.imageUrl != null
              ? NetworkImage(user.imageUrl!)
              : AssetImage('assets/images/dimoo.png'),
        ),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  user.username,
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
                        builder: (context) =>
                            EditProfilePage(userProfile: user),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.edit,
                    size: 20,
                  ),
                ),
              ],
            ),
            Text(
              user.gender,
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileDetails(UserProfile user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileDetailRow(
            Icons.person_2_outlined, "${user.firstname} ${user.lastname}"),
        SizedBox(height: 10),
        _buildProfileDetailRow(Icons.phone_outlined, user.phone),
        SizedBox(height: 10),
        _buildProfileDetailRow(Icons.email_outlined, user.email),
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
          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
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
      Icons.lock_outline,
      Icons.delete_outline,
      Icons.logout_outlined
    ];
    List<String> menuItems = [
      "ที่อยู่ของคุณ",
      "ช่องทางชำระเงิน",
      "ประวัติการแลก",
      "รายงานปัญหา",
      "เปลี่ยนรหัสผ่าน",
      "ลบบัญชี",
      "ออกจากระบบ"
    ];

    return Column(
      children: List.generate(menuItems.length, (index) {
        // สลับสีพื้นหลัง: ขาวและเทา
        Color backgroundColor =
            index % 2 == 0 ? Colors.grey[200]! : Colors.white;

        return InkWell(
          onTap: () async {
            switch (menuItems[index]) {
              case "ที่อยู่ของคุณ":
                await addressController.fetchAddresses();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddressPage()),
                );
                break;
              case "ช่องทางชำระเงิน":
                break;
              case "ประวัติการแลก":
                break;
              case "รายงานปัญหา":
                break;
              case "เปลี่ยนรหัสผ่าน":
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
                break;
              case "ลบบัญชี":
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteAccount()),
                );
                break;
              case "ออกจากระบบ":
                Get.snackbar('ออกจากระบบ', 'คุณได้ออกจากระบบแล้ว');
                await tokenController.deleteTokens();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
                break;
              // default:
            }
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
                    if (menuItems[index] == "ออกจากระบบ") ...[
                      Icon(iconList[index], color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        menuItems[index],
                        style: TextStyle(
                          fontSize: 15,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                if (menuItems[index] != "ออกจากระบบ")
                  Icon(Icons.arrow_forward_ios,
                      size: 16), // ลูกศรย้อนกลับเมื่อ index != 4
              ],
            ),
          ),
        );
      }),
    );
  }
}
