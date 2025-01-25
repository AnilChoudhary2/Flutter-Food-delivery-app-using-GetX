import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/search_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/web_menu_bar.dart';
import 'package:sixam_mart/view/screens/search/widget/filter_widget.dart';
import 'package:sixam_mart/view/screens/search/widget/search_field.dart';
import 'package:sixam_mart/view/screens/search/widget/search_result_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/screens/store/widget/bottom_cart_widget.dart';

class SearchScreen extends StatefulWidget {
  final String? queryText;
  const SearchScreen({Key? key, required this.queryText}) : super(key: key);

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();

    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if(_isLoggedIn) {
      Get.find<SearchingController>().getSuggestedItems();
    }
    Get.find<SearchingController>().getHistoryList();
    if(widget.queryText!.isNotEmpty) {
      _actionSearch(true, widget.queryText, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(Get.find<SearchingController>().isSearchMode) {
          return true;
        }else {
          Get.find<SearchingController>().setSearchMode(true);
          return false;
        }
      },
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
        body: SafeArea(child: Padding(
          padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          child: GetBuilder<SearchingController>(builder: (searchController) {
            _searchController.text = searchController.searchText!;
            return Column(children: [

              widget.queryText!.isNotEmpty ? const SizedBox() : Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Row(children: [
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(child: SearchField(
                  controller: _searchController,
                  hint: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                      ? 'search_food_or_restaurant'.tr : 'search_item_or_store'.tr,
                  suffixIcon: !searchController.isSearchMode ? Icons.filter_list : Icons.search,
                  iconPressed: () => _actionSearch(false, _searchController.text.trim(), false),
                  onSubmit: (text) => _actionSearch(true, _searchController.text.trim(), false),
                )),
                CustomButton(
                  onPressed: () => searchController.isSearchMode ? Get.back() : searchController.setSearchMode(true),
                  buttonText: 'cancel'.tr,
                  transparent: true,
                  width: 80,
                ),
              ]))),

              Expanded(child: searchController.isSearchMode ? SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: FooterView(
                  child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    searchController.historyList.isNotEmpty ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('history'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      InkWell(
                        onTap: () => searchController.clearSearchAddress(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: 4),
                          child: Text('clear_all'.tr, style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor,
                          )),
                        ),
                      ),
                    ]) : const SizedBox(),

                    ListView.builder(
                      itemCount: searchController.historyList.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Column(children: [
                          Row(children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => searchController.searchData(searchController.historyList[index], false),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                  child: Text(
                                    searchController.historyList[index]!,
                                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => searchController.removeHistory(index),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                                child: Icon(Icons.close, color: Theme.of(context).disabledColor, size: 20),
                              ),
                            )
                          ]),
                          index != searchController.historyList.length-1 ? const Divider() : const SizedBox(),
                        ]);
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    (_isLoggedIn && searchController.suggestedItemList != null) ? Text(
                      'suggestions'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ) : const SizedBox(),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    (_isLoggedIn && searchController.suggestedItemList != null) ? searchController.suggestedItemList!.isNotEmpty ?  GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 4, childAspectRatio: (1/ 0.4),
                        mainAxisSpacing: Dimensions.paddingSizeSmall, crossAxisSpacing: Dimensions.paddingSizeSmall,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: searchController.suggestedItemList!.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Get.find<ItemController>().navigateToItemPage(searchController.suggestedItemList![index], context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            child: Row(children: [
                              const SizedBox(width: Dimensions.paddingSizeSmall),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                child: CustomImage(
                                  image: '${Get.find<SplashController>().configModel!.baseUrls!.itemImageUrl}'
                                      '/${searchController.suggestedItemList![index].image}',
                                  width: 45, height: 45, fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),
                              Expanded(child: Text(
                                searchController.suggestedItemList![index].name!,
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                              )),
                            ]),
                          ),
                        );
                      },
                    ) : Padding(padding: const EdgeInsets.only(top: 10), child: Text('no_suggestions_available'.tr)) : const SizedBox(),
                  ])),
                ),
              ) : SearchResultWidget(searchText: _searchController.text.trim())),

            ]);
          }),
        )),

          bottomNavigationBar: GetBuilder<CartController>(builder: (cartController) {
            return cartController.cartList.isNotEmpty && !ResponsiveHelper.isDesktop(context) ? const BottomCartWidget() : const SizedBox();
          })
      ),
    );
  }

  void _actionSearch(bool isSubmit, String? queryText, bool fromHome) {
    if(Get.find<SearchingController>().isSearchMode || isSubmit) {
      if(queryText!.isNotEmpty) {
        Get.find<SearchingController>().searchData(queryText, fromHome);
      }else {
        showCustomSnackBar(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
            ? 'search_food_or_restaurant'.tr : 'search_item_or_store'.tr);
      }
    }else {
      List<double?> prices = [];
      if(!Get.find<SearchingController>().isStore) {
        for (var product in Get.find<SearchingController>().allItemList!) {
          prices.add(product.price);
        }
        prices.sort();
      }
      double? maxValue = prices.isNotEmpty ? prices[prices.length-1] : 1000;
      Get.dialog(FilterWidget(maxValue: maxValue, isStore: Get.find<SearchingController>().isStore));
    }
  }
}
