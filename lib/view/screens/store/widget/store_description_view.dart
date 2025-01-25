import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/wishlist_controller.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/data/model/response/store_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreDescriptionView extends StatelessWidget {
  final Store? store;
  const StoreDescriptionView({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isAvailable = Get.find<StoreController>().isStoreOpenNow(store!.active!, store!.schedules);
    Color? textColor = ResponsiveHelper.isDesktop(context) ? Colors.white : null;
    // Module? moduleData;
    // for(ZoneData zData in Get.find<LocationController>().getUserAddress()!.zoneData!) {
    //   for(Modules m in zData.modules!) {
    //     if(m.id == Get.find<SplashController>().module!.id) {
    //       moduleData = m as Module?;
    //       break;
    //     }
    //   }
    // }
    return Column(children: [
      ResponsiveHelper.isDesktop(context) ? Row(children: [

        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          child: Stack(children: [
            CustomImage(
              image: '${Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl}/${store!.logo}',
              height: ResponsiveHelper.isDesktop(context) ? 80 : 60, width: ResponsiveHelper.isDesktop(context) ? 100 : 70, fit: BoxFit.cover,
            ),
            isAvailable ? const SizedBox() : Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(Dimensions.radiusSmall)),
                  color: Colors.black.withOpacity(0.6),
                ),
                child: Text(
                  'closed_now'.tr, textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(
              store!.name!, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: textColor),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            )),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            ResponsiveHelper.isDesktop(context) ? InkWell(
              onTap: () => Get.toNamed(RouteHelper.getSearchStoreItemRoute(store!.id)),
              child: ResponsiveHelper.isDesktop(context) ? Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), color: Theme.of(context).primaryColor),
                child: const Center(child: Icon(Icons.search, color: Colors.white)),
              ) : Icon(Icons.search, color: Theme.of(context).primaryColor),
            ) : const SizedBox(),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            GetBuilder<WishListController>(builder: (wishController) {
              bool isWished = wishController.wishStoreIdList.contains(store!.id);
              return InkWell(
                onTap: () {
                  if(Get.find<AuthController>().isLoggedIn()) {
                    isWished ? wishController.removeFromWishList(store!.id, true)
                        : wishController.addToWishList(null, store, true);
                  }else {
                    showCustomSnackBar('you_are_not_logged_in'.tr);
                  }
                },
                child: ResponsiveHelper.isDesktop(context) ? Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), color: Theme.of(context).primaryColor),
                  child: Center(child: Icon(isWished ? Icons.favorite : Icons.favorite_border, color: Colors.white)),
                ) : Icon(
                  isWished ? Icons.favorite : Icons.favorite_border,
                  color: isWished ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                ),
              );
            }),
          ]),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            store!.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
          ),
          SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0),
          Row(children: [
            Text('minimum_order'.tr, style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
            )),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              PriceConverter.convertPrice(store!.minimumOrder), textDirection: TextDirection.ltr,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor),
            ),
          ]),
        ])),

      ]) : const SizedBox(),
      SizedBox(height: ResponsiveHelper.isDesktop(context) ? 30 : Dimensions.paddingSizeSmall),

      Row(children: [
        const Expanded(child: SizedBox()),
        InkWell(
          onTap: () => Get.toNamed(RouteHelper.getStoreReviewRoute(store!.id)),
          child: Column(children: [
            Row(children: [
              Icon(Icons.star, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text(
                store!.avgRating!.toStringAsFixed(1),
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: textColor),
              ),
            ]),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              '${store!.ratingCount} ${'ratings'.tr}',
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: textColor),
            ),
          ]),
        ),
        const Expanded(child: SizedBox()),
        InkWell(
          onTap: () => Get.toNamed(RouteHelper.getMapRoute(
            AddressModel(
              id: store!.id, address: store!.address, latitude: store!.latitude,
              longitude: store!.longitude, contactPersonNumber: '', contactPersonName: '', addressType: '',
            ), 'store', Get.find<SplashController>().getModuleConfig(Get.find<SplashController>().module!.moduleType!).newVariation!
          )),
          child: Column(children: [
            Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 20),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text('location'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: textColor)),
          ]),
        ),
        const Expanded(child: SizedBox()),
        Column(children: [
          Row(children: [
            Icon(Icons.timer, color: Theme.of(context).primaryColor, size: 20),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              store!.deliveryTime!,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: textColor),
            ),
          ]),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Text('delivery_time'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: textColor)),
        ]),
        (store!.delivery! && store!.freeDelivery!) ? const Expanded(child: SizedBox()) : const SizedBox(),
        (store!.delivery! && store!.freeDelivery!) ? Column(children: [
          Icon(Icons.money_off, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Text('free_delivery'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: textColor)),
        ]) : const SizedBox(),
        const Expanded(child: SizedBox()),
      ]),
    ]);
  }
}
