import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/base/veg_filter_widget.dart';

import '../../controller/splash_controller.dart';
import '../../data/model/response/item_model.dart';
import '../../data/model/response/store_model.dart';
import '../../helper/responsive_helper.dart';
import '../../util/dimensions.dart';
import '../screens/home/theme1/store_widget.dart';
import 'item_shimmer.dart';
import 'item_widget.dart';
import 'no_data_screen.dart';

class ItemsView extends StatelessWidget {


  final List<Item?>? items;
  final List<Store?>? stores;
  final bool? isStore;
  final EdgeInsetsGeometry padding;
  final bool isScrollable;
  final int shimmerLength;
  final String? noDataText;
  final bool isCampaign;
  final bool inStorePage;
  final String? type;
  final bool isFeatured;
  final bool showTheme1Store;
  final Function(String type)? onVegFilterTap;

  ItemsView(
      {required this.stores,
        required this.items,
        required this.isStore,
        this.isScrollable = false,
        this.shimmerLength = 20,
        this.padding = const EdgeInsets.all(Dimensions.paddingSizeSmall),
        this.noDataText,
        this.isCampaign = false,
        this.inStorePage = false,
        this.type,
        this.onVegFilterTap,
        this.isFeatured = false,
        this.showTheme1Store = false});

  @override
  Widget build(BuildContext context) {
    print("items.length");
    print(items?.length.toString());
    print("""""::::""");
    bool _isNull = true;
    int _length = 0;
    if (isStore ?? false) {
      _isNull = stores == null;
      if (!_isNull) {
        _length = stores!.length;
      }
    } else {
      _isNull = items == null;
      if (!_isNull) {
        _length = items!.length;
      }
    }

    return Column(children: [
      type != null
          ? VegFilterWidget(type: type!, onSelected: onVegFilterTap!)
          : SizedBox(),
      !_isNull
          ? _length > 0
          ? showTheme1Store ? DynamicHeightGridView(
        crossAxisSpacing: Dimensions.paddingSizeLarge,
        mainAxisSpacing: ResponsiveHelper.isDesktop(context)
            ? Dimensions.paddingSizeLarge
            : 0.01,
        crossAxisCount:
        ResponsiveHelper.isMobile(context) ? 1 : 2,
        shrinkWrap: isScrollable ? false : true,
        physics: isScrollable
            ? BouncingScrollPhysics()
            : NeverScrollableScrollPhysics(),
        itemCount: _length,
        builder: (context, index) {
          return showTheme1Store
              ? StoreWidget(
              store: stores![index]!,
              index: index,
              inStore: inStorePage)
              : ItemWidget(
            isStore: isStore!,
            item: isStore! ? null : items![index],
            store: isStore! ? stores![index] : null,
            index: index,
            length: _length,
            isCampaign: isCampaign,
            inStore: inStorePage,
          );
        },
      ).paddingSymmetric(horizontal: 12) : Padding(
        padding: const EdgeInsets.only(top: 15),
        child: GridView.builder(
          key: UniqueKey(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: Dimensions.paddingSizeLarge,
            mainAxisSpacing: ResponsiveHelper.isDesktop(context)
                ? Dimensions.paddingSizeLarge
                : 0.01,
            childAspectRatio: ResponsiveHelper.isDesktop(context)
                ? 4
                : showTheme1Store
                ? 1.9
                : 3.6,
            crossAxisCount:
            ResponsiveHelper.isMobile(context) ? 1 : 2,
          ),
          physics: isScrollable
              ? BouncingScrollPhysics()
              : NeverScrollableScrollPhysics(),
          shrinkWrap: isScrollable ? false : true,
          itemCount: _length,
          padding: padding,
          itemBuilder: (context, index) {
            return showTheme1Store
                ? StoreWidget(
                store: stores![index]!,
                index: index,
                inStore: inStorePage)
                : ItemWidget(
              isStore: isStore!,
              item: isStore! ? null : items![index],
              store: isStore! ? stores![index] : null,
              index: index,
              length: _length,
              isCampaign: isCampaign,
              inStore: inStorePage,
            );
          },
        ),
      )

          : NoDataScreen(
        text: noDataText != null
            ? noDataText!
            : isStore!
            ? Get.find<SplashController>()
            .configModel!
            .moduleConfig!
            .module!
            .showRestaurantText!
            ? 'no_restaurant_available'.tr
            : 'no_store_available'.tr
            : 'no_item_available'.tr,
      )
          : GridView.builder(
        key: UniqueKey(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: Dimensions.paddingSizeLarge,
          mainAxisSpacing: ResponsiveHelper.isDesktop(context)
              ? Dimensions.paddingSizeLarge
              : 0.01,
          childAspectRatio: ResponsiveHelper.isDesktop(context)
              ? 4
              : showTheme1Store
              ? 1.9
              : 4,
          //childAspectRatio: 6,
          crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
        ),
        physics: isScrollable
            ? BouncingScrollPhysics()
            : NeverScrollableScrollPhysics(),
        shrinkWrap: isScrollable ? false : true,
        itemCount: shimmerLength,
        padding: padding,
        itemBuilder: (context, index) {
          return showTheme1Store
              ? StoreShimmer(isEnable: _isNull)
              : ItemShimmer(
              isEnabled: _isNull,
              isStore: isStore!,
              hasDivider: index != shimmerLength - 1);
        },
      ),
    ]);
  }
}
