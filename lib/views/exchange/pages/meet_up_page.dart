import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/chat/controllers/chat_room_controller.dart';
import 'package:mbea_ssi3_front/views/exchange/controllers/exchange_controller.dart';
import 'package:mbea_ssi3_front/views/exchange/controllers/meet_up_exchange_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mbea_ssi3_front/views/exchange/pages/exchange_product_detail_page.dart';
import 'package:mbea_ssi3_front/views/mainScreen/pages/layout_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mbea_ssi3_front/views/report/pages/report_issue_page.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

enum Payer { post, offer }

class MeetUpPage extends StatefulWidget {
  final int currentStep;
  final String? exchangeID;
  final String offerID;
  final String postID;
  final Payer user;
  final Payer? payer;
  final int? priceDifference;
  const MeetUpPage(
      {super.key,
      this.exchangeID,
      required this.currentStep,
      required this.postID,
      required this.offerID,
      this.priceDifference,
      required this.user,
      this.payer});

  @override
  State<MeetUpPage> createState() => _MeetUpPageState();
}

class RatingController extends GetxController {
  var selectedRating = 0.obs;

  void setRating(int rating) {
    selectedRating.value = rating;
  }
}

class _MeetUpPageState extends State<MeetUpPage> {
  final RatingController ratingController = Get.put(RatingController());
  final ChatRoomController chatRoomController = Get.put(ChatRoomController());
  final ExchangeController exchangeController = Get.put(ExchangeController());
  final MeetUpExchangeController meetUpExchangeController =
      Get.put(MeetUpExchangeController());
  static const String googleApiKey = "AIzaSyDEYGoa1lbuULdaGiwh80EBtXUsUxWCP-U";
  GoogleMapController? mapController;
  String? exchangeID;
  LatLng? selectedLocation;
  String? placeID;
  String? placeName;
  String? placeAddress;
  int? _currentStage;
  DateTime? selectedDate;
  TimeOfDay? meetTime;
  TextEditingController reviewController = TextEditingController();
  int maxCharacters = 200; // จำกัดจำนวนตัวอักษร

  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> mediaList = [];
  VideoPlayerController? _videoController;
  int currentIndex = 0;

