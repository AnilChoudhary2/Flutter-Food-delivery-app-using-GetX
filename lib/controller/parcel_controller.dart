
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/data/api/api_checker.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/data/model/response/parcel_category_model.dart';
import 'package:sixam_mart/data/model/response/place_details_model.dart';
import 'package:sixam_mart/data/model/response/zone_response_model.dart';
import 'package:sixam_mart/data/repository/parcel_repo.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';

class ParcelController extends GetxController implements GetxService {
  final ParcelRepo parcelRepo;
  ParcelController({required this.parcelRepo});

  List<ParcelCategoryModel>? _parcelCategoryList;
  AddressModel? _pickupAddress;
  AddressModel? _destinationAddress;
  bool? _isPickedUp = true;
  bool _isSender = true;
  bool _isLoading = false;
  double? _distance = -1;
  final List<String> _payerTypes = ['sender', 'receiver'];
  int _payerIndex = 0;
  int _paymentIndex = 0;
  bool _acceptTerms = true;
  double? _extraCharge;

  List<ParcelCategoryModel>? get parcelCategoryList => _parcelCategoryList;
  AddressModel? get pickupAddress => _pickupAddress;
  AddressModel? get destinationAddress => _destinationAddress;
  bool? get isPickedUp => _isPickedUp;
  bool get isSender => _isSender;
  bool get isLoading => _isLoading;
  double? get distance => _distance;
  int get payerIndex => _payerIndex;
  List<String> get payerTypes => _payerTypes;
  int get paymentIndex => _paymentIndex;
  bool get acceptTerms => _acceptTerms;
  double? get extraCharge => _extraCharge;

  void toggleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }

  Future<void> getParcelCategoryList() async {
    Response response = await parcelRepo.getParcelCategory();
    if(response.statusCode == 200) {
      _parcelCategoryList = [];
      response.body.forEach((parcel) => _parcelCategoryList!.add(ParcelCategoryModel.fromJson(parcel)));
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void setPickupAddress(AddressModel? addressModel, bool notify) {
    _pickupAddress = addressModel;
    if(notify) {
      update();
    }
  }

  void setDestinationAddress(AddressModel addressModel) {
    _destinationAddress = addressModel;
    update();
  }

  void setLocationFromPlace(String? placeID, String? address, bool? isPickedUp) async {
    Response response = await parcelRepo.getPlaceDetails(placeID);
    if(response.statusCode == 200) {
      PlaceDetailsModel placeDetails = PlaceDetailsModel.fromJson(response.body);
      if(placeDetails.status == 'OK') {
        AddressModel address0 = AddressModel(
          address: address, addressType: 'others', latitude: placeDetails.result!.geometry!.location!.lat.toString(),
          longitude: placeDetails.result!.geometry!.location!.lng.toString(),
          contactPersonName: Get.find<LocationController>().getUserAddress()!.contactPersonName,
          contactPersonNumber: Get.find<LocationController>().getUserAddress()!.contactPersonNumber,
        );
        ZoneResponseModel response0 = await Get.find<LocationController>().getZone(address0.latitude, address0.longitude, false);
        if (response0.isSuccess) {
          bool inZone = false;
          for(int zoneId in Get.find<LocationController>().getUserAddress()!.zoneIds!) {
            if(response0.zoneIds.contains(zoneId)) {
              inZone = true;
              break;
            }
          }
          if(inZone) {
            address0.zoneId =  response0.zoneIds[0];
            address0.zoneIds = [];
            address0.zoneIds!.addAll(response0.zoneIds);
            address0.zoneData = [];
            address0.zoneData!.addAll(response0.zoneData);
            if(isPickedUp!) {
              setPickupAddress(address0, true);
            }else {
              setDestinationAddress(address0);
            }
          }else {
            showCustomSnackBar('your_selected_location_is_from_different_zone_store'.tr);
          }
        } else {
          showCustomSnackBar(response0.message);
        }
      }
    }
  }

  void setIsPickedUp(bool? isPickedUp, bool notify) {
    _isPickedUp = isPickedUp;
    if(notify) {
      update();
    }
  }

  void setIsSender(bool sender, bool notify) {
    _isSender = sender;
    if(notify) {
      update();
    }
  }

  void getDistance(AddressModel pickedUpAddress, AddressModel destinationAddress) async {
    _distance = -1;
    _distance = await Get.find<OrderController>().getDistanceInKM(
      LatLng(double.parse(pickedUpAddress.latitude!), double.parse(pickedUpAddress.longitude!)),
      LatLng(double.parse(destinationAddress.latitude!), double.parse(destinationAddress.longitude!)),
    );

    _extraCharge = Get.find<OrderController>().extraCharge;

    update();
  }

  void setPayerIndex(int index, bool notify) {
    _payerIndex = index;
    if(_payerIndex == 1) {
      _paymentIndex = 0;
    }
    if(notify) {
      update();
    }
  }

  void setPaymentIndex(int index, bool notify) {
    _paymentIndex = index;
    if(notify) {
      update();
    }
  }

  void startLoader(bool isEnable) {
    _isLoading = isEnable;
    update();
  }

}