import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/order_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryManWidget extends StatelessWidget {
  final DeliveryMan? deliveryMan;
  const DeliveryManWidget({Key? key, required this.deliveryMan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: [BoxShadow(
          color: Colors.grey[Get.isDarkMode ? 700 : 300]!,
          blurRadius: 5, spreadRadius: 1,
        )],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('delivery_man'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
        ListTile(
          leading: ClipOval(
            child: CustomImage(
              image: '${Get.find<SplashController>().configModel!.baseUrls!.deliveryManImageUrl}/${deliveryMan!.image}',
              height: 40, width: 40, fit: BoxFit.cover,
            ),
          ),
          title: Text(
            '${deliveryMan!.fName} ${deliveryMan!.lName}',
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          subtitle: RatingBar(rating: deliveryMan!.avgRating, size: 15, ratingCount: deliveryMan!.ratingCount ?? 0),
        ),
      ]),
    );
  }
}
