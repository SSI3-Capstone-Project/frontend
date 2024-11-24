import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/controller/post_detail_controller.dart';
import 'package:mbea_ssi3_front/views/home/controllers/product_detail_controller.dart';
import 'package:mbea_ssi3_front/views/home/models/product_detail_model.dart';
import 'package:mbea_ssi3_front/views/home/models/product_model.dart';
import 'package:video_player/video_player.dart';

class ProductDetailPage extends StatefulWidget {
  final String postId;
  const ProductDetailPage({super.key, required this.postId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ProductDetailController productDetailController =
      Get.put(ProductDetailController());
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    productDetailController.fetchProductDetail(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (productDetailController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          var productDetail = productDetailController.productDetail.value;
          if (productDetail != null) {
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
                            onTap: () => {Navigator.pop(context, true)},
                            child: const Icon(Icons.arrow_back, size: 30),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 45),
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
                              )
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
                      child: productDetails(scrollController, productDetail),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  // Define button action here
                  // print("Button tapped");
                  _sendOfferDialog();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFE875C),
                        Color(0xFFE4593F)
                      ], // ไล่เฉดสี
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'ยื่นข้อเสนอ',
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
                  // widget.product.isFavorated =
                  //     !widget.product.isFavorated;
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: true ? Colors.pink.shade50 : Colors.grey.shade400,
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: true ? Colors.pink : Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
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
                    child: const Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            child: Text(
                              'ยื่นข้อเสนอ',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                          ),

                          SizedBox(height: 30),
                          // _buildSubmitDeleteButton(),
                          SizedBox(height: 30),
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
      // String id,
      ) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 100,
        child: ElevatedButton(
          onPressed: () async {
            // var result = await addressController.deleteAddress(id: id);
            // if (mounted) {
            //   if (result) {
            //     Get.snackbar('สำเร็จ', 'ที่อยู่ถูกลบออกไปแล้ว');
            //   } else {
            //     Get.snackbar('ล้มเหลว', 'เกิดข้อผิดพลาดในการลบที่อยู่');
            //   }
            // }
            // Navigator.pop(context);
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

  Widget productDetails(
      ScrollController scrollController, ProductDetail productDetail) {
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
              productDetail.title,
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
                productDetail.subCollectionName,
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'สนใจแลก :',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // Add button tap functionality here
                  print("Button tapped");
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
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
                    productDetail.desiredItem,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Text(
            productDetail.description,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
        ),
        const SizedBox(height: 25),
        if (productDetail.flaw != null)
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Text(
              'ตำหนิ : ${productDetail.flaw}',
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
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 4),
                    Text(
                      productDetail.location,
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
        playedColor: Theme.of(context).primaryColor,
        bufferedColor: Colors.grey,
        backgroundColor: Colors.black,
      ),
    );
  }
}
