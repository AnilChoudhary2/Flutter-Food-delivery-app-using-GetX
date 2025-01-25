import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/coupon_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/store_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/item_widget.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/no_data_screen.dart';
import 'package:sixam_mart/view/base/web_constrained_box.dart';
import 'package:sixam_mart/view/screens/cart/widget/cart_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/screens/store/store_screen.dart';

import 'widget/not_available_bottom_sheet.dart';

class CartScreen extends StatefulWidget {
  final bool fromNav;
  const CartScreen({Key? key, required this.fromNav}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    if(Get.find<CartController>().cartList.isNotEmpty){
      if(Get.find<CartController>().addCutlery){
        Get.find<CartController>().updateCutlery(isUpdate: false);
      }
      Get.find<CartController>().setAvailableIndex(-1, isUpdate: false);
      Get.find<StoreController>().getCartStoreSuggestedItemList(Get.find<CartController>().cartList[0].item!.storeId);
      Get.find<StoreController>().getStoreDetails(Store(id: Get.find<CartController>().cartList[0].item!.storeId, name: null), false, fromCart: true);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'my_cart'.tr, backButton: (ResponsiveHelper.isDesktop(context) || !widget.fromNav)),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<CartController>(builder: (cartController) {

        return cartController.cartList.isNotEmpty ? Column(
          children: [

            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.only(
                    top: Dimensions.paddingSizeSmall,
                  ) : EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  child: FooterView(
                    child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Column(children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                // Product
                                WebConstrainedBox(
                                  dataLength: cartController.cartList.length, minLength: 5, minHeight: 0.6,
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: cartController.cartList.length,
                                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                      itemBuilder: (context, index) {
                                        return CartItemWidget(cart: cartController.cartList[index], cartIndex: index, addOns: cartController.addOnsList[index], isAvailable: cartController.availableList[index]);
                                      },
                                    ),

                                    const Divider(thickness: 0.5, height: 5),

                                    Padding(
                                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                                      child: TextButton.icon(
                                        onPressed: (){
                                          cartController.forcefullySetModule(cartController.cartList[0].item!.moduleId!);
                                          Get.toNamed(
                                            RouteHelper.getStoreRoute(cartController.cartList[0].item!.storeId, 'item'),
                                            arguments: StoreScreen(store: Store(id: cartController.cartList[0].item!.storeId), fromModule: false),
                                          );
                                        },
                                        icon: Icon(Icons.add_circle_outline_sharp, color: Theme.of(context).primaryColor),
                                        label: Text('add_more_items'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault)),
                                      ),
                                    ),

                                    !ResponsiveHelper.isDesktop(context) ? suggestedItemView(cartController.cartList) : const SizedBox(),

                                  ]),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                !ResponsiveHelper.isDesktop(context) ? pricingView(cartController, cartController.cartList[0].item!) : const SizedBox(),

                              ]),
                            ),

                            ResponsiveHelper.isDesktop(context) ? Expanded(flex: 4, child: pricingView(cartController, cartController.cartList[0].item!)) : const SizedBox(),
                          ],
                        ),

                        ResponsiveHelper.isDesktop(context) ? suggestedItemView(cartController.cartList) : const SizedBox(),
                      ]),
                    ),
                  ),
                ),
              ),
            ),

            ResponsiveHelper.isDesktop(context) ? const SizedBox.shrink() : CheckoutButton(cartController: cartController, availableList: cartController.availableList),

          ],
        ) : const NoDataScreen(isCart: true, text: '', showFooter: true);
      },
      ),
    );
  }

  Widget pricingView(CartController cartController, Item item){
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, blurRadius: 5, spreadRadius: 1)],
      ),
      child: GetBuilder<StoreController>(
        builder: (storeController) {
          return Column(children: [

            Get.find<SplashController>().getModuleConfig(item.moduleType).newVariation!
            && (storeController.store != null && storeController.store!.cutlery!) ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Image.asset(Images.cutlery, height: 18, width: 18),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('add_cutlery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text('do_not_have_cutlery'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                  ]),
                ),

                Transform.scale(
                  scale: 0.7,
                  child: CupertinoSwitch(
                    value: cartController.addCutlery,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (bool? value) {
                      cartController.updateCutlery();
                    },
                    trackColor: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                )

              ]),
            ) : const SizedBox(),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              margin: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall) : EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: (){
                      if(ResponsiveHelper.isDesktop(context)){
                        Get.dialog(const Dialog(child: NotAvailableBottomSheet()));
                      }else{
                        showModalBottomSheet(
                          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                          builder: (con) => const NotAvailableBottomSheet(),
                        );
                      }
                    },
                    child: Row(children: [
                      Expanded(child: Text('if_any_product_is_not_available'.tr, style: robotoMedium, maxLines: 2, overflow: TextOverflow.ellipsis)),
                      const Icon(Icons.arrow_forward_ios_sharp, size: 18),
                    ]),
                  ),


                  cartController.notAvailableIndex != -1 ? Row(children: [
                    Text(cartController.notAvailableList[cartController.notAvailableIndex].tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),

                    IconButton(
                      onPressed: ()=> cartController.setAvailableIndex(-1),
                      icon: const Icon(Icons.clear, size: 18),
                    )
                  ]) : const SizedBox(),
                ],
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Total
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('item_price'.tr, style: robotoRegular),
                  Text(PriceConverter.convertPrice(cartController.itemPrice), style: robotoRegular, textDirection: TextDirection.ltr),
                ]),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('discount'.tr, style: robotoRegular),
                  Text('(-) ${PriceConverter.convertPrice(cartController.itemDiscountPrice)}', style: robotoRegular, textDirection: TextDirection.ltr),
                ]),
                SizedBox(height: Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? 10 : 0),

                Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('addons'.tr, style: robotoRegular),
                    Text('(+) ${PriceConverter.convertPrice(cartController.addOns)}', style: robotoRegular, textDirection: TextDirection.ltr),
                  ],
                ) : const SizedBox(),

                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                //   child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                // ),
              ]),
            ),

            ResponsiveHelper.isDesktop(context) ? CheckoutButton(cartController: cartController, availableList: cartController.availableList) : const SizedBox.shrink(),

          ]);
        }
      ),
    );
  }

  Widget suggestedItemView(List<CartModel> cartList){
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        // boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.1), blurRadius: 10)]
      ),
      width: double.infinity,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        GetBuilder<StoreController>(builder: (storeController) {
          List<Item>? suggestedItems;
          if(storeController.cartSuggestItemModel != null){
            suggestedItems = [];
            List<int> cartIds = [];
            for (CartModel cartItem in cartList) {
              cartIds.add(cartItem.item!.id!);
            }
            for (Item item in storeController.cartSuggestItemModel!.items!) {
              if(cartIds.contains(item.id)){
                if (kDebugMode) {
                  print('it will not added -> ${storeController.cartSuggestItemModel!.items!.indexOf(item)}');
                }
              }else{
                suggestedItems.add(item);
              }
            }
          }
          return storeController.cartSuggestItemModel != null && suggestedItems!.isNotEmpty ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                child: Text('you_may_also_like'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
              ),

              SizedBox(
                height: ResponsiveHelper.isDesktop(context) ? 150 : 125,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: suggestedItems.length,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: 20) : const EdgeInsets.symmetric(vertical: 10) ,
                      child: Container(
                        width: ResponsiveHelper.isDesktop(context) ? 500 : 300,
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeExtraSmall),
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: ItemWidget(
                          isStore: false, item: suggestedItems![index], fromCartSuggestion: true,
                          store: null, index: index, length: null, isCampaign: false, inStore: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ) : const SizedBox();
        }),
      ]),
    );
  }

}

