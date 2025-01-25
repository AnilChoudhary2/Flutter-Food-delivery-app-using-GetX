import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/view/base/custom_dropdown.dart';
class ModuleViewWidget extends StatelessWidget {
  const ModuleViewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      List<int> moduleIndexList = [];
      List<DropdownItem<int>> moduleList = [];
      if(authController.moduleList != null && authController.moduleList!.length > 0) {
        for(int index=0; index < authController.moduleList!.length; index++) {
          if(authController.moduleList![index].moduleType != 'parcel') {
            moduleIndexList.add(index);
            moduleList.add(DropdownItem<int>(value: index, child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${authController.moduleList![index].moduleName}'),
              ),
            )));
          }
        }
      }
      return authController.moduleList != null ?  Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
            border: Border.all(color: Theme.of(context).primaryColor, width: 0.3)
        ),
        child: CustomDropdown<int>(
          onChange: (int? value, int index) {
            authController.selectModuleIndex(value);
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
          items: moduleList,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text('select_module_type'.tr),
          ),
        ),
      ) : Center(child: Text('not_available_module'.tr));
    });
  }
}
