import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_dropdown.dart';
import 'package:sixam_mart/view/screens/auth/widget/module_view.dart';
import 'package:sixam_mart/view/screens/location/widget/location_search_dialog.dart';

class SelectLocationView extends StatefulWidget {
  final bool fromView;
  final GoogleMapController? mapController;
  const SelectLocationView({Key? key, required this.fromView, this.mapController}) : super(key: key);

  @override
  State<SelectLocationView> createState() => _SelectLocationViewState();
}

class _SelectLocationViewState extends State<SelectLocationView> {
  late CameraPosition _cameraPosition;
  final Set<Polygon> _polygons = HashSet<Polygon>();
  GoogleMapController? _mapController;
  GoogleMapController? _screenMapController;
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      List<int> zoneIndexList = [];
      List<DropdownItem<int>> zoneList = [];
      if(authController.zoneList != null && authController.zoneIds != null) {
        for(int index=0; index<authController.zoneList!.length; index++) {
          if(authController.zoneIds!.contains(authController.zoneList![index].id)) {
            zoneIndexList.add(index);
            zoneList.add(DropdownItem<int>(value: index, child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${authController.zoneList![index].name}'),
              ),
            )));
          }
        }
      }

      return SizedBox(width: Dimensions.webMaxWidth, child: Padding(
        padding: EdgeInsets.all(widget.fromView ? 0 : Dimensions.paddingSizeSmall),
        child: SingleChildScrollView(
          child: ResponsiveHelper.isDesktop(context)? webView(authController, zoneList): Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // widget.fromView ? Center(
            //   child: Text(
            //     'set_your_store_location'.tr,
            //     style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
            //   ),
            // ) : const SizedBox(),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Row(children: [
              Expanded(child: authController.moduleList != null ? const ModuleViewWidget() : const SizedBox()),
              SizedBox(width: authController.moduleList != null ? Dimensions.paddingSizeSmall : 0),

              Expanded(child: zoneSection(authController, zoneList)),
            ]),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            mapView(authController),
            SizedBox(height: !widget.fromView ? Dimensions.paddingSizeSmall : 0),

            !widget.fromView ? CustomButton(
              buttonText: 'set_location'.tr,
              onPressed: () {
                try{
                  widget.mapController!.moveCamera(CameraUpdate.newCameraPosition(_cameraPosition));
                  Get.back();
                }catch(_){
                  Get.back();
                }
              },
            ) : const SizedBox()

          ]),
        ),
      ));
    });
  }

  Widget webView(AuthController authController, List<DropdownItem<int>> zoneList) {
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('module'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        authController.moduleList != null ? const ModuleViewWidget() : const SizedBox(),
        SizedBox(height: authController.moduleList != null ? Dimensions.paddingSizeLarge : 0),

        Text('zone'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        zoneSection(authController, zoneList),
      ])),
      const SizedBox(width: Dimensions.paddingSizeLarge),

      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: Dimensions.paddingSizeLarge),
          mapView(authController),
        ],
      )),
    ]);
  }

  Widget zoneSection(AuthController authController, List<DropdownItem<int>> zoneList) {
    return authController.zoneIds != null ?  Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).primaryColor, width: 0.3)
      ),
      child: CustomDropdown<int>(
        onChange: (int? value, int index) {
          authController.setZoneIndex(value);
        },
        dropdownButtonStyle: DropdownButtonStyle(
          height: 45,
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeExtraSmall,
            horizontal: Dimensions.paddingSizeExtraSmall,
          ),
          primaryColor: Theme.of(context).textTheme.bodyLarge!.color,
        ),
        dropdownStyle: DropdownStyle(
          elevation: 10,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        ),
        items: zoneList,
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(authController.selectedZoneIndex == -1 ? 'select_zone'.tr : authController.zoneList![authController.selectedZoneIndex!].name.toString()),
        ),
      ),
    ) : Center(child: Text('service_not_available_in_this_area'.tr));
  }

  Widget mapView(AuthController authController) {
    return authController.zoneList!.isNotEmpty ? Center(
      child: Container(
        height: ResponsiveHelper.isDesktop(context) ? widget.fromView ? 180 : 300 : widget.fromView ? 125 : (context.height * 0.55),
        width: Dimensions.webMaxWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(width: 1, color: Theme.of(context).primaryColor),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          child: Stack(clipBehavior: Clip.none, children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lat ?? '0'),
                  double.parse(Get.find<SplashController>().configModel!.defaultLocation!.lng ?? '0'),
                ), zoom: 16,
              ),
              minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
              zoomControlsEnabled: false,
              compassEnabled: false,
              indoorViewEnabled: true,
              mapToolbarEnabled: false,
              myLocationEnabled: false,
              zoomGesturesEnabled: true,
              polygons: _polygons,
              onCameraIdle: () {
                authController.setLocation(_cameraPosition.target);
                if(!widget.fromView) {
                  widget.mapController!.moveCamera(CameraUpdate.newCameraPosition(_cameraPosition));
                }
              },
              onCameraMove: ((position) => _cameraPosition = position),
              onMapCreated: (GoogleMapController controller) {
                if(widget.fromView) {
                  _mapController = controller;
                }else {
                  _screenMapController = controller;
                }
              },
            ),
            Center(child: Image.asset(Images.pickMarker, height: 50, width: 50)),

             Positioned(top: 10, left: 10,
              child: InkWell(
                onTap: () async {
                  var p = await Get.dialog(LocationSearchDialog(mapController: widget.fromView ? _mapController : _screenMapController));
                  Position? position = p;
                  if(position != null) {
                    _cameraPosition = CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 16);
                    if(!widget.fromView) {
                      widget.mapController!.moveCamera(CameraUpdate.newCameraPosition(_cameraPosition));
                      authController.setLocation(_cameraPosition.target);
                    }
                  }
                },
                child: Container(
                  height: 30, width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Theme.of(context).cardColor,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)],
                  ),
                  padding: const EdgeInsets.only(left: 10),
                  alignment: Alignment.centerLeft,
                  child: Text('search'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
                ),
              ),
            ),

            widget.fromView ? Positioned(
              top: 10, right: 0,
              child: InkWell(
                onTap: () {
                  Get.to(Scaffold(
                      appBar: CustomAppBar(title: 'set_your_store_location'.tr),
                      body: SelectLocationView(fromView: false, mapController: _mapController)),
                  );
                },
                child: Container(
                  width: 30, height: 30,
                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeLarge),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.white),
                  child: Icon(Icons.fullscreen, color: Theme.of(context).primaryColor, size: 20),
                ),
              ),
            ) : const SizedBox(),
          ]),
        ),
      ),
    ) : const SizedBox();
  }
}
