import 'package:flutter/gestures.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/controller/parcel_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutCondition extends StatelessWidget {
  final OrderController orderController;
  final ParcelController parcelController;
  final bool isParcel;
  const CheckoutCondition({Key? key, required this.orderController, this.isParcel = false, required this.parcelController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool activeRefund = Get.find<SplashController>().configModel!.refundPolicyStatus == 1;
    return Row(children: [
      // SizedBox(
      //   width: 24.0,
      //   height: 24.0,
      //   child: Checkbox(
      //     activeColor: Theme.of(context).primaryColor,
      //     value: isParcel ? parcelController.acceptTerms : orderController.acceptTerms,
      //     onChanged: (bool? isChecked) => isParcel ? parcelController.toggleTerms() : orderController.toggleTerms(),
      //   ),
      // ),
      // const SizedBox(width: Dimensions.paddingSizeSmall),

      Expanded(
        child: RichText(text: TextSpan(children: [
          TextSpan(
            text: '${'i_have_read_and_agreed_with'.tr} ',
            style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color),
          ),
          TextSpan(
            text: 'privacy_policy'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Get.toNamed(RouteHelper.getHtmlRoute('privacy-policy')),
          ),
          !isParcel && activeRefund ? TextSpan(
            text: ', ',
            style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color),
          ) : TextSpan(
            text: ' ${'and'.tr} ',
            style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color),
          ),
          TextSpan(
            text: 'terms_conditions'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Get.toNamed(RouteHelper.getHtmlRoute('terms-and-condition')),
          ),
          !isParcel && activeRefund ? TextSpan(text: ' ${'and'.tr} ', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyMedium!.color)) : const TextSpan(),

          !isParcel && activeRefund ? TextSpan(
            text: 'refund_policy'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
            recognizer: TapGestureRecognizer()
              ..onTap = () => Get.toNamed(RouteHelper.getHtmlRoute('refund-policy')),
          ) : const TextSpan(),
        ]), textAlign: TextAlign.start, maxLines: 3),
      ),
    ]);
  }
}
