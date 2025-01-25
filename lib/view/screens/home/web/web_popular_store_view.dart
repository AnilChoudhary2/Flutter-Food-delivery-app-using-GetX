import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/theme_controller.dart';
import 'package:sixam_mart/controller/wishlist_controller.dart';
import 'package:sixam_mart/data/model/response/store_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/discount_tag.dart';
import 'package:sixam_mart/view/base/not_available_widget.dart';
import 'package:sixam_mart/view/base/rating_bar.dart';
import 'package:sixam_mart/view/base/title_widget.dart';
import 'package:sixam_mart/view/screens/store/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class WebPopularStoreView extends StatelessWidget {
  final StoreController storeController;
  final bool isPopular;
  const WebPopularStoreView({Key? key, required this.storeController, required this.isPopular}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Store>? storeList = isPopular ? storeController.popularStoreList : storeController.latestStoreList;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
          child: TitleWidget(title: isPopular ? Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
              ? 'popular_restaurants'.tr : 'popular_stores'.tr : '${'new_on'.tr} ${AppConstants.appName}'),
        ),

        storeList != null ? GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: (1/0.7),
            crossAxisSpacing: Dimensions.paddingSizeLarge, mainAxisSpacing: Dimensions.paddingSizeLarge,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
          itemCount: storeList.length > 5 ? 6 : storeList.length,
          itemBuilder: (context, index){

            return Stack(
              children: [
                InkWell(
                  onTap: () {
                    Get.toNamed(
                      RouteHelper.getStoreRoute(storeList[index].id, 'store'),
                      arguments: StoreScreen(store: storeList[index], fromModule: false),
                    );
                  },
                  child: Container(
                    width: 500,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: [BoxShadow(
                        color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]!,
                        blurRadius: 5, spreadRadius: 1,
                      )],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                      Stack(children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                          child: CustomImage(
                            image: '${Get.find<SplashController>().configModel!.baseUrls!.storeCoverPhotoUrl}'
                                '/${storeList[index].coverPhoto}',
                            height: 120, width: 500, fit: BoxFit.cover,
                          ),
                        ),
                        DiscountTag(
                          discount: storeController.getDiscount(storeList[index]),
                          discountType: storeController.getDiscountType(storeList[index]),
                          freeDelivery: storeList[index].freeDelivery,
                        ),
                        storeController.isOpenNow(storeList[index]) ? const SizedBox() : const NotAvailableWidget(isStore: true),
                        Positioned(
                          top: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall,
                          child: GetBuilder<WishListController>(builder: (wishController) {
                            bool isWished = wishController.wishStoreIdList.contains(storeList[index].id);
                            return InkWell(
                              onTap: () {
                                if(Get.find<AuthController>().isLoggedIn()) {
                                  isWished ? wishController.removeFromWishList(storeList[index].id, true)
                                      : wishController.addToWishList(null, storeList[index], true);
                                }else {
                                  showCustomSnackBar('you_are_not_logged_in'.tr);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                ),
                                child: Icon(
                                  isWished ? Icons.favorite : Icons.favorite_border,  size: 20,
                                  color: isWished ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                ),
                              ),
                            );
                          }),
                        ),
                      ]),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(
                              storeList[index].name!,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            Text(
                              storeList[index].address!,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            RatingBar(
                              rating: storeList[index].avgRating,
                              ratingCount: storeList[index].ratingCount,
                              size: 15,
                            ),
                          ]),
                        ),
                      ),

                    ]),
                  ),
                ),

                Visibility(
                  visible: index == 5,
                  child: Positioned(
                    top: 0, bottom: 0, left: 0, right: 0,
                    child: InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getAllStoreRoute(isPopular ? 'popular' : 'latest')),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            gradient: LinearGradient(colors: [
                              Theme.of(context).primaryColor.withOpacity(0.7),
                              Theme.of(context).primaryColor.withOpacity(1),
                            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '+${storeList.length-5}\n${'more'.tr}', textAlign: TextAlign.center,
                          style: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).cardColor),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        ) : PopularStoreShimmer(storeController: storeController),
      ],
    );
  }
}

class PopularStoreShimmer extends StatelessWidget {
  final StoreController storeController;
  const PopularStoreShimmer({Key? key, required this.storeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, childAspectRatio: (1/0.7),
        crossAxisSpacing: Dimensions.paddingSizeLarge, mainAxisSpacing: Dimensions.paddingSizeLarge,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      itemCount: 6,
      itemBuilder: (context, index){
        return Container(
          width: 500,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 10, spreadRadius: 1)]
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Container(
                height: 120, width: 500,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                    color: Colors.grey[300]
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(height: 15, width: 100, color: Colors.grey[300]),
                    const SizedBox(height: 5),

                    Container(height: 10, width: 130, color: Colors.grey[300]),
                    const SizedBox(height: 5),

                    const RatingBar(rating: 0.0, size: 12, ratingCount: 0),
                  ]),
                ),
              ),

            ]),
          ),
        );
      },
    );
  }
}

