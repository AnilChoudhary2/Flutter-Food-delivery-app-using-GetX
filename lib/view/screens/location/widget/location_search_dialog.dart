import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/parcel_controller.dart';
import 'package:sixam_mart/controller/rider_controller.dart';
import 'package:sixam_mart/data/model/response/prediction_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSearchDialog extends StatelessWidget {
  final GoogleMapController? mapController;
  final bool? isPickedUp;
  final bool isRider;
  final bool isFrom;
  const LocationSearchDialog({Key? key, required this.mapController, this.isPickedUp, this.isRider = false, this.isFrom = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Scrollable(viewportBuilder: (context,viewPortOffset) => Container(
      margin: EdgeInsets.only(top: ResponsiveHelper.isWeb() ? 80 : 0),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      alignment: Alignment.topCenter,
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
        child: SizedBox(width: Dimensions.webMaxWidth, child: TypeAheadField(
          textFieldConfiguration: TextFieldConfiguration(
            controller: controller,
            textInputAction: TextInputAction.search,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.streetAddress,
            decoration: InputDecoration(
              hintText: 'search_location'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(style: BorderStyle.none, width: 0),
              ),
              hintStyle: Theme.of(context).textTheme.displayMedium!.copyWith(
                fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor,
              ),
              filled: true, fillColor: Theme.of(context).cardColor,
            ),
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
              color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          suggestionsCallback: (pattern) async {
            return await Get.find<LocationController>().searchLocation(context, pattern);
          },
          itemBuilder: (context, PredictionModel suggestion) {
            return Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Row(children: [
                const Icon(Icons.location_on),
                Expanded(
                  child: Text(suggestion.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeLarge,
                  )),
                ),
              ]),
            );
          },
          onSuggestionSelected: (PredictionModel suggestion) {
            if(isRider){
              Get.find<RiderController>().setLocationFromPlace(suggestion.placeId, suggestion.description, isFrom);
            }else {
              if(isPickedUp == null) {
                Get.find<LocationController>().setLocation(suggestion.placeId, suggestion.description, mapController);
              }else {
                Get.find<ParcelController>().setLocationFromPlace(suggestion.placeId, suggestion.description, isPickedUp);
              }
            }
            Get.back();
          },
        )),
      ),
    ));
  }
}
