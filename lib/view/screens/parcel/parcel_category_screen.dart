import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/parcel_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/screens/home/web/module_widget.dart';

class ParcelCategoryScreen extends StatefulWidget {
  const ParcelCategoryScreen({Key? key}) : super(key: key);

  @override
  State<ParcelCategoryScreen> createState() => _ParcelCategoryScreenState();
}

class _ParcelCategoryScreenState extends State<ParcelCategoryScreen> {

  @override
  void initState() {
    super.initState();

    if(Get.find<AuthController>().isLoggedIn() && Get.find<UserController>().userInfoModel == null) {
      Get.find<UserController>().getUserInfo();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? null : CustomAppBar(
        title: 'parcel'.tr, leadingIcon: Images.moduleIcon,
        onBackPressed: () => Get.find<SplashController>().setModule(null),
        backButton: (Get.find<SplashController>().module != null && Get.find<SplashController>().configModel!.module == null),
      ),
      body: GetBuilder<ParcelController>(builder: (parcelController) {
        return Stack(clipBehavior: Clip.none, children: [

          SingleChildScrollView(
            padding: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: FooterView(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Center(child: Image.asset(Images.parcel, height: 200)),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Center(child: Text('instant_same_day_delivery'.tr, style: robotoMedium)),
              Center(child: Text(
                'send_things_to_your_destination_instantly_and_safely'.tr,
                style: robotoRegular, textAlign: TextAlign.center,
              )),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text('what_are_you_sending'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              parcelController.parcelCategoryList != null ? parcelController.parcelCategoryList!.isNotEmpty ? GridView.builder(
                controller: ScrollController(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : ResponsiveHelper.isTab(context) ? 2 : 1,
                  childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/0.25) : (1/0.205),
                  crossAxisSpacing: Dimensions.paddingSizeSmall, mainAxisSpacing: Dimensions.paddingSizeSmall,
                ),
                itemCount: parcelController.parcelCategoryList!.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getParcelLocationRoute(parcelController.parcelCategoryList![index])),
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      ),
                      child: Row(children: [

                        Container(
                          height: 55, width: 55, alignment: Alignment.center,
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.2), shape: BoxShape.circle),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            child: CustomImage(
                              image: '${Get.find<SplashController>().configModel!.baseUrls!.parcelCategoryImageUrl}'
                                  '/${parcelController.parcelCategoryList![index].image}',
                              height: 30, width: 30,
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(parcelController.parcelCategoryList![index].name!, style: robotoMedium),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Text(
                            parcelController.parcelCategoryList![index].description!, maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                          ),
                        ])),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        const Icon(Icons.keyboard_arrow_right),

                      ]),
                    ),
                  );
                },
              ) : Center(child: Text('no_parcel_category_found'.tr)) : ParcelShimmer(isEnabled: parcelController.parcelCategoryList == null),

            ]))),
          ),

          ResponsiveHelper.isDesktop(context) ? const Positioned(top: 150, right: 0, child: ModuleWidget()) : const SizedBox(),

        ]);
      }),
    );
  }
}

class ParcelShimmer extends StatelessWidget {
  final bool isEnabled;
  const ParcelShimmer({Key? key, required this.isEnabled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : ResponsiveHelper.isTab(context) ? 2 : 1,
        childAspectRatio: (1/(ResponsiveHelper.isMobile(context) ? 0.20 : 0.20)),
        crossAxisSpacing: Dimensions.paddingSizeSmall, mainAxisSpacing: Dimensions.paddingSizeSmall,
      ),
      itemCount: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: isEnabled,
            child: Row(children: [

              Container(
                height: 50, width: 50, alignment: Alignment.center,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(height: 15, width: 200, color: Colors.grey[300]),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Container(height: 15, width: 100, color: Colors.grey[300]),
              ])),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              const Icon(Icons.keyboard_arrow_right),

            ]),
          ),
        );
      },
    );
  }
}

