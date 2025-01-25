import 'package:country_code_picker/country_code_picker.dart';
import 'package:phone_number/phone_number.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/custom_text_field.dart';
import 'package:sixam_mart/view/base/not_logged_in_screen.dart';
import 'package:sixam_mart/view/screens/location/pick_map_screen.dart';
import 'package:sixam_mart/view/screens/location/widget/permission_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

class AddAddressScreen extends StatefulWidget {
  final bool fromCheckout;
  final bool fromRide;
  final AddressModel? address;
  final int? zoneId;
  const AddAddressScreen({Key? key, required this.fromCheckout, required this.fromRide, this.address, this.zoneId}) : super(key: key);

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactPersonNameController = TextEditingController();
  final TextEditingController _contactPersonNumberController = TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final FocusNode _addressNode = FocusNode();
  final FocusNode _levelNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _numberNode = FocusNode();
  final FocusNode _streetNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();
  CameraPosition? _cameraPosition;
  late LatLng _initialPosition;
  bool _otherSelect = false;
  String? _countryDialCode = Get.find<AuthController>().getUserCountryCode().isNotEmpty ? Get.find<AuthController>().getUserCountryCode()
      : CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;

  @override
  void initState() {
    super.initState();

    initCall();
  }

  void initCall(){

    Get.find<LocationController>().setAddressTypeIndex(0, isUpdate: false);
    if(Get.find<AuthController>().isLoggedIn() && Get.find<UserController>().userInfoModel == null) {
      Get.find<UserController>().getUserInfo();
    }
    if(widget.address == null) {
      _initialPosition = LatLng(
        double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lat ?? '0'),
        double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lng ?? '0'),
      );
    }else {
      Get.find<LocationController>().setUpdateAddress(widget.address!);
      _initialPosition = LatLng(
        double.parse(widget.address!.latitude ?? '0'),
        double.parse(widget.address!.longitude ?? '0'),
      );
    }
  }

  void splitPhoneNumber(String number) async {
    if(GetPlatform.isAndroid) {
      try {
        PhoneNumber phoneNumber = await PhoneNumberUtil().parse(number);
        _countryDialCode = '+${phoneNumber.countryCode}';
        _contactPersonNumberController.text = phoneNumber.nationalNumber;
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return Scaffold(
      appBar: CustomAppBar(title: widget.address == null ? 'add_new_address'.tr : 'update_address'.tr),
      body: isLoggedIn ? GetBuilder<UserController>(builder: (userController) {
        if(widget.address != null) {
          if(_contactPersonNameController.text.isEmpty) {
            splitPhoneNumber(widget.address!.contactPersonNumber!);
            _contactPersonNameController.text = widget.address!.contactPersonName!;
            _streetNumberController.text = widget.address!.streetNumber!;
            _houseController.text = widget.address!.house!;
            _floorController.text = widget.address!.floor!;
          }
        }else if(userController.userInfoModel != null && _contactPersonNameController.text.isEmpty) {
          _contactPersonNameController.text = '${userController.userInfoModel!.fName} ${userController.userInfoModel!.lName}';
          splitPhoneNumber(userController.userInfoModel!.phone!);
        }

        return GetBuilder<LocationController>(builder: (locationController) {
          _addressController.text = locationController.address!;

          return Column(children: [

            Expanded(child: Scrollbar(child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeLarge),
              child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Container(
                  height: 140,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    border: Border.all(width: 2, color: Theme.of(context).primaryColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: Stack(clipBehavior: Clip.none, children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 16),
                        minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                        onTap: (latLng) {
                          Get.toNamed(
                            RouteHelper.getPickMapRoute('add-address', false),
                            arguments: PickMapScreen(
                              fromAddAddress: true, fromSignUp: false, googleMapController: locationController.mapController,
                              route: null, canRoute: false,
                            ),
                          );
                        },
                        zoomControlsEnabled: false,
                        compassEnabled: false,
                        indoorViewEnabled: true,
                        mapToolbarEnabled: false,
                        onCameraIdle: () {
                          locationController.updatePosition(_cameraPosition, true);
                        },
                        onCameraMove: ((position) => _cameraPosition = position),
                        onMapCreated: (GoogleMapController controller) {
                          locationController.setMapController(controller);
                          if(widget.address == null) {
                            locationController.getCurrentLocation(true, mapController: controller);
                          }
                        },
                      ),
                      locationController.loading ? const Center(child: CircularProgressIndicator()) : const SizedBox(),
                      Center(child: !locationController.loading ? Image.asset(Images.pickMarker, height: 50, width: 50)
                          : const CircularProgressIndicator()),
                      Positioned(
                        bottom: 10, right: 0,
                        child: InkWell(
                          onTap: () => _checkPermission(() {
                            locationController.getCurrentLocation(true, mapController: locationController.mapController);
                          }),
                          child: Container(
                            width: 30, height: 30,
                            margin: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.white),
                            child: Icon(Icons.my_location, color: Theme.of(context).primaryColor, size: 20),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10, right: 0,
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(
                              RouteHelper.getPickMapRoute('add-address', false),
                              arguments: PickMapScreen(
                                fromAddAddress: true, fromSignUp: false, googleMapController: locationController.mapController,
                                route: null, canRoute: false,
                              ),
                            );
                          },
                          child: Container(
                            width: 30, height: 30,
                            margin: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.white),
                            child: Icon(Icons.fullscreen, color: Theme.of(context).primaryColor, size: 20),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Center(child: Text(
                  'add_the_location_correctly'.tr,
                  style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall),
                )),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Text(
                  'label_as'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium!.color),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                SizedBox(height: 50, child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: locationController.addressTypeList.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                    child: InkWell(
                      onTap: () {
                        _otherSelect = index == 2;
                        locationController.setAddressTypeIndex(index);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault), color: locationController.addressTypeIndex == index
                            ? Theme.of(context).primaryColor.withOpacity(0.1) : Theme.of(context).cardColor,
                          boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
                          border: Border.all(color: locationController.addressTypeIndex == index ? Theme.of(context).primaryColor : Theme.of(context).disabledColor)
                        ),
                        child: SizedBox(
                          height: 24, width: 24,
                          child: Image.asset(
                            index == 0 ? Images.homeIcon : index == 1 ? Images.workIcon : Images.otherIcon,
                            color: locationController.addressTypeIndex == index ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
                SizedBox(height: _otherSelect ? Dimensions.paddingSizeLarge : 0),

                _otherSelect ? CustomTextField(
                  titleText: '${'level_name'.tr}(${'optional'.tr})',
                  inputType: TextInputType.text,
                  controller: _levelController,
                  focusNode: _levelNode,
                  nextFocus: _addressNode,
                  capitalization: TextCapitalization.words,
                ) : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                CustomTextField(
                  titleText: 'delivery_address'.tr,
                  inputType: TextInputType.streetAddress,
                  controller: _addressController,
                  focusNode: _addressNode,
                  nextFocus: _nameNode,
                  onChanged: (text) => locationController.setPlaceMark(text),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                CustomTextField(
                  titleText: 'contact_person_name'.tr,
                  inputType: TextInputType.name,
                  controller: _contactPersonNameController,
                  focusNode: _nameNode,
                  nextFocus: _numberNode,
                  capitalization: TextCapitalization.words,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                CustomTextField(
                  titleText: 'contact_person_number'.tr,
                  controller: _contactPersonNumberController,
                  focusNode: _numberNode,
                  nextFocus: _streetNode,
                  inputType: TextInputType.phone,
                  isPhone: true,
                  onCountryChanged: (CountryCode countryCode) {
                    _countryDialCode = countryCode.dialCode;
                  },
                  countryDialCode: _countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                CustomTextField(
                  titleText: '${'street_number'.tr} (${'optional'.tr})',
                  inputType: TextInputType.streetAddress,
                  focusNode: _streetNode,
                  nextFocus: _houseNode,
                  controller: _streetNumberController,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Row(children: [
                  Expanded(
                    child: CustomTextField(
                      titleText: '${'house'.tr} (${'optional'.tr})',
                      inputType: TextInputType.text,
                      focusNode: _houseNode,
                      nextFocus: _floorNode,
                      controller: _houseController,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: CustomTextField(
                      titleText: "${'floor'.tr} (${'optional'.tr})",
                      inputType: TextInputType.text,
                      focusNode: _floorNode,
                      inputAction: TextInputAction.done,
                      controller: _floorController,
                    ),
                  ),
                ]),

                const SizedBox(height: Dimensions.paddingSizeLarge),

              ]))),
            ))),

            Container(
              width: Dimensions.webMaxWidth,
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: CustomButton(
                isLoading: locationController.isLoading,
                buttonText: widget.address == null ? 'save_location'.tr : 'update_address'.tr,
                onPressed: locationController.loading ? null : () {

                  String? addressType = locationController.addressTypeList[locationController.addressTypeIndex];
                  if(locationController.addressTypeIndex == 2){
                    addressType = _levelController.text.isNotEmpty ? _levelController.text.trim() : locationController.addressTypeList[locationController.addressTypeIndex];
                  }

                    AddressModel addressModel = AddressModel(
                      id: widget.address != null ? widget.address!.id : null,
                      addressType: addressType,
                      contactPersonName: _contactPersonNameController.text,
                      contactPersonNumber: _countryDialCode! + _contactPersonNumberController.text,
                      address: _addressController.text,
                      latitude: locationController.position.latitude.toString(),
                      longitude: locationController.position.longitude.toString(),
                      zoneId: locationController.zoneID,
                      streetNumber: _streetNumberController.text,
                      house: _houseController.text,
                      floor: _floorController.text,
                    );

                    if(widget.address == null) {
                      locationController.addAddress(addressModel, widget.fromCheckout,  widget.fromRide, widget.zoneId).then((response) {
                        if(response.isSuccess) {
                          Get.back(result: addressModel);
                          showCustomSnackBar('new_address_added_successfully'.tr, isError: false);
                        }else {
                          showCustomSnackBar(response.message);
                        }
                      });
                    }else {
                      locationController.updateAddress(addressModel, widget.address!.id).then((response) {
                        if(response.isSuccess) {
                          Get.back();
                          showCustomSnackBar(response.message, isError: false);
                        }else {
                          showCustomSnackBar(response.message);
                        }
                      });
                    }
                  },
              ),
            ),

          ]);
        });
      }) : NotLoggedInScreen(callBack: (value){
        initCall();
        setState(() {});
      }),
    );
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialog());
    }else {
      onTap();
    }
  }
}
