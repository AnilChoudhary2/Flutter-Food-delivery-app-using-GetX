import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controller/auth_controller.dart';
import '../../../../controller/splash_controller.dart';
import '../../../../controller/store_controller.dart';
import '../../../../controller/wishlist_controller.dart';
import '../../../../data/model/response/config_model.dart';
import '../../../../data/model/response/store_model.dart';
import '../../../../helper/responsive_helper.dart';
import '../../../../helper/route_helper.dart';
import '../../../../util/dimensions.dart';
import '../../../../util/styles.dart';
import '../../../base/custom_image.dart';
import '../../../base/custom_snackbar.dart';
import '../../../base/discount_tag.dart';
import '../../../base/not_available_widget.dart';
import '../../../base/rating_bar.dart';
import '../../store/store_screen.dart';

class StoreWidget extends StatelessWidget {
  final Store store;
  final int index;
  final bool inStore;
  StoreWidget(
      {required this.store, required this.index, this.inStore = false});

  @override
  Widget build(BuildContext context) {
    BaseUrls? _baseUrls = Get.find<SplashController>().configModel?.baseUrls;
    bool _desktop = ResponsiveHelper.isDesktop(context);
    return InkWell(
      onTap: () {
        if (store != null) {
          Get.toNamed(
            RouteHelper.getStoreRoute(store.id, 'item'),
            arguments: StoreScreen(store: store, fromModule: false),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        //height: context.width * 0.5,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
              spreadRadius: 1,
              blurRadius: 5,
            )
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              //borderRadius: BorderRadius.circular(15),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                child: CustomImage(
                  image: '${_baseUrls?.storeCoverPhotoUrl}/${store.coverPhoto}',
                  height: context.width * 0.5,
                  width: Dimensions.webMaxWidth,
                  fit: BoxFit.cover,
                )),
            Get.find<StoreController>().isOpenNow(store)
                ? Container()
                : NotAvailableWidget(isStore: true),
            /*store.distance != null && store.distance < double.infinity
                ? Align(
                    child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    margin: EdgeInsets.only(top: 14),
                    decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(3)),
                    child: Text("${store.distance.toStringAsFixed(2)}KM",
                        style: robotoMedium.copyWith(
                            color: Colors.white, fontSize: 12)),
                  ))
                : Container(),*/
            DiscountTag(
              fromTop: 10,
              discount: Get.find<StoreController>().getDiscount(store),
              discountType: Get.find<StoreController>().getDiscountType(store),
              freeDelivery: store.freeDelivery!,
            ),
          ]),
          Expanded(
              flex: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 17, vertical: 15),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(children: [
                                Expanded(
                                    child: Text(
                                      store.name ?? "",
                                      style: robotoBold.copyWith(fontSize: 17),
                                      maxLines: _desktop ? 2 : 1,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                GetBuilder<WishListController>(
                                    builder: (wishController) {
                                      bool _isWished = wishController
                                          .wishStoreIdList!
                                          .contains(store.id);
                                      return InkWell(
                                        onTap: () {
                                          if (Get.find<AuthController>()
                                              .isLoggedIn()) {
                                            _isWished
                                                ? wishController.removeFromWishList(
                                                store.id, true)
                                                : wishController.addToWishList(
                                                null, store, true);
                                          } else {
                                            showCustomSnackBar(
                                                'you_are_not_logged_in'.tr);
                                          }
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: _desktop
                                                  ? Dimensions.paddingSizeSmall
                                                  : 0),
                                          child: Icon(
                                            _isWished
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            size: _desktop ? 30 : 25,
                                            color: _isWished
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context).disabledColor,
                                          ),
                                        ),
                                      );
                                    }),
                              ]),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  (store.address != null)
                                      ? Flexible(
                                      child: Text(
                                        store.address ?? '',
                                        style: robotoMedium.copyWith(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ))
                                      : Expanded(child: SizedBox()),
                                ],
                              ),
                              SizedBox(height: store.address != null ? 2 : 0),
                              Divider(color: Colors.grey[500]),
                              SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.grey[700], size: 16),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text('${store.avgRating?.toStringAsFixed(1)}',
                                      style: robotoBold.copyWith(
                                          fontSize: 14,
                                          color: Colors.grey[600])),
                                  /*Text(".",
                                      style:
                                          robotoBlack.copyWith(fontSize: 16)),*/
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    store.deliveryTime ?? "",
                                    style: robotoBold.copyWith(
                                        fontSize: 14, color: Colors.grey[600]),
                                    maxLines: _desktop ? 2 : 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  Text("",
                                      style:
                                          robotoBlack.copyWith(fontSize: 16)),
                                  store.distance != null && store.distance! < double.infinity
                                      ? Align(
                                      child: Text(
                                          "${(store.distance!/1000).toStringAsFixed(2)} km",
                                          style: robotoBold.copyWith(
                                              color: Colors.black,
                                              fontSize: 14)))
                                      : const Text('Find km'),
                                ],
                              ), /*
                          RatingBar(
                            rating: store.avgRating,
                            size: _desktop ? 15 : 12,
                            ratingCount: store.ratingCount,
                          ),*/
                            ]),
                      ),
                      //SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                    ]),
              )),
        ]),
      ).paddingOnly(bottom: 6),
    );
  }
}

class StoreShimmer extends StatelessWidget {
  final bool isEnable;
  StoreShimmer({required this.isEnable});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[Get.isDarkMode ? 800 : 300]!,
            spreadRadius: 1,
            blurRadius: 5,
          )
        ],
      ),
      child: Shimmer(
        duration: Duration(seconds: 2),
        enabled: isEnable,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: context.width * 0.3,
            width: Dimensions.webMaxWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Dimensions.radiusSmall)),
              color: Colors.grey[300],
            ),
          ),
          Expanded(
              child: Padding(
                padding:
                EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Row(children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              height: 15, width: 150, color: Colors.grey[300]),
                          SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Container(height: 10, width: 50, color: Colors.grey[300]),
                          SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          RatingBar(rating: 0, size: 12, ratingCount: 0),
                        ]),
                  ),
                  SizedBox(width: Dimensions.paddingSizeSmall),
                  Icon(Icons.favorite_border,
                      size: 25, color: Theme.of(context).disabledColor),
                ]),
              )),
        ]),
      ),
    );
  }
}