  Future<void> pickMedia() async {
    final XFile? pickedFile =
        await _picker.pickMedia(); // รองรับทั้งรูปและวิดีโอ
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      if (pickedFile.path.endsWith('.mp4')) {
        // ถ้าเป็นวิดีโอ ให้สร้าง Thumbnail
        final String? thumbPath = await VideoThumbnail.thumbnailFile(
          video: pickedFile.path,
          imageFormat: ImageFormat.PNG,
          maxWidth: 200,
          quality: 75,
        );
        setState(() {
          mediaList.add({
            'type': 'video',
            'file': file,
            'thumbnail': thumbPath != null ? File(thumbPath) : null,
          });
        });
      } else {
        // ถ้าเป็นรูปภาพ
        setState(() {
          mediaList.add({'type': 'image', 'file': file});
        });
      }
    }
  }

  void playVideo(File videoFile) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        setState(() {});
        _videoController?.play();
      });
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

  DateTime? combineDateAndTime(DateTime? selectedDate, TimeOfDay? meetTime) {
    if (selectedDate == null || meetTime == null) return null;

    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      meetTime.hour,
      meetTime.minute,
    );
  }

  String formatDateTimeWithOffset(DateTime dateTime) {
    final offset = DateTime.now().timeZoneOffset;
    final formattedOffset =
        "${offset.isNegative ? '-' : '+'}${offset.inHours.toString().padLeft(2, '0')}:${(offset.inMinutes % 60).toString().padLeft(2, '0')}";

    return DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(dateTime) +
        formattedOffset;
  }

  DateTime parseDateTimeWithOffset(String dateTimeString) {
    // กรณีที่เป็น UTC (ลงท้ายด้วย 'Z')
    if (dateTimeString.endsWith('Z')) {
      return DateTime.parse(dateTimeString);
    }

    // กรณีที่เป็น offset (+/-hh:mm)
    final regex = RegExp(r"(.+)([+-]\d{2}:\d{2})$");
    final match = regex.firstMatch(dateTimeString);

    if (match == null) {
      throw FormatException("Invalid date format", dateTimeString);
    }

    final dateTimePart = match.group(1)!;
    final offsetPart = match.group(2)!;

    // แปลงวันที่เป็น DateTime
    final dateTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss").parseUtc(dateTimePart);

    // แปลง offset เป็น Duration
    final offsetSign = offsetPart.startsWith('-') ? -1 : 1;
    final offsetParts = offsetPart.substring(1).split(':');
    final offsetDuration = Duration(
      hours: int.parse(offsetParts[0]) * offsetSign,
      minutes: int.parse(offsetParts[1]) * offsetSign,
    );

    // ปรับเวลาให้เป็น UTC
    return dateTime.subtract(offsetDuration);
  }

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm น.').format(dateTime);
  }

  Future<bool> isWithin200Meters(LatLng? selectedLocation) async {
    if (selectedLocation == null) return false;

    // ดึงตำแหน่งปัจจุบัน
    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // คำนวณระยะห่าง (เป็นเมตร)
    double distanceInMeters = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      selectedLocation.latitude,
      selectedLocation.longitude,
    );

    // ตรวจสอบระยะห่าง
    return distanceInMeters <= 200;
  }

  bool isFuture(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.isAfter(now);
  }

  bool isPast(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.isBefore(now);
  }

  Future<void> fetchExchangeDetails(String exchangeID) async {
    await exchangeController.fetchExchangeDetails(exchangeID);
    exchangeID = exchangeController.exchange.value!.id;
    setupDateTimeAndLocation(
        exchangeController.exchange.value!.meetingPoint.latitude,
        exchangeController.exchange.value!.meetingPoint.longitude,
        exchangeController.exchange.value!.meetingPoint.scheduledTime);
  }

  @override
  void initState() {
    super.initState();
    ratingController.selectedRating(0);
    _currentStage = widget.currentStep;
    exchangeID = widget.exchangeID;
    if (widget.exchangeID != null) {
      // exchangeController.fetchExchangeDetails(widget.exchangeID!);
      setupDateTimeAndLocation(
          exchangeController.exchange.value!.meetingPoint.latitude,
          exchangeController.exchange.value!.meetingPoint.longitude,
          exchangeController.exchange.value!.meetingPoint.scheduledTime);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> setupDateTimeAndLocation(
      double lat, double lng, String dateTime) async {
    selectedLocation = LatLng(lat, lng);
    getPlaceIdFromLatLng(lat, lng);

    // แปลง String dateTime เป็น DateTime
    DateTime parsedDateTime =
        DateTime.parse(dateTime).toUtc().add(Duration(hours: 7));

    setState(() {
      selectedDate = DateTime(
          parsedDateTime.year, parsedDateTime.month, parsedDateTime.day);
      meetTime =
          TimeOfDay(hour: parsedDateTime.hour, minute: parsedDateTime.minute);
    });
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: meetTime ?? TimeOfDay(hour: 12, minute: 0),
    );

    if (pickedTime != null) {
      setState(() {
        meetTime = pickedTime;
      });
    }
  }

  void _handleSearch() async {
    final Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: googleApiKey,
      mode: Mode.overlay, // ใช้โหมด Overlay
      language: "th",
      components: [Component(Component.country, "th")], // จำกัดผลลัพธ์ในไทย
    );

    if (p != null) {
      _getPlaceDetails(p.placeId!);
    }
  }

  void _getPlaceDetails(String placeId) async {
    final places = GoogleMapsPlaces(
      apiKey: googleApiKey,
      apiHeaders: await GoogleApiHeaders().getHeaders(),
    );

    final PlacesDetailsResponse detail = await places.getDetailsByPlaceId(
        placeId,
        language: "th"); // เพิ่มพารามิเตอร์ภาษาไทย

    setState(() {
      selectedLocation = LatLng(
        detail.result.geometry!.location.lat,
        detail.result.geometry!.location.lng,
      );
      placeName = detail.result.name; // ชื่อสถานที่ (ภาษาไทย)
      placeAddress = detail.result.formattedAddress; // ที่อยู่ (ภาษาไทย)
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLng(selectedLocation!),
    );
  }

  Future<void> getPlaceIdFromLatLng(double lat, double lng) async {
    final places = GoogleMapsPlaces(
      apiKey: googleApiKey,
    );

    final response = await places.searchByText(
      '$lat, $lng', // ค้นหาสถานที่จากพิกัด
    );

    if (response.status == "OK" && response.results.isNotEmpty) {
      final place = response.results.first;
      print("Place ID: ${place.placeId}");
      _getPlaceDetails(place.placeId);
    } else {
      Get.snackbar('แจ้งเตือน', 'ไม่พบข้อมูลของสถานที่นี้');
      print("ไม่พบ Place ID");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(125, 242, 242, 242),
        surfaceTintColor: Color.fromARGB(125, 242, 242, 242),
        elevation: 0,
        toolbarHeight: 60,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
            if (widget.currentStep == 1 && widget.user == Payer.post) {
              Navigator.pop(context);
            }
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text(
              "นัดรับ ${widget.user}",
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
            Spacer(),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.assignment_outlined, color: Colors.black),
            onPressed: () {
              if (exchangeID != null) {
                fetchExchangeDetails(exchangeID!);
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExchangeProductDetailPage(
                    offerID: widget.offerID,
                    postID: widget.postID,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(
                  bottom: 25, right: 30, left: 30, top: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                color: Color.fromARGB(125, 242, 242, 242),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: _buildStepIndicator(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (exchangeID != null) {
                    var result = await exchangeController
                        .fetchExchangeDetails(exchangeID!);
                    // if (result == false) {
                    //   Navigator.pop(context);
                    // }

                    if (exchangeController.exchange.value?.status ==
                        'cancelled') {
                      Get.snackbar('แจ้งเตือน',
                          'วันเวลาและสถานที่นัดหมายที่คุณเสนอถูกยกเลิก');
                      Navigator.pop(context);
                      if (widget.currentStep == 1 &&
                          widget.user == Payer.post) {
                        Navigator.pop(context);
                      }
                    }
                  }
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
                          if (_currentStage == 4 || _currentStage == 3)
                            SizedBox(height: 15),
                          if (_currentStage == 4 || _currentStage == 3)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 35,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Constants.secondaryColor, // สีแดง
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ReportIssuePage(
                                                    exchangeId: exchangeID!,
                                                    postID: widget.postID!,
                                                    offerID: widget.offerID!,
                                                  )));
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          "รายงานปัญหา",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                              ],
                            ),
                          if (_currentStage == 1 || _currentStage == 3)
                            Column(
                              children: [
                                SizedBox(height: 10),
                                chooseDateTime(),
                                SizedBox(height: 15),
                                if (_currentStage == 3)
                                  Column(
                                    children: [
                                      Center(
                                        child: Text(
                                          "กรุณาเช็คอินตามวันเวลาและสถานที่นัดหมาย",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Constants.secondaryColor,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          "ภายในระยะ 100 เมตร หากไม่เช็คอิน อาจถูกปรับ",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Constants.secondaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                SizedBox(height: 15),
                                chooseLocation(),
                                if (_currentStage == 1 &&
                                    widget.user == Payer.offer)
                                  Padding(
                                    padding: const EdgeInsets.all(25),
                                    child:
                                        buildConfirmCancelAppointmentButtons(),
                                  ),
                                if (_currentStage == 1 &&
                                    widget.user == Payer.post)
                                  Padding(
                                    padding: const EdgeInsets.all(25),
                                    child:
                                        buildSubmitDateTimeAndLocationButtons(),
                                  ),
                              ],
                            ),
                          if (_currentStage == 2)
                            Obx(() {
                              return Column(
                                children: [
                                  SizedBox(height: 10),
                                  if ((exchangeController
                                              .exchange.value?.exchangeStage ??
                                          0) <=
                                      2)
                                    statusCard(true),
                                  if ((exchangeController
                                              .exchange.value?.exchangeStage ??
                                          0) >
                                      2)
                                    statusCard(false),
                                  if ((exchangeController
                                              .exchange.value?.exchangeStage ??
                                          0) >
                                      2)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _currentStage =
                                                (_currentStage! + 1);
                                          });
                                        },
                                        label: Text("ขั้นตอนถัดไป",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        icon: Icon(Icons.arrow_forward,
                                            color: Colors.white),
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
                                    )
                                ],
                              );
                            }),
                          if (_currentStage == 3) userCheckInCard(),
                          if (_currentStage == 4)
                            Column(
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                finishCard(),
                                userRating(),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      await exchangeController
                                          .fetchExchangeDetails(exchangeID!);
                                      if (exchangeController
                                              .exchange.value?.status ==
                                          'completed') {
                                        if (ratingController
                                                .selectedRating.value !=
                                            0) {
                                          await exchangeController
                                              .sendUserReview(
                                                  exchangeID!,
                                                  ratingController
                                                      .selectedRating.value,
                                                  reviewController.text,
                                                  mediaList);
                                        }

                                        await chatRoomController
                                            .fetchChatRooms();
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                      } else {
                                        await exchangeController
                                            .updateExchangeStatus(
                                                exchangeID!, 'completed');
                                        if (ratingController
                                                .selectedRating.value !=
                                            0) {
                                          await exchangeController
                                              .sendUserReview(
                                                  exchangeID!,
                                                  ratingController
                                                      .selectedRating.value,
                                                  reviewController.text,
                                                  mediaList);
                                        }
                                        await chatRoomController
                                            .fetchChatRooms();
                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst);
                                      }

                                      // Navigator.pop(context);
                                      // Navigator.pop(context);
                                      // if (widget.currentStep == 1) {
                                      //   Navigator.pop(context);
                                      // }
                                    },
                                    label: Text("เสร็จสิ้นการแลกเปลี่ยน",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    // icon: Icon(Icons.arrow_forward, color: Colors.white),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Constants.primaryColor, // สีพื้นหลัง
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            15), // ขอบมน 15
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 5), // ปรับขนาดปุ่ม
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          // if (widget.priceDifference != null)
                          //   Text(widget.priceDifference.toString()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCheckInCancelButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ปุ่มยกเลิกนัดหมาย
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Constants.secondaryColor, // สีแดง
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              // TODO: ใส่ฟังก์ชันยกเลิกนัดหมาย
              var result = await exchangeController.updateExchangeStatus(
                  exchangeID!, 'cancelled');
              await exchangeController.fetchExchangeDetails(exchangeID!);
              if (result) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
              print("ยกเลิกนัดหมาย");
            },
            child: const Text(
              "ยกเลิกนัดหมาย",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 15), // ระยะห่างระหว่างปุ่ม
        // ปุ่มเช็คอิน
        Obx(() => Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Constants.primaryColor, // สีเขียว
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: widget.user == Payer.post &&
                        exchangeController.exchange.value?.meetingPoint
                                .postUserCheckinTime !=
                            null
                    ? null
                    : widget.user == Payer.offer &&
                            exchangeController.exchange.value?.meetingPoint
                                    .offerUserCheckinTime !=
                                null
                        ? null
                        : () async {
                            // await exchangeController.updateExchangeStatus(
                            //     exchangeID!, 'checkin');
                            // await exchangeController
                            //     .fetchExchangeDetails(exchangeID!);

                            // print("เช็คอินสำเร็จ");
                            await Geolocator.requestPermission();
                            var checkDistance =
                                await isWithin200Meters(selectedLocation);

                            if (exchangeController.exchange.value?.meetingPoint
                                        .scheduledTime !=
                                    null &&
                                isPast(parseDateTimeWithOffset(
                                    exchangeController.exchange.value!
                                        .meetingPoint.scheduledTime))) {
                              if (checkDistance) {
                                await exchangeController.updateExchangeStatus(
                                    exchangeID!, 'checkin');
                                await exchangeController
                                    .fetchExchangeDetails(exchangeID!);
                              } else {
                                Get.snackbar('แจ้งเตือน',
                                    'คุณไม่ได้อยู่ในระยะเช็คอินที่กำหนด');
                              }
                            } else {
                              Get.snackbar('แจ้งเตือน',
                                  'คุณไม่สามารถเช็คอินได้ก่อนเวลานัดหมาย');
                            }
                          },
                child: const Text(
                  "เช็คอิน",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            )),
      ],
    );
  }

  Widget buildConfirmCancelAppointmentButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ปุ่มยกเลิกนัดหมาย
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Constants.secondaryColor, // สีแดง
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: exchangeController.exchange.value != null &&
                    exchangeController.exchange.value!.exchangeStage <= 2
                ? () {
                    leaveExchange();
                    print("ปฏิเสธ");
                  }
                : null,
            child: const Text(
              "ปฏิเสธ",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 15), // ระยะห่างระหว่างปุ่ม
        // ปุ่มเช็คอิน
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Constants.primaryColor, // สีเขียว
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: exchangeController.exchange.value != null &&
                    exchangeController.exchange.value!.exchangeStage <= 2
                ? () async {
                    await exchangeController.updateExchangeStatus(
                        exchangeID!, 'waiting_payment');
                    await exchangeController.fetchExchangeDetails(exchangeID!);
                    setState(() {
                      _currentStage = 2;
                    });
                  }
                : null,
            child: const Text(
              "ยืนยัน",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void leaveExchange() {
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
                              'ปฏิเสธนัดหมาย',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                          ),
                          Text(
                            'คุณต้องการปฏิเสธ',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.normal),
                          ),
                          Text(
                            'วันเวลา และสถานที่นัดหมายนี้หรือไม่?',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.normal),
                          ),
                          const SizedBox(height: 30),
                          _buildCancelledExchange(),
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

  Widget _buildCancelledExchange() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 100,
        child: ElevatedButton(
          onPressed: () async {
            await exchangeController.updateExchangeStatus(
                exchangeID!, 'cancelled');
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

  Widget buildSubmitDateTimeAndLocationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ระยะห่างระหว่างปุ่ม
        // ปุ่มเช็คอิน
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Constants.primaryColor, // สีเขียว
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: (exchangeController.exchange.value?.exchangeStage ??
                        0) >=
                    2
                ? null
                : () async {
                    // TODO: ใส่ฟังก์ชันเช็คอิน

                    if (selectedLocation != null &&
                        selectedDate != null &&
                        meetTime != null &&
                        placeName != null) {
                      if (isFuture(
                          combineDateAndTime(selectedDate, meetTime)!)) {
                        var result =
                            await meetUpExchangeController.createExchange(
                                postId: widget.postID!,
                                offerId: widget.offerID!,
                                exchangeType: 'meeting',
                                postPriceDiff: widget.payer == Payer.post
                                    ? widget.priceDifference?.toDouble()
                                    : null,
                                offerPriceDiff: widget.payer == Payer.offer
                                    ? widget.priceDifference?.toDouble()
                                    : null,
                                latitude: double.parse(selectedLocation!
                                    .latitude
                                    .toStringAsFixed(6)),
                                longitude: double.parse(selectedLocation!
                                    .longitude
                                    .toStringAsFixed(6)),
                                location: placeName!,
                                scheduledTime: formatDateTimeWithOffset(
                                    combineDateAndTime(
                                        selectedDate, meetTime)!));
                        if (result != null) {
                          await exchangeController.fetchExchangeDetails(result);
                          setState(() {
                            _currentStage = 2;
                            exchangeID = exchangeController.exchange.value?.id;
                          });
                        }
                        print("เสนอวันเวลาและสถานที่นี้");
                      } else {
                        Get.snackbar(
                            'แจ้งเตือน', 'วันเวลาในการนัดหมายต้องเป็นอนาคต');
                      }
                    } else {
                      Get.snackbar('แจ้งเตือน',
                          'กรุณากรอกวันเวลา และเลือกสถานที่นัดหมายให้ครบถ้วน');
                    }
                  },
            child: const Text(
              "เสนอวันเวลาและสถานที่นี้",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget chooseDateTime() {
    String formattedDate = selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(selectedDate!)
        : "เลือกวันที่";

    String formattedTime =
        meetTime != null ? formatTimeOfDay(meetTime!) : "เลือกเวลา";

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _currentStage == 1
                ? widget.user == Payer.post
                    ? "เลือกวันเวลา"
                    : "วันเวลานัดหมาย"
                : "กำหนดการนัดหมาย",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap:
                      (exchangeController.exchange.value?.exchangeStage ?? 0) >=
                              2
                          ? null
                          : _pickDate,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      formattedDate,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap:
                      (exchangeController.exchange.value?.exchangeStage ?? 0) >=
                              2
                          ? null
                          : _pickTime,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      formattedTime,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget chooseLocation() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _currentStage == 1
                ? widget.user == Payer.post
                    ? "เลือกสถานที่"
                    : "สถานที่นัดหมาย"
                : "สถานที่นัดหมาย",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 10),
          if (_currentStage == 1 && widget.user == Payer.post)
            TextField(
              style: TextStyle(
                fontSize: 14, // ขนาดตัวอักษร
                fontWeight: FontWeight.w500, // สีตัวอักษร
              ),
              readOnly: true,
              onTap:
                  (exchangeController.exchange.value?.exchangeStage ?? 0) >= 2
                      ? null
                      : _handleSearch,
              decoration: InputDecoration(
                hintText: 'ค้นหา',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 25,
                  color: Colors.grey,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 350,
              height: 200, // กำหนดความสูงให้ Google Map
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: selectedLocation ?? LatLng(13.7563, 100.5018),
                  zoom: 14,
                ),
                onMapCreated: (GoogleMapController controller) {
                  setState(() {
                    mapController = controller;
                  });
                },
                markers: selectedLocation != null
                    ? {
                        Marker(
                          markerId: MarkerId("selected"),
                          position: selectedLocation!,
                          infoWindow: InfoWindow(
                              title: placeName, snippet: placeAddress),
                        ),
                      }
                    : {},
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          if (placeName != null && placeAddress != null)
            Card(
              color: Colors.white,
              elevation: 3,
              child: ListTile(
                leading: Icon(Icons.location_on, color: Colors.red),
                title: Text(
                    exchangeController.exchange.value != null
                        ? exchangeController
                            .exchange.value!.meetingPoint.location
                        : placeName!,
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                subtitle: Text(placeAddress!,
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ),
          SizedBox(
            height: 15,
          ),
          if (_currentStage == 3) buildCheckInCancelButtons(),
        ],
      ),
    );
  }

  Widget statusCard(bool status) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'ยืนยันวัน เวลา และสถานที่',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 15),
          if (status)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  size: 33,
                  Icons.access_time,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.user == Payer.offer
                      ? 'อีกฝ่ายกำลังรอคุณยืนยันวัน เวลา และสถานที่'
                      : 'กำลังรออีกฝ่ายยืนยันวัน เวลา และสถานที่',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          if (!status)
            Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/check_icon.svg',
                      width: 60,
                      height: 60,
                    ),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  'นัดวัน เวลา และสถานที่สำเร็จ',
                  style: TextStyle(
                      fontSize: 16,
                      color: Constants.primaryColor,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  'ทั้งสองฝ่ายยืนยัน วัน เวลา',
                  style: TextStyle(
                      fontSize: 12,
                      color: Constants.primaryColor,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  'และสถานที่เรียบร้อยแล้ว',
                  style: TextStyle(
                      fontSize: 12,
                      color: Constants.primaryColor,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget finishCard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'การแลกเปลี่ยนเสร็จสิ้นแล้ว',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 15),
              Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/check_icon.svg',
                        color: Color(0xFF5BD207),
                        width: 60,
                        height: 60,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    'การแลกเปลี่ยนเสร็จสิ้น ขอบคุณที่ใช้บริการ',
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF5BD207),
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    'กรุณาตรวจสอบสินค้า',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5BD207),
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'ว่าคุณได้รับสินค้าถูกต้องตามข้อตกลง',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5BD207),
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget userCheckInCard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // เจ้าของโพสต์
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(
                            exchangeController.exchange.value!.postImageUrl),
                      ),
                      const SizedBox(width: 10),
                      Text(exchangeController.exchange.value!.postUsername,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            size: 25,
                            exchangeController.exchange.value?.meetingPoint
                                        .postUserCheckinTime !=
                                    null
                                ? Icons.check_circle_outline_outlined
                                : Icons.cancel_outlined,
                            color: exchangeController.exchange.value
                                        ?.meetingPoint.postUserCheckinTime !=
                                    null
                                ? Color(0xFF5BD207)
                                : Color(0xFFFF0000),
                          ),
                          SizedBox(
                              width: exchangeController.exchange.value
                                          ?.meetingPoint.postUserCheckinTime !=
                                      null
                                  ? 13
                                  : 8),
                          Text(
                            exchangeController.exchange.value?.meetingPoint
                                        .postUserCheckinTime !=
                                    null
                                ? 'เช็คอินแล้ว'
                                : 'ยังไม่เช็คอิน',
                            style: TextStyle(
                                fontSize: 14,
                                color: exchangeController
                                            .exchange
                                            .value
                                            ?.meetingPoint
                                            .postUserCheckinTime !=
                                        null
                                    ? Color(0xFF5BD207)
                                    : Color(0xFFFF0000),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              // เจ้าของข้อเสนอ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(
                            exchangeController.exchange.value!.offerImageUrl),
                      ),
                      const SizedBox(width: 10),
                      Text(exchangeController.exchange.value!.offerUsername,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            size: 25,
                            exchangeController.exchange.value?.meetingPoint
                                        .offerUserCheckinTime !=
                                    null
                                ? Icons.check_circle_outline_outlined
                                : Icons.cancel_outlined,
                            color: exchangeController.exchange.value
                                        ?.meetingPoint.offerUserCheckinTime !=
                                    null
                                ? Color(0xFF5BD207)
                                : Color(0xFFFF0000),
                          ),
                          SizedBox(
                              width: exchangeController.exchange.value
                                          ?.meetingPoint.offerUserCheckinTime !=
                                      null
                                  ? 13
                                  : 8),
                          Text(
                            exchangeController.exchange.value?.meetingPoint
                                        .offerUserCheckinTime !=
                                    null
                                ? 'เช็คอินแล้ว'
                                : 'ยังไม่เช็คอิน',
                            style: TextStyle(
                                fontSize: 14,
                                color: exchangeController
                                            .exchange
                                            .value
                                            ?.meetingPoint
                                            .offerUserCheckinTime !=
                                        null
                                    ? Color(0xFF5BD207)
                                    : Color(0xFFFF0000),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
                ],
              ),
            ],
          ),
        ),
        Obx(() => Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: ElevatedButton.icon(
                onPressed: exchangeController.exchange.value?.meetingPoint
                                .postUserCheckinTime !=
                            null &&
                        exchangeController.exchange.value?.meetingPoint
                                .offerUserCheckinTime !=
                            null
                    ? () {
                        setState(() {
                          _currentStage = (_currentStage! + 1);
                        });
                      }
                    : null,
                label: Text("ขั้นตอนถัดไป",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                icon: Icon(Icons.arrow_forward, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor, // สีพื้นหลัง
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // ขอบมน 15
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 5), // ปรับขนาดปุ่ม
                ),
              ),
            )),
      ],
    );
  }

  Widget userRating() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // เจ้าของโพสต์
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(widget.user == Payer.post
                            ? exchangeController.exchange.value!.postImageUrl
                            : exchangeController.exchange.value!.offerImageUrl),
                      ),
                      const SizedBox(width: 10),
                      Text(
                          widget.user == Payer.post
                              ? exchangeController.exchange.value!.postUsername
                              : exchangeController
                                  .exchange.value!.offerUsername,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          int starIndex = index + 1;
                          return GestureDetector(
                            onTap: () => ratingController.setRating(starIndex),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ratingController.selectedRating.value ==
                                        starIndex
                                    ? Colors.grey.shade300
                                    : Colors.transparent,
                              ),
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.star,
                                size: 20,
                                color: ratingController.selectedRating.value >=
                                        starIndex
                                    ? Constants.primaryColor
                                    : Colors.grey,
                              ),
                            ),
                          );
                        }),
                      )),
                ],
              ),
              SizedBox(height: 16),

              TextField(
                controller: reviewController,
                maxLines: 3,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: "เขียนรีวิวผู้ใช้งานท่านนี้...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Colors.grey.shade300), // กำหนดสี border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Colors.grey.shade300), // border เมื่อไม่ได้โฟกัส
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 2), // border เมื่อโฟกัส
                  ),
                  contentPadding: EdgeInsets.all(12),
                ),
                onChanged: (text) {
                  limitTextLength(); // ตรวจสอบและตัดข้อความ
                },
              ),
              SizedBox(height: 5),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${reviewController.text.runes.length}/$maxCharacters",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_videoController != null &&
                      _videoController!.value.isInitialized)
                    AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                  if (mediaList.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ReorderableListView(
                        scrollDirection: Axis.horizontal,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final item = mediaList.removeAt(oldIndex);
                            mediaList.insert(newIndex, item);
                          });
                        },
                        children: List.generate(mediaList.length, (index) {
                          var media = mediaList[index];
                          File? file = media['file'];

                          return Stack(
                            key: ValueKey(media),
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      8), // เพิ่มมุมมนให้รูปภาพและวิดีโอ
                                  child: file != null && file.existsSync()
                                      ? media['type'] == 'image'
                                          ? Image.file(file, fit: BoxFit.cover)
                                          : _buildVideoPreview(
                                              file) // ใช้ฟังก์ชันพรีวิววิดีโอ
                                      : Center(
                                          child: Text("ไฟล์ไม่พบ",
                                              style: TextStyle(fontSize: 12))),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      mediaList.removeAt(index);
                                    });
                                  },
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.close,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Constants.primaryColor, // สีพื้นหลังฟ้า
                        shape: BoxShape.circle, // ทำให้เป็นวงกลม
                      ),
                      child: IconButton(
                        onPressed: pickMedia,
                        tooltip: "แนบไฟล์รูปภาพหรือวิดีโอ",
                        icon: Transform.rotate(
                          angle: pi / 4, // หมุน 45 องศา
                          child: Icon(Icons.attach_file, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPreview(File videoFile) {
    return FutureBuilder<Uint8List?>(
      future: VideoThumbnail.thumbnailData(
        video: videoFile.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 1500, // ลดความสูงของ thumbnail
        quality: 100,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return Stack(
            alignment: Alignment.bottomRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8), // เพิ่มมุมมนให้กับรูป
                child: Image.memory(
                  snapshot.data!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              FutureBuilder<Duration>(
                future: _getVideoDuration(videoFile),
                builder: (context, durationSnapshot) {
                  if (durationSnapshot.connectionState ==
                          ConnectionState.done &&
                      durationSnapshot.data != null) {
                    return Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(durationSnapshot.data!),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    );
                  } else {
                    return SizedBox(); // หากยังโหลดเวลาไม่เสร็จ จะไม่แสดงอะไร
                  }
                },
              ),
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<Duration> _getVideoDuration(File videoFile) async {
    final controller = VideoPlayerController.file(videoFile);
    await controller.initialize();
    final duration = controller.value.duration;
    await controller.dispose(); // ปล่อยหน่วยความจำหลังใช้งาน
    return duration;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        int stepNumber = index + 1;
        bool isActive = stepNumber == _currentStage;

        return Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 3,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (exchangeController.exchange.value != null) {
                    ratingController.setRating(0);
                    if (stepNumber < 3) {
                      setState(() {
                        _currentStage = stepNumber;
                      });
                    } else {
                      if (exchangeController.exchange.value?.status ==
                          'confirmed') {
                        if (stepNumber == 4) {
                          if (exchangeController.exchange.value?.meetingPoint
                                      .offerUserCheckinTime !=
                                  null &&
                              exchangeController.exchange.value?.meetingPoint
                                      .postUserCheckinTime !=
                                  null) {
                            setState(() {
                              _currentStage = stepNumber;
                            });
                          }
                        } else {
                          setState(() {
                            _currentStage = stepNumber;
                          });
                        }
                      }
                    }
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Colors.deepOrangeAccent
                        : Colors.grey.shade800,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$stepNumber",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
