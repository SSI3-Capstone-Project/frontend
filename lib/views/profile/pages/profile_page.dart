import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/controller/posts_controller.dart';
import 'package:mbea_ssi3_front/controller/offers_controller.dart';
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/address/controllers/address_controller.dart';
import 'package:mbea_ssi3_front/views/address/pages/address_page.dart';
import 'package:mbea_ssi3_front/views/authen/pages/login_page.dart';
import 'package:mbea_ssi3_front/views/profile/pages/offer_detail.dart';
import 'package:mbea_ssi3_front/views/profile/pages/post_detail.dart';
import 'package:mbea_ssi3_front/views/resetPassword/pages/change_password_page.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AddressController addressController = Get.put(AddressController());
  final TokenController tokenController = Get.put(TokenController());
  final PostsController postController = Get.put(PostsController());
  final OffersController offerController = Get.put(OffersController());
  bool isActivePost = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildTabContainer(),
                ),
                _buildMoreActionsDropdown(), // แทน GestureDetector ด้วย Dropdown
                const SizedBox(width: 15),
              ],
            ),
            SizedBox(height: 30),
            Expanded(child: Obx(() {
              if (isActivePost) {
                if (postController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                return _buildStaggeredGrid(
                  postController.postList,
                  (post) => PostDetailPage(postId: post.id),
                );
              } else {
                if (offerController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                return _buildStaggeredGrid(
                  offerController.offerList,
                  (offer) => OfferDetailPage(
                      offerId: offer.id), // Assuming an OfferDetailPage exists
                );
              }
            })),
          ],
        ),
      ),
    );
  }

  Widget _buildStaggeredGrid(
      List<dynamic> items, Widget Function(dynamic) detailPageBuilder) {
    return RefreshIndicator(
      onRefresh: () async {
        if (isActivePost) {
          await postController.fetchPosts();
        } else {
          await offerController.fetchOffers();
        }
      },
      color: Colors.white,
      backgroundColor: Constants.secondaryColor,
      child: StaggeredGridView.countBuilder(
        padding: const EdgeInsets.all(5),
        crossAxisCount: 4,
        mainAxisSpacing: 22,
        crossAxisSpacing: 22,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => detailPageBuilder(item),
                ),
              );

              if (result == true) {
                // ดึงข้อมูลใหม่
                await postController.fetchPosts();
                await offerController.fetchOffers();
              }
            },
            child: _buildGridItem(item),
          );
        },
        staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
      ),
    );
  }

  Widget _buildGridItem(dynamic item) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: .5,
            blurRadius: 6,
            offset: const Offset(0, 0),
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 20,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: const BorderRadius.all(
                        Radius.elliptical(100, 25),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.network(
                    item.coverImage,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue, // Background color
                          borderRadius:
                              BorderRadius.circular(8), // Border radius
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4), // Padding
                        child: Text(
                          item.subCollectionName.length > 10
                              ? '${item.subCollectionName.substring(0, 10)}...'
                              : item.subCollectionName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Text color
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              item.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              item.description.length > 100
                  ? '${item.description.substring(0, 45)}...'
                  : item.description,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
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
          _buildTabItem('โพสต์', isActivePost, () {
            setState(() {
              postController.fetchPosts();
              isActivePost = true;
            });
          }),
          _buildTabItem('ข้อเสนอ', !isActivePost, () {
            setState(() {
              isActivePost = false;
              offerController.fetchOffers();
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
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
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

  bool isDropdownOpen = false;

  Widget _buildMoreActionsDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: Icon(Icons.more_vert, color: Colors.black54),
        items: const [
          DropdownMenuItem(
            value: 'change_password',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_open,
                  color: Colors.black54,
                ),
                SizedBox(
                  width: 20,
                ),
                Text('เปลี่ยนรหัส', style: TextStyle(fontSize: 14))
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'manage_address',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.black54,
                ),
                SizedBox(
                  width: 20,
                ),
                Text('จัดการที่อยู่', style: TextStyle(fontSize: 14))
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'logout',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.black54,
                ),
                SizedBox(
                  width: 20,
                ),
                Text('ออกจากระบบ', style: TextStyle(fontSize: 14))
              ],
            ),
          ),
        ],
        onChanged: (value) {
          if (isDropdownOpen) return; // ไม่ทำงานซ้ำหากเมนูเปิดอยู่
          isDropdownOpen = true; // ตั้งสถานะเมื่อเปิดเมนู

          if (value == 'manage_address') {
            _navigateToManageAddress();
          } else if (value == 'change_password') {
            _navigateToChangePassword();
          } else if (value == 'logout') {
            _logout();
          }

          isDropdownOpen = false; // รีเซ็ตสถานะหลังทำงานเสร็จ
        },
        dropdownStyleData: DropdownStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
          ),
          offset: const Offset(-125, -30),
          width: 160,
        ),
      ),
    );
  }

  Future<void> _navigateToManageAddress() async {
    await addressController.fetchAddresses();
    // ไปยังหน้าจัดการที่อยู่
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddressPage()),
    );
  }

  Future<void> _navigateToChangePassword() async {
    // ไปยังหน้าจัดการที่อยู่
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChangePasswordPage()),
    );
  }

  Future<void> _logout() async {
    // ทำงาน Logout
    Get.snackbar('ออกจากระบบ', 'คุณได้ออกจากระบบแล้ว');
    await tokenController.deleteTokens();

    // ไปยังหน้า Login หรืออื่นๆ
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }
}
