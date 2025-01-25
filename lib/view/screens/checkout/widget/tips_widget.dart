import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class TipsWidget extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function onTap;
  const TipsWidget({Key? key, required this.title, required this.isSelected, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeExtraSmall, bottom:  Dimensions.paddingSizeExtraSmall),
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal:  Dimensions.paddingSizeSmall),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            boxShadow: [ BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 0.5, blurRadius: 0.5)],),
          child: Text(
            title, textDirection: TextDirection.ltr,
            style: robotoRegular.copyWith(color: isSelected ? Theme.of(context).cardColor : Theme.of(context).disabledColor),
          ),
        ),
      ),
    );
  }
}
