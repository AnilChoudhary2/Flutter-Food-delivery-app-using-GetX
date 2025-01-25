import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscountTag extends StatelessWidget {
  final double? discount;
  final String? discountType;
  final double fromTop;
  final double? fontSize;
  final bool inLeft;
  final bool? freeDelivery;
  const DiscountTag({Key? key, 
    required this.discount, required this.discountType, this.fromTop = 10, this.fontSize, this.freeDelivery = false,
    this.inLeft = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isRightSide = Get.find<SplashController>().configModel!.currencySymbolDirection == 'right';
    String currencySymbol = Get.find<SplashController>().configModel!.currencySymbol!;

    return (discount! > 0 || freeDelivery!) ? Positioned(
      top: fromTop, left: inLeft ? 0 : null, right: inLeft ? null : 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(inLeft ? Dimensions.radiusSmall : 0),
            left: Radius.circular(inLeft ? 0 : Dimensions.radiusSmall),
          ),
        ),
        child: Text(
          discount! > 0 ? '${isRightSide ? '' : currencySymbol}$discount${discountType == 'percent' ? '%'
              : isRightSide ? currencySymbol : ''} ${'off'.tr}' : 'free_delivery'.tr,
          style: robotoMedium.copyWith(
            color: Colors.white,
            fontSize: fontSize ?? (ResponsiveHelper.isMobile(context) ? 8 : 12),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ) : const SizedBox();
  }
}
