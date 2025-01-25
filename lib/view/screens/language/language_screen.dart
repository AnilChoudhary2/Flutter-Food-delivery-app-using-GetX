import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/screens/language/widget/language_widget.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:get/get.dart';

class ChooseLanguageScreen extends StatefulWidget {
  final bool fromMenu;
  const ChooseLanguageScreen({Key? key, this.fromMenu = false}) : super(key: key);

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.fromMenu || ResponsiveHelper.isDesktop(context)) ? CustomAppBar(title: 'language'.tr, backButton: true) : null,
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: GetBuilder<LocalizationController>(builder: (localizationController) {
          return Column(children: [

            Expanded(child: Center(
              child: Scrollbar(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: Center(child: FooterView(minHeight: 0.615,
                    child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Center(child: Image.asset(Images.logo, width: 200)),
                        // Center(child: Text(AppConstants.APP_NAME, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge))),
                        SizedBox(height: Get.find<LocalizationController>().isLtr ? 30 : 25),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                          child: Text('select_language'.tr, style: robotoMedium),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : ResponsiveHelper.isTab(context) ? 3 : 2,
                              childAspectRatio: (1/1),
                              mainAxisSpacing: Dimensions.paddingSizeSmall,
                              crossAxisSpacing: Dimensions.paddingSizeSmall,
                            ),
                            itemCount: localizationController.languages.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            itemBuilder: (context, index) => LanguageWidget(
                              languageModel: localizationController.languages[index],
                              localizationController: localizationController, index: index,
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        ResponsiveHelper.isDesktop(context) ? Text(
                          'you_can_change_language'.tr,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        ) : const SizedBox.shrink(),

                        ResponsiveHelper.isDesktop(context) ? Padding(
                          padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                          child: LanguageSaveButton(localizationController: localizationController, fromMenu: widget.fromMenu),
                        ) : const SizedBox.shrink() ,

                      ]),
                    ),
                  )),
                ),
              ),
            )),

            ResponsiveHelper.isDesktop(context) ? const SizedBox.shrink() : LanguageSaveButton(localizationController: localizationController, fromMenu: widget.fromMenu),
          ]);
        }),
      ),
    );
  }
}

class LanguageSaveButton extends StatelessWidget {
  final LocalizationController localizationController;
  final bool? fromMenu;
  const LanguageSaveButton({Key? key, required this.localizationController, this.fromMenu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      !ResponsiveHelper.isDesktop(context) ? Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Text(
          'you_can_change_language'.tr,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
        ),
      ) : const SizedBox(),

      CustomButton(
          buttonText: 'save'.tr,
          margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          onPressed: () {
            if(localizationController.languages.isNotEmpty && localizationController.selectedIndex != -1) {
              localizationController.setLanguage(Locale(
                AppConstants.languages[localizationController.selectedIndex].languageCode!,
                AppConstants.languages[localizationController.selectedIndex].countryCode,
              ));
              if (fromMenu!) {
                Navigator.pop(context);
              } else {
                Get.offNamed(RouteHelper.getOnBoardingRoute());
              }
            }else {
              showCustomSnackBar('select_a_language'.tr);
            }
          },
        ),
    ]);
  }
}

