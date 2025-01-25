import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/wishlist_controller.dart';
import 'package:sixam_mart/data/model/body/notification_body.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/view/base/no_internet_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBody? body;

  const SplashScreen({Key? key, required this.body}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>  with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  late StreamSubscription<ConnectivityResult> _onConnectivityChanged;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    bool firstTime = true;
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (!firstTime) {
        bool isNotConnected = result != ConnectivityResult.wifi &&
            result != ConnectivityResult.mobile;
        isNotConnected
            ? const SizedBox()
            : ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? 'no_connection'.tr : 'connected'.tr,
            textAlign: TextAlign.center,
          ),
        ));
        if (!isNotConnected) {
          _route();
        }
      }
      firstTime = false;
    });

    Get.find<SplashController>().initSharedData();
    Get.find<CartController>().getCartData();
    _route();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,

    )..repeat(reverse:true);
    _animation = CurvedAnimation(
        parent: _controller,
        curve: Curves.fastEaseInToSlowEaseOut
    );
  }

  @override
  void dispose() {
    super.dispose();
    _onConnectivityChanged.cancel();
    _controller.dispose();
  }

  void _route() {
    Get.find<SplashController>().getConfigData().then((isSuccess) {
      if (isSuccess) {
        Timer(const Duration(seconds: 1), () async {
          double? minimumVersion = 0;
          if (GetPlatform.isAndroid) {
            minimumVersion = Get.find<SplashController>()
                .configModel!
                .appMinimumVersionAndroid;
          } else if (GetPlatform.isIOS) {
            minimumVersion =
                Get.find<SplashController>().configModel!.appMinimumVersionIos;
          }
          if (AppConstants.appVersion < minimumVersion! ||
              Get.find<SplashController>().configModel!.maintenanceMode!) {
            Get.offNamed(RouteHelper.getUpdateRoute(
                AppConstants.appVersion < minimumVersion));
          } else {
            if (widget.body != null) {
              if (widget.body!.notificationType == NotificationType.order) {
                Get.offNamed(RouteHelper.getOrderDetailsRoute(
                    widget.body!.orderId,
                    fromNotification: true));
              } else if (widget.body!.notificationType ==
                  NotificationType.general) {
                Get.offNamed(
                    RouteHelper.getNotificationRoute(fromNotification: true));
              } else {
                Get.offNamed(RouteHelper.getChatRoute(
                    notificationBody: widget.body,
                    conversationID: widget.body!.conversationId,
                    fromNotification: true));
              }
            } else {
              if (Get.find<AuthController>().isLoggedIn()) {
                Get.find<AuthController>().updateToken();
                if (Get.find<LocationController>().getUserAddress() != null) {
                  await Get.find<WishListController>().getWishList();
                  Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
                } else {
                  Get.find<LocationController>()
                      .navigateToLocationScreen('splash', offNamed: true);
                }
              } else {
                // if (Get.find<SplashController>().showIntro()!) {
                //   if (AppConstants.languages.length > 1) {
                //     Get.offNamed(RouteHelper.getLanguageRoute('splash'));
                //   } else {
                //     Get.offNamed(RouteHelper.getOnBoardingRoute());
                //   }
                // } else {
                  Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
                //}
              }
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Get.find<SplashController>().initSharedData();
    if (Get.find<LocationController>().getUserAddress() != null &&
        Get.find<LocationController>().getUserAddress()!.zoneIds == null) {
      Get.find<AuthController>().clearSharedAddress();
    }

    return Scaffold(
      key: _globalKey,
      body: GetBuilder<SplashController>(builder: (splashController) {
        return Center(
          child: splashController.hasConnection
              ? /*Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  //  Image.asset(Images.logo, width: 200),
                   // const SizedBox(height: Dimensions.paddingSizeSmall),

                    Center(
                      child: FadeTransition(
                        opacity: _animation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(Images.logo,width: 200),
                          ],
                        ),
                      ),
                    ),
                    // Text(AppConstants.APP_NAME, style: robotoMedium.copyWith(fontSize: 25)),
                  ],
                )*/Stack(
            children: [
              Container(height: 870,width: double.infinity,
                  child: Image.asset(
                    'assets/image/shopcizer backgroun image.jpg',
                    fit: BoxFit.cover,
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 350),
                child: Image.asset("assets/image/shop.gif", width: double.infinity),
              ),
              SizedBox(height: Dimensions.paddingSizeSmall),
              // Text(AppConstants.APP_NAME,
              //     style: robotoMedium.copyWith(fontSize: 25)),

            ],
          )
              : NoInternetScreen(child: SplashScreen(body: widget.body)),
        );
      }),
    );
  }
}


