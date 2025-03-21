import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/exchange/controllers/exchange_product_detail_controller.dart';
import 'package:video_player/video_player.dart';

class ExchangeProductDetailPage extends StatefulWidget {
  final String offerID;
  final String postID;
  const ExchangeProductDetailPage(
      {super.key, required this.offerID, required this.postID});

  @override
  State<ExchangeProductDetailPage> createState() =>
      _ExchangeProductDetailPage();
}

class _ExchangeProductDetailPage extends State<ExchangeProductDetailPage> {
  final ExchangeProductDetailController productDetailController =
      Get.put(ExchangeProductDetailController());
  final PageController _postPageController = PageController();
  final PageController _offerPageController = PageController();
  final TextEditingController postPriceController = TextEditingController();
  final TextEditingController offerPriceController = TextEditingController();
  int _postCurrentPage = 0;
  int _offerCurrentPage = 0;

  @override
  void initState() {
    super.initState();

    productDetailController.fetchPostAndOfferDetail(
        widget.postID, widget.offerID);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int dashCount = (screenWidth / 5.5).floor();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'รายละเอียดการแลกเปลี่ยน',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
          // bottom: false,
          child: Obx(() {
        if (productDetailController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        var postDetail = productDetailController.postDetail.value;
        var offerDetail = productDetailController.offerDetail.value;
        if (postDetail != null && offerDetail != null) {
          return Stack(
            children: [
              ListView(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 25,
                      ),
                      productDetail(postDetail, 'post'),
                      SizedBox(
                        height: 25,
                      ),
                      productDetail(offerDetail, 'offer'),
                      SizedBox(
                        height: 80,
                      )
                    ],
                  ),
                ],
              ),
            ],
          );
        } else {
          return Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
        }
      })),
    );
  }

  Widget productDetail(dynamic item, String type) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white,
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(item.userImage),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      item.username,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                    color: type == 'post'
                        ? Constants.secondaryColor
                        : Constants.primaryColor,
                  ),
                  child: Text(
                    type == 'post' ? 'โพสต์' : 'ข้อเสนอ',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Center(child: mediaContent(item, type)),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'รายละเอียด',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      // ใช้ Expanded เพื่อให้ข้อความสามารถปรับขนาดตามพื้นที่ที่เหลือ
                      child: Text(
                        item.description,
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        softWrap: true, // อนุญาตให้ข้อความขึ้นบรรทัดใหม่
                        overflow: TextOverflow.visible, // แสดงข้อความทั้งหมด
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                if (item.flaw != null)
                  Text(
                    'ตำหนิ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                if (item.flaw != null) const SizedBox(height: 5),
                if (item.flaw != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        // ใช้ Expanded เพื่อให้ข้อความสามารถปรับขนาดตามพื้นที่ที่เหลือ
                        child: Text(
                          item.flaw,
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          softWrap: true, // อนุญาตให้ข้อความขึ้นบรรทัดใหม่
                          overflow: TextOverflow.visible, // แสดงข้อความทั้งหมด
                        ),
                      ),
                    ],
                  ),
                if (item.flaw != null) const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget mediaContent(dynamic item, String type) {
    var mediaItems = [];
    if (type == 'post') {
      mediaItems = [
        ...item.postImages.map((img) => img.imageUrl),
        ...item.postVideos.map((vid) => vid.videoUrl),
      ];
    } else {
      mediaItems = [
        ...item.offerImages.map((img) => img.imageUrl),
        ...item.offerVideos.map((vid) => vid.videoUrl),
      ];
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 🔹 ภาพหลัก (รูปภาพหรือวิดีโอ)
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 300,
            height: 250,
            child: PageView.builder(
              controller:
                  type == 'post' ? _postPageController : _offerPageController,
              itemCount: mediaItems.length,
              onPageChanged: (index) {
                setState(() {
                  if (type == 'post') {
                    _postCurrentPage = index;
                  } else {
                    _offerCurrentPage = index;
                  }
                });
              },
              itemBuilder: (context, index) {
                final mediaItem = mediaItems[index];
                return mediaItem.endsWith('.jpg') || mediaItem.endsWith('.png')
                    ? Image.network(mediaItem, fit: BoxFit.cover)
                    : VideoPlayerWidget(videoUrl: mediaItem);
              },
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 🔹 Thumbnail Slider
        Container(
          // color: Colors.black,
          child: SizedBox(
            width: 320,
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mediaItems.length,
              itemBuilder: (context, index) {
                final mediaItem = mediaItems[index];
                bool isSelected = index ==
                    (type == 'post' ? _postCurrentPage : _offerCurrentPage);

                return GestureDetector(
                  onTap: () {
                    if (type == 'post') {
                      _postPageController.animateToPage(index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    } else {
                      _offerPageController.animateToPage(index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    }
                    setState(() {
                      if (type == 'post') {
                        _postCurrentPage = index;
                      } else {
                        _offerCurrentPage = index;
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: mediaItem.endsWith('.jpg') ||
                              mediaItem.endsWith('.png')
                          ? Image.network(mediaItem,
                              width: 50, height: 50, fit: BoxFit.cover)
                          : Container(
                              color: Colors.black,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 50,
                                    height: 50,
                                  ),
                                  const Icon(Icons.play_circle_fill,
                                      color: Colors.white, size: 30),
                                ],
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
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
