import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
// import 'package:mbea_ssi3_front/controller/offer_detail_controller.dart';
import 'package:mbea_ssi3_front/model/offer_detail_model.dart';
import 'package:mbea_ssi3_front/views/chat/controllers/create_chat_room_controller.dart';
import 'package:mbea_ssi3_front/views/chat/pages/chat_room_page.dart';
import 'package:mbea_ssi3_front/views/exchange/pages/exchange_page.dart';
import 'package:mbea_ssi3_front/views/post/controllers/post_offer_controller.dart';
import 'package:mbea_ssi3_front/views/post/controllers/post_offer_detail_controller.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/get_profile_controller.dart';
import 'package:mbea_ssi3_front/views/profile/pages/other_user_profile_page.dart';
import 'package:video_player/video_player.dart';

class OfferDetailPage extends StatefulWidget {
  final String postID;
  final String postName;
  final String offerID;
  final String userID;
  final String username;
  final String userImage;

  OfferDetailPage(
      {Key? key,
      required this.postID,
      required this.postName,
      required this.offerID,
      required this.userID,
      required this.username,
      required this.userImage})
      : super(key: key);

  @override
  _OfferDetailsPageState createState() => _OfferDetailsPageState();
}

class _OfferDetailsPageState extends State<OfferDetailPage> {
  final UserProfileController userProfileController =
      Get.put(UserProfileController());
  final PostOfferDetailController offerDetailController =
      Get.put(PostOfferDetailController());
  final PostOfferController offerListController =
      Get.put(PostOfferController());
  final CreateChatRoomController createChatRoomController =
      Get.put(CreateChatRoomController());
  final PageController _pageController = PageController();
  Map<String, dynamic>? offerData;
  bool isLoading = true;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    offerDetailController.fetchOfferDetail(widget.postID, widget.offerID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Column(
          children: [
            const Text(
              'ข้อเสนอของโพสต์',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              widget.postName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            )
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(child: Obx(() {
        if (offerDetailController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        var offerDetail = offerDetailController.offerDetail.value;
        if (offerDetail != null) {
          return Stack(
            children: [
              ListView(children: [
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
                                              userId: widget.userID),
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
                                      backgroundImage:
                                          NetworkImage(widget.userImage),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                widget.username,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(30)),
                                  color: Constants.primaryColor,
                                ),
                                child: Text(
                                  'ข้อเสนอ',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15,
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
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    mediaContent(offerDetail),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            offerDetail.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 24,
                            ),
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
                                offerDetail.location,
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
                              color: Constants.primaryColor,
                            ),
                            child: Text(
                              offerDetail.subCollectionName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                // ใช้ Expanded เพื่อให้ข้อความสามารถปรับขนาดตามพื้นที่ที่เหลือ
                                child: Text(
                                  offerDetail.description,
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
                          if (offerDetail.flaw != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'ตำหนิ : ${offerDetail.flaw}',
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
                    ),
                  ],
                ),
              ]),
              if (userProfileController.userProfile.value?.username !=
                  widget.username)
                Positioned(
                  right: 0,
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // IconButton(
                        //   padding: EdgeInsets.symmetric(horizontal: 40),
                        //   icon: Icon(Icons.favorite_border),
                        //   onPressed: () {
                        //     // กดปุ่มโปรด
                        //   },
                        // ),

                        // IconButton(
                        //   padding: EdgeInsets.symmetric(horizontal: 40),
                        //   icon: Icon(Icons.chat_bubble_outline),
                        //   onPressed: () {
                        //     // กดปุ่มแชท
                        //   },
                        // ),
                        Expanded(
                          child: TextButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Constants.secondaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              onPressed: () async {
                                deletePostOffer(widget.postID, widget.offerID);
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.delete_outline,
                                      color: Colors.black),
                                  Text(
                                    'ทิ้งข้อเสนอนี้',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        Expanded(
                          child: TextButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 45),
                              ),
                              onPressed: () async {
                                var result = await createChatRoomController
                                    .createChatRoom(
                                        widget.postID, widget.offerID);
                                if (result != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoom(
                                        roomID: result,
                                        anotherUsername: widget.username,
                                        anotherUserImage: widget.userImage,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.chat_outlined,
                                      color: Colors.black),
                                  Text(
                                    'แชท',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              )),
                        ),

                        // ปุ่มตรงกลาง
                        // ElevatedButton(
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: Constants.secondaryColor,
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(0),
                        //       ),
                        //       padding: const EdgeInsets.symmetric(
                        //           vertical: 25, horizontal: 24),
                        //     ),
                        //     onPressed: () {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) => ExchangePage(
                        //             postID: widget.postID,
                        //             offerID: widget.offerID,
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //     child: Row(
                        //       children: [
                        //         Icon(Icons.autorenew, color: Colors.white),
                        //         SizedBox(
                        //           width: 5,
                        //         ),
                        //         Text(
                        //           'ตกลงแลกเปลี่ยน',
                        //           style: const TextStyle(
                        //             fontSize: 14,
                        //             fontWeight: FontWeight.w500,
                        //             color: Colors.white,
                        //           ),
                        //         ),
                        //       ],
                        //     )),
                      ],
                    ),
                  ),
                ),
              if (userProfileController.userProfile.value?.username ==
                  widget.username)
                Positioned(
                  right: 0,
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(),
                    decoration: BoxDecoration(
                      color: Constants.secondaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 30),
                            ),
                            onPressed: () async {
                              deletePostOffer(widget.postID, widget.offerID);
                            },
                            child: Column(
                              children: [
                                Icon(Icons.cancel, color: Colors.white),
                                Text(
                                  'ยกเลิกข้อเสนอ',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
            ],
          );
        } else {
          return Center(child: Text('No data available'));
        }
      })),
    );
  }

  void deletePostOffer(String postID, String offerID) {
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
                              'ยืนยันการยกเลิก',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                          ),
                          Text(
                            'คุณต้องการยกเลิกข้อเสนอนี้ใช่หรือไม่?',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.normal),
                          ),
                          const SizedBox(height: 30),
                          _buildSubmitDeleteButton(postID, offerID),
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

  Widget _buildSubmitDeleteButton(String postID, String offerID) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 100,
        child: ElevatedButton(
          onPressed: () async {
            offerDetailController.deleteOfferInPost(
                widget.postID, widget.offerID);
            await offerListController.fetchOffers(widget.postID);
            Navigator.pop(context);
            Navigator.pop(context);
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
                color: Constants.primaryColor,
                borderRadius: BorderRadius.circular(5),
              ),
            );
          }),
        ),
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
