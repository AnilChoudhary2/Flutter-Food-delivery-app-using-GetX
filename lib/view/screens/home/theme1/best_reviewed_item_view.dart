import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/theme_controller.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/discount_tag.dart';
import 'package:sixam_mart/view/base/not_available_widget.dart';
import 'package:sixam_mart/view/base/organic_tag.dart';
import 'package:sixam_mart/view/base/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class BestReviewedItemView extends StatelessWidget {
  const BestReviewedItemView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      List<Item>? itemList = itemController.reviewedItemList;

      return (itemList != null && itemList.isEmpty) ? const SizedBox() : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
            child: TitleWidget(
              title: 'best_reviewed_item'.tr,
              onTap: () => Get.toNamed(RouteHelper.getPopularItemRoute(false)),
            ),
          ),

          SizedBox(
            height: 220,
            child: itemList != null ? ListView.builder(
              controller: ScrollController(),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
              itemCount: itemList.length > 10 ? 10 : itemList.length,
              itemBuilder: (context, index){

                return Padding(
                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: 5),
                  child: InkWell(
                    onTap: () {
                      Get.find<ItemController>().navigateToItemPage(itemList[index], context);
                    },
                    child: Container(
                      height: 220,
                      width: 180,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        boxShadow: [BoxShadow(
                          color: Colors.grey[Get.find<ThemeController>().darkTheme ? 800 : 300]!,
                          blurRadius: 5, spreadRadius: 1,
                        )],
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                        Stack(children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                            child: CustomImage(
                              image: '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}/${itemList[index].image}',
                              height: 125, width: 170, fit: BoxFit.cover,
                            ),
                          ),
                          DiscountTag(
                            discount: itemList[index].discount, discountType: itemList[index].discountType,
                            inLeft: true,
                          ),
                          itemController.isAvailable(itemList[index]) ? const SizedBox() : const NotAvailableWidget(isStore: true),
                          Positioned(
                            top: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              child: Row(children: [
                                Icon(Icons.star, color: Theme.of(context).primaryColor, size: 15),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                Text(itemList[index].avgRating!.toStringAsFixed(1), style: robotoRegular),
                              ]),
                            ),
                          ),

                          OrganicTag(item: itemList[index], placeTop: itemList[index].discount! == 0),
                        ]),

                        Expanded(
                          child: Stack(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                                Center(
                                  child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                                    Text(
                                      itemList[index].name ?? '', textAlign: TextAlign.center,
                                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                    (Get.find<SplashController>().configModel!.moduleConfig!.module!.vegNonVeg! && Get.find<SplashController>().configModel!.toggleVegNonVeg!)
                                        ? Image.asset(itemList[index].veg == 0 ? Images.nonVegImage : Images.vegImage,
                                        height: 10, width: 10, fit: BoxFit.contain) : const SizedBox(),
                                  ]),
                                ),
                                const SizedBox(height: 2),

                                Text(
                                  itemList[index].storeName ?? '', textAlign: TextAlign.center,
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),

                                (Get.find<SplashController>().configModel!.moduleConfig!.module!.unit! && itemList[index].unitType != null) ? Text(
                                  '(${itemList[index].unitType ?? ''})', textAlign: TextAlign.center,
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
                                ) : const SizedBox(),
                                const SizedBox(height: 2),

                                Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                  itemController.getDiscount(itemList[index])! > 0  ? Flexible(child: Text(
                                    PriceConverter.convertPrice(itemController.getStartingPrice(itemList[index])),
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).colorScheme.error,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  )) : const SizedBox(),
                                  SizedBox(width: itemList[index].discount! > 0 ? Dimensions.paddingSizeExtraSmall : 0),
                                  Text(
                                    PriceConverter.convertPrice(
                                      itemController.getStartingPrice(itemList[index]), discount: itemController.getDiscount(itemList[index]),
                                      discountType: itemController.getDiscountType(itemList[index]),
                                    ),
                                    style: robotoMedium, textDirection: TextDirection.ltr,
                                  ),
                                ]),
                              ]),
                            ),
                            Positioned(bottom: 0, right: 0, child: Container(
                              height: 25, width: 25,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).primaryColor
                              ),
                              child: const Icon(Icons.add, size: 20, color: Colors.white),
                            )),
                          ]),
                        ),

                      ]),
                    ),
                  ),
                );
              },
            ) : BestReviewedItemShimmer(itemController: itemController),
          ),
        ],
      );
    });
  }
}

class BestReviewedItemShimmer extends StatelessWidget {
  final ItemController itemController;
  const BestReviewedItemShimmer({Key? key, required this.itemController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
      itemCount: 10,
      itemBuilder: (context, index){
        return Padding(
          padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: 5),
          child: Container(
            height: 220, width: 180,
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: [BoxShadow(
                color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]!,
                blurRadius: 5, spreadRadius: 1,
              )],
            ),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: itemController.reviewedItemList == null,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                Stack(children: [
                  Container(
                    height: 125, width: 170,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusSmall)),
                      color: Colors.grey[300],
                    ),
                  ),
                  Positioned(
                    top: Dimensions.paddingSizeExtraSmall, right: Dimensions.paddingSizeExtraSmall,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: Dimensions.paddingSizeExtraSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Row(children: [
                        Icon(Icons.star, color: Theme.of(context).primaryColor, size: 15),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text('0.0', style: robotoRegular),
                      ]),
                    ),
                  ),
                ]),

                Expanded(
                  child: Stack(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Container(height: 15, width: 100, color: Colors.grey[300]),
                        const SizedBox(height: 2),

                        Container(height: 10, width: 70, color: Colors.grey[300]),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Container(height: 10, width: 40, color: Colors.grey[300]),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Container(height: 15, width: 40, color: Colors.grey[300]),
                        ]),
                      ]),
                    ),
                    Positioned(bottom: 0, right: 0, child: Container(
                      height: 25, width: 25,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor
                      ),
                      child: const Icon(Icons.add, size: 20, color: Colors.white),
                    )),
                  ]),
                ),

              ]),
            ),
          ),
        );
      },
    );
  }
}