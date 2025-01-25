import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/search_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/text_hover.dart';
import 'package:sixam_mart/view/screens/auth/sign_in_screen.dart';
import 'package:sixam_mart/view/screens/search/widget/search_field.dart';

class WebMenuBar extends StatefulWidget implements PreferredSizeWidget {
  const WebMenuBar({Key? key}) : super(key: key);

  @override
  State<WebMenuBar> createState() => _WebMenuBarState();

  @override
  Size get preferredSize => const Size(Dimensions.webMaxWidth, 70);
}

class _WebMenuBarState extends State<WebMenuBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimensions.webMaxWidth,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Row(children: [

        InkWell(
          onTap: () => Get.toNamed(RouteHelper.getInitialRoute()),
          child: Image.asset(Images.logo, width: 100),
        ),

        Get.find<LocationController>().getUserAddress() != null ? Expanded(child: InkWell(
          onTap: () => Get.find<LocationController>().navigateToLocationScreen('home'),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: GetBuilder<LocationController>(builder: (locationController) {
              return Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    locationController.getUserAddress()!.addressType == 'home' ? Icons.home_filled
                        : locationController.getUserAddress()!.addressType == 'office' ? Icons.work : Icons.location_on,
                    size: 20, color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Flexible(
                    child: Text(
                      locationController.getUserAddress()!.address!,
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeSmall,
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Theme.of(context).primaryColor),
                ],
              );
            }),
          ),
        )) : const Expanded(child: SizedBox()),
        const SizedBox(width: 20),

        Get.find<LocationController>().getUserAddress() == null ? Row(children: [
          MenuButton(title: 'home'.tr, onTap: () => Get.toNamed(RouteHelper.getInitialRoute())),
          const SizedBox(width: 20),
          MenuButton(title: 'about_us'.tr, onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('about-us'))),
          const SizedBox(width: 20),
          MenuButton(title: 'privacy_policy'.tr, onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('privacy-policy'))),
        ]) : SizedBox(width: 250, child: GetBuilder<SearchingController>(builder: (searchController) {
          _searchController.text = searchController.searchHomeText!;
          return SearchField(
            controller: _searchController,
            hint: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                ? 'search_food_or_restaurant'.tr : 'search_item_or_store'.tr,
            suffixIcon: searchController.searchHomeText!.isNotEmpty ? Icons.highlight_remove : Icons.search,
            filledColor: Theme.of(context).colorScheme.background,
            iconPressed: () {
              if(searchController.searchHomeText!.isNotEmpty) {
                _searchController.text = '';
                searchController.clearSearchHomeText();
              }else {
                searchData();
              }
            },
            onSubmit: (text) => searchData(),
          );
        })),
        const SizedBox(width: 20),

        MenuIconButton(icon: Icons.notifications, onTap: () => Get.toNamed(RouteHelper.getNotificationRoute())),
        const SizedBox(width: 20),
        MenuIconButton(icon: Icons.favorite, onTap: () => Get.toNamed(RouteHelper.getMainRoute('favourite'))),
        const SizedBox(width: 20),
        MenuIconButton(icon: Icons.shopping_cart, isCart: true, onTap: () => Get.toNamed(RouteHelper.getCartRoute())),
        const SizedBox(width: 20),
        GetBuilder<LocalizationController>(builder: (localizationController) {
          int index0 = 0;
          List<DropdownMenuItem<int>> languageList = [];
          for(int index=0; index<AppConstants.languages.length; index++) {
            languageList.add(DropdownMenuItem(
              value: index,
              child: TextHover(builder: (hovered) {
                return Row(children: [
                  Image.asset(AppConstants.languages[index].imageUrl!, height: 20, width: 20),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Text(AppConstants.languages[index].languageName!, style: robotoRegular.copyWith(color: hovered ? Theme.of(context).primaryColor : null)),
                ]);
              }),
            ));
            if(AppConstants.languages[index].languageCode == localizationController.locale.languageCode) {
              index0 = index;
            }
          }
          return DropdownButton<int>(
            value: index0,
            items: languageList,
            dropdownColor: Theme.of(context).cardColor,
            icon: const Icon(Icons.keyboard_arrow_down),
            elevation: 0, iconSize: 30, underline: const SizedBox(),
            onChanged: (int? index) {
              localizationController.setLanguage(Locale(AppConstants.languages[index!].languageCode!, AppConstants.languages[index].countryCode));
            },
          );
        }),
        const SizedBox(width: 20),
        MenuIconButton(icon: Icons.menu, onTap: () {
          Scaffold.of(context).openEndDrawer();
        }),
        const SizedBox(width: 20),
        GetBuilder<AuthController>(builder: (authController) {
          return InkWell(
            onTap: () {
              if (authController.isLoggedIn()) {
                Get.toNamed(RouteHelper.getProfileRoute());
              }else{
                Get.dialog(const SignInScreen(exitFromApp: false, backFromThis: false));
              }
            },
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                color: Theme.of(context).primaryColor,
              ),
              child: Row(children: [
                Icon(authController.isLoggedIn() ? Icons.person_pin_rounded : Icons.lock, size: 20, color: Colors.white),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Text(authController.isLoggedIn() ? 'profile'.tr : 'sign_in'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.white)),
              ]),
            ),
          );
        }),

      ]))),
    );
  }

  void searchData() {
    if (_searchController.text.trim().isEmpty) {
      showCustomSnackBar(Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
          ? 'search_food_or_restaurant'.tr : 'search_item_or_store'.tr);
    } else {
      Get.toNamed(RouteHelper.getSearchRoute(queryText: _searchController.text.trim()));
    }
  }

}

class MenuButton extends StatelessWidget {
  final String title;
  final Function onTap;
  const MenuButton({Key? key, required this.title, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextHover(builder: (hovered) {
      return InkWell(
        onTap: onTap as void Function()?,
        child: Text(title, style: robotoRegular.copyWith(color: hovered ? Theme.of(context).primaryColor : null)),
      );
    });
  }
}

class MenuIconButton extends StatelessWidget {
  final IconData icon;
  final bool isCart;
  final Function onTap;
  const MenuIconButton({Key? key, required this.icon, this.isCart = false, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextHover(builder: (hovered) {
      return IconButton(
        onPressed: onTap as void Function()?,
        icon: GetBuilder<CartController>(builder: (cartController) {
          return Stack(clipBehavior: Clip.none, children: [
            Icon(
              icon,
              color: hovered ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge!.color,
            ),
            (isCart && cartController.cartList.isNotEmpty) ? Positioned(
              top: -5, right: -5,
              child: Container(
                height: 15, width: 15, alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                child: Text(
                  cartController.cartList.length.toString(),
                  style: robotoRegular.copyWith(fontSize: 12, color: Theme.of(context).cardColor),
                ),
              ),
            ) : const SizedBox()
          ]);
        }),
      );
    });
  }
}

