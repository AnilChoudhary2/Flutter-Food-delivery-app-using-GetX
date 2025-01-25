import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/item_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';

class AllStoreScreen extends StatefulWidget {
  final bool isPopular;
  final bool isFeatured;
  const AllStoreScreen({Key? key, required this.isPopular, required this.isFeatured}) : super(key: key);

  @override
  State<AllStoreScreen> createState() => _AllStoreScreenState();
}

class _AllStoreScreenState extends State<AllStoreScreen> {

  @override
  void initState() {
    super.initState();

    if(widget.isFeatured) {
      Get.find<StoreController>().getFeaturedStoreList();
    }else if(widget.isPopular) {
      Get.find<StoreController>().getPopularStoreList(false, 'all', false);
    }else {
      Get.find<StoreController>().getLatestStoreList(false, 'all', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      builder: (storeController) {
        return Scaffold(
          appBar: CustomAppBar(
            title: widget.isFeatured ? 'featured_stores'.tr :  widget.isPopular
              ? Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
              ? 'popular_restaurants'.tr : 'popular_stores'.tr : '${'new_on'.tr} ${AppConstants.appName}',
            type: widget.isFeatured ? null : storeController.type,
            onVegFilterTap: (String type) {
              if(widget.isPopular) {
                Get.find<StoreController>().getPopularStoreList(true, type, true);
              }else {
                Get.find<StoreController>().getLatestStoreList(true, type, true);
              }
            },
          ),
          endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
          body: RefreshIndicator(
            onRefresh: () async {
              if(widget.isFeatured) {
                await Get.find<StoreController>().getFeaturedStoreList();
              }else if(widget.isPopular) {
                await Get.find<StoreController>().getPopularStoreList(
                  true, Get.find<StoreController>().type, false,
                );
              }else {
                await Get.find<StoreController>().getLatestStoreList(
                  true, Get.find<StoreController>().type, false,
                );
              }
            },
            child: Scrollbar(child: SingleChildScrollView(child: FooterView(child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: GetBuilder<StoreController>(builder: (storeController) {
                return ItemsView(
                  isStore: true, items: null, isFeatured: widget.isFeatured,
                  noDataText: widget.isFeatured ? 'no_store_available'.tr : Get.find<SplashController>().configModel!.moduleConfig!
                      .module!.showRestaurantText! ? 'no_restaurant_available'.tr : 'no_store_available'.tr,
                  stores: widget.isFeatured ? storeController.featuredStoreList : widget.isPopular ? storeController.popularStoreList
                      : storeController.latestStoreList,
                );
              }),
            )))),
          ),
        );
      }
    );
  }
}
