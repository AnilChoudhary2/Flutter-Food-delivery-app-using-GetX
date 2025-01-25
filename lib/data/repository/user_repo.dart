import 'package:sixam_mart/data/api/api_client.dart';
import 'package:sixam_mart/data/model/response/userinfo_model.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:image_picker/image_picker.dart';

class UserRepo {
  final ApiClient apiClient;
  UserRepo({required this.apiClient});

  Future<Response> getUserInfo() async {
    return await apiClient.getData(AppConstants.customerInfoUri);
  }

  Future<Response> updateProfile(UserInfoModel userInfoModel, XFile? data, String token) async {
    Map<String, String> body = {};
    body.addAll(<String, String>{
      'f_name': userInfoModel.fName!, 'l_name': userInfoModel.lName!, 'email': userInfoModel.email!
    });
    return await apiClient.postMultipartData(AppConstants.updateProfileUri, body, [MultipartBody('image', data)]);
  }

  Future<Response> changePassword(UserInfoModel userInfoModel) async {
    return await apiClient.postData(AppConstants.updateProfileUri, {'f_name': userInfoModel.fName, 'l_name': userInfoModel.lName,
      'email': userInfoModel.email, 'password': userInfoModel.password});
  }

  Future<Response> deleteUser() async {
    return await apiClient.deleteData(AppConstants.customerRemoveUri);
  }

}