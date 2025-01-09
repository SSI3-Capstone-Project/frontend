import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/views/favoritePosts/controllers/get_wishLists_controller.dart';

class FavoritePosts extends StatefulWidget {
  final String userId;
  const FavoritePosts({super.key, required this.userId});

  @override
  State<FavoritePosts> createState() => _FavoritePostsState();
}

class _FavoritePostsState extends State<FavoritePosts> {
  final GetWishListsController getWishListsController =
      Get.put(GetWishListsController());

  @override
  void initState() {
    super.initState();
    if (widget.userId.isNotEmpty) {
      getWishListsController.getWishLists(widget.userId);
    } else {
      Get.snackbar('Error', 'User ID is empty');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายการโปรด"),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (getWishListsController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          } else if (getWishListsController.wishLists.isEmpty) {
            return const Center(child: Text('ยังไม่มีรายการโปรด'));
          } else {
            return ListView.builder(
              itemCount: getWishListsController.wishLists.length,
              itemBuilder: (context, index) {
                final wishList = getWishListsController.wishLists[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        wishList.coverImage,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 50),
                      ),
                    ),
                    title: Text(
                      wishList.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(wishList.subCollectionName),
                        Text(
                          'สถานที่: ${wishList.location}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'เพิ่มเมื่อ: ${wishList.createdAt.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        }),
      ),
    );
  }
}
