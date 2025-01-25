import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String image;
  final String title;
  final String data;
  const ProfileCard({Key? key, required this.data, required this.title, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).primaryColor, width: 0.1),
        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset(image, height: 30, width: 30),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Text(
          data, textDirection: TextDirection.ltr,
          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(title, style: robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor,
        )),
      ]),
    );
  }
}
