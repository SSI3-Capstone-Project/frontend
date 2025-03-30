import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/exchange/controllers/exchange_controller.dart';
import 'package:mbea_ssi3_front/views/exchange/controllers/exchange_product_detail_controller.dart';
import 'package:mbea_ssi3_front/views/exchange/pages/user_review_section.dart';
import 'package:mbea_ssi3_front/views/profile/pages/other_user_profile_page.dart';
import 'package:mbea_ssi3_front/views/exchange/controllers/rating_controller.dart';

import 'package:mbea_ssi3_front/views/report/pages/report_issue_page.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ExchangeDetail extends StatefulWidget {
  final String exchangeID;
  final bool status;
  const ExchangeDetail({
    super.key,
    required this.exchangeID,
    required this.status,
  });

  @override
  State<ExchangeDetail> createState() => _ExchangeDetailState();
}

class _ExchangeDetailState extends State<ExchangeDetail> {
  final ExchangeController exchangeController = Get.put(ExchangeController());
  final ExchangeProductDetailController productDetailController =
      Get.put(ExchangeProductDetailController());
  final RatingController ratingController = Get.put(RatingController());
  final PageController _postPageController = PageController();
  final PageController _offerPageController = PageController();
  TextEditingController reviewController = TextEditingController();
  List<Map<String, dynamic>> mediaList = [];
  int _postCurrentPage = 0;
  int _offerCurrentPage = 0;
  int maxCharacters = 200;

