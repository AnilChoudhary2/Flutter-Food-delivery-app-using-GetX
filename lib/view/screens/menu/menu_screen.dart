import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/menu_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/view/screens/menu/widget/menu_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late List<MenuModel> _menuList;
  late double _ratio;

  @override
  Widget build(BuildContext context) {
    _ratio = ResponsiveHelper.isDesktop(context) ? 1.1 : ResponsiveHelper.isTab(context) ? 1.1 : 1.2;
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    _menuList = [
      MenuModel(icon: '', title: 'profile'.tr, route: RouteHelper.getProfileRoute()),
      MenuModel(icon: Images.location, title: 'my_address'.tr, route: RouteHelper.getAddressRoute()),
      MenuModel(icon: Images.language, title: 'language'.tr, route: RouteHelper.getLanguageRoute('menu')),
      MenuModel(icon: Images.coupon, title: 'coupon'.tr, route: RouteHelper.getCouponRoute()),
      MenuModel(icon: Images.support, title: 'help_support'.tr, route: RouteHelper.getSupportRoute()),
      MenuModel(icon: Images.policy, title: 'privacy_policy'.tr, route: RouteHelper.getHtmlRoute('privacy-policy')),
      MenuModel(icon: Images.aboutUs, title: 'about_us'.tr, route: RouteHelper.getHtmlRoute('about-us')),
      MenuModel(icon: Images.terms, title: 'terms_conditions'.tr, route: RouteHelper.getHtmlRoute('terms-and-condition')),
      MenuModel(icon: Images.chat, title: 'live_chat'.tr, route: RouteHelper.getConversationRoute()),
      ///only for taxi module.. will come soon.
      // MenuModel(icon: Images.orders, title: 'trip_order'.tr, route: RouteHelper.getTripHistoryScreen()),
    ];

    if(Get.find<SplashController>().configModel!.refundPolicyStatus == 1 ){
      _menuList.add(MenuModel(icon: Images.refund, title: 'refund_policy'.tr, route: RouteHelper.getHtmlRoute('refund-policy')));
    }
    if(Get.find<SplashController>().configModel!.cancellationPolicyStatus == 1 ){
      _menuList.add(MenuModel(icon: Images.cancellation, title: 'cancellation_policy'.tr, route: RouteHelper.getHtmlRoute('cancellation-policy')));
    }
    if(Get.find<SplashController>().configModel!.shippingPolicyStatus == 1 ){
      _menuList.add(MenuModel(icon: Images.shippingPolicy, title: 'shipping_policy'.tr, route: RouteHelper.getHtmlRoute('shipping-policy')));
    }
    if(Get.find<SplashController>().configModel!.refEarningStatus == 1 ){
      _menuList.add(MenuModel(icon: Images.referCode, title: 'refer_and_earn'.tr, route: RouteHelper.getReferAndEarnRoute()));
    }
    if(Get.find<SplashController>().configModel!.customerWalletStatus == 1 ){
      _menuList.add(MenuModel(icon: Images.wallet, title: 'wallet'.tr, route: RouteHelper.getWalletRoute(true)));
    }
    if(Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 ){
      _menuList.add(MenuModel(icon: Images.loyal, title: 'loyalty_points'.tr, route: RouteHelper.getWalletRoute(false)));
    }
    if(Get.find<SplashController>().configModel!.toggleDmRegistration! && !ResponsiveHelper.isDesktop(context)) {
      _menuList.add(MenuModel(
        icon: Images.deliveryManJoin, title: 'join_as_a_delivery_man'.tr,
        route: RouteHelper.getDeliverymanRegistrationRoute(),
      ));
    }
    if(Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context)) {
      _menuList.add(MenuModel(
        icon: Images.restaurantJoin, title: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
          ? 'join_as_a_restaurant'.tr : 'join_as_a_store'.tr,
        route: RouteHelper.getRestaurantRegistrationRoute(),
      ));
    }
    _menuList.add(MenuModel(icon: Images.logOut, title: isLoggedIn ? 'logout'.tr : 'sign_in'.tr, route: ''));

    return PointerInterceptor(
      child: Container(
        width: Dimensions.webMaxWidth,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          color: Theme.of(context).cardColor,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          InkWell(
            onTap: () => Get.back(),
            child: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : ResponsiveHelper.isTab(context) ? 6 : 4,
              childAspectRatio: (1/_ratio),
              crossAxisSpacing: Dimensions.paddingSizeExtraSmall, mainAxisSpacing: Dimensions.paddingSizeExtraSmall,
            ),
            itemCount: _menuList.length,
            itemBuilder: (context, index) {
              return MenuButton(menu: _menuList[index], isProfile: index == 0, isLogout: index == _menuList.length-1);
            },
          ),
          SizedBox(height: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeSmall : 0),

        ]),
      ),
    );
  }
}
