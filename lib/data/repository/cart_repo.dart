import 'dart:convert';

import 'package:get/get.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartRepo{
  final SharedPreferences sharedPreferences;
  CartRepo({required this.sharedPreferences});

  List<CartModel> getCartList() {
    List<String> carts = [];
    if(sharedPreferences.containsKey(AppConstants.cartList)) {
      carts = sharedPreferences.getStringList(AppConstants.cartList) ?? [];
    }
    List<CartModel> cartList = [];
    for (String cart in carts) {
      CartModel cartModel = CartModel.fromJson(jsonDecode(cart));
      if((cartModel.item?.moduleId ?? 0) == getModuleId()) {
        cartList.add(cartModel);
      }
    }
    return cartList;
  }

  Future<void> addToCartList(List<CartModel> cartProductList) async {
    List<String> carts = [];
    if(sharedPreferences.containsKey(AppConstants.cartList)) {
      carts = sharedPreferences.getStringList(AppConstants.cartList) ?? [];
    }
    List<String> cartStringList = [];
    for(String cartString in carts) {
      CartModel cartModel = CartModel.fromJson(jsonDecode(cartString));
      if(cartModel.item!.moduleId != getModuleId()) {
        cartStringList.add(cartString);
      }
    }
    for(CartModel cartModel in cartProductList) {
      cartStringList.add(jsonEncode(cartModel));
    }
    await sharedPreferences.setStringList(AppConstants.cartList, cartStringList);
  }

  int getModuleId() {
    return Get.find<SplashController>().module?.id ?? Get.find<SplashController>().cacheModule?.id ?? 0;
  }

}