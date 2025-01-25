import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';

class CustomCheckBox extends StatelessWidget {
  final String title;
  final bool value;
  final Function onClick;
  const CustomCheckBox({Key? key, required this.title, required this.value, required this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick as void Function()?,
      child: Row(children: [
        Checkbox(
          value: value,
          onChanged: (bool? isActive) => onClick(),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          activeColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), side: BorderSide.none),
        ),
        Text(title, style: robotoRegular),
      ]),
    );
  }
}
