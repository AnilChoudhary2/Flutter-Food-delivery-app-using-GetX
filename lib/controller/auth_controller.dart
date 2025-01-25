import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/data/api/api_checker.dart';
import 'package:sixam_mart/data/api/api_client.dart';
import 'package:sixam_mart/data/model/body/delivery_man_body.dart';
import 'package:sixam_mart/data/model/body/store_body.dart';
import 'package:sixam_mart/data/model/body/signup_body.dart';
import 'package:sixam_mart/data/model/body/social_log_in_body.dart';
import 'package:sixam_mart/data/model/response/delivery_man_vehicles.dart';
import 'package:sixam_mart/data/model/response/module_model.dart';
import 'package:sixam_mart/data/model/response/response_model.dart';
import 'package:sixam_mart/data/model/response/zone_model.dart';
import 'package:sixam_mart/data/model/response/zone_response_model.dart';
import 'package:sixam_mart/data/repository/auth_repo.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:get/get.dart';

class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;
  AuthController({required this.authRepo}) {
   _notification = authRepo.isNotificationActive();
  }

  bool _isLoading = false;
  bool _notification = true;
  bool _acceptTerms = true;
  XFile? _pickedLogo;
  XFile? _pickedCover;
  List<ZoneModel>? _zoneList;
  int? _selectedZoneIndex = -1;
  LatLng? _restaurantLocation;
  List<int>? _zoneIds;
  XFile? _pickedImage;
  List<XFile> _pickedIdentities = [];
  final List<String> _identityTypeList = ['passport', 'driving_license', 'nid'];
  int _identityTypeIndex = 0;
  final List<String?> _dmTypeList = ['freelancer', 'salary_based'];
  int _dmTypeIndex = 0;
  List<ModuleModel>? _moduleList;
  int? _selectedModuleIndex = -1;
  List<DeliveryManVehicleModel>? _vehicles;
  List<int?>? _vehicleIds;
  int? _vehicleIndex = 0;
  double _dmStatus = 0.4;
  bool _lengthCheck = false;
  bool _numberCheck = false;
  bool _uppercaseCheck = false;
  bool _lowercaseCheck = false;
  bool _spatialCheck = false;
  double _storeStatus = 0.4;
  String? _storeAddress;
  String _storeMinTime = '--';
  String _storeMaxTime = '--';
  String _storeTimeUnit = 'minute';
  bool _showPassView = false;

  bool get isLoading => _isLoading;
  bool get notification => _notification;
  bool get acceptTerms => _acceptTerms;
  XFile? get pickedLogo => _pickedLogo;
  XFile? get pickedCover => _pickedCover;
  List<ZoneModel>? get zoneList => _zoneList;
  int? get selectedZoneIndex => _selectedZoneIndex;
  LatLng? get restaurantLocation => _restaurantLocation;
  List<int>? get zoneIds => _zoneIds;
  XFile? get pickedImage => _pickedImage;
  List<XFile> get pickedIdentities => _pickedIdentities;
  List<String> get identityTypeList => _identityTypeList;
  int get identityTypeIndex => _identityTypeIndex;
  List<String?> get dmTypeList => _dmTypeList;
  int get dmTypeIndex => _dmTypeIndex;
  List<ModuleModel>? get moduleList => _moduleList;
  int? get selectedModuleIndex => _selectedModuleIndex;
  List<DeliveryManVehicleModel>? get vehicles => _vehicles;
  List<int?>? get vehicleIds => _vehicleIds;
  int? get vehicleIndex => _vehicleIndex;
  double get dmStatus => _dmStatus;
  bool get lengthCheck => _lengthCheck;
  bool get numberCheck => _numberCheck;
  bool get uppercaseCheck => _uppercaseCheck;
  bool get lowercaseCheck => _lowercaseCheck;
  bool get spatialCheck => _spatialCheck;
  double get storeStatus => _storeStatus;
  String? get storeAddress => _storeAddress;
  String get storeMinTime => _storeMinTime;
  String get storeMaxTime => _storeMaxTime;
  String get storeTimeUnit => _storeTimeUnit;
  bool get showPassView => _showPassView;

  void showHidePass({bool isUpdate = true}){
    _showPassView = ! _showPassView;
    if(isUpdate) {
      update();
    }
  }

  void minTimeChange(String time){
    _storeMinTime = time;
    update();
  }

  void maxTimeChange(String time){
    _storeMaxTime = time;
    update();
  }

  void timeUnitChange(String unit){
    _storeTimeUnit = unit;
    update();
  }

  void validPassCheck(String pass, {bool isUpdate = true}) {
    _lengthCheck = false;
    _numberCheck = false;
    _uppercaseCheck = false;
    _lowercaseCheck = false;
    _spatialCheck = false;

    if(pass.length > 7){
      _lengthCheck = true;
    }
    if(pass.contains(RegExp(r'[a-z]'))) {
      _lowercaseCheck = true;
    }
    if(pass.contains(RegExp(r'[A-Z]'))){
      _uppercaseCheck = true;
    }
    if(pass.contains(RegExp(r'[ .!@#$&*~^%]'))){
      _spatialCheck = true;
    }
    if(pass.contains(RegExp(r'[\d+]'))){
      _numberCheck = true;
    }
    if(isUpdate) {
      update();
    }
  }


  void dmStatusChange(double value, {bool isUpdate = true}){
    _dmStatus = value;
    if(isUpdate) {
      update();
    }
  }

  void storeStatusChange(double value, {bool isUpdate = true}){
    _storeStatus = value;
    if(isUpdate) {
      update();
    }
  }

  Future<void> getVehicleList() async {
    Response response = await authRepo.getVehicleList();
    if (response.statusCode == 200) {
      _vehicles = [];
      _vehicleIds = [];
      _vehicleIds!.add(0);
      response.body.forEach((vehicle) => _vehicles!.add(DeliveryManVehicleModel.fromJson(vehicle)));
      response.body.forEach((vehicle) => _vehicleIds!.add(DeliveryManVehicleModel.fromJson(vehicle).id));

    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void setVehicleIndex(int? index, bool notify) {
    _vehicleIndex = index;
    if(notify) {
      update();
    }
  }

  Future<ResponseModel> registration(SignUpBody signUpBody) async {
    _isLoading = true;
    update();
    Response response = await authRepo.registration(signUpBody);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
    //  if(!Get.find<SplashController>().configModel!.customerVerification!) {
        authRepo.saveUserToken(response.body["token"]);
        await authRepo.updateToken();
        //Get.find<UserController>().getUserInfo();
   //   }
      responseModel = ResponseModel(true, response.body["token"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> login(String? phone, String password, {bool alreadyInApp = false}) async {
    _isLoading = true;
    update();
    Response response = await authRepo.login(phone: phone, password: password);
    ResponseModel responseModel;

    if (response.statusCode == 200) {

      if(Get.find<SplashController>().configModel!.customerVerification! && response.body['is_phone_verified'] == 0) {

      }else {
        authRepo.saveUserToken(response.body['token'], alreadyInApp: alreadyInApp);
        await authRepo.updateToken();
       // Get.find<UserController>().getUserInfo();
      }
      responseModel = ResponseModel(true, '${response.body['is_phone_verified']}${response.body['token']}');
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> loginWithSocialMedia(SocialLogInBody socialLogInBody) async {
    _isLoading = true;
    update();
    Response response = await authRepo.loginWithSocialMedia(socialLogInBody, 60);
    if (response.statusCode == 200) {
      String? token = response.body['token'];
      if(token != null && token.isNotEmpty) {
        if(Get.find<SplashController>().configModel!.customerVerification! && response.body['is_phone_verified'] == 0) {
          Get.toNamed(RouteHelper.getVerificationRoute(response.body['phone'] ?? socialLogInBody.email, token, RouteHelper.signUp, ''));
        }else {
          authRepo.saveUserToken(response.body['token']);
          await authRepo.updateToken();
          Get.find<LocationController>().navigateToLocationScreen('sign-in');
        }
      }else {
        Get.toNamed(RouteHelper.getForgotPassRoute(true, socialLogInBody));
      }
    }else if(response.statusCode == 403 && response.body['errors'][0]['code'] == 'email'){
      Get.toNamed(RouteHelper.getForgotPassRoute(true, socialLogInBody));
    } else {
      showCustomSnackBar(response.statusText);
    }
    _isLoading = false;
    update();
  }

  Future<void> registerWithSocialMedia(SocialLogInBody socialLogInBody) async {
    _isLoading = true;
    update();
    Response response = await authRepo.registerWithSocialMedia(socialLogInBody);
    if (response.statusCode == 200) {
      String? token = response.body['token'];
      if(Get.find<SplashController>().configModel!.customerVerification! && response.body['is_phone_verified'] == 0) {
        Get.toNamed(RouteHelper.getVerificationRoute(socialLogInBody.phone, token, RouteHelper.signUp, ''));
      }else {
        authRepo.saveUserToken(response.body['token']);
        await authRepo.updateToken();
        Get.find<LocationController>().navigateToLocationScreen('sign-in');
      }
    } else {
      showCustomSnackBar(response.statusText);
    }
    _isLoading = false;
    update();
  }

  Future<ResponseModel> forgetPassword(String? email) async {
    _isLoading = true;
    update();
    Response response = await authRepo.forgetPassword(email);

    ResponseModel responseModel;
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> updateToken() async {
    await authRepo.updateToken();
  }

  Future<ResponseModel> verifyToken(String? email) async {
    _isLoading = true;
    update();
    Response response = await authRepo.verifyToken(email, _verificationCode);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> resetPassword(String? resetToken, String number, String password, String confirmPassword) async {
    _isLoading = true;
    update();
    Response response = await authRepo.resetPassword(resetToken, number, password, confirmPassword);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> checkEmail(String email) async {
    _isLoading = true;
    update();
    Response response = await authRepo.checkEmail(email);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      responseModel = ResponseModel(true, response.body["token"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> verifyEmail(String email, String token) async {
    _isLoading = true;
    update();
    Response response = await authRepo.verifyEmail(email, _verificationCode);
    ResponseModel responseModel;
    if (response.statusCode == 200) {
      authRepo.saveUserToken(token);
      await authRepo.updateToken();
      Get.find<UserController>().getUserInfo();
      responseModel = ResponseModel(true, response.body["message"]);
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  // Future<ResponseModel> verifyPhone(String? phone, String? token) async {
  //   _isLoading = true;
  //   update();
  //   Response response = await authRepo.verifyPhone(phone, _verificationCode);
  //   ResponseModel responseModel;
  //   if (response.statusCode == 200) {
  //     authRepo.saveUserToken(token!);
  //     await authRepo.updateToken();
  //    // Get.find<UserController>().getUserInfo();
  //     responseModel = ResponseModel(true, response.body["message"]);
  //   } else {
  //     responseModel = ResponseModel(false, response.statusText);
  //   }
  //   _isLoading = false;
  //   update();
  //   return responseModel;
  // }


  Future<OtpResponseModel> verifyPhone(String phone, String token) async {
    _isLoading = true;
    update();
    Response response = await authRepo.verifyPhone(phone, _verificationCode);
    OtpResponseModel responseModel;
    if (response.statusCode == 200) {
      authRepo.saveUserToken(response.body['token']);
      await authRepo.updateToken();
      responseModel = OtpResponseModel(
          true, response.body["message"], response.body["token"]);
    } else {
      responseModel = OtpResponseModel(false, response.statusText, "");
    }
    _isLoading = false;
    update();
    return responseModel;
  }


  Future<void> updateZone() async {
    Response response = await authRepo.updateZone();
    if (response.statusCode == 200) {
      // Nothing to do
    } else {
      ApiChecker.checkApi(response);
    }
  }

  String _verificationCode = '';

  String get verificationCode => _verificationCode;

  void updateVerificationCode(String query) {
    _verificationCode = query;
    update();
  }


  bool _isActiveRememberMe = false;

  bool get isActiveRememberMe => _isActiveRememberMe;

  void toggleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  bool isLoggedIn() {
    return authRepo.isLoggedIn();
  }

  bool clearSharedData() {
    Get.find<SplashController>().setModule(null);
    return authRepo.clearSharedData();
  }
  Future<void> socialLogout() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.disconnect();
    await FacebookAuth.instance.logOut();
  }

  bool clearSharedAddress() {
    return authRepo.clearSharedAddress();
  }

  void saveUserNumberAndPassword(String number, String password, String countryCode) {
    authRepo.saveUserNumberAndPassword(number, password, countryCode);
  }

  String getUserNumber() {
    return authRepo.getUserNumber();
  }

  String getUserCountryCode() {
    return authRepo.getUserCountryCode();
  }

  String getUserPassword() {
    return authRepo.getUserPassword();
  }

  Future<bool> clearUserNumberAndPassword() async {
    return authRepo.clearUserNumberAndPassword();
  }

  String getUserToken() {
    return authRepo.getUserToken();
  }

  void saveDmTipIndex(String i){
    authRepo.saveDmTipIndex(i);
  }

  String getDmTipIndex() {
    return authRepo.getDmTipIndex();
  }

  void saveEarningPoint(String point){
    authRepo.saveEarningPoint(point);
  }

  String getEarningPint() {
    return authRepo.getEarningPint();
  }

  bool setNotificationActive(bool isActive) {
    _notification = isActive;
    authRepo.setNotificationActive(isActive);
    update();
    return _notification;
  }

  void pickImage(bool isLogo, bool isRemove) async {
    if(isRemove) {
      _pickedLogo = null;
      _pickedCover = null;
    }else {
      if (isLogo) {
        _pickedLogo = await ImagePicker().pickImage(source: ImageSource.gallery);
      } else {
        _pickedCover = await ImagePicker().pickImage(source: ImageSource.gallery);
      }
      update();
    }
  }

  Future<void> getZoneList() async {
    _pickedLogo = null;
    _pickedCover = null;
    _selectedZoneIndex = -1;
    _restaurantLocation = null;
    _zoneIds = null;
    Response response = await authRepo.getZoneList();
    if (response.statusCode == 200) {
      _zoneList = [];
      response.body.forEach((zone) => _zoneList!.add(ZoneModel.fromJson(zone)));
      setLocation(LatLng(
        double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lat ?? '0'),
        double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lng ?? '0'),
      ));
      await getModules(_zoneList![0].id);
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> setZoneIndex(int? index, {bool canUpdate = true}) async {
    _selectedZoneIndex = index;
    if(canUpdate){
      await getModules(zoneList![selectedZoneIndex!].id);
      update();
    }
  }

  void setLocation(LatLng location) async {
    ZoneResponseModel response = await Get.find<LocationController>().getZone(
      location.latitude.toString(), location.longitude.toString(), false,
    );
    _storeAddress = await Get.find<LocationController>().getAddressFromGeocode(LatLng(location.latitude, location.longitude));
    if(response.isSuccess && response.zoneIds.isNotEmpty) {
      _restaurantLocation = location;
      _zoneIds = response.zoneIds;
      for(int index=0; index<_zoneList!.length; index++) {
        if(_zoneIds!.contains(_zoneList![index].id)) {
          _selectedZoneIndex = index;
          break;
        }
      }
    }else {
      _restaurantLocation = null;
      _zoneIds = null;
    }
    update();
  }

  Future<void> registerStore(StoreBody storeBody) async {
    _isLoading = true;
    update();
    Response response = await authRepo.registerStore(storeBody, _pickedLogo, _pickedCover);
    if(response.statusCode == 200) {
      if(ResponsiveHelper.isDesktop(Get.context)){
        Get.offAllNamed(RouteHelper.getInitialRoute());
      }else {
        Get.back();
      }
      showCustomSnackBar('store_registration_successful'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  // bool _checkIfValidMarker(LatLng tap, List<LatLng> vertices) {
  //   int intersectCount = 0;
  //   for (int j = 0; j < vertices.length - 1; j++) {
  //     if (_rayCastIntersect(tap, vertices[j], vertices[j + 1])) {
  //       intersectCount++;
  //     }
  //   }
  //
  //   return ((intersectCount % 2) == 1); // odd = inside, even = outside;
  // }

  // bool _rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
  //   double aY = vertA.latitude;
  //   double bY = vertB.latitude;
  //   double aX = vertA.longitude;
  //   double bX = vertB.longitude;
  //   double pY = tap.latitude;
  //   double pX = tap.longitude;
  //
  //   if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
  //     return false; // a and b can't both be above or below pt.y, and a or
  //     // b must be east of pt.x
  //   }
  //
  //   double m = (aY - bY) / (aX - bX); // Rise over run
  //   double bee = (-aX) * m + aY; // y = mx + b
  //   double x = (pY - bee) / m; // algebra is neat!
  //
  //   return x > pX;
  // }

  void setIdentityTypeIndex(String? identityType, bool notify) {
    int index0 = 0;
    for(int index=0; index<_identityTypeList.length; index++) {
      if(_identityTypeList[index] == identityType) {
        index0 = index;
        break;
      }
    }
    _identityTypeIndex = index0;
    if(notify) {
      update();
    }
  }

  void setDMTypeIndex(int dmType, bool notify) {
    _dmTypeIndex = dmType;
    if(notify) {
      update();
    }
  }


  void pickDmImage(bool isLogo, bool isRemove) async {
    if(isRemove) {
      _pickedImage = null;
      _pickedIdentities = [];
    }else {
      if (isLogo) {
        _pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      } else {
        XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
        if(xFile != null) {
          _pickedIdentities.add(xFile);
        }
      }
      update();
    }
  }

  void removeDmImage(){
    _pickedImage = null;
    update();
  }

  void removeIdentityImage(int index) {
    _pickedIdentities.removeAt(index);
    update();
  }

  Future<void> registerDeliveryMan(DeliveryManBody deliveryManBody) async {
    _isLoading = true;
    update();
    List<MultipartBody> multiParts = [];
    multiParts.add(MultipartBody('image', _pickedImage));
    for(XFile file in _pickedIdentities) {
      multiParts.add(MultipartBody('identity_image[]', file));
    }
    Response response = await authRepo.registerDeliveryMan(deliveryManBody, multiParts);
    if (response.statusCode == 200) {
      Get.offAllNamed(RouteHelper.getInitialRoute());
      showCustomSnackBar('delivery_man_registration_successful'.tr, isError: false);
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  void selectModuleIndex(int? index, {canUpdate = true}) {
    _selectedModuleIndex = index;
    if(canUpdate) {
      update();
    }
  }

  Future<void> getModules(int? zoneId) async {
    Response response = await authRepo.getModules(zoneId);
    if (response.statusCode == 200) {
      _moduleList = [];
      response.body.forEach((storeCategory) => _moduleList!.add(ModuleModel.fromJson(storeCategory)));
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

}