import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/controller/posts_controller.dart';
import 'package:mbea_ssi3_front/controller/offers_controller.dart';
import 'package:mbea_ssi3_front/views/favoritePosts/pages/favorite_posts.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/get_profile_controller.dart';
import 'package:mbea_ssi3_front/views/profile/models/profile_get_model.dart';
import 'package:mbea_ssi3_front/views/offer/pages/offer_detail.dart';
import 'package:mbea_ssi3_front/views/post/pages/post_detail.dart';
import 'package:mbea_ssi3_front/views/profile/pages/profile_detail.dart';
import 'package:mbea_ssi3_front/views/profile/pages/profile_edit.dart';
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/address/controllers/address_controller.dart';
// import 'package:mbea_ssi3_front/views/address/pages/address_page.dart';
// import 'package:mbea_ssi3_front/views/authen/pages/login_page.dart';
// import 'package:mbea_ssi3_front/views/profile/pages/offer_detail.dart';
// import 'package:mbea_ssi3_front/views/profile/pages/post_detail.dart';
// import 'package:mbea_ssi3_front/views/resetPassword/pages/change_password_page.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

import '../../../model/offers_model.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';

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
  final UserProfileController userProfileController =
      Get.put(UserProfileController());
  bool isActivePost = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (userProfileController.isLoading.value) {
            // แสดง CircularProgressIndicator หากกำลังโหลดข้อมูล
            return Center(child: CircularProgressIndicator());
          }
          final userProfile = userProfileController.userProfile.value;
          if (userProfile == null) {
            // กรณีข้อมูลเป็น null หรือไม่ได้รับข้อมูลจาก API
            return Center(child: Text("Failed to load user profile"));
          }
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            color: Colors.white,
            child: Column(
              children: [
                _buildProfileContainer(userProfile), // ส่งข้อมูล UserProfile ไป
                SizedBox(height: 20),
                _buildMenuBox(userProfile), // ส่งข้อมูล UserProfile ไป
                SizedBox(height: 20),
                _buildTabContainer(),
                SizedBox(height: 20),
                Expanded(
                  child: Obx(() {
                    if (isActivePost) {
                      if (postController.isLoading.value) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (postController.postList.isNotEmpty) {
                        return _buildStaggeredGrid(
                          postController.postList,
                          (post) => PostDetailPage(
                            postId: post.id,
                            username: userProfile.username,
                            userImageUrl: userProfile.imageUrl.toString(),
                          ),
                        );
                      } else {
                        return const Align(
                          alignment: Alignment.center,
                          child: Text('ยังไม่มีโพสต์'),
                        );
                      }
                    } else {
                      if (offerController.isLoading.value) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (offerController.offerList.isNotEmpty) {
                        return _buildOfferList(
                          offerController.offerList,
                          (offer) => OfferDetailPage(offerId: offer.id),
                        );
                      } else {
                        return const Align(
                          alignment: Alignment.center,
                          child: Text('ยังไม่มีข้อเสนอ'),
                        );
                      }
                    }
                  }),
                ),
              ],
            ),
          );
        }),
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

  Widget _buildOfferList(
      List<Offers> items, Widget Function(Offers) detailPageBuilder) {
    return RefreshIndicator(
      onRefresh: () async {
        await offerController.fetchOffers();
      },
      color: Colors.white,
      backgroundColor: Constants.secondaryColor,
      child: ListView.builder(
        shrinkWrap: true, // ให้ขนาดพอดีกับจำนวน item
        padding: const EdgeInsets.symmetric(horizontal: 5),
        physics:
            const AlwaysScrollableScrollPhysics(), // ทำให้เลื่อนและรีเฟรชได้
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => detailPageBuilder(item),
                ),
              );
            },
            child: _offerCard(item),
          );
        },
      ),
    );
  }

  Widget _offerCard(Offers item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0.5,
            blurRadius: 6,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.coverImage,
                    width: 82,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 10),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & SubCollection in the same row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(30)),
                              color: Constants.primaryColor,
                            ),
                            child: Text(
                              item.subCollectionName.length > 10
                                  ? '${item.subCollectionName.substring(0, 10)}...'
                                  : item.subCollectionName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        item.description.length > 45
                            ? '${item.description.substring(0, 35)}...'
                            : item.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
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
                          color: Constants.secondaryColor, // Background color
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
              item.description.length > 40
                  ? '${item.description.substring(0, 40)}...'
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
      // margin: EdgeInsets.symmetric(horizontal: 20.0),
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: isSelected ? Constants.secondaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContainer(UserProfile user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17, vertical: 13),
      decoration: BoxDecoration(
        color: Constants.primaryColor, // สีพื้นหลัง
        borderRadius: BorderRadius.circular(15), // ทำขอบมน
        boxShadow: const [
          BoxShadow(
            color: Colors.black26, // สีของเงา (ปรับได้)
            blurRadius: 10, // ระยะเบลอของเงา
            offset: Offset(0, 4), // การเลื่อนตำแหน่งของเงา (X, Y)
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 41,
                backgroundImage: user.imageUrl != null
                    ? NetworkImage(user.imageUrl!)
                    : AssetImage('assets/images/dimoo.png') as ImageProvider,
              ),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, // จัดแนวชิดซ้าย
                children: [
                  Text(
                    "Welcome,",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        user.username, // ชื่อ User
                        style: TextStyle(
                          color: Colors.white, // สีขาวอ่อน
                          fontSize: 21, // ขนาดตัวอักษรเล็กกว่า Welcome
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 7), // เว้นระยะห่างระหว่างชื่อและไอคอน
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfilePage(userProfile: user)),
                            );
                          },
                          child: Icon(
                            Icons.edit, // ไอคอนแก้ไข
                            color: Colors.white, // สีของไอคอน
                            size: 20,
                          )),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            width: 50,
            height: 50,
            child: IconButton(
              padding: EdgeInsets.zero, // ไม่ให้มี padding เกิน
              icon: const Icon(
                Icons.arrow_forward_ios, // ไอคอนจุดสามจุดแนวตั้ง
                size: 24,
                color: Colors.white, // ขนาดไอคอน (ตามมาตรฐานพอดีใน 30x30)
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileDetail(),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuBox(UserProfile user) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // แถวแรก
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBox(
                "คะแนน",
                Icons.star,
                user.rating != null && user.rating != 0
                    ? "${user.rating}/5"
                    : "ยังไม่มีคะแนนรีวิว",
                user.id),
            _buildBox("รายการโปรด", Icons.favorite, "", user.id),
          ],
        ),
      ],
    );
  }

  Widget _buildBox(
      String label, IconData icon, String description, String userId) {
    return GestureDetector(
        onTap: () {
          if (label == "รายการโปรด") {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritePosts(userId: userId),
                ));
          }
        },
        child: Container(
          width: 180,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: .5,
                blurRadius: 6,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20, // ไอคอนที่ต้องการ
                  ),
                  SizedBox(width: 8), // ระยะห่างระหว่างไอคอนและข้อความ
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              description.isNotEmpty
                  ? Text(
                      description,
                      style: TextStyle(fontSize: 14),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ));
  }
}
