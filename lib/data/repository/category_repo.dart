import 'package:get/get.dart';
import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/data/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';

class CategoryRepo {
  final ApiClient apiClient;
  CategoryRepo({required this.apiClient});

  Future<Response> getCategoryList(bool allCategory) async {
    return await apiClient.getData(AppConstants.categoryUri, headers: allCategory ? {
      'Content-Type': 'application/json; charset=UTF-8',
      AppConstants.localizationKey: Get.find<LocalizationController>().locale.languageCode
    } : null);
  }

  Future<Response> getSubCategoryList(String? parentID) async {
    return await apiClient.getData('${AppConstants.subCategoryUri}$parentID');
  }

  Future<Response> getCategoryItemList(String? categoryID, int offset, String type) async {
    return await apiClient.getData('${AppConstants.categoryItemUri}$categoryID?limit=10&offset=$offset&type=$type');
  }

  Future<Response> getCategoryStoreList(String? categoryID, int offset, String type) async {
    return await apiClient.getData('${AppConstants.categoryStoreUri}$categoryID?limit=10&offset=$offset&type=$type');
  }

  Future<Response> getSearchData(String? query, String? categoryID, bool isStore, String type) async {
    return await apiClient.getData(
      '${AppConstants.searchUri}${isStore ? 'stores' : 'items'}/search?name=$query&category_id=$categoryID&type=$type&offset=1&limit=50',
    );
  }

  Future<Response> saveUserInterests(List<int?> interests) async {
    return await apiClient.postData(AppConstants.interestUri, {"interest": interests});
  }

}