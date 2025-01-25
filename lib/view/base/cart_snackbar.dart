import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

import '../../controller/cart_controller.dart';
import '../../controller/coupon_controller.dart';
import '../../controller/splash_controller.dart';
import 'custom_snackbar.dart';

void showCartSnackBar() {
  ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
    dismissDirection: DismissDirection.horizontal,
    margin: EdgeInsets.only(
      right: ResponsiveHelper.isDesktop(Get.context) ? Get.context!.width*0.7 : Dimensions.paddingSizeSmall,
      top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall,
    ),
    duration: const Duration(seconds: 4),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
    content: Text('item_added_to_cart'.tr, style: robotoMedium.copyWith(color: Colors.white)),
    action: SnackBarAction(

    //    label: 'view_cart'.tr, onPressed: () => Get.toNamed(RouteHelper.getCartRoute()), textColor: Colors.white),
        label: 'view_cart'.tr,textColor: Colors.white, onPressed: (){
      if( Get.find<CartController>().cartList.first.item!.scheduleOrder! && Get.find<CartController>().availableList.contains(false)) {
        showCustomSnackBar('one_or_more_product_unavailable'.tr);
      } else {
        if(Get.find<SplashController>().module == null) {
          int i = 0;
          for(i = 0; i < Get.find<SplashController>().moduleList!.length; i++){
            if( Get.find<CartController>().cartList[0].item!.moduleId == Get.find<SplashController>().moduleList![i].id){
              break;
            }
          }
          Get.find<SplashController>().setModule(Get.find<SplashController>().moduleList![i]);
        }
        Get.find<CouponController>().removeCouponData(false);

        Get.toNamed(RouteHelper.getCheckoutRoute('cart'));
      }
    }),
  ));
  // Get.showSnackbar(GetSnackBar(
  //   backgroundColor: Colors.green,
  //   message: 'item_added_to_cart'.tr,
  //   mainButton: TextButton(
  //     onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
  //     child: Text('view_cart'.tr, style: robotoMedium.copyWith(color: Theme.of(context).cardColor)),
  //   ),
  //   onTap: (_) => Get.toNamed(RouteHelper.getCartRoute()),
  //   duration: Duration(seconds: 3),
  //   maxWidth: Dimensions.WEB_MAX_WIDTH,
  //   snackStyle: SnackStyle.FLOATING,
  //   margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
  //   borderRadius: 10,
  //   isDismissible: true,
  //   dismissDirection: DismissDirection.horizontal,
  // ));
}