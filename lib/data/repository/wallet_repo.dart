import 'package:get/get_connect/http/src/response/response.dart';
import 'package:sixam_mart/data/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';

class WalletRepo {
  final ApiClient apiClient;
  WalletRepo({required this.apiClient});

  Future<Response> getWalletTransactionList(String offset) async {
    return await apiClient.getData('${AppConstants.walletTransactionUri}?offset=$offset&limit=10');
  }

  Future<Response> getLoyaltyTransactionList(String offset) async {
    return await apiClient.getData('${AppConstants.loyaltyTransactionUri}?offset=$offset&limit=10');
  }

  Future<Response> pointToWallet({int? point}) async {
    return await apiClient.postData(AppConstants.loyaltyPointTransferUri, {"point": point});
  }

}