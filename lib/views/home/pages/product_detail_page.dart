import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/controller/offers_controller.dart';
import 'package:mbea_ssi3_front/controller/post_detail_controller.dart';
import 'package:mbea_ssi3_front/views/createForm/pages/create_offer.dart';
import 'package:mbea_ssi3_front/views/favoritePosts/controllers/create_wishList_controller.dart';
import 'package:mbea_ssi3_front/views/favoritePosts/controllers/delete_wishList_controller.dart';
import 'package:mbea_ssi3_front/views/home/controllers/product_detail_controller.dart';
import 'package:mbea_ssi3_front/views/home/models/product_detail_model.dart';
import 'package:mbea_ssi3_front/views/home/pages/choose_offer_page.dart';
import 'package:mbea_ssi3_front/views/home/pages/offer_detail_page.dart';
import 'package:mbea_ssi3_front/views/home/pages/offers_page.dart';
import 'package:mbea_ssi3_front/views/post/controllers/post_offer_controller.dart';
import 'package:mbea_ssi3_front/views/post/pages/post_offer_page.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/get_profile_controller.dart';
import 'package:mbea_ssi3_front/views/profile/models/profile_get_model.dart';
import 'package:mbea_ssi3_front/views/profile/pages/other_user_profile_page.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'package:video_player/video_player.dart';

import '../../favoritePosts/controllers/get_wishLists_controller.dart';

