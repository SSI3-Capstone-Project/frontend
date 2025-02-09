import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/controller/offer_detail_controller.dart'; // Import the controller
import 'package:mbea_ssi3_front/controller/offers_controller.dart';
import 'package:mbea_ssi3_front/model/offer_detail_model.dart';
import 'package:mbea_ssi3_front/views/offer/controllers/delete_offer_controller.dart';
import 'package:mbea_ssi3_front/views/offer/pages/offer_edit.dart';
import 'package:video_player/video_player.dart';

class OfferDetailPage extends StatefulWidget {
  final String offerId;
  const OfferDetailPage({super.key, required this.offerId});

  @override
  State<OfferDetailPage> createState() => _OfferDetailPageState();
}

class _OfferDetailPageState extends State<OfferDetailPage> {
  final OffersController offerController = Get.put(OffersController());
  final OfferDetailController offerDetailController =
      Get.put(OfferDetailController());
  final OfferDeleteController offerDeleteController =
      Get.put(OfferDeleteController());
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    offerDetailController.fetchOfferDetail(widget.offerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          'ข้อเสนอ',
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
          if (offerDetailController.isLoading.value ||
              offerDeleteController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          var offerDetail = offerDetailController.offerDetail.value;
          if (offerDetail != null) {
            return Stack(
              children: [
                ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start, // จัดชิดซ้าย
                      children: [
                        const SizedBox(height: 25),
                        mediaContent(offerDetail),
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
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
                                    offerDetail.title,
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(30)),
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
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            );
          } else {
            return Center(child: Text('No data available'));
          }
        }),
      ),
    );
  }

  Widget mediaContent(OfferDetail offerDetail) {
    final mediaItems = [
      ...offerDetail.offerImages.map((img) => img.imageUrl),
      ...offerDetail.offerVideos.map((vid) => vid.videoUrl),
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
                            EditOfferForm(offerDetail: offerDetail),
                      ),
                    );

                    // ตรวจสอบว่าโพสต์มีการอัปเดตหรือไม่
                    if (result == true) {
                      // ดึงข้อมูลใหม่
                      offerDetailController.fetchOfferDetail(widget.offerId);
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
                    deleteOffer(widget.offerId);
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

  void deleteOffer(String id) {
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
                            'คุณต้องการลบข้อเสนอนี้ใช่หรือไม่?',
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
            var result = await offerDeleteController.deleteOffer(id);
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
