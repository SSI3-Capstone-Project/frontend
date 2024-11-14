import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/controller/offer_detail_controller.dart'; // Import the controller
import 'package:mbea_ssi3_front/model/offer_detail_model.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/delete_offer_controller.dart';
import 'package:video_player/video_player.dart';

class OfferDetailPage extends StatefulWidget {
  final String offerId;
  const OfferDetailPage({super.key, required this.offerId});

  @override
  State<OfferDetailPage> createState() => _OfferDetailPageState();
}

class _OfferDetailPageState extends State<OfferDetailPage> {
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
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back, size: 30),
                          ),
                        ],
                      ),
                    ),
                    mediaContent(offerDetail),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 45),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.28,
                  minChildSize: 0.28,
                  maxChildSize: 0.9,
                  builder: (context, scrollController) {
                    return Container(
                      padding: const EdgeInsets.only(top: 28),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 0.5,
                            blurRadius: 6,
                            offset: const Offset(0, 0),
                          ),
                        ],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        color: Colors.white,
                      ),
                      child: productDetails(scrollController, offerDetail),
                    );
                  },
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
            height: 350,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                print("Edit button tapped");
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3AB0F8), Color(0xFF3176B1)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'แก้ไขข้อเสนอ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 30),
            GestureDetector(
              onTap: () {
                offerDeleteController.deleteOffer(widget.offerId);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFE875C), Color(0xFFE4593F)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'ลบข้อเสนอ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget productDetails(
      ScrollController scrollController, OfferDetail offerDetail) {
    return ListView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: Divider(
                color: Colors.black.withOpacity(0.7),
                thickness: 3,
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              offerDetail.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                color: Constants.primaryColor,
              ),
              child: Text(
                offerDetail.subCollectionName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Text(
            offerDetail.description,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
        ),
        const SizedBox(height: 25),
        if (offerDetail.flaw != null)
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Text(
              'ตำหนิ : ${offerDetail.flaw}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Constants.secondaryColor,
              ),
            ),
          ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
                  children: const [
                    Icon(
                      Icons.location_on,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'ปากเกร็ด, นนทบุรี',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {}); // Refresh state after initialization
      }).catchError((error) {
        setState(() {
          _isError = true;
        });
        print("Error loading video: $error");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Center(child: Text("ไม่สามารถโหลดวิดีโอได้"));
    }

    return _controller.value.isInitialized
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      });
                    },
                    child: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                colors: VideoProgressColors(
                  playedColor: Theme.of(context).primaryColor,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDuration(_controller.value.position),
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      formatDuration(_controller.value.duration),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          )
        : Center(child: CircularProgressIndicator());
  }

  String formatDuration(Duration position) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = position.inHours;
    final minutes = position.inMinutes.remainder(60);
    final seconds = position.inSeconds.remainder(60);
    return hours > 0
        ? '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}'
        : '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
