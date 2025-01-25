import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class AddressDetails extends StatelessWidget {
  final AddressModel? addressDetails;
  const AddressDetails({Key? key, required this.addressDetails,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        addressDetails!.address!,
        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), maxLines: 4, overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 5),

      Wrap(children: [
        (addressDetails!.streetNumber != null && addressDetails!.streetNumber!.isNotEmpty) ? Text('${'street_number'.tr}: ${addressDetails!.streetNumber!}',
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall), maxLines: 2, overflow: TextOverflow.ellipsis,
        ) : const SizedBox(),

        (addressDetails!.house != null && addressDetails!.house!.isNotEmpty) ? Text('${addressDetails!.streetNumber != null ? ', ' : ''}${'house'.tr}: ${addressDetails!.house!}',
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall), maxLines: 2, overflow: TextOverflow.ellipsis,
        ) : const SizedBox(),

        (addressDetails!.floor != null && addressDetails!.floor!.isNotEmpty) ? Text('${(addressDetails!.streetNumber != null || addressDetails!.house != null) ? ', ' : ''}${'floor'.tr}: ${addressDetails!.floor!}' ,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall), maxLines: 2, overflow: TextOverflow.ellipsis,
        ) : const SizedBox(),

      ]),
    ]);
  }
}

