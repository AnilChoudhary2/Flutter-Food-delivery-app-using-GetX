import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/item_bottom_sheet.dart';
import 'package:sixam_mart/view/base/quantity_button.dart';
import 'package:sixam_mart/view/base/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controller/order_controller.dart';

class CartItemWidget extends StatelessWidget {
   bool isOpenBottomSheet = true;
  final CartModel cart;
  final int cartIndex;
  final List<AddOns> addOns;
  final bool isAvailable;
   CartItemWidget({Key? key, this.isOpenBottomSheet = true, required this.cart, required this.cartIndex, required this.isAvailable, required this.addOns}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String addOnText = '';
    int index0 = 0;
    List<int?> ids = [];
    List<int?> qtys = [];
    for (var addOn in cart.addOnIds!) {
      ids.add(addOn.id);
      qtys.add(addOn.quantity);
    }
    for (var addOn in cart.item!.addOns!) {
      if (ids.contains(addOn.id)) {
        addOnText = '$addOnText${(index0 == 0) ? '' : ',  '}${addOn.name} (${qtys[index0]})';
        index0 = index0 + 1;
      }
    }

    String? variationText = '';
    if(Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation!) {
      if(cart.foodVariations!.isNotEmpty) {
        for(int index=0; index<cart.foodVariations!.length; index++) {
          if(cart.foodVariations![index].contains(true)) {
            variationText = '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${cart.item!.foodVariations![index].name} (';
            for(int i=0; i<cart.foodVariations![index].length; i++) {
              if(cart.foodVariations![index][i]!) {
                variationText = '${variationText!}${variationText.endsWith('(') ? '' : ', '}${cart.item!.foodVariations![index].variationValues![i].level}';
              }
            }
            variationText = '${variationText!})';
          }
        }
      }
    }else {
      if(cart.variation!.isNotEmpty) {
        List<String> variationTypes = cart.variation![0].type!.split('-');
        if(variationTypes.length == cart.item!.choiceOptions!.length) {
          int index0 = 0;
          for (var choice in cart.item!.choiceOptions!) {
            variationText = '${variationText!}${(index0 == 0) ? '' : ',  '}${choice.title} - ${variationTypes[index0]}';
            index0 = index0 + 1;
          }
        }else {
          variationText = cart.item!.variations![0].type;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      child: InkWell(
        onTap: () {
          if(isOpenBottomSheet){
            ResponsiveHelper.isMobile(context) ? showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (con) => ItemBottomSheet(item: cart.item, cartIndex: cartIndex, cart: cart),
            ) : showDialog(context: context, builder: (con) => Dialog(
              child: ItemBottomSheet(item: cart.item, cartIndex: cartIndex, cart: cart),
            ));
          }

        },
        child: Slidable(
          key: UniqueKey(),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.2,
            children: [
              SlidableAction(
                onPressed: (context)=> Get.find<CartController>().removeFromCart(cartIndex),
                backgroundColor: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.horizontal(right: Radius.circular(Get.find<LocalizationController>().isLtr ? Dimensions.radiusDefault : 0), left: Radius.circular(Get.find<LocalizationController>().isLtr ? 0 : Dimensions.radiusDefault)),
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: [BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                blurRadius: 5, spreadRadius: 1,
              )],
            ),
            child: Column(
              children: [

                Row(children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        child: CustomImage(
                          image: '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}/${cart.item!.image}',
                          height: 65, width: 70, fit: BoxFit.cover,
                        ),
                      ),
                      isAvailable ? const SizedBox() : Positioned(
                        top: 0, left: 0, bottom: 0, right: 0,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.black.withOpacity(0.6)),
                          child: Text('not_available_now_break'.tr, textAlign: TextAlign.center, style: robotoRegular.copyWith(
                            color: Colors.white, fontSize: 8,
                          )),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Row(children: [
                        Flexible(
                          child: Text(
                            cart.item!.name!,
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        ((Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && cart.item!.unitType != null && !Get.find<SplashController>().getModuleConfig(cart.item!.moduleType).newVariation!)
                        || (Get.find<SplashController>().configModel!.moduleConfig!.module!.vegNonVeg! && Get.find<SplashController>().configModel!.toggleVegNonVeg!)) ? Container(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                          ),
                          child: Text(
                            Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! ? cart.item!.unitType ?? ''
                                : cart.item!.veg == 0 ? 'non_veg'.tr : 'veg'.tr,
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
                          ),
                        ) : const SizedBox(),
                      ]),
                      const SizedBox(height: 2),

                      RatingBar(rating: cart.item!.avgRating, size: 12, ratingCount: cart.item!.ratingCount),
                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Text(
                            PriceConverter.convertPrice(cart.discountedPrice),
                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), textDirection: TextDirection.ltr,
                          ),

                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          cart.discountedPrice!+cart.discountAmount! > cart.discountedPrice! ? Text(
                            PriceConverter.convertPrice(cart.discountedPrice!+cart.discountAmount!), textDirection: TextDirection.ltr,
                            style: robotoMedium.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall, decoration: TextDecoration.lineThrough),
                          ) : const SizedBox(),
                        ],
                      ),
                    ]),
                  ),

                  Row(children: [
                    QuantityButton(
                      onTap: () {
                        if (cart.quantity! > 1) {
                          Get.find<CartController>().setQuantity(false, cartIndex, cart.stock);
                        }else {
                          Get.find<CartController>().removeFromCart(cartIndex);
                          Get.back();
                        }
                        Get.find<OrderController>().update();
                      },
                      isIncrement: false,
                      showRemoveIcon: cart.quantity! == 1,
                    ),
                    Text(cart.quantity.toString(), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),

                    QuantityButton(
                      onTap: () {
                        Get.find<CartController>().forcefullySetModule(Get.find<CartController>().cartList[0].item!.moduleId!);
                        Get.find<CartController>().setQuantity(true, cartIndex, cart.stock);
                       // orderController.update();
                        Get.find<OrderController>().update();
                      },
                      isIncrement: true,
                    ),
                  ]),

                  !ResponsiveHelper.isMobile(context) ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    child: IconButton(
                      onPressed: () {
                        Get.find<CartController>().removeFromCart(cartIndex);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ) : const SizedBox(),

                ]),

                (Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! && addOnText.isNotEmpty) ? Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                  child: Row(children: [
                    const SizedBox(width: 80),
                    Text('${'addons'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                    Flexible(child: Text(
                      addOnText,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    )),
                  ]),
                ) : const SizedBox(),

                variationText!.isNotEmpty ? Padding(
                  padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                  child: Row(children: [
                    const SizedBox(width: 80),
                    Text('${'variations'.tr}: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                    Flexible(child: Text(
                      variationText,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    )),
                  ]),
                ) : const SizedBox(),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
