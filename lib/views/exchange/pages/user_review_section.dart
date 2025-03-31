import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/exchange/controllers/exchange_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:mbea_ssi3_front/views/exchange/controllers/rating_controller.dart';

class UserReviewSection extends StatefulWidget {
  final RatingController ratingController;
  final TextEditingController reviewController;
  final List<Map<String, dynamic>> mediaList;
  final Function(List<Map<String, dynamic>>) onMediaChanged;

  const UserReviewSection({
    super.key,
    required this.ratingController,
    required this.reviewController,
    required this.mediaList,
    required this.onMediaChanged,
  });

  @override
  State<UserReviewSection> createState() => _UserReviewSectionState();
}

class _UserReviewSectionState extends State<UserReviewSection> {
  final ImagePicker _picker = ImagePicker();
  final exchangeController = Get.find<ExchangeController>();
  final int maxCharacters = 200;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.ratingController.setRating(0);
      widget.reviewController.clear();
      widget.mediaList.clear();
      widget.onMediaChanged(widget.mediaList);
    });
  }

  @override
  Widget build(BuildContext context) {
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
              // 🔸 Profile + Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(exchangeController
                                .exchange.value!.isOwnerPost
                            ? exchangeController.exchange.value!.postImageUrl
                            : exchangeController.exchange.value!.offerImageUrl),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        exchangeController.exchange.value!.isOwnerPost
                            ? exchangeController.exchange.value!.postUsername
                            : exchangeController.exchange.value!.offerUsername,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Obx(() => Row(
                        children: List.generate(5, (index) {
                          int starIndex = index + 1;
                          return GestureDetector(
                            onTap: () =>
                                widget.ratingController.setRating(starIndex),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.ratingController.selectedRating
                                            .value ==
                                        starIndex
                                    ? Colors.grey.shade300
                                    : Colors.transparent,
                              ),
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.star,
                                size: 20,
                                color: widget.ratingController.selectedRating
                                            .value >=
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
              const SizedBox(height: 16),

              // 🔸 Review Box
              TextField(
                controller: widget.reviewController,
                maxLines: 3,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: "เขียนรีวิวผู้ใช้งานท่านนี้...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: (text) {
                  if (text.runes.length > maxCharacters) {
                    widget.reviewController.text =
                        String.fromCharCodes(text.runes.take(maxCharacters));
                    widget.reviewController.selection =
                        TextSelection.fromPosition(
                      TextPosition(offset: widget.reviewController.text.length),
                    );
                  }
                  setState(() {});
                },
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${widget.reviewController.text.runes.length}/$maxCharacters",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),

              // 🔸 Media Preview + Button
              if (widget.mediaList.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ReorderableListView(
                    scrollDirection: Axis.horizontal,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = widget.mediaList.removeAt(oldIndex);
                        widget.mediaList.insert(newIndex, item);
                        widget.onMediaChanged(widget.mediaList);
                      });
                    },
                    children: List.generate(widget.mediaList.length, (index) {
                      var media = widget.mediaList[index];
                      File? file = media['file'];

                      return Stack(
                        key: ValueKey(media),
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: file != null && file.existsSync()
                                  ? media['type'] == 'image'
                                      ? Image.file(file, fit: BoxFit.cover)
                                      : _buildVideoPreview(file)
                                  : const Center(child: Text("ไฟล์ไม่พบ")),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  widget.mediaList.removeAt(index);
                                  widget.onMediaChanged(widget.mediaList);
                                });
                              },
                              child: const CircleAvatar(
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
                    color: widget.mediaList.length >= 5
                        ? Colors.grey
                        : Constants.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: widget.mediaList.length >= 5 ? null : _pickMedia,
                    tooltip: widget.mediaList.length >= 5
                        ? "ไม่สามารถแนบไฟล์ได้เกิน 5 รายการ"
                        : "แนบไฟล์รูปภาพหรือวิดีโอ",
                    icon: Transform.rotate(
                      angle: pi / 4,
                      child: Icon(
                        Icons.attach_file,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickMedia() async {
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
          widget.mediaList.add({
            'type': 'video',
            'file': file,
            'thumbnail': thumbPath != null ? File(thumbPath) : null,
          });
        });
      } else {
        // ถ้าเป็นรูปภาพ
        setState(() {
          widget.mediaList.add({'type': 'image', 'file': file});
        });
      }
    }
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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<Duration> _getVideoDuration(File videoFile) async {
    final controller = VideoPlayerController.file(videoFile);
    await controller.initialize();
    final duration = controller.value.duration;
    await controller.dispose(); // ปล่อยหน่วยความจำหลังใช้งาน
    return duration;
  }
}