class CheckoutButton extends StatelessWidget {
  final CartController cartController;
  final List<bool> availableList;
  const CheckoutButton({Key? key, required this.cartController, required this.availableList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double percentage = 0;

    return Container(
      width: Dimensions.webMaxWidth,
      padding:  const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: ResponsiveHelper.isDesktop(context) ? null : [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.2), blurRadius: 10)]
      ),
      child: GetBuilder<StoreController>(
        builder: (storeController) {
          if(Get.find<StoreController>().store != null && !Get.find<StoreController>().store!.freeDelivery! && Get.find<SplashController>().configModel!.freeDeliveryOver != null){
            percentage = cartController.subTotal/Get.find<SplashController>().configModel!.freeDeliveryOver!;
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              (storeController.store != null && !storeController.store!.freeDelivery!
                  && Get.find<SplashController>().configModel!.freeDeliveryOver != null && percentage < 1)
              ? Column(children: [
                  Row(children: [
                    Image.asset(Images.percentTag, height: 20, width: 20),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text(
                      PriceConverter.convertPrice(Get.find<SplashController>().configModel!.freeDeliveryOver! - cartController.subTotal),
                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor), textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text('more_for_free_delivery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                  ]),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                LinearProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  value: percentage,
                ),
              ]) : const SizedBox(),


              Padding(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('subtotal'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                    Text(
                      PriceConverter.convertPrice(cartController.subTotal),
                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor), textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),

              SafeArea(
                child: CustomButton(buttonText: 'proceed_to_checkout'.tr, onPressed: () {

                  if(!cartController.cartList.first.item!.scheduleOrder! && availableList.contains(false)) {
                    showCustomSnackBar('one_or_more_product_unavailable'.tr);
                  } else {
                    if(Get.find<SplashController>().module == null) {
                      int i = 0;
                      for(i = 0; i < Get.find<SplashController>().moduleList!.length; i++){
                        if(cartController.cartList[0].item!.moduleId == Get.find<SplashController>().moduleList![i].id){
                          break;
                        }
                      }
                      Get.find<SplashController>().setModule(Get.find<SplashController>().moduleList![i]);
                    }
                    Get.find<CouponController>().removeCouponData(false);

                    Get.toNamed(RouteHelper.getCheckoutRoute('cart'));
                  }
                }),
              ),
            ],
          );
        }
      ),
    );
  }
}
