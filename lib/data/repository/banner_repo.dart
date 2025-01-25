import 'package:sixam_mart/data/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';
class BannerRepo {
  final ApiClient apiClient;
  BannerRepo({required this.apiClient});

  Future<Response> getBannerList() async {
    return await apiClient.getData(AppConstants.bannerUri);
  }

  Future<Response> getTaxiBannerList() async {
    return await apiClient.getData(AppConstants.taxiBannerUri);
  }

  Future<Response> getFeaturedBannerList() async {
    return await apiClient.getData('${AppConstants.bannerUri}?featured=1');
  }

}