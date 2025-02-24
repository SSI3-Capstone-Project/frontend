import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/controller/post_detail_controller.dart';
import 'package:mbea_ssi3_front/controller/posts_controller.dart';
import 'package:mbea_ssi3_front/model/post_detail_model.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/home/pages/offer_detail_page.dart';
import 'package:mbea_ssi3_front/views/home/pages/offers_page.dart';
import 'package:mbea_ssi3_front/views/post/controllers/delete_post_controller.dart';
import 'package:mbea_ssi3_front/views/post/controllers/post_offer_controller.dart';
import 'package:mbea_ssi3_front/views/post/pages/post_edit.dart';
import 'package:mbea_ssi3_front/views/post/pages/post_offer_page.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'package:video_player/video_player.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;
  final String username;
  final String userImageUrl;
  const PostDetailPage(
      {super.key,
      required this.postId,
      required this.username,
      required this.userImageUrl});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final PostsController postController = Get.put(PostsController());
  final PostOfferController offerListController =
      Get.put(PostOfferController());
  final PostDetailController postDetailController =
      Get.put(PostDetailController());
  final PostDeleteController postDeleteController =
      Get.put(PostDeleteController());
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isActiveDetail = true;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    postDetailController.fetchPostDetail(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          'โพสต์',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (postDetailController.isLoading.value ||
              postDeleteController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          var postDetail = postDetailController.postDetail.value;
          if (postDetail != null) {
            return Stack(
              children: [
                ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start, // จัดชิดซ้าย
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 25),
                            mediaContent(postDetail),
                            const SizedBox(height: 25),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        postDetail.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        size: 22,
                                        Icons.location_on_outlined,
                                        color: Color(0xFF9E9E9E),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        postDetail.location,
                                        style: const TextStyle(
                                          color: Color(0xFF9E9E9E),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(30)),
                                      color: Constants.secondaryColor,
                                    ),
                                    child: Text(
                                      postDetail.subCollectionName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedIndex = 0;
                                          });
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'รายละเอียด',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: selectedIndex == 0
                                                    ? Constants.secondaryColor
                                                    : Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 4),
                                              height: 2,
                                              width: 190,
                                              color: selectedIndex == 0
                                                  ? Constants.secondaryColor
                                                  : Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          await offerListController
                                              .fetchOffers(postDetail.id);
                                          setState(() {
                                            selectedIndex = 1;
                                          });
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'ข้อเสนอของโพสต์นี้',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: selectedIndex == 1
                                                    ? Constants.secondaryColor
                                                    : Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 4),
                                              height: 2,
                                              width: 190,
                                              color: selectedIndex == 1
                                                  ? Constants.secondaryColor
                                                  : Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 25),
                                  if (selectedIndex == 0)
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'สนใจแลก :',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 3,
                                                      horizontal: 15),
                                              decoration: BoxDecoration(
                                                color: Constants.secondaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                postDetail.desiredItem,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 25),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              // ใช้ Expanded เพื่อให้ข้อความสามารถปรับขนาดตามพื้นที่ที่เหลือ
                                              child: Text(
                                                postDetail.description,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                                softWrap:
                                                    true, // อนุญาตให้ข้อความขึ้นบรรทัดใหม่
                                                overflow: TextOverflow
                                                    .visible, // แสดงข้อความทั้งหมด
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 25),
                                        if (postDetail.flaw != null)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                'ตำหนิ : ${postDetail.flaw}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      Constants.secondaryColor,
                                                ),
                                                softWrap:
                                                    true, // อนุญาตให้ข้อความขึ้นบรรทัดใหม่
                                                overflow: TextOverflow.visible,
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            // const SizedBox(height: 30),
                          ],
                        ),
                        if (selectedIndex == 1)
                          Obx(() {
                            if (offerListController.isLoading.value) {
                              // แสดง CircularProgressIndicator หากกำลังโหลดข้อมูล
                              return Center(child: CircularProgressIndicator());
                            }
                            if (!offerListController.offerList.isEmpty) {
                              // แสดง CircularProgressIndicator หากกำลังโหลดข้อมูล
                              return Column(
                                children: [
                                  buildOfferList(
                                      offerListController.offerList,
                                      postDetail.id,
                                      postDetail.title,
                                      widget.username,
                                      widget.userImageUrl),
                                  if (offerListController.offerList.length > 3)
                                    TextButton(
                                      onPressed: () {
                                        // เพิ่มโค้ดที่ต้องการทำงานเมื่อกดปุ่มที่นี่
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => OffersPage(
                                                    postId: postDetail.id,
                                                    postTitle: postDetail.title,
                                                    postImageURL:
                                                        postDetail.coverImage,
                                                    postLocation:
                                                        postDetail.location,
                                                    postSubCollectionName:
                                                        postDetail
                                                            .subCollectionName,
                                                    username: widget.username,
                                                    userImageURL:
                                                        widget.userImageUrl,
                                                  )),
                                        );
                                      },
                                      child: Text(
                                        "ดูข้อเสนอเพิ่มเติม", // ใส่ข้อความที่ต้องการแสดงบนปุ่ม
                                        style: TextStyle(
                                          fontSize: 14, // ขนาดตัวอักษร
                                          fontWeight: FontWeight
                                              .w500, // น้ำหนักตัวอักษร
                                          color: Colors.white, // สีของข้อความ
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Constants
                                            .primaryColor, // สีพื้นหลังของปุ่ม
                                        padding: const EdgeInsets.symmetric(
                                          horizontal:
                                              30, // ระยะห่างด้านซ้ายและขวา
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              20), // มุมปุ่มโค้งมน
                                        ),
                                      ),
                                    ),
                                  SizedBox(
                                    height: 100,
                                  ),
                                ],
                              );
                            } else {
                              return Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'ยังไม่มีข้อเสนอของคุณในโพสต์นี้',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey),
                                    )
                                  ],
                                ),
                              );
                            }
                          })
                      ],
                    ),
                  ],
                ),
              ],
            );
          } else {
            return Center(child: Text('No data available'));
          }
        }),
      ),
    );
  }

  Widget buildOfferList(List<dynamic> items, String postId, String postName,
      String username, String userImage) {
    final limitedItems = items.take(3).toList();
    return RefreshIndicator(
      onRefresh: () async {
        await offerListController.fetchOffers(postId);
      },
      color: Colors.white,
      backgroundColor: Constants.secondaryColor,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.57, // กำหนดความสูง
            child: StaggeredGridView.countBuilder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              crossAxisCount: 1,
              mainAxisSpacing: 5,
              crossAxisSpacing: 22,
              itemCount: limitedItems.length,
              itemBuilder: (context, index) {
                final item = limitedItems[index];
                return GestureDetector(
                  onTap: () async {
                    // await offerDetailController.fetchOfferDetail(
                    //     widget.postId, item.id);
                    // _offerDetailDialog();
                  },
                  child: offerCard(item, username, userImage, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OfferDetailPage(
                          postID: postId,
                          postName: postName,
                          offerID: item.id,
                          username: item.userName,
                          userImage: item.imageURL,
                        ),
                      ),
                    );
                  }),
                );
              },
              staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget offerCard(
      dynamic item, String username, String userImage, VoidCallback onTap) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap, // ฟังก์ชันที่เรียกเมื่อกด Card
          borderRadius: BorderRadius.circular(16), // ให้เอฟเฟกต์กดดูเรียบเนียน
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // สีของเงา
                  spreadRadius: 2, // การกระจายตัวของเงา
                  blurRadius: 4, // ความเบลอของเงา
                  offset: Offset(0, 0), // ทิศทางของเงา (x, y)
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundImage: NetworkImage(
                                item.imageURL), // ใส่ URL รูปภาพโปรไฟล์
                          ),
                          SizedBox(width: 10),
                          Text(
                            item.userName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
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
                            color: Colors.white, // Text color
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  // Content
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.coverImage, // ใส่ URL รูปภาพสินค้า
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
                            Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  size: 15,
                                  Icons.location_on_outlined,
                                  color: Color(0xFF9E9E9E),
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'บางรัก, สีลม',
                                  style: const TextStyle(
                                    color: Color(0xFF9E9E9E),
                                    fontSize: 12,
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
          ),
        ),
      ],
    );
  }

  // Widget _buildTabContainer() {
  //   return Container(
  //     // margin: EdgeInsets.symmetric(horizontal: 20.0),
  //     padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(15),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.3),
  //           spreadRadius: 2,
  //           blurRadius: 6,
  //           offset: Offset(0, 3),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: [
  //         Row(
  //           children: [
  //             GestureDetector(
  //               onTap: () async => {
  //                 await postController.fetchPosts(),
  //                 Navigator.pop(context),
  //               },
  //               child: const Icon(
  //                 Icons.arrow_back_ios,
  //                 size: 25,
  //               ),
  //             ),
  //             SizedBox(
  //               width: 20,
  //             ),
  //             _buildTabItem('รายละเอียด', isActiveDetail, () {
  //               setState(() {
  //                 isActiveDetail = true;
  //               });
  //             }),
  //           ],
  //         ),
  //         _buildTabItem('ข้อเสนอ', !isActiveDetail, () async {
  //           await offerController.fetchOffers(widget.postId);
  //           setState(() {
  //             isActiveDetail = false;
  //             // Navigator.push(
  //             //   context,
  //             //   MaterialPageRoute(
  //             //     builder: (context) => PostOfferPage(),
  //             //   ),
  //             // );
  //           });
  //         }),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildTabItem(String label, bool isSelected, VoidCallback onTap) {
  //   return InkWell(
  //     onTap: onTap,
  //     child: Container(
  //       padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
  //       decoration: BoxDecoration(
  //         color: isSelected ? Constants.secondaryColor : Colors.transparent,
  //         borderRadius: BorderRadius.circular(15.0),
  //       ),
  //       child: Text(
  //         label,
  //         style: TextStyle(
  //           color: isSelected ? Colors.white : Colors.black,
  //           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget mediaContent(PostDetail postDetail) {
    final mediaItems = [
      ...postDetail.postImages.map((img) => img.imageUrl),
      ...postDetail.postVideos.map((vid) => vid.videoUrl),
    ];

    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: SizedBox(
                width: 420,
                height: 300,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: mediaItems.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final mediaItem = mediaItems[index];
                    if (mediaItem.endsWith('.jpg') ||
                        mediaItem.endsWith('.png')) {
                      return Hero(
                        tag: mediaItem,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: ClipRRect(
                            child: Image.network(
                              mediaItem,
                              width: 320,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return VideoPlayerWidget(videoUrl: mediaItem);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(mediaItems.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 10.0,
                  width: _currentPage == index ? 20 : 8,
                  margin: const EdgeInsets.only(right: 5.0),
                  decoration: BoxDecoration(
                    color: Constants.secondaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),
          ],
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.3),
                ),
                child: IconButton(
                  onPressed: () async {
                    // Navigate to EditPostForm และรอผลลัพธ์
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditPostForm(postDetail: postDetail),
                      ),
                    );

                    // ตรวจสอบว่าโพสต์มีการอัปเดตหรือไม่
                    if (result == true) {
                      // ดึงข้อมูลใหม่
                      postDetailController.fetchPostDetail(widget.postId);
                    }
                    print('แก้ไข');
                  },
                  icon: Icon(Icons.edit, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.3),
                ),
                child: IconButton(
                  onPressed: () {
                    deletePost(widget.postId);
                    print('ลบ');
                  },
                  icon: Icon(Icons.delete, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void deletePost(String id) {
    // การทำงานเมื่อกดปุ่มลบ
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Form(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Text(
                              'ยืนยันการลบ',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                          ),
                          Text(
                            'คุณต้องการลบโพสต์นี้ใช่หรือไม่?',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.normal),
                          ),
                          const SizedBox(height: 30),
                          _buildSubmitDeleteButton(id),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  // ปุ่ม X ที่มุมขวาบน
                  Positioned(
                    right: 15,
                    top: 15,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context); // ปิด Dialog
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Constants.secondaryColor),
                        child: Icon(
                          Icons.close,
                          size: 21,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubmitDeleteButton(
    String id,
  ) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 100,
        child: ElevatedButton(
          onPressed: () async {
            // await postDeleteController.deletePost(widget.postId);
            // bool isReload = true;
            // Navigator.pop(context, isReload);
            var result = await postDeleteController.deletePost(id);
            if (mounted) {
              if (result) {
                Navigator.pop(context);
                Navigator.pop(context, true);
              }
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Constants.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(
            'ยื่นยัน',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  // Initialize the video player
  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {}); // Refresh UI after video initialization
      }).catchError((error) {
        setState(() {
          _isError = true; // Update UI to show error state
        });
        debugPrint("Error loading video: $error");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isError ? _buildErrorWidget() : _buildVideoPlayer();
  }

  // Widget displayed when there's an error loading the video
  Widget _buildErrorWidget() {
    return Center(
        child:
            Text("Unable to load video", style: TextStyle(color: Colors.red)));
  }

  // Widget for the video player
  Widget _buildVideoPlayer() {
    return _controller.value.isInitialized
        ? Container(
            color: Colors.black,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: _buildPlayPauseButton(),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 10,
                  right: 10,
                  child: _buildProgressIndicator(),
                ),
              ],
            ),
          )
        : Center(child: CircularProgressIndicator());
  }

  // Play/Pause button
  Widget _buildPlayPauseButton() {
    return IconButton(
      iconSize: 50,
      color: Colors.white,
      icon: Icon(
        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
      ),
      onPressed: () {
        setState(() {
          _controller.value.isPlaying
              ? _controller.pause()
              : _controller.play();
        });
      },
    );
  }

  // Progress indicator for the video
  Widget _buildProgressIndicator() {
    return VideoProgressIndicator(
      _controller,
      allowScrubbing: true,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      colors: VideoProgressColors(
        playedColor: Colors.white,
        bufferedColor: Colors.grey,
        backgroundColor: Colors.grey,
      ),
    );
  }
}
