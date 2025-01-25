import 'dart:convert';

import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/data/api/api_client.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/data/model/response/module_model.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/util/html_type.dart';

class SplashRepo {
  ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  SplashRepo({required this.sharedPreferences, required this.apiClient});

  Future<Response> getConfigData() async {
    return await apiClient.getData(AppConstants.configUri);
  }

  Future<Response> getLandingPageData() async {
    return await apiClient.getData(AppConstants.landingPageUri);
  }

  Future<ModuleModel?> initSharedData() async {
    if(!sharedPreferences.containsKey(AppConstants.theme)) {
      sharedPreferences.setBool(AppConstants.theme, false);
    }
    if(!sharedPreferences.containsKey(AppConstants.countryCode)) {
      sharedPreferences.setString(AppConstants.countryCode, AppConstants.languages[0].countryCode!);
    }
    if(!sharedPreferences.containsKey(AppConstants.languageCode)) {
      sharedPreferences.setString(AppConstants.languageCode, AppConstants.languages[0].languageCode!);
    }
    if(!sharedPreferences.containsKey(AppConstants.cartList)) {
      sharedPreferences.setStringList(AppConstants.cartList, []);
    }
    if(!sharedPreferences.containsKey(AppConstants.searchHistory)) {
      sharedPreferences.setStringList(AppConstants.searchHistory, []);
    }
    if(!sharedPreferences.containsKey(AppConstants.notification)) {
      sharedPreferences.setBool(AppConstants.notification, true);
    }
    if(!sharedPreferences.containsKey(AppConstants.intro)) {
      sharedPreferences.setBool(AppConstants.intro, true);
    }

    if(!sharedPreferences.containsKey(AppConstants.notificationCount)) {
      sharedPreferences.setInt(AppConstants.notificationCount, 0);
    }
    if(!sharedPreferences.containsKey(AppConstants.acceptCookies)) {
      sharedPreferences.setBool(AppConstants.acceptCookies, false);
    }

    ModuleModel? module;
    if(sharedPreferences.containsKey(AppConstants.moduleId)) {
      try {
        module = ModuleModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.moduleId)!));
      }catch(_) {}
    }
    return module;
  }

  void disableIntro() {
    sharedPreferences.setBool(AppConstants.intro, false);
  }

  bool? showIntro() {
    return sharedPreferences.getBool(AppConstants.intro);
  }

  Future<void> setStoreCategory(int storeCategoryID) async {
    AddressModel? addressModel;
    try {
      addressModel = AddressModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!));
    }catch(_) {}
    apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.token), addressModel?.zoneIds,
      addressModel?.areaIds, sharedPreferences.getString(AppConstants.languageCode),
      storeCategoryID, addressModel?.latitude, addressModel?.longitude,
    );
  }

  Future<Response> getModules({Map<String, String>? headers}) async {
    return await apiClient.getData(AppConstants.moduleUri, headers: headers);
  }

  Future<void> setModule(ModuleModel? module) async {
    AddressModel? addressModel;
    try {
      addressModel = AddressModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!));
    }catch(_) {}
    apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.token), addressModel?.zoneIds, addressModel?.areaIds,
      sharedPreferences.getString(AppConstants.languageCode), module?.id,
        addressModel?.latitude, addressModel?.longitude
    );
    if(module != null) {
      await sharedPreferences.setString(AppConstants.moduleId, jsonEncode(module.toJson()));
    }else {
      await sharedPreferences.remove(AppConstants.moduleId);
    }
  }

  Future<void> setCacheModule(ModuleModel? module) async {
    if(module != null) {
      await sharedPreferences.setString(AppConstants.cacheModuleId, jsonEncode(module.toJson()));
    }else {
      await sharedPreferences.remove(AppConstants.cacheModuleId);
    }
  }

  ModuleModel? getCacheModule() {
    ModuleModel? module;
    if(sharedPreferences.containsKey(AppConstants.cacheModuleId)) {
      try {
        module = ModuleModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.cacheModuleId)!));
      }catch(_) {}
    }
    return module;
  }

  ModuleModel? getModule() {
    ModuleModel? module;
    if(sharedPreferences.containsKey(AppConstants.moduleId)) {
      try {
        module = ModuleModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.moduleId)!));
      }catch(_) {}
    }
    return module;
  }

  Future<Response> getHtmlText(HtmlType htmlType) async {
    return await apiClient.getData(
      htmlType == HtmlType.termsAndCondition ? AppConstants.termsAndConditionUri
        : htmlType == HtmlType.privacyPolicy ? AppConstants.privacyPolicyUri : htmlType == HtmlType.aboutUs
          ? AppConstants.aboutUsUri : htmlType == HtmlType.shippingPolicy ? AppConstants.shippingPolicyUri
          : htmlType == HtmlType.cancellation ? AppConstants.cancellationUri : AppConstants.refundUri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        AppConstants.localizationKey: Get.find<LocalizationController>().locale.languageCode,
      },
    );
  }

  Future<Response> subscribeEmail(String email) async {
    return await apiClient.postData(AppConstants.subscriptionUri, {'email': email});
  }

  bool getSavedCookiesData() {
    return sharedPreferences.getBool(AppConstants.acceptCookies)!;
  }

  Future<void> saveCookiesData(bool data) async {
    try {
      await sharedPreferences.setBool(AppConstants.acceptCookies, data);

    } catch (e) {
      rethrow;
    }
  }
  void cookiesStatusChange(String? data) {
    if(data != null){
      sharedPreferences.setString(AppConstants.cookiesManagement, data);
    }
  }

  bool getAcceptCookiesStatus(String data) => sharedPreferences.getString(AppConstants.cookiesManagement) != null
      && sharedPreferences.getString(AppConstants.cookiesManagement) == data;

}
