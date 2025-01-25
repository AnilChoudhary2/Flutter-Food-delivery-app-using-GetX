import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/coupon_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/screens/coupon/widget/coupon_card.dart';
class CouponBottomSheet extends StatelessWidget {
  const CouponBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.webMaxWidth,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
        child: Column(children: [

          !ResponsiveHelper.isDesktop(context) ? Container(
            height: 4, width: 35,
            margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
          ) : const SizedBox(),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('available_promo'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
            IconButton(
              onPressed: ()=> Get.back(),
              icon: Icon(Icons.clear, color: Theme.of(context).disabledColor),
            )
          ]),

          GetBuilder<CouponController>(builder: (couponController){
            return couponController.couponList!.isNotEmpty ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : ResponsiveHelper.isTab(context) ? 2 : 1,
                mainAxisSpacing: Dimensions.paddingSizeSmall, crossAxisSpacing: Dimensions.paddingSizeSmall,
                childAspectRatio: ResponsiveHelper.isMobile(context) ? 3 : 3,
              ),
              itemCount: couponController.couponList!.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Get.back(result: couponController.couponList![index].code);
                  },
                  child: CouponCard(couponController: couponController, index: index),
                );
              },
            ) : Column(
                  children: [
                    Image.asset(Images.noCoupon, height: 70),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Text('no_promo_available'.tr, style: robotoMedium),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text(
                      '${'please_add_manually_or_collect_promo_from'.tr} ${Get.find<SplashController>().configModel!.businessName!}',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    ),
                    const SizedBox(height: 50),

                  ],
                );
          })

        ]),
      ),
    );
  }
}
