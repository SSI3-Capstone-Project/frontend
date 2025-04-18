import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import '../../home/pages/product_detail_page.dart';
import '../controllers/sent_offer_posts_list_controller.dart';
import '../models/sent_offer_posts_list_model.dart';

class SentOfferPostsListPage extends StatefulWidget {
  final String offerId;

  const SentOfferPostsListPage({super.key, required this.offerId});

  @override
  State<SentOfferPostsListPage> createState() => _SentOfferPostsListPageState();
}

class _SentOfferPostsListPageState extends State<SentOfferPostsListPage> {
  final SentOfferPostsListController controller = Get.put(SentOfferPostsListController());

  @override
  void initState() {
    super.initState();
    controller.fetchSentOfferPosts(widget.offerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "โพสต์ที่ยื่นข้อเสนอ",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.sentOfferPosts.isEmpty) {
              return const Center(
                child: Text(
                  "ยังไม่มีโพสต์ที่ยื่นข้อเสนอ",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await controller.fetchSentOfferPosts(widget.offerId);
              },
              color: Colors.white,
              backgroundColor: Constants.secondaryColor,
              child: StaggeredGridView.countBuilder(
                padding: const EdgeInsets.only(top: 10),
                crossAxisCount: 4,
                mainAxisSpacing: 22,
                crossAxisSpacing: 22,
                itemCount: controller.sentOfferPosts.length,
                itemBuilder: (context, index) {
                  final item = controller.sentOfferPosts[index];
                  return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(
                            postId: item.postId,
                            // username: item.username,
                            // userImageUrl: item.userImageUrl,
                          ),
                        ),
                      );

                      if (result == true) {
                        await controller.fetchSentOfferPosts(widget.offerId);
                      }
                    },
                    child: _buildGridItem(item),
                  );
                },
                staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildGridItem(GetSentOfferPostList item) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: .5,
            blurRadius: 6,
            offset: const Offset(0, 0),
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white,
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(item.userImageUrl),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  item.username,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 20,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: const BorderRadius.all(
                        Radius.elliptical(100, 25),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Image.network(
                  item.coverImageUrl,
                  fit: BoxFit.fill,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Constants.secondaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Text(
                          item.subCollectionName.length > 10
                              ? '${item.subCollectionName.substring(0, 10)}...'
                              : item.subCollectionName,
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
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              item.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              item.description.length > 40
                  ? '${item.description.substring(0, 40)}...'
                  : item.description,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}