import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/views/favoritePosts/controllers/get_wishLists_controller.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

class FavoritePosts extends StatefulWidget {
  final String userId;
  const FavoritePosts({super.key, required this.userId});

  @override
  State<FavoritePosts> createState() => _FavoritePostsState();
}

class _FavoritePostsState extends State<FavoritePosts> {
  final GetWishListsController getWishListsController = Get.put(GetWishListsController());

  @override
  void initState() {
    super.initState();
    getWishListsController.getWishLists();
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Obx(() {
            if (getWishListsController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            } else if (getWishListsController.wishLists.isEmpty) {
              return const Center(child: Text('ยังไม่มีรายการโปรด'));
            } else {
              return RefreshIndicator(
                onRefresh: () async {
                  await getWishListsController.getWishLists();
                },
                color: Colors.white,
                backgroundColor: Colors.blue,
                child: StaggeredGridView.countBuilder(
                  padding: const EdgeInsets.all(5),
                  crossAxisCount: 4,
                  mainAxisSpacing: 22,
                  crossAxisSpacing: 22,
                  itemCount: getWishListsController.wishLists.length,
                  itemBuilder: (context, index) {
                    final wishList = getWishListsController.wishLists[index];
                    return GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 0.5,
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
                              padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(50),
                                            color: Colors.white,
                                          ),
                                          child: CircleAvatar(
                                              radius: 18,
                                              backgroundImage: NetworkImage(wishList.imageUrl))),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    wishList.username,
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
                                          borderRadius: const BorderRadius.all(Radius.elliptical(100, 25))),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Image.network(
                                    wishList.coverImage,
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
                                        const SizedBox(width: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Text(
                                            wishList.subCollectionName.length > 10
                                                ? '${wishList.subCollectionName.substring(0, 10)}...'
                                                : wishList.subCollectionName,
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
                                wishList.title,
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
                                wishList.description.length > 35
                                    ? '${wishList.description.substring(0, 35)}...'
                                    : wishList.description,
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
                ),
              );
            }
          }),
        ),
      ),
    );
  }
}