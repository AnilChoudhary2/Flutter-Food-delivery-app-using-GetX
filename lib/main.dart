import 'dart:async';
import 'dart:io';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:hypersdkflutter/hypersdkflutter.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/theme_controller.dart';
import 'package:sixam_mart/controller/wishlist_controller.dart';
import 'package:sixam_mart/data/model/body/notification_body.dart';
import 'package:sixam_mart/helper/notification_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/theme/dark_theme.dart';
import 'package:sixam_mart/theme/light_theme.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/screens/home/widget/cookies_view.dart';
import 'package:url_strategy/url_strategy.dart';
import 'helper/get_di.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  if(ResponsiveHelper.isMobilePhone()) {
    HttpOverrides.global = MyHttpOverrides();
  }
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  if(GetPlatform.isWeb){
    await Firebase.initializeApp(options: const FirebaseOptions(
      apiKey: 'AIzaSyDFN-73p8zKVZbA0i5DtO215XzAb-xuGSE',
      appId: '1:1000163153346:web:4f702a4b5adbd5c906b25b',
      messagingSenderId: 'G-L1GNL2YV61',
      projectId: 'ammart-8885e',
    ));
  }
  await Firebase.initializeApp();
  Map<String, Map<String, String>> languages = await di.init();

  NotificationBody? body;
  try {
    if (GetPlatform.isMobile) {
      final RemoteMessage? remoteMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null) {
        body = NotificationHelper.convertNotification(remoteMessage.data);
      }
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
    }
  }catch(_) {}

  if (ResponsiveHelper.isWeb()) {
    await FacebookAuth.instance.webAndDesktopInitialize(
      appId: "380903914182154",
      cookie: true,
      xfbml: true,
      version: "v15.0",
    );
  }
  final hyperSDK = HyperSDK();
  runApp(MyApp(languages: languages, body: body, ));
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBody? body;


  const MyApp({Key? key, required this.languages, required this.body, }) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    _route();
  }

  void _route() async {
    if(GetPlatform.isWeb) {
      await Get.find<SplashController>().initSharedData();
      if(Get.find<LocationController>().getUserAddress() != null && Get.find<LocationController>().getUserAddress()!.zoneIds == null) {
        Get.find<AuthController>().clearSharedAddress();
      }
      Get.find<CartController>().getCartData();
    }
    Get.find<SplashController>().getConfigData(loadLandingData: GetPlatform.isWeb).then((bool isSuccess) async {
      if (isSuccess) {
        if (Get.find<AuthController>().isLoggedIn()) {
          Get.find<AuthController>().updateToken();
          await Get.find<WishListController>().getWishList();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetBuilder<SplashController>(builder: (splashController) {
          return (GetPlatform.isWeb && splashController.configModel == null) ? const SizedBox() : GetMaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: Get.key,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
            ),
            theme: themeController.darkTheme ? themeController.darkColor == null ? dark() : dark(color
                : themeController.darkColor!) : themeController.lightColor == null ? light()
                : light(color: themeController.lightColor!),
            locale: localizeController.locale,
            translations: Messages(languages: widget.languages),
            fallbackLocale: Locale(AppConstants.languages[0].languageCode!, AppConstants.languages[0].countryCode),
            initialRoute: GetPlatform.isWeb ? RouteHelper.getInitialRoute() : RouteHelper.getSplashRoute(widget.body),
            getPages: RouteHelper.routes,
            defaultTransition: Transition.topLevel,
            transitionDuration: const Duration(milliseconds: 500),
            builder: (BuildContext context, widget) => Material(
              child: Stack(children: [
                widget!,
                GetBuilder<SplashController>(builder: (splashController){
                  if(!splashController.savedCookiesData && !splashController.getAcceptCookiesStatus(splashController.configModel != null ? splashController.configModel!.cookiesText! : '')){
                    return ResponsiveHelper.isWeb() ? const Align(alignment: Alignment.bottomCenter, child: CookiesView()) : const SizedBox();
                  }else{
                    return const SizedBox();
                  }
                })
              ]),
            ),
          );
        });
      });
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
