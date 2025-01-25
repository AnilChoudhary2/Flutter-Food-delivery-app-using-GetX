import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/wishlist_controller.dart';
import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/confirmation_dialog.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/screens/checkout/checkout_screen.dart';
import 'package:sixam_mart/view/screens/item/item_details_screen.dart';
import 'package:sixam_mart/view/screens/item/widget/item_title_view.dart';

class DetailsWebView extends StatelessWidget {
  final CartModel? cartModel;
  final int? stock;
  final double priceWithAddOns;
  const DetailsWebView({Key? key, required this.cartModel, required this.stock, required this.priceWithAddOns}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      List<String?> imageList = [];
      imageList.add(itemController.item!.image);
      imageList.addAll(itemController.item!.images!);

      String? baseUrl = itemController.item!.availableDateStarts == null ? Get.find<SplashController>().
      configModel!.baseUrls!.itemImageUrl : Get.find<SplashController>().configModel!.baseUrls!.campaignImageUrl;

      return SingleChildScrollView(child: FooterView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height -560),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            const SizedBox(height: 20),
            Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4,child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: Get.size.height*0.5,
                          child: CustomImage(
                            fit: BoxFit.cover,
                            image: '$baseUrl/${imageList[itemController.productSelect]}',
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(height: 70, child: itemController.item!.image != null ? ListView.builder(
                          itemCount: imageList.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context,index){
                            return Padding(
                              padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                              child: InkWell(
                                onTap: () => itemController.setSelect(index,true),
                                child: Container(
                                  width: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    border: Border.all(color: index == itemController.productSelect ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                        width: index == itemController.productSelect ? 2 : 1),
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: CustomImage(
                                    fit: BoxFit.cover,
                                    image: '$baseUrl/${imageList[index]}',
                                  ),
                                ),
                              ),
                            );
                          },
                        ) : const SizedBox(),)
                      ],
                    ),
                  )),
                  const SizedBox(width: 40),
                  Expanded(flex: 6, child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ItemTitleView(item: itemController.item, inStock: Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! && stock! <= 0),
                        const SizedBox(height: 35),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: itemController.item!.choiceOptions!.length,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(itemController.item!.choiceOptions![index].title!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                              GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: ResponsiveHelper.isDesktop(context) ? 6.5 : (1 / 0.25),
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: itemController.item!.choiceOptions![index].options!.length,
                                itemBuilder: (context, i) {
                                  return InkWell(
                                    onTap: () {
                                      itemController.setCartVariationIndex(index, i, itemController.item);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                      decoration: BoxDecoration(
                                        color: itemController.variationIndex![index] != i ? Theme.of(context).disabledColor : Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(5),
                                        border: itemController.variationIndex![index] != i ? Border.all(color: Theme.of(context).disabledColor, width: 2) : null,
                                      ),
                                      child: Text(
                                        itemController.item!.choiceOptions![index].options![i].trim(), maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: robotoRegular.copyWith(
                                          color: itemController.variationIndex![index] != i ? Colors.black : Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: index != itemController.item!.choiceOptions!.length-1 ? Dimensions.paddingSizeLarge : 0),
                            ]);
                          },
                        ),

                        const SizedBox(height: 30),

                        GetBuilder<CartController>(builder: (cartController) {
                          return Row(children: [
                            QuantityButton(
                              isIncrement: false, quantity: itemController.cartIndex != -1 ? cartController.cartList[itemController.cartIndex].quantity : itemController.quantity,
                              stock: stock, isExistInCart : itemController.cartIndex != -1, cartIndex: itemController.cartIndex,
                            ),
                            const SizedBox(width: 30),

                            Text(
                              itemController.cartIndex != -1 ? cartController.cartList[itemController.cartIndex].quantity.toString() : itemController.quantity.toString(),
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                            ),
                            const SizedBox(width: 30),

                            QuantityButton(
                              isIncrement: true, quantity: itemController.cartIndex != -1 ? cartController.cartList[itemController.cartIndex].quantity : itemController.quantity,
                              stock: stock, cartIndex: itemController.cartIndex, isExistInCart: itemController.cartIndex != -1,
                            ),

                          ]);
                        }),
                        const SizedBox(height: 30),

                        GetBuilder<CartController>(
                          builder: (cartController) {
                            return Row(children: [
                              Text('${'total_amount'.tr}:', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              Text(PriceConverter.convertPrice(itemController.cartIndex != -1 ?
                              (cartController.cartList[itemController.cartIndex].discountedPrice! * cartController.cartList[itemController.cartIndex].quantity!)
                                  : priceWithAddOns), textDirection: TextDirection.ltr, style: robotoBold.copyWith(
                                color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge,
                              )),
                            ]);
                          }
                        ),
                        const SizedBox(height: 30),

                        SizedBox(width: 400, child: Row(children: [
                          Expanded(flex:5, child: CustomButton(
                            buttonText: (Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! && stock! <= 0) ? 'out_of_stock'.tr
                                : itemController.item!.availableDateStarts != null ? 'order_now'.tr : itemController.cartIndex != -1 ? 'update_in_cart'.tr : 'add_to_cart'.tr,
                            onPressed: (!Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! || stock! > 0) ?  () {
                              if(itemController.item!.availableDateStarts != null) {
                                Get.toNamed(RouteHelper.getCheckoutRoute('campaign'), arguments: CheckoutScreen(
                                  storeId: null, fromCart: false, cartList: [cartModel],
                                ));
                              }else if (Get.find<CartController>().existAnotherStoreItem(cartModel!.item!.storeId, Get.find<SplashController>().module!.id)) {
                                Get.dialog(ConfirmationDialog(
                                  icon: Images.warning,
                                  title: 'are_you_sure_to_reset'.tr,
                                  description: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                                      ? 'if_you_continue'.tr : 'if_you_continue_without_another_store'.tr,
                                  onYesPressed: () {
                                    Get.back();
                                    Get.find<CartController>().removeAllAndAddToCart(cartModel!);
                                    showCustomSnackBar('item_added_to_cart'.tr, isError: false);
                                  },
                                ), barrierDismissible: false);
                              } else {
                                if(itemController.cartIndex == -1) {
                                  Get.find<CartController>().addToCart(cartModel!, itemController.cartIndex);
                                }
                                showCustomSnackBar('item_added_to_cart'.tr, isError: false);
                              }
                            } : null,
                          )),
                          const SizedBox(width: Dimensions.paddingSizeLarge),
                          Expanded(
                            flex:1,
                            child: Container(
                              padding: const EdgeInsets.all(8), alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              child: GetBuilder<WishListController>(
                                  builder: (wishController) {
                                    return InkWell(
                                      onTap: () {
                                        if(Get.find<AuthController>().isLoggedIn()){
                                          if(wishController.wishItemIdList.contains(itemController.item!.id)) {
                                            wishController.removeFromWishList(itemController.item!.id, false);
                                          }else {
                                            wishController.addToWishList(itemController.item, null, false);
                                          }
                                        }else {
                                          showCustomSnackBar('you_are_not_logged_in'.tr);
                                        }
                                      },
                                      child: Icon(
                                        wishController.wishItemIdList.contains(itemController.item!.id) ? Icons.favorite : Icons.favorite_border, size: 25,
                                        color: wishController.wishItemIdList.contains(itemController.item!.id) ? Theme.of(context).cardColor : Theme.of(context).disabledColor,
                                      ),
                                    );
                                  }
                              ),
                            ),
                          ),
                        ])),

                        (itemController.item!.description != null && itemController.item!.description!.isNotEmpty) ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                            Text('description'.tr, style: robotoMedium),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                            Text(itemController.item!.description!, style: robotoRegular),
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                          ],
                        ) : const SizedBox(),

                      ]),
                  )),
                ]))),
          ]),
        ),
      ));
    });
  }
}
