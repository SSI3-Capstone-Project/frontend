import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
// import 'package:mbea_ssi3_front/views/exchange/controllers/exchange_offer_detail_controller.dart';
// import 'package:mbea_ssi3_front/views/exchange/controllers/exchange_post_detail_controller.dart';
import 'package:mbea_ssi3_front/views/exchange/controllers/exchange_product_detail_controller.dart';
import 'package:mbea_ssi3_front/views/exchange/pages/meet_up_page.dart';
import 'package:video_player/video_player.dart';

class ExchangePage extends StatefulWidget {
  final String offerID;
  final String postID;
  const ExchangePage({super.key, required this.offerID, required this.postID});

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  // final ExchangeOfferDetailController offerDetailController =
  //     Get.put(ExchangeOfferDetailController());
  // final ExchangePostDetailController postDetailController =
  //     Get.put(ExchangePostDetailController());
  final ExchangeProductDetailController productDetailController =
      Get.put(ExchangeProductDetailController());
  final PageController _postPageController = PageController();
  final PageController _offerPageController = PageController();
  final TextEditingController postPriceController = TextEditingController();
  final TextEditingController offerPriceController = TextEditingController();
  final RxString selectedPriceDifference = 'ไม่มี'.obs;
  final RxString selectedExchangeFormat = 'นัดรับ'.obs;
  final RxString selectedPayer = 'post'.obs;
  int _postCurrentPage = 0;
  int _offerCurrentPage = 0;
  int _exchangeStage = 0;

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
          _exchangeStage == 0
              ? 'ยืนยันการแลกเปลี่ยน'
              : _exchangeStage == 1
                  ? 'ราคาส่วนต่าง'
                  : 'รูปแบบในการแลกเปลี่ยน',
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
                  if (_exchangeStage == 0)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        productDetail(postDetail, 'post'),
                        Center(
                          child: Text(
                            '-' * dashCount, // ทำซ้ำ "-" ตามที่คำนวณได้
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                        productDetail(offerDetail, 'offer'),
                        SizedBox(
                          height: 80,
                        )
                      ],
                    ),
                  if (_exchangeStage == 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            "ในการแลกเปลี่ยนสินค้า มีสินไหมที่ต้องชำระค่าราคาส่วนต่างของราคาหรือไม่?",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                          SizedBox(height: 24),
                          Obx(() => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildPriceDifferenceOptionButton("มี",
                                      selectedPriceDifference.value == "มี",
                                      () {
                                    selectedPriceDifference.value = "มี";
                                  }),
                                  SizedBox(width: 12),
                                  _buildPriceDifferenceOptionButton("ไม่มี",
                                      selectedPriceDifference.value == "ไม่มี",
                                      () {
                                    selectedPriceDifference.value = "ไม่มี";
                                  }),
                                ],
                              )),
                          SizedBox(height: 50),
                          if (selectedPriceDifference.value == "มี")
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Text(
                                    "กรุณากรอกราคาส่วนต่างสินค้า หากมีราคาที่ต้องจ่ายเพิ่ม",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.black87),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Obx(() => Column(
                                      children: [
                                        _buildPayerOption(
                                            postDetail.username,
                                            postDetail.userImage,
                                            "post",
                                            postPriceController),
                                        const SizedBox(height: 12),
                                        _buildPayerOption(
                                            offerDetail.username,
                                            offerDetail.userImage,
                                            "offer",
                                            offerPriceController),
                                      ],
                                    )),
                              ],
                            ),
                        ],
                      ),
                    ),
                  if (_exchangeStage == 2)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          Obx(() => Column(
                                children: [
                                  _buildOptionButton(
                                      "นัดรับ",
                                      Icons.location_on,
                                      selectedExchangeFormat.value == "นัดรับ",
                                      () {
                                    selectedExchangeFormat.value = "นัดรับ";
                                  }),
                                  SizedBox(height: 12),
                                  _buildOptionButton(
                                      "ขนส่งด้วยไปรษณีย์และตัวกลาง",
                                      Icons.local_shipping,
                                      selectedExchangeFormat.value == "ขนส่ง",
                                      () {
                                    selectedExchangeFormat.value = "ขนส่ง";
                                  }),
                                ],
                              )),
                          SizedBox(height: 50),
                        ],
                      ),
                    ),
                ],
              ),
              Positioned(
                right: 0,
                bottom: 0,
                left: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // พื้นหลังขาวเหมือนในภาพ
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // ปุ่มย้อนกลับ (สีเทา)
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0),
                                bottomLeft: Radius.circular(0),
                              ),
                            ),
                          ),
                          onPressed: () {
                            if (_exchangeStage == 0) {
                              Navigator.pop(context);
                            } else {
                              setState(() {
                                _exchangeStage = _exchangeStage - 1;
                              });
                            }
                          },
                          child: Text(
                            'ย้อนกลับ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54, // สีเทา
                            ),
                          ),
                        ),
                      ),
                      // ปุ่มต่อไป (สีส้ม)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            backgroundColor: Constants.secondaryColor, // สีส้ม
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(0),
                                bottomRight: Radius.circular(0),
                              ),
                            ),
                          ),
                          onPressed: () {
                            if (_exchangeStage == 1) {
                              print(
                                  '-----------------Debugs------------------');
                              print(postPriceController);
                              print(postPriceController.text.toString());
                              if (selectedPriceDifference.value == 'มี') {
                                // if (postPriceController.text.isEmpty &&
                                //     offerPriceController.text.isEmpty) {
                                //   Get.snackbar('แจ้งเตือน',
                                //       'ถ้าการแลกเปลี่ยนของคุณมีค่าส่วนต่างต้องระบุค่าส่วนต่าง\nขั้นต่ำคือ 1 บาท');
                                //   return;
                                // }

                                int? postPrice =
                                    int.tryParse(postPriceController.text);
                                int? offerPrice =
                                    int.tryParse(offerPriceController.text);

                                if ((postPrice == null || postPrice == 0) &&
                                    (offerPrice == null || offerPrice == 0)) {
                                  Get.snackbar('แจ้งเตือน',
                                      'ถ้าการแลกเปลี่ยนของคุณมีค่าส่วนต่างต้องระบุค่าส่วนต่าง\nขั้นต่ำคือ 1 บาท');
                                } else {
                                  // setState(() {
                                  //   _exchangeStage = _exchangeStage + 1;
                                  // });
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MeetUpPage(
                                        currentStep: 1,
                                        user: Payer.post,
                                        payer: selectedPayer.value == 'post'
                                            ? Payer.post
                                            : Payer.offer,
                                        priceDifference:
                                            selectedPayer.value == 'post'
                                                ? int.tryParse(
                                                    postPriceController.text
                                                        .toString())
                                                : int.tryParse(
                                                    offerPriceController.text),
                                        postID: widget.postID,
                                        offerID: widget.offerID,
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                // setState(() {
                                //   _exchangeStage = _exchangeStage + 1;
                                // });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MeetUpPage(
                                      currentStep: 1,
                                      user: Payer.post,
                                      postID: widget.postID,
                                      offerID: widget.offerID,
                                    ),
                                  ),
                                );
                              }
                            } else if (_exchangeStage == 2) {
                              if (selectedExchangeFormat.value == 'นัดรับ') {
                                if (selectedPriceDifference.value == 'มี') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MeetUpPage(
                                        currentStep: 1,
                                        user: Payer.post,
                                        payer: selectedPayer.value == 'post'
                                            ? Payer.post
                                            : Payer.offer,
                                        priceDifference:
                                            selectedPayer.value == 'post'
                                                ? int.tryParse(
                                                    postPriceController.text
                                                        .toString())
                                                : int.tryParse(
                                                    offerPriceController.text),
                                        postID: widget.postID,
                                        offerID: widget.offerID,
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MeetUpPage(
                                        currentStep: 1,
                                        user: Payer.post,
                                        postID: widget.postID,
                                        offerID: widget.offerID,
                                      ),
                                    ),
                                  );
                                }
                              }
                            } else {
                              setState(() {
                                _exchangeStage = _exchangeStage + 1;
                              });
                            }
                          },
                          child: Text(
                            'ต่อไป',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        } else {
          return Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
        }
      })),
    );
  }

  Widget _buildPayerOption(String name, String imageUrl, String key,
      TextEditingController controller) {
    bool isSelected = selectedPayer.value == key;
    return GestureDetector(
      onTap: () {
        selectedPayer.value = key;
        if (key == "post") {
          postPriceController.text = "0"; // ตั้งค่าเริ่มต้น
          offerPriceController.text = "0"; // ทำให้ user2 เป็น 0 ตลอด
        } else {
          offerPriceController.text = "0";
          postPriceController.text = "0"; // ทำให้ user1 เป็น 0 ตลอด
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Constants.secondaryColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // 🔹 รูปโปรไฟล์ (ใส่สีแทน)
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(width: 10),

            // 🔹 ชื่อคน
            Expanded(
              child: Text(
                name,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),

            // 🔹 ช่องกรอกราคา
            SizedBox(
              width: 100,
              height: 40,
              child: TextField(
                controller: controller,
                enabled: isSelected, // ✅ เปิดใช้งานเฉพาะคนที่ถูกเลือก
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // ✅ อนุญาตเฉพาะตัวเลข
                  LengthLimitingTextInputFormatter(6), // ✅ จำกัดสูงสุด 6 หลัก
                ],
                onChanged: (value) {
                  if (!isSelected) {
                    controller.text = "0"; // ✅ ป้องกันการเปลี่ยนค่า
                  }
                },
                decoration: InputDecoration(
                  hintText: "0",
                  hintStyle: TextStyle(fontSize: 14),
                  filled: true,
                  fillColor: isSelected ? Colors.white : Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // 🔹 คำว่า "บาท"
            Text(
              "บาท",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
      String text, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
                  isSelected ? Constants.secondaryColor : Colors.grey.shade300,
              width: 2),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? Constants.secondaryColor : Colors.black87),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Constants.secondaryColor : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDifferenceOptionButton(
      String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color:
                  isSelected ? Constants.secondaryColor : Colors.grey.shade300,
              width: 2),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Constants.secondaryColor : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget productDetail(dynamic item, String type) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
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
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  color: type == 'post'
                      ? Constants.secondaryColor
                      : Constants.primaryColor,
                ),
                child: Text(
                  type == 'post' ? 'โพสต์ของคุณ' : 'ข้อเสนอ',
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
          padding: const EdgeInsets.symmetric(horizontal: 50),
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
