import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/wishlist_controller.dart';
import 'package:sixam_mart/data/model/response/config_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/module_model.dart';
import 'package:sixam_mart/data/model/response/store_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/corner_banner/banner.dart';
import 'package:sixam_mart/view/base/corner_banner/corner_discount_tag.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/discount_tag.dart';
import 'package:sixam_mart/view/base/not_available_widget.dart';
import 'package:sixam_mart/view/base/organic_tag.dart';
import 'package:sixam_mart/view/base/rating_bar.dart';
import 'package:sixam_mart/view/screens/store/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ItemWidget extends StatelessWidget {
  final Item? item;
  final Store? store;
  final bool isStore;
  final int index;
  final int? length;
  final bool inStore;
  final bool isCampaign;
  final bool isFeatured;
  final bool fromCartSuggestion;
  const ItemWidget({Key? key, required this.item, required this.isStore, required this.store, required this.index,
   required this.length, this.inStore = false, this.isCampaign = false, this.isFeatured = false, this.fromCartSuggestion = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool ltr = Get.find<LocalizationController>().isLtr;
    BaseUrls? baseUrls = Get.find<SplashController>().configModel!.baseUrls;
    bool desktop = ResponsiveHelper.isDesktop(context);
    double? discount;
    String? discountType;
    bool isAvailable;
    if(isStore) {
      discount = store!.discount != null ? store!.discount!.discount : 0;
      discountType = store!.discount != null ? store!.discount!.discountType : 'percent';
      // bool _isClosedToday = Get.find<StoreController>().isRestaurantClosed(true, store.active, store.offDay);
      // _isAvailable = DateConverter.isAvailable(store.openingTime, store.closeingTime) && store.active && !_isClosedToday;
      isAvailable = store!.open == 1 && store!.active!;
    }else {
      discount = (item!.storeDiscount == 0 || isCampaign) ? item!.discount : item!.storeDiscount;
      discountType = (item!.storeDiscount == 0 || isCampaign) ? item!.discountType : 'percent';
      isAvailable = DateConverter.isAvailable(item!.availableTimeStarts, item!.availableTimeEnds);
    }

    return InkWell(
      onTap: () {
        if(isStore) {
          if(store != null) {
            if(isFeatured && Get.find<SplashController>().moduleList != null) {
              for(ModuleModel module in Get.find<SplashController>().moduleList!) {
                if(module.id == store!.moduleId) {
                  Get.find<SplashController>().setModule(module);
                  break;
                }
              }
            }
            Get.toNamed(
              RouteHelper.getStoreRoute(store!.id, isFeatured ? 'module' : 'item'),
              arguments: StoreScreen(store: store, fromModule: isFeatured),
            );
          }
        }else {
          if(isFeatured && Get.find<SplashController>().moduleList != null) {
            for(ModuleModel module in Get.find<SplashController>().moduleList!) {
              if(module.id == item!.moduleId) {
                Get.find<SplashController>().setModule(module);
                break;
              }
            }
          }
          Get.find<ItemController>().navigateToItemPage(item, context, inStore: inStore, isCampaign: isCampaign);
        }
      },
      child: Stack(
        children: [
          Container(
            padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.all(Dimensions.paddingSizeSmall) : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
            margin: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).cardColor,
              boxShadow: ResponsiveHelper.isDesktop(context) ? [BoxShadow(
                color: Colors.grey[Get.isDarkMode ? 700 : 300]!, spreadRadius: 1, blurRadius: 5,
              )] : [BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(5, 5)
              )],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

              Expanded(child: Padding(
                padding: EdgeInsets.symmetric(vertical: desktop ? 0 : Dimensions.paddingSizeExtraSmall),
                child: Row(children: [

                  Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: CustomImage(
                        image: '${isCampaign ? baseUrls!.campaignImageUrl : isStore ? baseUrls!.storeImageUrl
                            : baseUrls!.itemImageUrl}'
                            '/${isStore ? store != null ? store!.logo : '' : item!.image}',
                        height: desktop ? 120 : length == null ? 100 : 65, width: desktop ? 120 : 80, fit: BoxFit.cover,
                      ),
                    ),

                    isStore ? DiscountTag(
                      discount: discount, discountType: discountType,
                      freeDelivery: isStore ? store!.freeDelivery : false,
                    ) : const SizedBox(),

                    !isStore ? OrganicTag(item: item!, placeInImage: true) : const SizedBox(),

                    isAvailable ? const SizedBox() : NotAvailableWidget(isStore: isStore),
                  ]),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                      Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                        Text(
                          isStore ? store!.name! : item!.name!,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                          maxLines: desktop ? 2 : 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        (Get.find<SplashController>().configModel!.moduleConfig!.module!.vegNonVeg! && Get.find<SplashController>().configModel!.toggleVegNonVeg!)
                            ? Image.asset(item != null && item!.veg == 0 ? Images.nonVegImage : Images.vegImage,
                            height: 10, width: 10, fit: BoxFit.contain) : const SizedBox(),
                      ]),
                      SizedBox(height: isStore ? Dimensions.paddingSizeExtraSmall : 0),

                      (isStore ? store!.address != null : item!.storeName != null) ? Text(
                        isStore ? store!.address ?? '' : item!.storeName ?? '',
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).disabledColor,
                        ),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ) : const SizedBox(),
                      SizedBox(height: ((desktop || isStore) && (isStore ? store!.address != null : item!.storeName != null)) ? 5 : 0),

                      !isStore ? RatingBar(
                        rating: isStore ? store!.avgRating : item!.avgRating, size: desktop ? 15 : 12,
                        ratingCount: isStore ? store!.ratingCount : item!.ratingCount,
                      ) : const SizedBox(),
                      SizedBox(height: (!isStore && desktop) ? Dimensions.paddingSizeExtraSmall : 0),

                      (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && item != null && item!.unitType != null) ? Text(
                        '(${ item!.unitType ?? ''})',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
                      ) : const SizedBox(),

                      isStore ? RatingBar(
                        rating: isStore ? store!.avgRating : item!.avgRating, size: desktop ? 15 : 12,
                        ratingCount: isStore ? store!.ratingCount : item!.ratingCount,
                      ) : Row(children: [

                        Text(
                          PriceConverter.convertPrice(item!.price, discount: discount, discountType: discountType),
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall), textDirection: TextDirection.ltr,
                        ),
                        SizedBox(width: discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),

                        discount > 0 ? Text(
                          PriceConverter.convertPrice(item!.price),
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).disabledColor,
                            decoration: TextDecoration.lineThrough,
                          ), textDirection: TextDirection.ltr,
                        ) : const SizedBox(),

                      ]),

                    ]),
                  ),

                  Column(mainAxisAlignment: isStore ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween, children: [

                    const SizedBox(),

                    fromCartSuggestion ? Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      child: Icon(Icons.add, color: Theme.of(context).cardColor),
                    ) : GetBuilder<WishListController>(builder: (wishController) {
                      bool isWished = isStore ? wishController.wishStoreIdList.contains(store!.id)
                          : wishController.wishItemIdList.contains(item!.id);
                      return InkWell(
                        onTap: !wishController.isRemoving ? () {
                          if(Get.find<AuthController>().isLoggedIn()) {
                            isWished ? wishController.removeFromWishList(isStore ? store!.id : item!.id, isStore)
                                : wishController.addToWishList(item, store, isStore);
                          }else {
                            showCustomSnackBar('you_are_not_logged_in'.tr);
                          }
                        } : null,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: desktop ? Dimensions.paddingSizeSmall : 0),
                          child: Icon(
                            isWished ? Icons.favorite : Icons.favorite_border,  size: desktop ? 30 : 25,
                            color: isWished ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                          ),
                        ),
                      );
                    }),

                  ]),

                ]),
              )),

            ]),
          ),

          !isStore ? Positioned(
            right: ltr ? 0 : null, left: ltr ? null : 0,
            child: CornerDiscountTag(
              bannerPosition: ltr ? CornerBannerPosition.topRight : CornerBannerPosition.topLeft,
              elevation: 0,
              discount: discount, discountType: discountType,
              freeDelivery: isStore ? store!.freeDelivery : false,
            ),

          ) : const SizedBox(),
        ],
      ),
    );
  }
}
