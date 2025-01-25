import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/data/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';

class ChatRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  ChatRepo({required this.apiClient, required this.sharedPreferences});


  Future<Response> getConversationList(int offset) async {
    return apiClient.getData('${AppConstants.conversationListUri}?limit=10&offset=$offset');
  }

  Future<Response> searchConversationList(String name) async {
    return apiClient.getData('${AppConstants.searchConversationListUri}?name=$name&limit=20&offset=1');
  }

  Future<Response> getMessages(int offset, int? userID, String userType, int? conversationID) async {
    return await apiClient.getData('${AppConstants.messageListUri}?${conversationID != null ? 'conversation_id' : userType == AppConstants.admin ? 'admin_id'
        : userType == AppConstants.vendor ? 'vendor_id' : 'delivery_man_id'}=${conversationID ?? userID}&offset=$offset&limit=10');
  }

  Future<Response> sendMessage(String message, List<MultipartBody> images, int? userID, String userType, int? conversationID) async {
    Map<String, String> fields = {};
    fields.addAll({'message': message, 'receiver_type': userType, 'offset': '1', 'limit': '10'});
    if(conversationID != null) {
      fields.addAll({'conversation_id': conversationID.toString()});
    }else {
      fields.addAll({'receiver_id': userID.toString()});
    }
    return await apiClient.postMultipartData(AppConstants.sendMessageUri, fields, images);
  }

}