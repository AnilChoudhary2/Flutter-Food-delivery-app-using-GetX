import 'package:sixam_mart/controller/banner_controller.dart';
import 'package:sixam_mart/controller/campaign_controller.dart';
import 'package:sixam_mart/controller/category_controller.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/item_view.dart';
import 'package:sixam_mart/view/base/paginated_list_view.dart';
import 'package:sixam_mart/view/screens/home/web/module_widget.dart';
import 'package:sixam_mart/view/screens/home/web/web_banner_view.dart';
import 'package:sixam_mart/view/screens/home/web/web_popular_item_view.dart';
import 'package:sixam_mart/view/screens/home/web/web_category_view.dart';
import 'package:sixam_mart/view/screens/home/web/web_campaign_view.dart';
import 'package:sixam_mart/view/screens/home/web/web_popular_store_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebHomeScreen extends StatelessWidget {
  final ScrollController scrollController;
  const WebHomeScreen({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.find<BannerController>().setCurrentIndex(0, false);

    return GetBuilder<SplashController>(builder: (splashController) {
      return Stack(clipBehavior: Clip.none, children: [

        SizedBox(height: context.height),

        SingleChildScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(children: [

            GetBuilder<BannerController>(builder: (bannerController) {
              return bannerController.bannerImageList == null ? WebBannerView(bannerController: bannerController)
                  : bannerController.bannerImageList!.isEmpty ? const SizedBox() : WebBannerView(bannerController: bannerController);
            }),

            FooterView(child: SizedBox(width: Dimensions.webMaxWidth, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

              GetBuilder<CategoryController>(builder: (categoryController) {
                return categoryController.categoryList == null ? WebCategoryView(categoryController: categoryController)
                    : categoryController.categoryList!.isEmpty ? const SizedBox() : WebCategoryView(categoryController: categoryController);
              }),
              const SizedBox(width: Dimensions.paddingSizeLarge),

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  GetBuilder<StoreController>(builder: (storeController) {
                    return storeController.popularStoreList == null ? WebPopularStoreView(storeController: storeController, isPopular: true)
                        : storeController.popularStoreList!.isEmpty ? const SizedBox() : WebPopularStoreView(storeController: storeController, isPopular: true);
                  }),

                  GetBuilder<CampaignController>(builder: (campaignController) {
                    return campaignController.itemCampaignList == null ? WebCampaignView(campaignController: campaignController)
                        : campaignController.itemCampaignList!.isEmpty ? const SizedBox() : WebCampaignView(campaignController: campaignController);
                  }),

                  GetBuilder<ItemController>(builder: (itemController) {
                    return itemController.popularItemList == null ? WebPopularItemView(itemController: itemController, isPopular: true)
                        : itemController.popularItemList!.isEmpty ? const SizedBox() : WebPopularItemView(itemController: itemController, isPopular: true);
                  }),

                  GetBuilder<StoreController>(builder: (storeController) {
                    return storeController.latestStoreList == null ? WebPopularStoreView(storeController: storeController, isPopular: false)
                        : storeController.latestStoreList!.isEmpty ? const SizedBox() : WebPopularStoreView(storeController: storeController, isPopular: false);
                  }),

                  GetBuilder<ItemController>(builder: (itemController) {
                    return itemController.reviewedItemList == null ? WebPopularItemView(itemController: itemController, isPopular: false)
                        : itemController.reviewedItemList!.isEmpty ? const SizedBox() : WebPopularItemView(itemController: itemController, isPopular: false);
                  }),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 0, 5),
                    child: GetBuilder<StoreController>(builder: (storeController) {
                      return Row(children: [
                        Expanded(child: Text(
                          Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                              ? 'all_restaurants'.tr : 'all_stores'.tr,
                          style: robotoMedium.copyWith(fontSize: 24),
                        )),
                        storeController.storeModel != null ? PopupMenuButton(
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(value: 'all', textStyle: robotoMedium.copyWith(
                                color: storeController.storeType == 'all'
                                    ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).disabledColor,
                              ), child: Text('all'.tr)),
                              PopupMenuItem(value: 'take_away', textStyle: robotoMedium.copyWith(
                                color: storeController.storeType == 'take_away'
                                    ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).disabledColor,
                              ), child: Text('take_away'.tr)),
                              PopupMenuItem(value: 'delivery', textStyle: robotoMedium.copyWith(
                                color: storeController.storeType == 'delivery'
                                    ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).disabledColor,
                              ), child: Text('delivery'.tr)),
                            ];
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            child: Icon(Icons.filter_list),
                          ),
                          onSelected: (dynamic value) => storeController.setStoreType(value),
                        ) : const SizedBox(),
                      ]);
                    }),
                  ),

                  GetBuilder<StoreController>(builder: (storeController) {
                    return PaginatedListView(
                      scrollController: scrollController,
                      totalSize: storeController.storeModel != null ? storeController.storeModel!.totalSize : null,
                      offset: storeController.storeModel != null ? storeController.storeModel!.offset : null,
                      onPaginate: (int? offset) async => await storeController.getStoreList(offset!, false),
                      itemView: ItemsView(
                        isStore: true, items: null,
                        stores: storeController.storeModel != null ? storeController.storeModel!.stores : null,
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall,
                          vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0,
                        ),
                      ),
                    );
                  }),

                ]),
              ),

            ]))),
          ]),
        ),

        const Positioned(right: 0, top: 0, bottom: 0, child: Center(child: ModuleWidget())),

      ]);
    });
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;

  SliverDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != 50 || oldDelegate.minExtent != 50 || child != oldDelegate.child;
  }
}
