import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/theme_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
class CongratulationDialogue extends StatelessWidget {
  const CongratulationDialogue({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 300,
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Image.asset(Get.find<ThemeController>().darkTheme ? Images.congratulationDark : Images.congratulationLight, width: 100, height: 100),

                Text('congratulations'.tr , style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: Text(
                    '${'you_will_earn'.tr} ${Get.find<AuthController>().getEarningPint()} ${'points_after_completing_this_order'.tr}',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge,color: Theme.of(context).disabledColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                CustomButton(
                  buttonText: 'visit_loyalty_points'.tr,
                  onPressed: (){
                    Get.find<AuthController>().saveEarningPoint('');
                    Get.back();
                    Get.toNamed(RouteHelper.getWalletRoute(false));
                  },
                )
              ]),
            ),

            Positioned(
              top: 5, right: 5,
                child: InkWell(
                  onTap: (){
                    Get.find<AuthController>().saveEarningPoint('');
                    Get.back();
                  },
                    child: const Icon(Icons.clear, size: 18),
                ),
            )
          ],
        ),
      ),
    );
  }
}
