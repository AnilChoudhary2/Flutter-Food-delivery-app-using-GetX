import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/data/model/response/zone_response_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_loader.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/screens/address/widget/address_widget.dart';
class AddressBottomSheet extends StatelessWidget {
  const AddressBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(Get.find<LocationController>().addressList == null){
      Get.find<LocationController>().getAddressList();
    }
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius : const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.paddingSizeExtraLarge),
            topRight : Radius.circular(Dimensions.paddingSizeExtraLarge),
          ),
      ),
      child: GetBuilder<LocationController>(
        builder: (locationController) {
          AddressModel? selectedAddress = locationController.getUserAddress();
          return Column(mainAxisSize: MainAxisSize.min, children: [

            Center(
              child: Container(
                margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault),
                height: 3, width: 40,
                decoration: BoxDecoration(
                    color: Theme.of(context).highlightColor,
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
                ),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                  Text('${'hey_welcome_back'.tr}\n${'which_location_do_you_want_to_select'.tr}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  locationController.addressList != null && locationController.addressList!.isEmpty ? Column(children: [
                    Image.asset(Images.noAddress, width: 150),

                    Text(
                      'you_dont_have_any_saved_address_yet'.tr, textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    ),

                  ]) : const SizedBox(),

                  locationController.addressList != null && locationController.addressList!.isEmpty
                      ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),

                  Align(
                    alignment: locationController.addressList != null && locationController.addressList!.isEmpty ? Alignment.center : Alignment.topLeft,
                    child: TextButton.icon(
                      onPressed: (){
                        Get.find<LocationController>().checkPermission(() async {
                          Get.dialog(const CustomLoader(), barrierDismissible: false);
                          AddressModel address = await Get.find<LocationController>().getCurrentLocation(true);
                          ZoneResponseModel response = await locationController.getZone(address.latitude, address.longitude, false);
                          if(response.isSuccess) {
                            locationController.saveAddressAndNavigate(
                              address, false, '', false, ResponsiveHelper.isDesktop(Get.context),
                            );
                          }else {
                            Get.back();
                            Get.toNamed(RouteHelper.getPickMapRoute(RouteHelper.accessLocation, false));
                            showCustomSnackBar('service_not_available_in_current_location'.tr);
                          }
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: locationController.addressList != null && locationController.addressList!.isEmpty
                            ? Theme.of(context).primaryColor : Colors.transparent,
                      ),
                      icon:  Icon(Icons.my_location, color: locationController.addressList != null && locationController.addressList!.isEmpty
                          ? Theme.of(context).cardColor : Theme.of(context).primaryColor),
                      label: Text('use_current_location'.tr, style: robotoMedium.copyWith(color: locationController.addressList != null && locationController.addressList!.isEmpty
                          ? Theme.of(context).cardColor : Theme.of(context).primaryColor)),
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  locationController.addressList != null ? locationController.addressList!.isNotEmpty ? Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: locationController.addressList!.length > 5 ? 5 : locationController.addressList!.length,
                      itemBuilder: (context, index) {
                        bool selected = false;
                        if(selectedAddress!.address == locationController.addressList![index].address){
                          selected = true;
                        }
                        return Center(child: SizedBox(width: 700, child: AddressWidget(
                          address: locationController.addressList![index],
                          fromAddress: false, isSelected: selected, fromDashBoard: true,
                          onTap: () {
                            Get.dialog(const CustomLoader(), barrierDismissible: false);
                            AddressModel address = locationController.addressList![index];
                            locationController.saveAddressAndNavigate(
                              address, false, null, false, ResponsiveHelper.isDesktop(context),
                            );
                          },
                        )));
                      },
                    ),
                  ) : const SizedBox() : const Center(child: CircularProgressIndicator()),

                  SizedBox(height: locationController.addressList != null && locationController.addressList!.isEmpty ? 0 : Dimensions.paddingSizeSmall),

                  locationController.addressList != null && locationController.addressList!.isNotEmpty ? TextButton.icon(
                    onPressed: () => Get.toNamed(RouteHelper.getAddAddressRoute(false, false, 0)),
                    icon: const Icon(Icons.add_circle_outline_sharp),
                    label: Text('add_new_address'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                  ) : const SizedBox(),

                ]),
              ),
            ),
          ]);
        }
      ),
    );
  }
}
