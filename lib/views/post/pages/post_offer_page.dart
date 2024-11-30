import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/controller/offer_detail_controller.dart';
import 'package:mbea_ssi3_front/model/offer_detail_model.dart';
import 'package:mbea_ssi3_front/views/post/controllers/post_offer_controller.dart';
import 'package:mbea_ssi3_front/views/post/controllers/post_offer_detail_controller.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'package:video_player/video_player.dart';

class PostOfferPage extends StatefulWidget {
  final String postId;
  const PostOfferPage({super.key, required this.postId});

  @override
  State<PostOfferPage> createState() => _PostOfferPageState();
}

class _PostOfferPageState extends State<PostOfferPage> {
  final PostOfferController offerController = Get.put(PostOfferController());
  final PostOfferDetailController offerDetailController =
      Get.put(PostOfferDetailController());
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (offerController.isLoading.value) {
            // แสดง CircularProgressIndicator หากกำลังโหลดข้อมูล
            return Center(child: CircularProgressIndicator());
          }
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
            ),
            color: Colors.white,
            child: Column(
              children: [
                Expanded(
                  child: Obx(() {
                    if (offerController.isLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!offerController.offerList.isEmpty) {
                      return _buildStaggeredGrid(offerController.offerList);
                    } else {
                      return const Align(
                        alignment: Alignment.center,
                        child: Text('ยังไม่มีข้อเสนอ'),
                      );
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

  Widget _buildStaggeredGrid(List<dynamic> items) {
    return RefreshIndicator(
      onRefresh: () async {
        await offerController.fetchOffers(widget.postId);
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
              // final result = await Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => detailPageBuilder(item),
              //   ),
              // );

              // if (result == true) {
              //   // ดึงข้อมูลใหม่
              //   await offerController.fetchOffers();
              // }
              await offerDetailController.fetchOfferDetail(
                  widget.postId, item.id);
              _offerDetailDialog();
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

  void _offerDetailDialog() {
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
                            SizedBox(
                              height: 30,
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Obx(() {
                                  if (offerDetailController.isLoading.value) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }

                                  var offerDetail =
                                      offerDetailController.offerDetail.value;
                                  if (offerDetail != null) {
                                    return Stack(
                                      children: [
                                        SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              mediaContent(offerDetail),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              offerDetail.title,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize: 16),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          15,
                                                                      vertical:
                                                                          5),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                        Radius.circular(
                                                                            30)),
                                                                color: Constants
                                                                    .primaryColor,
                                                              ),
                                                              child: Text(
                                                                offerDetail
                                                                    .subCollectionName,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 15),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                  vertical: 6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.1),
                                                                spreadRadius: 2,
                                                                blurRadius: 6,
                                                                offset: Offset(
                                                                    0, 0),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                size: 21,
                                                                Icons
                                                                    .location_on,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                offerDetail
                                                                    .location,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black87,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 25),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Expanded(
                                                          // ใช้ Expanded เพื่อให้ข้อความสามารถปรับขนาดตามพื้นที่ที่เหลือ
                                                          child: Text(
                                                            offerDetail
                                                                .description,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
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
                                                    if (offerDetail.flaw !=
                                                        null)
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'ตำหนิ : ${offerDetail.flaw}',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Constants
                                                                  .secondaryColor,
                                                            ),
                                                            softWrap:
                                                                true, // อนุญาตให้ข้อความขึ้นบรรทัดใหม่
                                                            overflow:
                                                                TextOverflow
                                                                    .visible,
                                                          ),
                                                        ],
                                                      ),
                                                    const SizedBox(height: 25),
                                                    // _buildSubmitButton(
                                                    //     widget.postId,
                                                    //     offerDetail.id),
                                                    const SizedBox(height: 25),
                                                    // _buildSubmitButton()
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Center(
                                        child: Text('ยังไม่พอข้อเสนอที่ส่งมา'));
                                  }
                                }),
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

  // Widget _buildSubmitButton(String postId, String offerID) {
  //   return Align(
  //     alignment: Alignment.center,
  //     child: SizedBox(
  //       width: 150,
  //       child: ElevatedButton(
  //         onPressed: () async {
  //           sendOfferController.addOffer(postId: postId, offerId: offerID);
  //           Navigator.pop(context);
  //         },
  //         style: ElevatedButton.styleFrom(
  //           foregroundColor: Colors.white,
  //           backgroundColor: Constants.secondaryColor,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  //         ),
  //         child: Text(
  //           'ยื่นข้อเสนอ',
  //           style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget mediaContent(OfferDetail offerDetail) {
    final mediaItems = [
      ...offerDetail.offerImages.map((img) => img.imageUrl),
      ...offerDetail.offerVideos.map((vid) => vid.videoUrl),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
            width: 335,
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
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
        const SizedBox(height: 30),
      ],
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
