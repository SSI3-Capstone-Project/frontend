import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/views/home/controllers/brand_controller.dart';
// import 'package:mbea_ssi3_front/model/plants.dart';
import 'package:mbea_ssi3_front/views/home/controllers/product_controller.dart';
import 'package:mbea_ssi3_front/views/home/pages/product_detail_page.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductController productController = Get.put(ProductController());
  final BrandControllerTwo brandController = Get.put(BrandControllerTwo());
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        color: Colors.white,
        child: Column(
          children: [
            // for welcome
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Row(
                children: [
                  searchField(),
                  const SizedBox(
                    width: 10,
                  ),
                  shortItemsButton()
                ],
              ),
            ),

            // for category
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryItem('ทั้งหมด', 0),
                _buildCategoryItem('แนะนำ', 1),
                _buildCategoryItem('ที่นิยม', 2),
                _buildCategoryItem('มาใหม่', 3),
                _buildCategoryItem('ที่คุณถูกใจ', 4),
              ],
            ),
            const SizedBox(
              height: 25,
            ),

            // Wrap Expanded with Obx to observe the changes only here
            Expanded(
              child: Obx(() {
                if (productController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                } else if (productController.productList.isEmpty) {
                  return const Align(
                    alignment: Alignment.center,
                    child: Text('ยังไม่มีโพสต์'),
                  );
                } else {
                  return RefreshIndicator(
                    onRefresh: () async {
                      // Call the refresh function in ProductController
                      await productController.fetchProducts();
                    },
                    color: Colors.white, // Refresh icon color
                    backgroundColor: Constants.secondaryColor,
                    child: StaggeredGridView.countBuilder(
                      padding: const EdgeInsets.all(5),
                      crossAxisCount: 4,
                      mainAxisSpacing: 22,
                      crossAxisSpacing: 22,
                      itemCount: productController.productList.length,
                      itemBuilder: (context, index) {
                        final product = productController.productList[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProductDetailPage(
                                          postId: product.id,
                                        )));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(
                                      0.5), // Shadow color and transparency
                                  spreadRadius: .5, // Shadow spread radius
                                  blurRadius: 6, // Shadow blur radius
                                  offset: const Offset(0,
                                      0), // Shadow position (horizontal, vertical)
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 10, left: 10, right: 10),
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
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: Colors.white,
                                              ),
                                              child: CircleAvatar(
                                                  radius: 18,
                                                  backgroundImage: NetworkImage(
                                                      product.imageUrl))),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        product.username,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black, // Text color
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Stack(
                                  children: [
                                    // for image base
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
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.elliptical(100, 25),
                                                  )),
                                            ),
                                          ),
                                        ),
                                        // for image
                                        Center(
                                          child: Image.network(
                                            product.coverImage,
                                            fit: BoxFit.fill,
                                          ),
                                        )
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors
                                                    .blue, // Background color
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8), // Border radius
                                              ),
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 8,
                                                  vertical:
                                                      4), // Padding between border and text
                                              child: Text(
                                                product.subCollectionName
                                                            .length >
                                                        10
                                                    ? '${product.subCollectionName.substring(0, 10)}...'
                                                    : product.subCollectionName,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors
                                                      .white, // Text color
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    product.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    product.description.length > 35
                                        ? '${product.description.substring(0, 35)}...'
                                        : product.description,
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
                      staggeredTileBuilder: (index) =>
                          const StaggeredTile.fit(2),
                    ),
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget searchField() {
    return Expanded(
      child: TextField(
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
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget shortItemsButton() {
    return InkWell(
      onTap: () {
        // Show a popup with a blurred background
        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return Stack(
        //       children: [
        //         // Blurred background
        //         // BackdropFilter(
        //         //   filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        //         //   child: Container(
        //         //     color: Colors.black.withOpacity(0.5),
        //         //   ),
        //         // ),
        //         Center(
        //           child: AlertDialog(
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(15.0),
        //             ),
        //             title: const Text(
        //               "แบรนด์",
        //               style:
        //                   TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        //               textAlign: TextAlign.center,
        //             ),
        //             content: SingleChildScrollView(
        //               child: Wrap(
        //                 spacing: 8.0,
        //                 children: brandController.selectedBrands.keys
        //                     .map((String brand) {
        //                   return Obx(() {
        //                     return FilterChip(
        //                       labelStyle: TextStyle(
        //                         color: brandController.selectedBrands[brand]!
        //                             ? Colors.white
        //                             : Colors
        //                                 .black, // สีของตัวอักษรเมื่อถูกเลือก
        //                       ),
        //                       label: Text(brand),
        //                       selected: brandController.selectedBrands[brand]!,
        //                       onSelected: (bool selected) {
        //                         brandController.toggleBrandSelection(
        //                             brand, selected);
        //                       },
        //                       selectedColor: Constants.secondaryColor,
        //                       checkmarkColor: Colors.white,
        //                     );
        //                   });
        //                 }).toList(),
        //               ),
        //             ),
        //             actions: [
        //               TextButton(
        //                 style: TextButton.styleFrom(
        //                     backgroundColor:
        //                         Constants.primaryColor, // สีพื้นหลังของปุ่ม
        //                     foregroundColor: Colors.white,
        //                     padding: EdgeInsets.all(0.5) // สีของตัวอักษร
        //                     ),
        //                 onPressed: () {
        //                   // แสดงแบรนด์ที่เลือกในคอนโซล

        //                   Navigator.of(context).pop();
        //                   final selected = brandController
        //                       .selectedBrands.entries
        //                       .where((entry) => entry
        //                           .value) // กรองเฉพาะแบรนด์ที่ถูกเลือก (true)
        //                       .map((entry) =>
        //                           entry.key) // แปลงจาก MapEntry เป็นชื่อแบรนด์
        //                       .toList();
        //                   print("Selected Brands: $selected");
        //                 },
        //                 child: const Text(
        //                   "ยืนยัน",
        //                   style: TextStyle(
        //                       fontSize: 14, fontWeight: FontWeight.w600),
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     );
        //   },
        // );
      },
      borderRadius: BorderRadius.circular(15),
      splashColor: Colors.white24,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Constants.primaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const RotatedBox(
          quarterTurns: 4,
          child: Icon(
            Icons.tune,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget categoryItems({
    bool isActive = false,
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
              color: isActive ? Constants.primaryColor : Colors.grey,
              fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 5),
          height: 3,
          width: 40,
          decoration: isActive
              ? BoxDecoration(
                  color: Constants.primaryColor,
                  borderRadius: BorderRadius.circular(10))
              : const BoxDecoration(),
        )
      ],
    );
  }

  Widget _buildCategoryItem(String title, int index) {
    bool isActive = _selectedCategoryIndex == index;

    return GestureDetector(
      onTap: () async {
        setState(() {
          _selectedCategoryIndex = index;
        });
        print(title);
        await productController.fetchProducts();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
                color: isActive ? Constants.secondaryColor : Colors.grey,
                fontWeight: FontWeight.bold),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            height: 3,
            width: 40,
            decoration: isActive
                ? BoxDecoration(
                    color: Constants.secondaryColor,
                    borderRadius: BorderRadius.circular(10))
                : const BoxDecoration(),
          )
        ],
      ),
    );
  }
}
