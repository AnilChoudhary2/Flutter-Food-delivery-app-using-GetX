import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/screens/checkout/widget/payment_button_new.dart';
class PaymentMethodBottomSheet extends StatelessWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final int? storeId;
  const PaymentMethodBottomSheet({Key? key, required this.isCashOnDeliveryActive, required this.isDigitalPaymentActive, required this.isWalletActive, required this.storeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
        child: GetBuilder<OrderController>(
          builder: (orderController) {
            return Column(children: [

              !ResponsiveHelper.isDesktop(context) ? Container(
                height: 4, width: 35,
                margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
              ) : const SizedBox(),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('choose_payment_method'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                IconButton(
                  onPressed: ()=> Get.back(),
                  icon: Icon(Icons.clear, color: Theme.of(context).disabledColor),
                )
              ]),

              const SizedBox(height: Dimensions.paddingSizeSmall),

              storeId == null && isDigitalPaymentActive ? PaymentButtonNew(
                icon: Images.digitalPayment,
                title: 'digital_payment'.tr,
                isSelected: orderController.paymentMethodIndex == 1,
                onTap: (){
                  orderController.setPaymentMethod(1);
                  Get.back();
                },
              ) : const SizedBox(),
              SizedBox(height: storeId == null && isDigitalPaymentActive ? Dimensions.paddingSizeSmall : 0),


              isCashOnDeliveryActive ? PaymentButtonNew(
                icon: Images.codIcon,
                title: 'cash_on_delivery'.tr,
                isSelected: orderController.paymentMethodIndex == 0,
                onTap: () {
                  orderController.setPaymentMethod(0);
                  Get.back();
                },
              ) : const SizedBox(),
              SizedBox(height: isCashOnDeliveryActive ? Dimensions.paddingSizeSmall : 0),


              storeId == null && isWalletActive ? PaymentButtonNew(
                icon: Images.wallet,
                title: 'wallet_payment'.tr,
                isSelected: orderController.paymentMethodIndex == 2,
                onTap: () {
                  orderController.setPaymentMethod(2);
                  Get.back();
                },
              ) : const SizedBox(),
            ]);
          }
        ),
      ),
    );
  }
}
