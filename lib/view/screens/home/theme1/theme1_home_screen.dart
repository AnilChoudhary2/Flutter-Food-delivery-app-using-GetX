import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/notification_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/item_view.dart';
import 'package:sixam_mart/view/base/paginated_list_view.dart';
import 'package:sixam_mart/view/screens/home/home_screen.dart';
import 'package:sixam_mart/view/screens/home/theme1/banner_view1.dart';
import 'package:sixam_mart/view/screens/home/theme1/best_reviewed_item_view.dart';
import 'package:sixam_mart/view/screens/home/theme1/category_view1.dart';
import 'package:sixam_mart/view/screens/home/theme1/item_campaign_view1.dart';
import 'package:sixam_mart/view/screens/home/theme1/popular_item_view1.dart';
import 'package:sixam_mart/view/screens/home/theme1/popular_store_view1.dart';
import 'package:sixam_mart/view/screens/home/widget/filter_view.dart';
import 'package:sixam_mart/view/screens/home/widget/module_view.dart';

import '../../../../drawer.dart';
import '../../menu/menu_screen_new.dart';

class Theme1HomeScreen extends StatelessWidget {
  final ScrollController scrollController;
  final SplashController splashController;
  final bool showMobileModule;

  Theme1HomeScreen(
      {Key? key,
      required this.scrollController,
      required this.splashController,
      required this.showMobileModule})
      : super(key: key);

  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey<ScaffoldState>();

  void _openEndDrawer() {
    _drawerKey.currentState!.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // endDrawer: const MenuScreenNew(),
      endDrawer: Drawer(
          width: 300,
          child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(left: 20),
              color: Colors.transparent,
              child: draweraa())),
      endDrawerEnableOpenDragGesture: true,
      drawer: Drawer(
          width: 200,
          child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(left: 20),
              color: Colors.transparent,
              child: MenuScreenNew())),
      body: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: ResponsiveHelper.isDesktop(context)
                ? Colors.transparent
                : Theme.of(context).colorScheme.onPrimaryContainer,
            title: Center(
                child: Container(
              width: Dimensions.webMaxWidth,
              height: 50,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              child: Row(children: [
                // (splashController.module != null && splashController.configModel!.module == null) ? InkWell(
                //   onTap: () => splashController.removeModule(),
                //   child: Image.asset(Images.moduleIcon, height: 22, width: 22),
                // ) : const SizedBox(),
                SizedBox(
                    width: (splashController.module != null &&
                            splashController.configModel!.module == null)
                        ? Dimensions.paddingSizeExtraSmall
                        : 0),
                Expanded(
                    child: InkWell(
                  onTap: () => Get.find<LocationController>()
                      .navigateToLocationScreen('home'),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeSmall,
                      horizontal: ResponsiveHelper.isDesktop(context)
                          ? Dimensions.paddingSizeSmall
                          : 0,
                    ),
                    child: GetBuilder<LocationController>(
                        builder: (locationController) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            locationController.getUserAddress()!.addressType ==
                                    'home'
                                ? Icons.home_filled
                                : locationController
                                            .getUserAddress()!
                                            .addressType ==
                                        'office'
                                    ? Icons.work
                                    : Icons.location_on,
                            size: 20,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              locationController.getUserAddress()!.address!,
                              style: robotoRegular.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color),
                        ],
                      );
                    }),
                  ),
                )),
                InkWell(
                  child: GetBuilder<NotificationController>(
                      builder: (notificationController) {
                    return Stack(children: [
                      Icon(Icons.notifications,
                          size: 25,
                          color: Theme.of(context).textTheme.bodyLarge!.color),
                      notificationController.hasNotification
                          ? Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 1,
                                      color: Theme.of(context).cardColor),
                                ),
                              ))
                          : const SizedBox(),
                    ]);
                  }),
                  onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                ),
                InkWell(
                  child: GetBuilder<NotificationController>(
                      builder: (notificationController) {
                    return Stack(children: [
                      Icon(Icons.menu,
                          size: 25,
                          color: Theme.of(context).textTheme.bodyLarge!.color),
                      notificationController.hasNotification
                          ? Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 1,
                                      color: Theme.of(context).cardColor),
                                ),
                              ))
                          : const SizedBox(),
                    ]);
                  }),
                  onTap: () => Scaffold.of(context).openEndDrawer(),
                ),
              ]),
            )),
            actions: const [SizedBox()],
          ),
          SliverToBoxAdapter(
            child: BannerView1(isFeatured: false),
          ),
          // Search Button
          !showMobileModule ? SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverDelegate(
                      child: Center(
                          child: Container(
                    height: 50,
                    width: Dimensions.webMaxWidth,
                    color: Theme.of(context).colorScheme.background,
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall),
                    child: InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                                spreadRadius: 1,
                                blurRadius: 5)
                          ],
                        ),
                        child: Row(children: [
                          const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall),
                          Icon(
                            Icons.search,
                            size: 25,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall),
                          Expanded(
                              child: Text(
                            Get.find<SplashController>()
                                    .configModel!
                                    .moduleConfig!
                                    .module!
                                    .showRestaurantText!
                                ? 'search_food_or_restaurant'.tr
                                : 'search_item_or_store'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                            ),
                          )),
                        ]),
                      ),
                    ),
                  ))
                  ),
                )
              : const SliverToBoxAdapter(),

          SliverToBoxAdapter(
            child: Center(
                child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: !showMobileModule
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         // const BannerView1(isFeatured: false),

                           CategoryView1(),
                          //    const ItemCampaignView1(),
                          //     const BestReviewedItemView(),
                          //   const PopularStoreView1(isPopular: true, isFeatured: false),
                          //  const PopularItemView1(isPopular: true),
//              const PopularStoreView1(isPopular: false, isFeatured: false),
//SizedBox(height: 20,),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 15, 0, 5),
                            child: Row(children: [
                              Expanded(
                                  child: Text(
                                Get.find<SplashController>()
                                        .configModel!
                                        .moduleConfig!
                                        .module!
                                        .showRestaurantText!
                                    ? 'all_restaurants'.tr
                                    : 'all_stores'.tr,
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge),
                              )),
                              const FilterView(),
                            ]),
                          ),

                          GetBuilder<StoreController>(
                              builder: (storeController) {
                            return PaginatedListView(
                              scrollController: scrollController,
                              totalSize: storeController.storeModel != null
                                  ? storeController.storeModel!.totalSize
                                  : null,
                              offset: storeController.storeModel != null
                                  ? storeController.storeModel!.offset
                                  : null,
                              onPaginate: (int? offset) async =>
                                  await storeController.getStoreList(
                                      offset!, false),
                              itemView: ItemsView(
                                isStore: true,
                                items: null,
                                showTheme1Store: true,
                                stores: storeController.storeModel != null
                                    ? storeController.storeModel!.stores
                                    : null,
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      ResponsiveHelper.isDesktop(context)
                                          ? Dimensions.paddingSizeExtraSmall
                                          : Dimensions.paddingSizeSmall,
                                  vertical: ResponsiveHelper.isDesktop(context)
                                      ? Dimensions.paddingSizeExtraSmall
                                      : 0,
                                ),
                              ),
                            );
                          }),
                        ])
                  : ModuleView(splashController: splashController),
            )),
          ),
        ],
      ),
    );
  }
}
