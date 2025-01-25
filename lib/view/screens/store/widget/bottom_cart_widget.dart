import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_button.dart';

import '../../../../controller/coupon_controller.dart';
import '../../../../controller/splash_controller.dart';
import '../../../base/custom_snackbar.dart';

class BottomCartWidget extends StatelessWidget {
  const BottomCartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
        return Container(
          height: GetPlatform.isIOS ? 100 : 70, width: Get.width,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge,/* vertical: Dimensions.PADDING_SIZE_SMALL*/),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor, boxShadow: [BoxShadow(color: const Color(0xFF2A2A2A).withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${'item'.tr}: ${cartController.cartList.length}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Row(children: [
                Text(
                  '${'total'.tr}: ',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                ),

                Text(
                  PriceConverter.convertPrice(cartController.calculationCart()),
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor), textDirection: TextDirection.ltr,
                ),
              ]),
            ]),

            CustomButton(buttonText: 'view_cart'.tr,width: 130,height: 45,
                //onPressed: () => Get.toNamed(RouteHelper.getCartRoute())
                onPressed: () {
                  if( Get.find<CartController>().cartList.first.item!.scheduleOrder! && Get.find<CartController>().availableList.contains(false)) {
                    showCustomSnackBar('one_or_more_product_unavailable'.tr);
                  } else {//20593388
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
                }
            )
          ]),
        );
      });
  }
}
