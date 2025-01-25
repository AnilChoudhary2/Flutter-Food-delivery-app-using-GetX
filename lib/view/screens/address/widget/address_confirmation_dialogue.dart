import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
class AddressConfirmDialogue extends StatelessWidget {
  final String icon;
  final String? title;
  final String description;
  final Function onYesPressed;
  const AddressConfirmDialogue({Key? key, required this.icon, this.title, required this.description, required this.onYesPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: PointerInterceptor(
        child: SizedBox(
          width: 500,
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Image.asset(icon, width: 50, height: 50),
              ),

              title != null ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                child: Text(
                  title!, textAlign: TextAlign.center,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Colors.red),
                ),
              ) : const SizedBox(),

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Text(description, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor), textAlign: TextAlign.center),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              GetBuilder<LocationController>(builder: (locationController) {
                return !locationController.isLoading ? Row(children: [
                  Expanded(child: TextButton(
                    onPressed: () => onYesPressed(),
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error, minimumSize: const Size(Dimensions.webMaxWidth, 50), padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                    ),
                    child: Text(
                      'delete'.tr, textAlign: TextAlign.center,
                      style: robotoBold.copyWith(color: Theme.of(context).cardColor),
                    ),
                  )),
                  const SizedBox(width: Dimensions.paddingSizeLarge),

                  Expanded(child: CustomButton(
                    buttonText:  'cancel'.tr, textColor: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5),
                    onPressed: () => Get.back(),
                    radius: Dimensions.radiusSmall, height: 50, color: Theme.of(context).disabledColor.withOpacity(0.4),
                  )),
                ]) : const Center(child: CircularProgressIndicator());
              }),

            ]),
          ),
        ),
      ),
    );
  }
}
