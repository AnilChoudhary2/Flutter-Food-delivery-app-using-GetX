import 'package:sixam_mart/data/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class CampaignRepo {
  final ApiClient apiClient;
  CampaignRepo({required this.apiClient});

  Future<Response> getBasicCampaignList() async {
    return await apiClient.getData(AppConstants.basicCampaignUri);
  }

  Future<Response> getCampaignDetails(String campaignID) async {
    return await apiClient.getData('${AppConstants.basicCampaignDetailsUri}$campaignID');
  }

  Future<Response> getItemCampaignList() async {
    return await apiClient.getData(AppConstants.itemCampaignUri);
  }

}