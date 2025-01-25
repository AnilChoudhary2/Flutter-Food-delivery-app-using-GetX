import 'package:sixam_mart/data/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class WishListRepo {
  final ApiClient apiClient;
  WishListRepo({required this.apiClient});

  Future<Response> getWishList() async {
    return await apiClient.getData(AppConstants.wishListGetUri);
  }

  Future<Response> addWishList(int? id, bool isStore) async {
    return await apiClient.postData('${AppConstants.addWishListUri}${isStore ? 'store_id=' : 'item_id='}$id', null);
  }

  Future<Response> removeWishList(int? id, bool isStore) async {
    return await apiClient.deleteData('${AppConstants.removeWishListUri}${isStore ? 'store_id=' : 'item_id='}$id');
  }
}
