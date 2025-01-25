import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/item_view.dart';
import 'package:sixam_mart/view/base/paginated_list_view.dart';
import 'package:sixam_mart/view/base/veg_filter_widget.dart';
import 'package:sixam_mart/view/screens/store/widget/bottom_cart_widget.dart';

class StoreItemSearchScreen extends StatefulWidget {
  final String? storeID;
  const StoreItemSearchScreen({Key? key, required this.storeID}) : super(key: key);

  @override
  State<StoreItemSearchScreen> createState() => _StoreItemSearchScreenState();
}

class _StoreItemSearchScreenState extends State<StoreItemSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<StoreController>().initSearchData();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(
      builder: (storeController) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size(Dimensions.webMaxWidth, 60),
            child: Container(
              height: 60 + context.mediaQueryPadding.top, width: Dimensions.webMaxWidth,
              padding: EdgeInsets.only(top: context.mediaQueryPadding.top),
              color: Theme.of(context).cardColor,
              alignment: Alignment.center,
              child: SizedBox(width: Dimensions.webMaxWidth, child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                child: Row(children: [

                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).primaryColor),
                  ),

                  Expanded(child: TextField(
                    controller: _searchController,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                    textInputAction: TextInputAction.search,
                    cursorColor: Theme.of(context).primaryColor,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'search_item_in_store'.tr,
                      hintStyle: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor),
                      isDense: true,
                      contentPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search, color: Theme.of(context).hintColor, size: 25),
                        onPressed: () => Get.find<StoreController>().getStoreSearchItemList(
                          _searchController.text.trim(), widget.storeID, 1, Get.find<StoreController>().searchType,
                        ),
                      ),
                    ),
                    onSubmitted: (text) => Get.find<StoreController>().getStoreSearchItemList(
                      _searchController.text.trim(), widget.storeID, 1, Get.find<StoreController>().searchType,
                    ),
                  )),

                  VegFilterWidget(
                    type: storeController.searchText.isNotEmpty ? storeController.searchType : null,
                    onSelected: (String type) {
                      storeController.getStoreSearchItemList(storeController.searchText, widget.storeID, 1, type);
                    },
                    fromAppBar: true,
                  )

                ]),
              )),
            ),
          ),

          body: SingleChildScrollView(
            controller: _scrollController,
            padding: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: FooterView(child: SizedBox(width: Dimensions.webMaxWidth, child: PaginatedListView(
              scrollController: _scrollController,
              onPaginate: (int? offset) => storeController.getStoreSearchItemList(
                storeController.searchText, widget.storeID, offset!, storeController.searchType,
              ),
              totalSize: storeController.storeSearchItemModel != null ? storeController.storeSearchItemModel!.totalSize : null,
              offset: storeController.storeSearchItemModel != null ? storeController.storeSearchItemModel!.offset : null,
              itemView: ItemsView(
                  isStore: false, stores: null,
                  items: storeController.storeSearchItemModel != null ? storeController.storeSearchItemModel!.items : null,
                  inStorePage: true,
              ),
            ))),
          ),

          bottomNavigationBar: GetBuilder<CartController>(builder: (cartController) {
            return cartController.cartList.isNotEmpty && !ResponsiveHelper.isDesktop(context) ? const BottomCartWidget() : const SizedBox();
          })

        );
      }
    );
  }
}