  @override
  void initState() {
    super.initState();

    productDetailController.fetchPostAndOfferDetail(
        exchangeController.exchange.value!.postId,
        exchangeController.exchange.value!.offerId);
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                  child: RefreshIndicator(
                onRefresh: () async {
                  await exchangeController
                      .fetchExchangeDetails(widget.exchangeID);
                },
                color: Colors.white,
                backgroundColor: Constants.secondaryColor,
                child: ListView(
                    padding: EdgeInsets.zero,
                    physics:
                        AlwaysScrollableScrollPhysics(), // เพิ่มเพื่อให้แน่ใจว่าเลื่อนได้
                    children: [
                      Center(
                        child: Column(
                          children: [
                            statusCard(isSuccess: widget.status),
                            customCard(
                              "รูปแบบการแลกเปลี่ยน: นัดรับ",
                              [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: infoRow(
                                      Icons.calendar_today,
                                      "วันที่ตกลงแลกเปลี่ยน",
                                      formatDateTime(exchangeController
                                          .exchange.value!.createdAt)),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10), // ระยะห่างจากเนื้อหา
                                  height: 1, // ความหนาของเส้น
                                  width: double.infinity, // ความกว้างของเส้น
                                  color: Colors.grey.shade400, // สีของเส้น
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: infoRow(
                                      Icons.event,
                                      "วันที่นัดหมาย",
                                      formatDateTime(exchangeController.exchange
                                          .value!.meetingPoint.scheduledTime)),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10), // ระยะห่างจากเนื้อหา
                                  height: 1, // ความหนาของเส้น
                                  width: double.infinity, // ความกว้างของเส้น
                                  color: Colors.grey.shade400, // สีของเส้น
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: infoRow(
                                      Icons.check_circle_outline,
                                      widget.status
                                          ? "วันที่แลกเปลี่ยนสำเร็จ"
                                          : "วันที่ยกเลิกการแลกเปลี่ยน",
                                      formatDateTime(exchangeController
                                          .exchange.value!.exchangeDate!)),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10), // ระยะห่างจากเนื้อหา
                                  height: 1, // ความหนาของเส้น
                                  width: double.infinity, // ความกว้างของเส้น
                                  color: Colors.grey.shade400, // สีของเส้น
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: infoRow(
                                      Icons.location_on,
                                      "สถานที่นัดรับ",
                                      exchangeController.exchange.value!
                                          .meetingPoint.location),
                                ),
                              ],
                            ),
                            customCard(
                              "รายละเอียดการชำระเงิน",
                              [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'ราคาส่วนต่าง',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${exchangeController.exchange.value?.paymentDetails?.priceDiff == null ? '0.00' : exchangeController.exchange.value?.paymentDetails?.priceDiff} บาท',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'ประกันค่าเสียเวลา',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${exchangeController.exchange.value?.paymentDetails?.depositAmount} บาท',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'ค่าธรรมเนียมการโอน 3.65%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${exchangeController.exchange.value?.paymentDetails?.omiseFee} บาท',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'ภาษีมูลค่าเพิ่ม 7%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${exchangeController.exchange.value?.paymentDetails?.vat} บาท',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10), // ระยะห่างจากเนื้อหา
                                  height: 1, // ความหนาของเส้น
                                  width: double.infinity, // ความกว้างของเส้น
                                  color: Colors.grey.shade400, // สีของเส้น
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'ยอดรวม',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '${exchangeController.exchange.value?.paymentDetails?.totalAmount} บาท',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            customCard("โพสต์และข้อเสนอ", [
                              Obx(() {
                                final post =
                                    productDetailController.postDetail.value;
                                final offer =
                                    productDetailController.offerDetail.value;

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
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ReportIssuePage(
                                              exchangeId: widget.exchangeID,
                                              postID: exchangeController
                                                  .exchange.value!.postId,
                                              offerID: exchangeController
                                                  .exchange.value!.offerId,
                                            )));
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: Colors.grey.shade700,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "รายงานปัญหาการแลกเปลี่ยนนี้",
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 20,
                                        color: Colors.grey.shade700,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (widget.status)
                              Obx(() {
                                if (exchangeController.exchange.value != null &&
                                    exchangeController
                                            .exchange.value!.isReview! ==
                                        false) {
                                  return Column(
                                    children: [
                                      UserReviewSection(
                                        ratingController: ratingController,
                                        reviewController: reviewController,
                                        mediaList: mediaList,
                                        onMediaChanged: (updatedMediaList) {
                                          setState(() {
                                            mediaList = updatedMediaList;
                                          });
                                        },
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          if (ratingController.selectedRating ==
                                              0) {
                                            Get.snackbar('แจ้งเตือน',
                                                'กรุณากดให้คะแนนผู้ใช้ท่านนี้ก่อนส่งความคิดเห็น');
                                          } else if (mediaList.length == 0) {
                                            Get.snackbar('แจ้งเตือน',
                                                'กรุณาแนบอย่างน้องหนึ่งรูปหรือหนึ่งคลิปวีดีโอ');
                                          } else {
                                            await exchangeController
                                                .sendUserReview(
                                                    widget.exchangeID,
                                                    ratingController
                                                        .selectedRating.value,
                                                    reviewController.text,
                                                    mediaList);
                                            await exchangeController
                                                .fetchExchangeDetails(
                                                    widget.exchangeID);
                                          }
                                        },
                                        icon: Icon(
                                          Icons.send,
                                          color: Colors.white,
                                        ),
                                        label: Text("ส่งความคิดเห็น",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        // icon: Icon(Icons.arrow_forward, color: Colors.white),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Constants
                                              .primaryColor, // สีพื้นหลัง
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                15), // ขอบมน 15
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 5), // ปรับขนาดปุ่ม
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return SizedBox();
                                }
                              }),
                          ],
                        ),
                      )
                    ]),
              ))
            ],
          ),
        ));
  }

  String formatDateTime(String rawDateTime) {
    try {
      DateTime dateTime = DateTime.parse(rawDateTime).toLocal();
      return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
    } catch (e) {
      return '-'; // หรือส่ง error message
    }
  }

  Widget statusCard({required bool isSuccess}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              "สถานะการแลกเปลี่ยน: ",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Text(
              isSuccess ? "สำเร็จ" : "ไม่สำเร็จ",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSuccess ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoRow(IconData? icon, String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(icon, size: 20, color: Colors.grey.shade600),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    )),
                SizedBox(
                  height: 6,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  void limitTextLength() {
    String text = reviewController.text;
    if (text.runes.length > maxCharacters) {
      // ตัดข้อความให้ไม่เกิน 200 ตัวอักษร
      reviewController.text =
          String.fromCharCodes(text.runes.take(maxCharacters));
      reviewController.selection = TextSelection.fromPosition(
        TextPosition(offset: reviewController.text.length),
      );
    }
    setState(() {}); // อัปเดตตัวนับ
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
