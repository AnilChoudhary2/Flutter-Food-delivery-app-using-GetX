import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/view/base/confirmation_dialog.dart';
import 'package:sixam_mart/view/screens/cart/cart_screen.dart';
import 'package:sixam_mart/view/screens/order/order_screen.dart';
import 'package:sixam_mart/view/screens/profile/profile_screen.dart';

import 'controller/auth_controller.dart';
import 'controller/cart_controller.dart';
import 'controller/wishlist_controller.dart';
import 'helper/route_helper.dart';
import 'view/screens/address/address_screen.dart';
import 'view/screens/coupon/coupon_screen.dart';
import 'view/screens/favourite/favourite_screen.dart';
import 'view/screens/refer_and_earn/refer_and_earn_screen.dart';
import 'view/screens/support/support_screen.dart';
import 'view/screens/wallet/wallet_screen.dart';

class draweraa extends StatefulWidget {
  const draweraa({Key? key}) : super(key: key);

  @override
  State<draweraa> createState() => _draweraaState();
}

class _draweraaState extends State<draweraa> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 330),
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: Icon(Icons.close),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(),
                        ));
                  },
                  child: Container(
                    height: 100,
                    // width: 345,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 80,
                            width: 80,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              // border: Border.all(width: 2, color: Colors.black),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Profile',
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.w600),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20, top: 10),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                'EDIT',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromARGB(255, 211, 211, 210),
                              blurRadius: 1)
                        ]),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 13,
          ),
          // left: 15, right: 15
          Padding(
            padding: const EdgeInsets.only(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FavouriteScreen(),
                        ));
                  },
                  child: Container(
                    height: 60,
                    width: 70,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Icon(
                          Icons.favorite_border,
                        ),
                        Text(
                          'favorite',
                          style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromARGB(255, 211, 211, 210),
                              blurRadius: 1)
                        ]),
                  ),
                ),
                // InkWell(
                //   onTap: () {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => OrderTracker(),
                //         ));
                //   },
                //   child: Container(
                //     height: 60,
                //     width: 70,
                //     child: Column(
                //       children: [
                //         SizedBox(
                //           height: 10,
                //         ),
                //         Icon(
                //           Icons.share_location_rounded,
                //         ),
                //         Text(
                //           'Order Track',
                //           style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                //         ),
                //       ],
                //     ),
                //     decoration: BoxDecoration(
                //         color: Colors.grey[100],
                //         borderRadius: BorderRadius.circular(10),
                //         boxShadow: [
                //           BoxShadow(
                //               color: Color.fromARGB(255, 211, 211, 210),
                //               blurRadius: 1)
                //         ]),
                //   ),
                // ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WalletScreen(
                            fromWallet: false,
                          ),
                        ));
                  },
                  child: Container(
                    height: 60,
                    width: 70,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Image.asset(
                          'assets/image/6.png',
                          height: 20,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Wallet',
                          style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromARGB(255, 211, 211, 210),
                              blurRadius: 1)
                        ]),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CouponScreen(),
                        ));
                  },
                  child: Container(
                    height: 60,
                    width: 70,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Image.asset(
                          'assets/image/1.png',
                          height: 25,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Coupon',
                          style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromARGB(255, 211, 211, 210),
                              blurRadius: 1)
                        ]),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 355,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CartScreen(
                              fromNav: true,
                            ),
                          ));
                    },
                    child: Container(
                      height: 50,
                      width: 360,
                      decoration: BoxDecoration(
                          color: Colors.grey[100],
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromARGB(255, 211, 211, 210),
                                blurRadius: 1)
                          ],
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Icon(Icons.card_travel),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Cart',
                            style:
                                TextStyle(fontSize: 18, color: Colors.grey[800]),
                          ),
                          Spacer(),
                          Icon(Icons.navigate_next_outlined)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddressScreen(),
                          ));
                    },
                    child: Container(
                      height: 50,
                      width: 360,
                      decoration: BoxDecoration(
                          color: Colors.grey[100],
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromARGB(255, 211, 211, 210),
                                blurRadius: 1)
                          ],
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Image.asset(
                              'assets/image/10.png',
                              height: 25,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'My Address',
                            style:
                                TextStyle(fontSize: 18, color: Colors.grey[800]),
                          ),
                          Spacer(),
                          Icon(Icons.navigate_next_outlined)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderScreen(),
                          ));
                    },
                    child: Container(
                      height: 50,
                      width: 360,
                      decoration: BoxDecoration(
                          color: Colors.grey[100],
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromARGB(255, 211, 211, 210),
                                blurRadius: 1)
                          ],
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            // child: Image.asset(
                            //   'assets/image/10.png',
                            //   height: 25,
                            // ),c
                            child: Icon(Icons.fastfood_outlined),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'My Order',
                            style:
                                TextStyle(fontSize: 18, color: Colors.grey[800]),
                          ),
                          Spacer(),
                          Icon(Icons.navigate_next_outlined)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Container(
                    height: 180,
                    width: 360,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            Get.toNamed(
                                RouteHelper.getHtmlRoute('terms-and-condition'));
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Image.asset(
                                  'assets/image/11.png',
                                  height: 25,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'About us',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey[800]),
                              ),
                              Spacer(),
                              Icon(Icons.navigate_next_outlined)
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Divider(
                          color: Colors.grey,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SupportScreen(),
                                ));
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Image.asset(
                                  'assets/image/3.png',
                                  height: 25,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Help & Support',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey[800]),
                              ),
                              Spacer(),
                              Icon(Icons.navigate_next_outlined)
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Divider(
                          color: Colors.grey,
                        ),
                        SizedBox(
                          height: 4,
                        ),

                        // SizedBox(
                        //   height: 4,
                        // ),
                        SizedBox(
                          height: 6,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReferAndEarnScreen(),
                                ));
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Image.asset(
                                  'assets/image/coins.png',
                                  height: 40,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Refer & Earn',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w300),
                              ),
                              Spacer(),
                              Icon(Icons.navigate_next_outlined)
                            ],
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromARGB(255, 211, 211, 210),
                              blurRadius: 1)
                        ],
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      Get.back();
                      if (Get.find<AuthController>().isLoggedIn()) {
                        Get.dialog(
                            ConfirmationDialog(
                                icon: Images.support,
                                description: 'are_you_sure_to_logout'.tr,
                                isLogOut: true,
                                onYesPressed: () {
                                  Get.find<AuthController>().clearSharedData();
                                  Get.find<CartController>().clearCartList();
                                  Get.find<WishListController>().removeWishes();
                                  Get.offAllNamed(RouteHelper.getSignInRoute(
                                      RouteHelper.splash));
                                }),
                            useSafeArea: false);
                      } else {
                        Get.find<WishListController>().removeWishes();
                        Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
                      }
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.grey[100],
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromARGB(255, 211, 211, 210),
                                blurRadius: 1)
                          ],
                          borderRadius: BorderRadius.circular(10)),
                      width: 345,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              color: Colors.orange,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Logout',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.orange),
                            ),
                            Spacer(),
                            Icon(Icons.navigate_next_outlined,
                                color: Colors.orange)
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 60,
                    width: 289,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 6, bottom: 10),
                          child: Image.asset(
                            'assets/image/giftbox 1.png',
                            height: 30,
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 100,
                                top: 13,
                              ),
                              child: Text(
                                'Did you Know?',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              'You will get cashback when your friends place\norder using the invite',
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w400),
                            ),
                          ],
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 6,
                              color: Colors.grey,
                              offset: Offset(0.0, 4)),
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
