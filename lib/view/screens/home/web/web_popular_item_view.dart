import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/theme_controller.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/discount_tag.dart';
import 'package:sixam_mart/view/base/not_available_widget.dart';
import 'package:sixam_mart/view/base/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class WebPopularItemView extends StatelessWidget {
  final bool isPopular;
  final ItemController itemController;
  const WebPopularItemView({Key? key, required this.itemController, required this.isPopular}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Item>? itemList = isPopular ? itemController.popularItemList : itemController.reviewedItemList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: Text(isPopular ? 'popular_items_nearby'.tr : 'best_reviewed_item'.tr, style: robotoMedium.copyWith(fontSize: 24)),
        ),

        itemList != null ? GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: (1/0.35),
            crossAxisSpacing: Dimensions.paddingSizeLarge, mainAxisSpacing: Dimensions.paddingSizeLarge,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
          itemCount: itemList.length > 5 ? 6 : itemList.length,
          itemBuilder: (context, index){

            return Stack(
              children: [
                InkWell(
                  onTap: () {
                    Get.find<ItemController>().navigateToItemPage(itemList[index], context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: [BoxShadow(
                        color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]!,
                        blurRadius: 5, spreadRadius: 1,
                      )],
                    ),
                    child: Row(children: [

                      Stack(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImage(
                            image: '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}'
                                '/${itemList[index].image}',
                            height: 90, width: 90, fit: BoxFit.cover,
                          ),
                        ),
                        DiscountTag(
                          discount: itemController.getDiscount(itemList[index]),
                          discountType: itemController.getDiscountType(itemList[index]),
                        ),
                        itemController.isAvailable(itemList[index]) ? const SizedBox() : const NotAvailableWidget(),
                      ]),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(
                              itemList[index].name!,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                            Text(
                              itemList[index].storeName!,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),

                            RatingBar(
                              rating: itemList[index].avgRating, size: 15,
                              ratingCount: itemList[index].ratingCount,
                            ),

                            Row(
                              children: [
                                Text(
                                  PriceConverter.convertPrice(
                                    itemList[index].price, discount: itemList[index].discount, discountType: itemList[index].discountType,
                                  ), textDirection: TextDirection.ltr,
                                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                                ),
                                SizedBox(width: itemList[index].discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),
                                itemList[index].discount! > 0 ? Expanded(child: Text(
                                  PriceConverter.convertPrice(itemController.getStartingPrice(itemList[index])),
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor,
                                    decoration: TextDecoration.lineThrough,
                                  ), textDirection: TextDirection.ltr,
                                )) : const Expanded(child: SizedBox()),
                                const Icon(Icons.add, size: 25),
                              ],
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
                      onTap: () => Get.toNamed(RouteHelper.getPopularItemRoute(isPopular)),
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
                          '+${itemList.length-5}\n${'more'.tr}', textAlign: TextAlign.center,
                          style: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).cardColor),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        ) : WebCampaignShimmer(enabled: itemList == null),
      ],
    );
  }
}

class WebCampaignShimmer extends StatelessWidget {
  final bool enabled;
  const WebCampaignShimmer({Key? key, required this.enabled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, childAspectRatio: (1/0.35),
        crossAxisSpacing: Dimensions.paddingSizeLarge, mainAxisSpacing: Dimensions.paddingSizeLarge,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      itemCount: 6,
      itemBuilder: (context, index){
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 10, spreadRadius: 1)],
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: enabled,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Container(
                height: 90, width: 90,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.grey[300]),
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
                    const SizedBox(height: 5),

                    Container(height: 10, width: 30, color: Colors.grey[300]),
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

