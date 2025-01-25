
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/controller/wallet_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/custom_text_field.dart';

class WalletBottomSheet extends StatefulWidget {
  final bool fromWallet;
  final String amount;
  const WalletBottomSheet({Key? key, required this.fromWallet, required this.amount}) : super(key: key);

  @override
  State<WalletBottomSheet> createState() => _WalletBottomSheetState();
}

class _WalletBottomSheetState extends State<WalletBottomSheet> {

  final TextEditingController _amountController = TextEditingController();


  int? exchangePointRate = Get.find<SplashController>().configModel!.loyaltyPointExchangeRate ?? 0;
  int? minimumExchangePoint = Get.find<SplashController>().configModel!.minimumPointToTransfer ?? 0;

  @override
  void initState() {
    super.initState();

    _amountController.text = exchangePointRate!.toString();
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Container(
          width: 550,
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
          ),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              Image.asset(Images.creditIcon, height: 50, width: 50),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  '$exchangePointRate ${'points'.tr}= ',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
                Text(
                  PriceConverter.convertPrice(1), textDirection: TextDirection.ltr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                '(${'from'.tr} ${widget.amount} ${'points'.tr})',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                'amount_can_be_convert_into_wallet_money'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              CustomTextField(
                titleText: '0',
                controller: _amountController,
                inputType: TextInputType.phone,
                maxLines: 1,
                textAlign: TextAlign.start,
              ),

              const SizedBox(height: Dimensions.paddingSizeLarge),

              GetBuilder<WalletController>(
                  builder: (walletController) {
                    return !walletController.isLoading ? CustomButton(
                      buttonText: 'convert'.tr, width: context.width/3, radius: 50,
                      onPressed: () {
                        if(_amountController.text.isEmpty) {
                          if(Get.isBottomSheetOpen!){
                            Get.back();
                          }
                          showCustomSnackBar('input_field_is_empty'.tr);
                        }else{
                          int amount = int.parse(_amountController.text.trim());
                          int? point = Get.find<UserController>().userInfoModel!.loyaltyPoint;

                          if(amount <minimumExchangePoint!){
                            if(Get.isBottomSheetOpen!){
                              Get.back();
                            }
                            showCustomSnackBar('${'please_exchange_more_then'.tr} $minimumExchangePoint ${'points'.tr}');
                          }else if(point! < amount){
                            if(Get.isBottomSheetOpen!){
                              Get.back();
                            }
                            showCustomSnackBar('you_do_not_have_enough_point_to_exchange'.tr);
                          } else {
                            walletController.pointToWallet(amount, widget.fromWallet);
                          }
                        }
                      },
                    ) : const Center(child: CircularProgressIndicator());
                  }
              ),
            ]),
          ),
        ),
        Positioned(
          top: 10, right: 10,
          child: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.clear, size: 18),
          ),
        ),
      ],
    );
  }
}
