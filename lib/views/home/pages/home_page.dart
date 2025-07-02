import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/controller/brand_controller.dart';
import 'package:mbea_ssi3_front/model/brand_model.dart';
import 'package:mbea_ssi3_front/views/home/controllers/brand_controller.dart';
import 'package:mbea_ssi3_front/views/home/controllers/product_controller.dart';
import 'package:mbea_ssi3_front/views/home/pages/product_detail_page.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../notifications/pages/notification_list_get_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductController productController = Get.put(ProductController());
  final BrandController brandController = Get.put(BrandController());
  final TextEditingController _brandSearchController = TextEditingController();
  final TextEditingController _collectionSearchController =
      TextEditingController();
  final TextEditingController _subCollectionSearchController =
      TextEditingController();

  final TextEditingController _searchController = TextEditingController();
  final RxString searchText = ''.obs;

  int _selectedCategoryIndex = 0;
  Brand? _selectedBrand;
  Collection? _selectedCollection;
  SubCollection? _selectedSubCollection;

  @override
  void initState() {
    super.initState();

    debounce(searchText, (val) {
      productController.fetchProducts(title: val.trim());
    }, time: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _brandSearchController.dispose();
    _collectionSearchController.dispose();
    _subCollectionSearchController.dispose();
    super.dispose();
  }

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
                  shortItemsButton(),
                  const SizedBox(
                    width: 10,
                  ),
                  notificationButton()
                ],
              ),
            ),

            // for category
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     _buildCategoryItem('ทั้งหมด', 0),
            //     _buildCategoryItem('แนะนำ', 1),
            //     _buildCategoryItem('ที่นิยม', 2),
            //     _buildCategoryItem('มาใหม่', 3),
            //     _buildCategoryItem('ที่คุณถูกใจ', 4),
            //   ],
            // ),
            // const SizedBox(
            //   height: 25,
            // ),

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
                      if (_selectedSubCollection != null) {
                        await productController.fetchProducts(
                          brandName: _selectedBrand?.name,
                          collectionName: _selectedCollection?.name,
                          subCollectionName: _selectedSubCollection?.name,
                        );
                      } else if (_selectedCollection != null) {
                        await productController.fetchProducts(
                          brandName: _selectedBrand?.name,
                          collectionName: _selectedCollection?.name,
                        );
                      } else if (_selectedBrand != null) {
                        await productController.fetchProducts(
                          brandName: _selectedBrand?.name,
                        );
                      } else {
                        await productController.fetchProducts();
                      }
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
                                            const SizedBox(width: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Constants
                                                    .secondaryColor, // Background color
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
        controller: _searchController,
        onChanged: (value) {
          productController.fetchProducts(title: value.trim());
        },
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
            borderRadius: BorderRadius.circular(10),
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
        showDialog(
          context: context,
          builder: (BuildContext context) {
            Brand? selectedBrand = _selectedBrand;
            Collection? selectedCollection = _selectedCollection;
            SubCollection? selectedSubCollection = _selectedSubCollection;

            return Center(
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                title: const Text(
                  "ตัวกรองการค้นหา",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
                content: Obx(() {
                  final brands = brandController.brands.toList();

                  return StatefulBuilder(
                    builder: (context, setStateDialog) {
                      final collections = selectedBrand?.collections ?? [];
                      final subCollections =
                          selectedCollection?.subCollections ?? [];

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10),

                          /// 🔵 Brand Dropdown
                          DropdownButtonHideUnderline(
                            child: DropdownButtonFormField2<Brand>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: "แบรนด์",
                                labelStyle: TextStyle(fontSize: 12),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              value: selectedBrand,
                              items: brands.map((brand) {
                                return DropdownMenuItem(
                                  value: brand,
                                  child: Text(brand.name,
                                      style: const TextStyle(fontSize: 12)),
                                );
                              }).toList(),
                              onChanged: (brand) {
                                setStateDialog(() {
                                  selectedBrand = brand;
                                  selectedCollection = null;
                                  selectedSubCollection = null;
                                });
                              },
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                              ),
                              dropdownSearchData: DropdownSearchData(
                                searchController: _brandSearchController,
                                searchInnerWidget: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: SizedBox(
                                    height: 40,
                                    child: TextFormField(
                                      controller: _brandSearchController,
                                      decoration: InputDecoration(
                                        hintText: 'ค้นหาแบรนด์...',
                                        hintStyle: TextStyle(fontSize: 12),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                searchInnerWidgetHeight: 60,
                                searchMatchFn: (item, searchValue) {
                                  return item.value!.name
                                      .toLowerCase()
                                      .contains(searchValue.toLowerCase());
                                },
                              ),
                            ),
                          ),
                          if (collections.isNotEmpty)
                            const SizedBox(height: 10),

                          /// 🟠 Collection Dropdown
                          if (collections.isNotEmpty)
                            DropdownButtonHideUnderline(
                              child: DropdownButtonFormField2<Collection>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: "คอลเลกชัน",
                                  labelStyle: TextStyle(fontSize: 12),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                value: selectedCollection,
                                items: collections.map((collection) {
                                  return DropdownMenuItem(
                                    value: collection,
                                    child: Text(collection.name,
                                        style: const TextStyle(fontSize: 12)),
                                  );
                                }).toList(),
                                onChanged: (collection) {
                                  setStateDialog(() {
                                    selectedCollection = collection;
                                    selectedSubCollection = null;
                                  });
                                },
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                  ),
                                ),
                                dropdownSearchData: DropdownSearchData(
                                  searchController: _collectionSearchController,
                                  searchInnerWidget: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: SizedBox(
                                      height: 40,
                                      child: TextFormField(
                                        controller: _collectionSearchController,
                                        decoration: InputDecoration(
                                          hintText: 'ค้นหาคอลเลกชัน...',
                                          hintStyle: TextStyle(fontSize: 12),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  searchInnerWidgetHeight: 60,
                                  searchMatchFn: (item, searchValue) {
                                    return item.value!.name
                                        .toLowerCase()
                                        .contains(searchValue.toLowerCase());
                                  },
                                ),
                              ),
                            )
                          else if (selectedBrand != null)
                            const Text(
                              "ไม่มีคอลเลกชัน",
                              style: TextStyle(color: Colors.grey),
                            ),
                          if (subCollections.isNotEmpty)
                            const SizedBox(height: 10),

                          /// 🟢 SubCollection Dropdown
                          if (subCollections.isNotEmpty)
                            DropdownButtonHideUnderline(
                              child: DropdownButtonFormField2<SubCollection>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: "ซับคอลเลกชัน",
                                  labelStyle: TextStyle(fontSize: 12),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                value: selectedSubCollection,
                                items: subCollections.map((sub) {
                                  return DropdownMenuItem(
                                    value: sub,
                                    child: Text(sub.name,
                                        style: const TextStyle(fontSize: 12)),
                                  );
                                }).toList(),
                                onChanged: (sub) {
                                  setStateDialog(() {
                                    selectedSubCollection = sub;
                                  });
                                },
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                  ),
                                ),
                                dropdownSearchData: DropdownSearchData(
                                  searchController:
                                      _subCollectionSearchController,
                                  searchInnerWidget: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: SizedBox(
                                      height: 40,
                                      child: TextFormField(
                                        controller:
                                            _subCollectionSearchController,
                                        decoration: InputDecoration(
                                          hintText: 'ค้นหาซับคอลเลกชัน...',
                                          hintStyle: TextStyle(fontSize: 12),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  searchInnerWidgetHeight: 5,
                                  searchMatchFn: (item, searchValue) {
                                    return item.value!.name
                                        .toLowerCase()
                                        .contains(searchValue.toLowerCase());
                                  },
                                ),
                              ),
                            )
                          else if (selectedCollection != null)
                            const Text(
                              "ไม่มีซับคอลเลกชัน",
                              style: TextStyle(color: Colors.grey),
                            ),
                        ],
                      );
                    },
                  );
                }),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          setState(() {
                            _selectedBrand = null;
                            _selectedCollection = null;
                            _selectedSubCollection = null;
                          });

                          if (_selectedSubCollection != null) {
                            await productController.fetchProducts(
                              brandName: _selectedBrand?.name,
                              collectionName: _selectedCollection?.name,
                              subCollectionName: _selectedSubCollection?.name,
                            );
                          } else if (_selectedCollection != null) {
                            await productController.fetchProducts(
                              brandName: _selectedBrand?.name,
                              collectionName: _selectedCollection?.name,
                            );
                          } else if (_selectedBrand != null) {
                            await productController.fetchProducts(
                              brandName: _selectedBrand?.name,
                            );
                          } else {
                            await productController.fetchProducts();
                          }
                        },
                        child: Text(
                          "ล้าง",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          setState(() {
                            _selectedBrand = selectedBrand;
                            _selectedCollection = selectedCollection;
                            _selectedSubCollection = selectedSubCollection;
                          });

                          if (_selectedSubCollection != null) {
                            await productController.fetchProducts(
                              brandName: _selectedBrand?.name,
                              collectionName: _selectedCollection?.name,
                              subCollectionName: _selectedSubCollection?.name,
                            );
                          } else if (_selectedCollection != null) {
                            await productController.fetchProducts(
                              brandName: _selectedBrand?.name,
                              collectionName: _selectedCollection?.name,
                            );
                          } else if (_selectedBrand != null) {
                            await productController.fetchProducts(
                              brandName: _selectedBrand?.name,
                            );
                          } else {
                            await productController.fetchProducts();
                          }
                        },
                        child: Text(
                          "ยืนยัน",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800),
                        ),
                      )
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(15),
      splashColor: Colors.white24,
      child: Container(
        padding: const EdgeInsets.all(10),
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

  Widget notificationButton() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationListGetPage(),
          ),
        );
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
            Icons.notifications,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
