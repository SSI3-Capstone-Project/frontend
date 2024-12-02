import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/controller/post_detail_controller.dart';
import 'package:mbea_ssi3_front/controller/posts_controller.dart';
import 'package:mbea_ssi3_front/model/post_detail_model.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/post/controllers/delete_post_controller.dart';
import 'package:mbea_ssi3_front/views/post/controllers/post_offer_controller.dart';
import 'package:mbea_ssi3_front/views/post/pages/post_edit.dart';
import 'package:mbea_ssi3_front/views/post/pages/post_offer_page.dart';
import 'package:video_player/video_player.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;
  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final PostsController postController = Get.put(PostsController());
  final PostOfferController offerController = Get.put(PostOfferController());
  final PostDetailController postDetailController =
      Get.put(PostDetailController());
  final PostDeleteController postDeleteController =
      Get.put(PostDeleteController());
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isActiveDetail = true;

  @override
  void initState() {
    super.initState();
    postDetailController.fetchPostDetail(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (postDetailController.isLoading.value ||
              postDeleteController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          var postDetail = postDetailController.postDetail.value;
          if (postDetail != null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start, // จัดชิดซ้าย
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: _buildTabContainer(),
                ),
                if (isActiveDetail)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),
                      mediaContent(postDetail),
                      const SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Wrap(
                              alignment:
                                  WrapAlignment.start, // จัดชิดซ้ายในแนวนอน
                              runAlignment: WrapAlignment.start,
                              spacing: 10, // ระยะห่างระหว่าง children ในแนวนอน
                              runSpacing: 10, // ระยะห่างระหว่างบรรทัด
                              children: [
                                Text(
                                  postDetail.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 21),
                                  softWrap:
                                      true, // อนุญาตให้ข้อความขึ้นบรรทัดใหม่
                                  overflow: TextOverflow.visible,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(30)),
                                    color: Constants.primaryColor,
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
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 2,
                                        blurRadius: 6,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        size: 25,
                                        Icons.location_on,
                                        color: Colors.black54,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        postDetail.location,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            Wrap(
                              alignment:
                                  WrapAlignment.start, // จัดชิดซ้ายในแนวนอน
                              runAlignment: WrapAlignment.start,
                              spacing: 8, // ระยะห่างระหว่าง children ในแนวนอน
                              runSpacing: 10,
                              children: [
                                const Text(
                                  'สนใจแลก :',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFE875C),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
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
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'ตำหนิ : ${postDetail.flaw}',
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
                            const SizedBox(height: 25),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                if (!isActiveDetail)
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: PostOfferPage(
                      postId: widget.postId,
                    ),
                  ))

                // DraggableScrollableSheet(
                //   initialChildSize: 0.28,
                //   minChildSize: 0.28,
                //   maxChildSize: 0.9,
                //   builder: (context, scrollController) {
                //     return Container(
                //       padding: const EdgeInsets.only(top: 28),
                //       decoration: BoxDecoration(
                //         boxShadow: [
                //           BoxShadow(
                //             color: Colors.grey.withOpacity(0.5),
                //             spreadRadius: 0.5,
                //             blurRadius: 6,
                //             offset: const Offset(0, 0),
                //           ),
                //         ],
                //         borderRadius: const BorderRadius.only(
                //           topLeft: Radius.circular(30),
                //           topRight: Radius.circular(30),
                //         ),
                //         color: Colors.white,
                //       ),
                //       child: productDetails(scrollController, postDetail),
                //     );
                //   },
                // ),
              ],
            );
          } else {
            return Center(child: Text('No data available'));
          }
        }),
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
          Row(
            children: [
              GestureDetector(
                onTap: () async => {
                  await postController.fetchPosts(),
                  Navigator.pop(context),
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 25,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              _buildTabItem('รายละเอียด', isActiveDetail, () {
                setState(() {
                  isActiveDetail = true;
                });
              }),
            ],
          ),
          _buildTabItem('ข้อเสนอ', !isActiveDetail, () async {
            await offerController.fetchOffers(widget.postId);
            setState(() {
              isActiveDetail = false;
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => PostOfferPage(),
              //   ),
              // );
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
                    color: Constants.primaryColor,
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

  // Widget productDetails(
  //     ScrollController scrollController, PostDetail postDetail) {
  //   return ListView(
  //     controller: scrollController,
  //     physics: const BouncingScrollPhysics(),
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           SizedBox(
  //             width: 150,
  //             child: Divider(
  //               color: Colors.black.withOpacity(0.7),
  //               thickness: 3,
  //             ),
  //           ),
  //           SizedBox(width: 10),
  //         ],
  //       ),
  //       const SizedBox(height: 25),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text(
  //             postDetail.title,
  //             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 25),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
  //             decoration: BoxDecoration(
  //               borderRadius: const BorderRadius.only(
  //                 topRight: Radius.circular(30),
  //                 bottomRight: Radius.circular(30),
  //               ),
  //               color: Constants.primaryColor,
  //             ),
  //             child: Text(
  //               postDetail.subCollectionName,
  //               style: const TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 25),
  //       Padding(
  //         padding: const EdgeInsets.only(left: 18),
  //         child: Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Text(
  //               'สนใจแลก :',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 color: Colors.black87,
  //               ),
  //             ),
  //             const SizedBox(width: 8),
  //             GestureDetector(
  //               onTap: () {
  //                 // Add button tap functionality here
  //                 print("Button tapped");
  //               },
  //               child: Container(
  //                 padding:
  //                     const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
  //                 decoration: BoxDecoration(
  //                   color: const Color(0xFFFE875C),
  //                   borderRadius: BorderRadius.circular(20),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.black.withOpacity(0.1),
  //                       blurRadius: 4,
  //                       offset: Offset(0, 2),
  //                     ),
  //                   ],
  //                 ),
  //                 child: Text(
  //                   postDetail.desiredItem,
  //                   style: const TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 16,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(height: 25),
  //       Padding(
  //         padding: const EdgeInsets.only(left: 18),
  //         child: Text(
  //           postDetail.description,
  //           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
  //         ),
  //       ),
  //       const SizedBox(height: 25),
  //       if (postDetail.flaw != null)
  //         Padding(
  //           padding: const EdgeInsets.only(left: 18),
  //           child: Text(
  //             'ตำหนิ : ${postDetail.flaw}',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //               color: Constants.secondaryColor,
  //             ),
  //           ),
  //         ),
  //       const SizedBox(height: 25),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.end,
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 18),
  //             child: Container(
  //               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(20),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.1),
  //                     spreadRadius: 2,
  //                     blurRadius: 6,
  //                     offset: Offset(0, 0),
  //                   ),
  //                 ],
  //               ),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Icon(
  //                     Icons.location_on,
  //                     color: Colors.black54,
  //                   ),
  //                   SizedBox(width: 4),
  //                   Text(
  //                     postDetail.location,
  //                     style: TextStyle(
  //                       color: Colors.black87,
  //                       fontSize: 16,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

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
