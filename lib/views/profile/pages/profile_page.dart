import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/controller/posts_controller.dart';
import 'package:mbea_ssi3_front/controller/offers_controller.dart';
import 'package:mbea_ssi3_front/views/profile/pages/offer_detail.dart';
import 'package:mbea_ssi3_front/views/profile/pages/post_detail.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
            _buildProfileContainer(),
            SizedBox(height: 20),
            _buildMenuBox(),
            SizedBox(height: 20),
            _buildTabContainer(),
            SizedBox(height: 20),
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => detailPageBuilder(item),
                ),
              );
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
      // margin: EdgeInsets.symmetric(horizontal: 20.0),
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

  Widget _buildProfileContainer() {
    return GestureDetector(
        onTap: () {
          // เพิ่มการทำงานเมื่อกดปุ่ม เช่น นำทางไปยังหน้า Profile
          print("Profile button tapped!");
        },
        child: Container(
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 41,
                backgroundImage: AssetImage('assets/images/dimoo.png'),
              ),
              SizedBox(width: 10),
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
                        "John Doe", // ชื่อ User
                        style: TextStyle(
                          color: Colors.white, // สีขาวอ่อน
                          fontSize: 21, // ขนาดตัวอักษรเล็กกว่า Welcome
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 7), // เว้นระยะห่างระหว่างชื่อและไอคอน
                      GestureDetector(
                          onTap: () {
                            // กำหนดฟังก์ชันที่จะทำงานเมื่อกดปุ่ม
                            print("Profile Edit button pressed");
                          },
                          child: Icon(
                            Icons.edit, // ไอคอนแก้ไข
                            color: Colors.white, // สีของไอคอน
                            size: 18,
                          )),
                    ],
                  ),
                ],
              ),
              Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "42", // ตัวเลขที่ต้องการ
                    style: TextStyle(
                      color: Colors.white, // สีของตัวเลข
                      fontSize: 17, // ขนาดตัวอักษร
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "trades", // ตัวเลขที่ต้องการ
                    style: TextStyle(
                        color: Colors.white, // สีของตัวเลข
                        fontSize: 15,
                        fontWeight: FontWeight.w500 // ขนาดตัวอักษร
                        ),
                  )
                ],
              )
            ],
          ),
        ));
  }

  Widget _buildMenuBox() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // แถวแรก
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBox("Box 1", Icons.location_on, Colors.blue),
            _buildBox("Box 2", Icons.favorite, Colors.green),
          ],
        ),
        SizedBox(height: 10), // เว้นระยะห่างระหว่างแถว
        // แถวที่สอง
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBox("Box 3", Icons.star, Colors.red),
            _buildBox("Box 4", Icons.post_add, Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildBox(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        print("$label tapped!");
      },
      child: Container(
        width: 182,
        height: 70,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, // ไอคอนที่ต้องการ
              color: Colors.white, // สีของไอคอน
              size: 24, // ขนาดไอคอน
            ),
            SizedBox(width: 8), // ระยะห่างระหว่างไอคอนและข้อความ
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
