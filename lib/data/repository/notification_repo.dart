import 'package:sixam_mart/data/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  NotificationRepo({required this.apiClient, required this.sharedPreferences});

  Future<Response> getNotificationList() async {
    return await apiClient.getData(AppConstants.notificationUri);
  }

  void saveSeenNotificationCount(int count) {
    sharedPreferences.setInt(AppConstants.notificationCount, count);
  }

  int? getSeenNotificationCount() {
    return sharedPreferences.getInt(AppConstants.notificationCount);
  }

}
