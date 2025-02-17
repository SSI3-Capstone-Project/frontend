import 'dart:async';
import 'dart:ffi';
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
import 'package:mbea_ssi3_front/views/exchange/controllers/exchange_controller.dart';
import 'package:mbea_ssi3_front/views/exchange/controllers/meet_up_exchange_controller.dart';
import 'package:geolocator/geolocator.dart';

enum Payer { post, offer }

class MeetUpPage extends StatefulWidget {
  final int currentStep;
  final String? exchangeID;
  final String? offerID;
  final String? postID;
  final Payer user;
  final Payer? payer;
  final int? priceDifference;
  const MeetUpPage(
      {super.key,
      this.exchangeID,
      required this.currentStep,
      this.postID,
      this.offerID,
      this.priceDifference,
      required this.user,
      this.payer});

  @override
  State<MeetUpPage> createState() => _MeetUpPageState();
}

class _MeetUpPageState extends State<MeetUpPage> {
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

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm น.').format(dateTime);
  }

  Future<bool> isWithin500Meters(LatLng? selectedLocation) async {
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
    return distanceInMeters <= 500;
  }

  bool isFutureAtLeastOneDay(DateTime dateTime) {
    final now = DateTime.now();
    final tomorrow = now.add(Duration(days: 1));

    return dateTime.isAfter(tomorrow);
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
                          if (_currentStage == 1 || _currentStage == 3)
                            Column(
                              children: [
                                SizedBox(height: 25),
                                chooseDateTime(),
                                SizedBox(height: 15),
                                if (_currentStage == 3)
                                  Center(
                                    child: Text(
                                      "กรุณาเช็คอินตามวันเวลาและสถานที่\nนัดหมาย หากไม่เช็คอิน อาจถูกปรับ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Constants.secondaryColor,
                                      ),
                                    ),
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
                                  SizedBox(height: 25),
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
                                ],
                              );
                            }),
                          if (_currentStage == 3) userCheckInCard(),
                          if (_currentStage == 4)
                            Column(
                              children: [
                                SizedBox(
                                  height: 25,
                                ),
                                finishCard()
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
              await exchangeController.updateExchangeStatus(
                  exchangeID!, 'cancelled');
              await exchangeController.fetchExchangeDetails(exchangeID!);
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
                            await exchangeController.updateExchangeStatus(
                                exchangeID!, 'checkin');
                            await exchangeController
                                .fetchExchangeDetails(exchangeID!);

                            // print("เช็คอินสำเร็จ");
                            // await Geolocator.requestPermission();
                            // var checkDistance =
                            //     await isWithin500Meters(selectedLocation);
                            // if (checkDistance) {
                            //   Get.snackbar('ได้', 'เช็คอินได้');
                            // } else {
                            //   Get.snackbar('ไม่ได้', 'เช็คอินไม่ได้');
                            // }
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
                        exchangeID!, 'confirmed');
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
                              'ยืนยันการปฏิเสธ',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                          ),
                          Text(
                            'คุณต้องการปฏิเสธวันเวลา และสถานที่นัดหมายนี้หรือไม่?',
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
            onPressed:
                (exchangeController.exchange.value?.exchangeStage ?? 0) >= 2
                    ? null
                    : () async {
                        // TODO: ใส่ฟังก์ชันเช็คอิน

                        if (selectedLocation != null &&
                            selectedDate != null &&
                            meetTime != null &&
                            placeName != null) {
                          if (isFutureAtLeastOneDay(
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
                                    latitude: double.parse(selectedLocation!.latitude
                                        .toStringAsFixed(6)),
                                    longitude: double.parse(selectedLocation!
                                        .longitude
                                        .toStringAsFixed(6)),
                                    location: placeName!,
                                    scheduledTime: formatDateTimeWithOffset(
                                        combineDateAndTime(
                                            selectedDate, meetTime)!));
                            if (result != null) {
                              await exchangeController
                                  .fetchExchangeDetails(result);
                              setState(() {
                                _currentStage = 2;
                                exchangeID =
                                    exchangeController.exchange.value?.id;
                              });
                            }
                            print("เสนอวันเวลาและสถานที่นี้");
                          } else {
                            Get.snackbar('แจ้งเตือน',
                                'การนัดหมายต้องสร้างล่วงหน้าอย่างน้อยหนึ่งวัน');
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
    );
  }

  Widget userCheckInCard() {
    return Container(
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
                        color: exchangeController.exchange.value?.meetingPoint
                                    .postUserCheckinTime !=
                                null
                            ? Color(0xFF5BD207)
                            : Color(0xFFFF0000),
                      ),
                      SizedBox(
                          width: exchangeController.exchange.value?.meetingPoint
                                      .postUserCheckinTime !=
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
                            color: exchangeController.exchange.value
                                        ?.meetingPoint.postUserCheckinTime !=
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
                        color: exchangeController.exchange.value?.meetingPoint
                                    .offerUserCheckinTime !=
                                null
                            ? Color(0xFF5BD207)
                            : Color(0xFFFF0000),
                      ),
                      SizedBox(
                          width: exchangeController.exchange.value?.meetingPoint
                                      .offerUserCheckinTime !=
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
                            color: exchangeController.exchange.value
                                        ?.meetingPoint.offerUserCheckinTime !=
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
    );
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