class ProductDetailPage extends StatefulWidget {
  final String postId;
  const ProductDetailPage({super.key, required this.postId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final OffersController offerController = Get.put(OffersController());
  final UserProfileController userProfileController =
      Get.put(UserProfileController());
  final ProductDetailController productDetailController =
      Get.put(ProductDetailController());
  final PageController _pageController = PageController();
  final CreateWishListController createWishListController =
      Get.put(CreateWishListController());
  final DeleteWishlistController deleteWishlistController =
      Get.put(DeleteWishlistController());
  final PostOfferController offerListController =
      Get.put(PostOfferController());
  final GetWishListsController getWishListsController =
      Get.put(GetWishListsController());
  int _currentPage = 0;
  UserProfile? user;
  var wishListId = "";
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productDetailController.fetchProductDetail(widget.postId);
      userProfileController.fetchUserProfile();
    });
  }

  void createAndDeleteWishList(String postId, String userId) async {
    if (productDetailController.productDetail.value!.isFavorated.value ==
        false) {
      try {
        var wishListDetail =
            await createWishListController.createWishList(userId, postId);
        wishListId = wishListDetail.wishListId;
      } catch (e) {
        Get.snackbar("Error", "Failed to create WishList: $e");
        return;
      }
    } else {
      try {
        if (wishListId.isNotEmpty) {
          await deleteWishlistController.deleteWishList(wishListId);
        }
        if (wishListId.isEmpty) {
          await deleteWishlistController.deleteWishList(
              productDetailController.productDetail.value!.wishListId);
        }
      } catch (e) {
        Get.snackbar("Error", "Failed to delete WishList: $e");
        return;
      }
    }

    Future.delayed(Duration.zero, () {
      productDetailController.productDetail.value!.isFavorated.value =
          !productDetailController.productDetail.value!.isFavorated.value;
    });
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
          onPressed: () async {
            await getWishListsController.getWishLists();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (productDetailController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          var productDetail = productDetailController.productDetail.value;
          if (productDetail != null) {
            return Stack(children: [
              ListView(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start, // จัดชิดซ้าย
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OtherUserProfileDetail(
                                                userId: productDetail.userID),
                                      ),
                                    );
                                  },
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.white,
                                      ),
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                            productDetail.userImageUrl),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  productDetail.username,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                if (userProfileController
                                        .userProfile.value?.username ==
                                    productDetail.username)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          '• โพสต์ของคุณ',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Constants.secondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                // widget.product.isFavorated =
                                //     !widget.product.isFavorated;
                              },
                              child: Icon(
                                Icons.more_horiz,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      mediaContent(productDetail),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  productDetail.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 24,
                                  ),
                                ),
                                // Favorite
                                if (userProfileController
                                        .userProfile.value?.username !=
                                    productDetail.username)
                                  Obx(() {
                                    return GestureDetector(
                                      onTap: () {
                                        createAndDeleteWishList(
                                            productDetail.id,
                                            userProfileController
                                                .userProfile.value!.id);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Icon(
                                          Icons.favorite,
                                          size: 30,
                                          color: productDetail.isFavorated.value
                                              ? Constants.secondaryColor
                                              : Color(0xFF9E9E9E),
                                        ),
                                      ),
                                    );
                                  }),
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
                                  productDetail.location,
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
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(30)),
                                color: Constants.secondaryColor,
                              ),
                              child: Text(
                                productDetail.subCollectionName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        margin: const EdgeInsets.only(top: 4),
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
                                        .fetchOffers(productDetail.id);
                                    setState(() {
                                      selectedIndex = 1;
                                    });
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        userProfileController.userProfile.value
                                                    ?.username ==
                                                productDetail.username
                                            ? 'ข้อเสนอของโพสต์นี้'
                                            : 'ข้อเสนอที่คุณยื่น',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: selectedIndex == 1
                                              ? Constants.secondaryColor
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
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
                              if (selectedIndex == 0)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3, horizontal: 15),
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
                                            productDetail.desiredItem,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
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
                                            productDetail.description,
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
                                    if (productDetail.flaw != null)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ตำหนิ : ${productDetail.flaw}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Constants.secondaryColor,
                                            ),
                                            softWrap:
                                                true, // อนุญาตให้ข้อความขึ้นบรรทัดใหม่
                                            overflow: TextOverflow.visible,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                            // if (selectedIndex == 1)
                            // Padding(
                            //   padding: EdgeInsets.only(top: 10),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //       Text(
                            //         'ยังไม่มีข้อเสนอของคุณในโพสต์นี้',
                            //         style: TextStyle(
                            //             fontSize: 15,
                            //             fontWeight: FontWeight.bold,
                            //             color: Colors.grey),
                            //       )
                            //     ],
                            //   ),
                            // )
                          ],
                        ),
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
                                    productDetail.id,
                                    productDetail.title,
                                    productDetail.username,
                                    productDetail.userImageUrl),
                                SizedBox(
                                  height: 15,
                                ),
                                if (offerListController.offerList.length > 3)
                                  TextButton(
                                    onPressed: () {
                                      // เพิ่มโค้ดที่ต้องการทำงานเมื่อกดปุ่มที่นี่
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => OffersPage(
                                                  postId: productDetail.id,
                                                  postTitle:
                                                      productDetail.title,
                                                  postImageURL:
                                                      productDetail.coverImage,
                                                  postLocation:
                                                      productDetail.location,
                                                  postSubCollectionName:
                                                      productDetail
                                                          .subCollectionName,
                                                  username:
                                                      productDetail.username,
                                                  userImageURL: productDetail
                                                      .userImageUrl,
                                                )),
                                      );
                                    },
                                    child: Text(
                                      "ดูข้อเสนอเพิ่มเติม", // ใส่ข้อความที่ต้องการแสดงบนปุ่ม
                                      style: TextStyle(
                                        fontSize: 14, // ขนาดตัวอักษร
                                        fontWeight:
                                            FontWeight.w500, // น้ำหนักตัวอักษร
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
                                  height: 50,
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
              if (userProfileController.userProfile.value!.username !=
                      productDetail.username &&
                  selectedIndex == 0)
                Positioned(
                  right: 15, // ระยะห่างจากขอบขวา
                  bottom: 30, // ระยะห่างจากขอบล่าง
                  child: GestureDetector(
                    onTap: () {
                      _sendOfferDialog();
                    },
                    child: IntrinsicWidth(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10, // ระยะห่างบน-ล่าง
                          horizontal: 20, // ระยะห่างซ้าย-ขวา
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFE875C), Color(0xFFE4593F)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'ยื่นข้อเสนอ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ]);
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
          StaggeredGridView.countBuilder(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            crossAxisCount: 1,
            mainAxisSpacing: 5,
            crossAxisSpacing: 22,
            itemCount: limitedItems.length,
            shrinkWrap: true, // ปรับขนาดให้พอดีกับจำนวนของรายการ
            physics:
                const NeverScrollableScrollPhysics(), // ปิดการเลื่อนแยกจากหน้าหลัก
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
                        userID: item.userID,
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
                          if (userProfileController
                                  .userProfile.value?.username ==
                              item.userName)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    '• ข้อเสนอของคุณ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
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
                                  item.location,
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

  Widget mediaContent(ProductDetail productDetail) {
    final mediaItems = [
      ...productDetail.productImages.map((img) => img.imageUrl),
      ...productDetail.productVideos.map((vid) => vid.videoUrl),
    ];

    return Column(
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
                if (mediaItem.endsWith('.jpg') || mediaItem.endsWith('.png')) {
                  return Hero(
                    tag: mediaItem,
                    child: ClipRRect(
                      child: Image.network(
                        mediaItem,
                        width: 320,
                        fit: BoxFit.cover,
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
        // const SizedBox(height: 30),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 45),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       GestureDetector(
        //         onTap: () {
        //           // Define button action here
        //           // print("Button tapped");
        //           _sendOfferDialog();
        //         },
        //         child: Container(
        //           padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        //           decoration: BoxDecoration(
        //             gradient: const LinearGradient(
        //               colors: [
        //                 Color(0xFFFE875C),
        //                 Color(0xFFE4593F)
        //               ], // ไล่เฉดสี
        //               begin: Alignment.topCenter,
        //               end: Alignment.bottomCenter,
        //             ),
        //             borderRadius: BorderRadius.circular(15),
        //             boxShadow: [
        //               BoxShadow(
        //                 color: Colors.black.withOpacity(0.1),
        //                 blurRadius: 8,
        //                 offset: Offset(0, 4),
        //               ),
        //             ],
        //           ),
        //           child: const Text(
        //             'ยื่นข้อเสนอ',
        //             style: TextStyle(
        //               color: Colors.white,
        //               fontSize: 14,
        //               fontWeight: FontWeight.bold,
        //             ),
        //           ),
        //         ),
        //       ),
        //       SizedBox(width: 30),
        //       GestureDetector(
        //         onTap: () {
        //           // widget.product.isFavorated =
        //           //     !widget.product.isFavorated;
        //         },
        //         child: Align(
        //           alignment: Alignment.topRight,
        //           child: Container(
        //             padding: EdgeInsets.all(6),
        //             decoration: BoxDecoration(
        //               borderRadius: BorderRadius.circular(50),
        //               color: true ? Colors.pink.shade50 : Colors.grey.shade400,
        //             ),
        //             child: Icon(
        //               Icons.favorite,
        //               color: true ? Colors.pink : Colors.black54,
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // )
      ],
    );
  }

  void _sendOfferDialog() {
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Text(
                            'คุณจะเลือกข้อเสนอจากไหน?',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.normal),
                          ),
                        ),
                        _buildSubmitButton('สร้างข้อเสนอใหม่'),
                        const SizedBox(height: 15),
                        _buildSubmitButton('เลือกจากข้อเสนอที่มีอยู่แล้ว'),
                        const SizedBox(height: 30),
                      ],
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

  void _createNewOfferDialog() {
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
                    child: SizedBox(
                      height: 700,
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Text(
                                'สร้างข้อเสนอใหม่',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: CreateOfferForm(
                                  isSendOffer: true,
                                  postId: productDetailController
                                      .productDetail.value!.id,
                                ), // Switch to CreateOfferForm
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildSubmitButton(
    String buttonType,
    // String id,
  ) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 250,
        height: 50,
        child: GestureDetector(
          onTap: () async {
            if (buttonType == 'สร้างข้อเสนอใหม่') {
              _createNewOfferDialog();
            } else {
              await offerController.fetchOffers();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChooseOfferPage(
                            postId: widget.postId,
                          )));
            }
          },
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              vertical: 12,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: buttonType == 'สร้างข้อเสนอใหม่'
                    ? [Color(0xFFFE875C), Color(0xFFE4593F)]
                    : [Color(0xFF3AB0F8), Color(0xFF3176B1)], // ไล่เฉดสี
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              buttonType,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
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
