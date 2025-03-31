import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/exchange/controllers/exchange_product_detail_controller.dart';
import 'package:mbea_ssi3_front/views/report/controllers/report_controller.dart';
import 'package:video_player/video_player.dart';

class ReportIssuePage extends StatefulWidget {
  final String exchangeId;
  final String postID;
  final String offerID;

  const ReportIssuePage(
      {super.key,
      required this.exchangeId,
      required this.postID,
      required this.offerID});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final ExchangeProductDetailController productDetailController =
      Get.put(ExchangeProductDetailController());
  final TextEditingController _reasonController = TextEditingController();
  final ReportController _reportController = Get.put(ReportController());
  final PageController _postPageController = PageController();
  final PageController _offerPageController = PageController();
  int _postCurrentPage = 0;
  int _offerCurrentPage = 0;
  int maxCharacters = 200;

  ReportType? _selectedReportType;

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    String? value,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField2<String>(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              fontSize: 14, // ปรับขนาดฟอนต์ของ labelText
              fontWeight: FontWeight.w500,
            ),
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
          value: value,
          onChanged: onChanged,
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white,
            ),
            maxHeight: 200,
          ),
          validator: validator ??
              (value) =>
                  value == null ? 'โปรดเลือก${label.toLowerCase()}' : null,
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate() && _selectedReportType != null) {
      final success = await _reportController.createExchangeReport(
        widget.exchangeId,
        _selectedReportType!,
        _reasonController.text,
      );

      if (success) {
        Get.snackbar('สำเร็จ', 'รายงานของคุณถูกส่งเรียบร้อยแล้ว');
        Navigator.of(context).pop();
      } else {
        Get.snackbar('ผิดพลาด', 'เกิดปัญหาระหว่างการส่งรายงาน');
      }
    }
  }

  void limitTextLength() {
    String text = _reasonController.text;
    if (text.runes.length > maxCharacters) {
      // ตัดข้อความให้ไม่เกิน 200 ตัวอักษร
      _reasonController.text =
          String.fromCharCodes(text.runes.take(maxCharacters));
      _reasonController.selection = TextSelection.fromPosition(
        TextPosition(offset: _reasonController.text.length),
      );
    }
    setState(() {}); // อัปเดตตัวนับ
  }

  @override
  void initState() {
    super.initState();

    productDetailController.fetchPostAndOfferDetail(
        widget.postID, widget.offerID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(child: Obx(() {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        size: 80,
                                        Icons.error_outline,
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Text(
                                    'รายงานปัญหาการแลกเปลี่ยน',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade900,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  // Column(
                                  //   mainAxisSize: MainAxisSize.min,
                                  //   children: [
                                  //     productDetail(postDetail, 'post'),
                                  //     // Center(
                                  //     //   child: Text(
                                  //     //     '-' *
                                  //     //         dashCount, // ทำซ้ำ "-" ตามที่คำนวณได้
                                  //     //     style: TextStyle(
                                  //     //         fontSize: 14, color: Colors.grey),
                                  //     //   ),
                                  //     // ),
                                  //     SizedBox(
                                  //       height: 25,
                                  //     ),
                                  //     productDetail(offerDetail, 'offer'),
                                  //   ],
                                  // ),
                                  customCard("โพสต์และข้อเสนอ", [
                                    Obx(() {
                                      final post = productDetailController
                                          .postDetail.value;
                                      final offer = productDetailController
                                          .offerDetail.value;

                                      if (post == null || offer == null) {
                                        return Center(
                                            child: CircularProgressIndicator());
                                      }

                                      return Column(
                                        children: [
                                          productDetail(post, 'post'),
                                          SizedBox(height: 10),
                                          Divider(color: Colors.grey.shade400),
                                          productDetail(offer, 'offer'),
                                          SizedBox(height: 8),
                                        ],
                                      );
                                    }),
                                  ]),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Text(
                                    'แอดมินจะทำการตรวจสอบและตอบกลับ',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    'รายงานปัญหาผ่านทางอีเมลของท่าน เพื่อแก้ไขปัญหาที่เกิดขึ้น',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                ],
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                _buildDropdownField(
                                  label: 'ประเภทปัญหา',
                                  items: ReportType.values
                                      .map((type) => type.displayName)
                                      .toList(),
                                  value: _selectedReportType?.displayName,
                                  onChanged: (value) => setState(() =>
                                      _selectedReportType = ReportType.values
                                          .firstWhere((type) =>
                                              type.displayName == value)),
                                ),
                                TextFormField(
                                  controller: _reasonController,
                                  maxLines: 3,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    hintText: "รายละเอียดปัญหา...",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 2),
                                    ),
                                    contentPadding: EdgeInsets.all(12),
                                  ),
                                  onChanged: (text) {
                                    limitTextLength();
                                  },
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'โปรดกรอกรายละเอียดปัญหา';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "${_reasonController.text.runes.length}/$maxCharacters",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // ElevatedButton(
                          //   onPressed: _submitReport,
                          //   child: const Text('ส่งรายงาน'),
                          // ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 120), // ปรับแต่งตามต้องการ
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Constants.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _submitReport,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "ส่งรายงาน",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
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

  Widget customCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วนหัวสีส้ม
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF15A29),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          // ส่วนเนื้อหาพื้นหลังขาว
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget productDetail(dynamic item, String type) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 14,
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
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) =>
                        //         OtherUserProfileDetail(userId: item.id),
                        //   ),
                        // );
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white,
                          ),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(item.userImage),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 6,
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
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'รายละเอียด',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
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
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
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
            width: 320,
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
