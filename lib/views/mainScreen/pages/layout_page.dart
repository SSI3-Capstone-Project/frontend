import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/common/constants.dart';
import 'package:mbea_ssi3_front/controller/brand_controller.dart';
import 'package:mbea_ssi3_front/controller/offers_controller.dart';
import 'package:mbea_ssi3_front/controller/posts_controller.dart';
import 'package:mbea_ssi3_front/controller/province_controller.dart';
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/exchangeList/pages/exchange_list.dart';
import 'package:mbea_ssi3_front/views/chat/controllers/chat_room_controller.dart';
import 'package:mbea_ssi3_front/views/chat/pages/chat_page.dart';
import 'package:mbea_ssi3_front/views/home/controllers/product_controller.dart';
import 'package:mbea_ssi3_front/views/home/pages/home_page.dart';
import 'package:mbea_ssi3_front/views/createForm/pages/create_page.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/get_profile_controller.dart';
import 'package:mbea_ssi3_front/views/profile/pages/profile_page.dart';
import 'package:page_transition/page_transition.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final TokenController tokenController = Get.put(TokenController());
  final ProductController productController = Get.put(ProductController());
  final UserProfileController userProfileController =
      Get.put(UserProfileController());
  final PostsController postController = Get.put(PostsController());
  final OffersController offerController = Get.put(OffersController());
  final BrandController brandController = Get.put(BrandController());
  final ChatRoomController chatRoomController = Get.put(ChatRoomController());
  final ProvinceController provinceController = Get.put(ProvinceController());

  int _bottomNavIndex = 0;

  //List of the pages
  List<Widget> pages = const [
    HomePage(),
    ChatPage(),
    ExchangeList(),
    ProfilePage()
  ];

  //List of the pages icons
  List<IconData> iconList = [
    Icons.home,
    Icons.chat,
    Icons.autorenew,
    Icons.person
  ];

  //List of the pages titles
  List<String> titleList = ['Home', 'Chat', 'Exchange', 'Profile'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      // await tokenController.loadTokens();
      await productController.fetchProducts();
      await userProfileController.fetchUserProfile();
      await chatRoomController.fetchChatRooms();
      brandController.fetchBrands();
      provinceController.fetchProvince();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       Text(titleList[_bottomNavIndex],
      //           style: TextStyle(
      //               color: Constants.blackColor,
      //               fontWeight: FontWeight.w500,
      //               fontSize: 24)),
      //       Icon(
      //         Icons.notifications,
      //         color: Constants.blackColor,
      //         size: 30.0,
      //       )
      //     ],
      //   ),
      //   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      //   elevation: 0.0,
      // ),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: pages,
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Constants.primaryColor,
        onPressed: () {
          Navigator.push(
              context,
              PageTransition(
                  child: const CreatePostOffer(),
                  type: PageTransitionType.bottomToTop));
        },
        child: const Icon(
          Icons.add,
          size: 40,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        splashColor: Constants.secondaryColor,
        activeColor: Constants.secondaryColor,
        inactiveColor: Colors.black.withOpacity(.5),
        icons: iconList,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        onTap: (index) async {
          setState(() {
            _bottomNavIndex = index;
          });
          if (index == 0) {
            await productController.fetchProducts();
          }
          if (index == 1) {
            await chatRoomController.fetchChatRooms();
          }
          if (index == 3) {
            await postController.fetchPosts();
            await userProfileController.fetchUserProfile();
          }
        },
      ),
    );
  }
}
