import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/controller/websocket_controller.dart';
import 'package:mbea_ssi3_front/views/home/pages/offer_detail_page.dart';
import 'package:mbea_ssi3_front/views/post/controllers/post_offer_controller.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

class OffersPage extends StatefulWidget {
  final String postId;
  final String postTitle;
  final String postImageURL;
  final String postLocation;
  final String postSubCollectionName;
  final String username;
  final String userImageURL;
  const OffersPage({
    super.key,
    required this.postId,
    required this.postTitle,
    required this.postImageURL,
    required this.postLocation,
    required this.postSubCollectionName,
    required this.username,
    required this.userImageURL,
  });

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  final PostOfferController offerListController =
      Get.put(PostOfferController());
  final ChatController chatController = Get.put(ChatController());
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title: const Text(
            'ข้อเสนอในโพสต์ของคุณ',
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
              if (offerListController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              if (!offerListController.offerList.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {}, // ฟังก์ชันที่เรียกเมื่อกด Card
                                borderRadius: BorderRadius.circular(
                                    16), // ให้เอฟเฟกต์กดดูเรียบเนียน
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.2), // สีของเงา
                                        spreadRadius: 2, // การกระจายตัวของเงา
                                        blurRadius: 4, // ความเบลอของเงา
                                        offset:
                                            Offset(0, 0), // ทิศทางของเงา (x, y)
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Content
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Product Image
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                widget
                                                    .postImageURL, // ใส่ URL รูปภาพสินค้า
                                                width: 82,
                                                height: 72,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            // Product Details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    widget.postTitle,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      const Icon(
                                                        size: 15,
                                                        Icons
                                                            .location_on_outlined,
                                                        color:
                                                            Color(0xFF9E9E9E),
                                                      ),
                                                      SizedBox(width: 2),
                                                      Text(
                                                        'บางรัก, สีลม',
                                                        style: const TextStyle(
                                                          color:
                                                              Color(0xFF9E9E9E),
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5),
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
                          ),
                          Positioned(
                            right: 15, // ระยะห่างจากขอบขวา
                            bottom: 20, // ระยะห่างจากขอบล่าง
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(30)),
                                    color: Constants.secondaryColor,
                                  ),
                                  child: Text(
                                    widget.postSubCollectionName.length > 10
                                        ? '${widget.postSubCollectionName.substring(0, 10)}...'
                                        : widget.postSubCollectionName,
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
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: searchField(),
                    ),
                    buildOfferList(offerListController.offerList, widget.postId,
                        widget.postTitle, widget.username, widget.userImageURL),
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
            })));
  }

  Widget buildOfferList(List<dynamic> items, String postId, String postName,
      String username, String userImage) {
    return RefreshIndicator(
      onRefresh: () async {
        await offerListController.fetchOffers(postId);
      },
      color: Colors.white,
      backgroundColor: Constants.secondaryColor,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.62, // กำหนดความสูง
            child: StaggeredGridView.countBuilder(
              padding: const EdgeInsets.all(15),
              crossAxisCount: 1,
              mainAxisSpacing: 5,
              crossAxisSpacing: 22,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
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
                          username: username,
                          userImage: userImage,
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
              padding: const EdgeInsets.all(15.0),
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
                                userImage), // ใส่ URL รูปภาพโปรไฟล์
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

  Widget searchField() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // สีของเงา
              spreadRadius: 0, // การกระจายตัวของเงา
              blurRadius: 5, // ความเบลอของเงา
              offset: Offset(0, 0), // ทิศทางของเงา (x, y)
            ),
          ],
          borderRadius: BorderRadius.circular(15), // ขอบโค้ง
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'ค้นหา',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: const Icon(
              Icons.search,
              size: 25,
              color: Colors.grey,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }
}
