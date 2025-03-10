import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/exchange/pages/exchange_page.dart';
import 'package:mbea_ssi3_front/views/profile/models/other_user_profile_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/other_user_profile_controller.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class OtherUserProfileDetail extends StatefulWidget {
  final String userId;
  const OtherUserProfileDetail({super.key, required this.userId});

  @override
  State<OtherUserProfileDetail> createState() => _OtherUserProfileDetailState();
}

class _OtherUserProfileDetailState extends State<OtherUserProfileDetail> {
  final OtherUserProfileController userProfileController =
      Get.put(OtherUserProfileController());

  @override
  void initState() {
    super.initState();
    userProfileController.fetchOtherUserProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (userProfileController.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          final userProfile = userProfileController.userProfile.value;
          if (userProfile == null) {
            return Center(child: Text("Failed to load other user profile"));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(userProfile),
                SizedBox(height: 20),
                _buildUserDetails(userProfile),
                SizedBox(height: 20),
                _buildReviews(userProfile.reviews),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(OtherUserProfile user) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios, size: 25),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetails(OtherUserProfile user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: user.imageUrl != null
              ? NetworkImage(user.imageUrl!)
              : AssetImage('assets/images/default_profile.png')
                  as ImageProvider,
        ),
        SizedBox(height: 10),
        Text(user.username,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("คะแนนเฉลี่ย: ${user.avgRating.toString()}",
                style: TextStyle(color: Colors.grey[600])),
            SizedBox(
              width: 3,
            ),
            Icon(
              Icons.star,
              size: 16,
              color: Constants.primaryColor,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildReviews(List<OtherUserReview> reviews) {
    if (reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text("ไม่มีรีวิว", style: TextStyle(color: Colors.grey[600])),
      );
    }

    return Column(
      children: reviews.map((review) => _buildReviewCard(review)).toList(),
    );
  }

  Widget _buildReviewCard(OtherUserReview review) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 0),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: review.reviewerImageUrl != null
                      ? NetworkImage(review.reviewerImageUrl!)
                      : AssetImage('assets/images/default_profile.png')
                          as ImageProvider,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.reviewerUsername,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Text("คะแนน: ${review.rating}",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13)),
                        SizedBox(
                          width: 3,
                        ),
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Constants.primaryColor,
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            if (review.reviewMedia != null)
              _buildReviewMedia(review.reviewMedia!),
            SizedBox(height: 10),
            Text(review.reviewText),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewMedia(List<OtherUserReviewMedia> mediaList) {
    if (mediaList.isEmpty) return SizedBox.shrink();

    return SizedBox(
      height: 85,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mediaList.length,
        itemBuilder: (context, index) {
          final media = mediaList[index];
          if (media.mediaType == "video") {
            return FutureBuilder<String?>(
              future: _generateThumbnail(media.mediaUrl),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: 85,
                    height: 85,
                    color: Colors.grey[300],
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError || snapshot.data == null) {
                  return _buildErrorThumbnail();
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FullScreenVideoPlayer(videoUrl: media.mediaUrl),
                      ),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.file(
                        File(snapshot.data!), // แสดง Thumbnail จากไฟล์ชั่วคราว
                        width: 85,
                        height: 85,
                        fit: BoxFit.cover,
                      ),
                      Icon(Icons.play_circle_fill,
                          color: Colors.white, size: 30),
                    ],
                  ),
                );
              },
            );
          } else {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FullScreenImageViewer(imageUrl: media.mediaUrl),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Image.network(
                  media.mediaUrl,
                  width: 85,
                  height: 85,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 85,
                      height: 85,
                      color: Colors.grey[300],
                      child: Icon(Icons.broken_image, color: Colors.grey[600]),
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildErrorThumbnail() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[300],
      child: Icon(Icons.video_library, color: Colors.grey[600]),
    );
  }

// ฟังก์ชันสร้าง Thumbnail จากวิดีโอ URL
  Future<String?> _generateThumbnail(String videoUrl) async {
    return await VideoThumbnail.thumbnailFile(
      video: videoUrl,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 80, // กำหนดขนาด Thumbnail
      quality: 75,
    );
  }
}

class FullScreenVideoPlayer extends StatelessWidget {
  final String videoUrl;
  const FullScreenVideoPlayer({Key? key, required this.videoUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: VideoPlayerWidget(videoUrl: videoUrl),
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  const FullScreenImageViewer({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
