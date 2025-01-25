import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

import '../../../../controller/category_controller.dart';
import '../../../../controller/splash_controller.dart';
import '../../../../helper/responsive_helper.dart';
import '../../../../helper/route_helper.dart';
import '../../../../util/dimensions.dart';
import '../../../../util/styles.dart';
import '../../../base/custom_image.dart';
import '../../../base/title_widget.dart';
import '../widget/category_pop_up.dart';

class CategoryView1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController = ScrollController();

    return GetBuilder<CategoryController>(builder: (categoryController) {
      return (categoryController.categoryList != null &&
          categoryController.categoryList?.length == 0)
          ? SizedBox()
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: TitleWidget(
                title: "What you like to order?",
                onTap: () => Get.toNamed(RouteHelper.getCategoryRoute())),
          ),
          // SizedBox(
          //   height: 10,
          // ),
          ResponsiveHelper.isMobile(context)
              ? categoryController.categoryList != null
              ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  child: ConstrainedBox(
                    // padding:
                    //     EdgeInsets.symmetric(horizontal: 3),
                      constraints: BoxConstraints(
                          maxWidth: (11 *
                              MediaQuery.of(context)
                                  .size
                                  .width /
                              4 *
                              0.9 +
                              12)
                              .toDouble() +
                              5),
                      child: Wrap(
                        // controller: _scrollController,
                          runSpacing: 16,
                          spacing: 2,
                          children: List.generate(
                            categoryController
                                .categoryList!.length >
                                15
                                ? 15
                                : categoryController
                                .categoryList!.length,
                                (index) {
                              return Container(
                                width: MediaQuery.of(context)
                                    .size
                                    .width /
                                    4 *
                                    0.9,
                                // padding: EdgeInsets.symmetric(
                                //     horizontal: 1),
                                /*margin:
                                      EdgeInsets.only(left: index == 0 ? 3 : 0),*/
                                child: InkWell(
                                  onTap: () => Get.toNamed(
                                      RouteHelper
                                          .getCategoryItemRoute(
                                        categoryController
                                            .categoryList![index].id,
                                        categoryController
                                            .categoryList?[index].name ?? "",
                                      )),
                                  child: Column(children: [
                                    Container(
                                      padding: EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              width: 3,
                                              color:
                                              Colors.white),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors
                                                    .grey[350]!,
                                                spreadRadius: 1,
                                                blurRadius: 2)
                                          ]),
                                      child: ClipRRect(
                                          borderRadius:
                                          BorderRadius
                                              .circular(50),
                                          child: CustomImage(
                                            image:
                                            '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl!}/${categoryController.categoryList?[index].image}',
                                            height: 65,
                                            width: 65,
                                            fit: BoxFit.cover,
                                          )),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      categoryController
                                          .categoryList![index]
                                          .name ?? "",
                                      maxLines: 1,
                                      overflow:
                                      TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style:
                                      robotoMedium.copyWith(
                                        fontSize: Dimensions
                                            .fontSizeExtraSmall,
                                      ),
                                    ),
                                  ]),
                                ),
                              );
                            },
                          )))))
              : CategoryShimmer(
              categoryController: categoryController)
              : Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 65,
                  child: categoryController.categoryList != null
                      ? ListView.builder(
                    controller: _scrollController,
                    itemCount: categoryController
                        .categoryList!.length >
                        15
                        ? 15
                        : categoryController
                        .categoryList!.length,
                    padding: EdgeInsets.only(
                        left: Dimensions.paddingSizeSmall),
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 1),
                        child: InkWell(
                          onTap: () => Get.toNamed(RouteHelper
                              .getCategoryItemRoute(
                            categoryController
                                .categoryList![index].id,
                            categoryController
                                .categoryList?[index].name ?? "",
                          )),
                          child: SizedBox(
                            width: 75,
                            child: Container(
                              height: 65,
                              width: 65,
                              margin: EdgeInsets.only(
                                left: index == 0
                                    ? 0
                                    : Dimensions
                                    .paddingSizeExtraSmall,
                                right: Dimensions
                                    .paddingSizeExtraSmall,
                              ),
                              child: Stack(children: [
                                ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(
                                      Dimensions
                                          .radiusSmall),
                                  child: CustomImage(
                                    image:
                                    '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl!}/${categoryController.categoryList![index].image}',
                                    height: 65,
                                    width: 65,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets
                                          .symmetric(
                                          vertical: 2),
                                      decoration:
                                      BoxDecoration(
                                        borderRadius:
                                        BorderRadius.vertical(
                                            bottom: Radius
                                                .circular(
                                                Dimensions
                                                    .radiusSmall)),
                                        color: Theme.of(
                                            context)
                                            .primaryColor
                                            .withOpacity(0.8),
                                      ),
                                      child: Text(
                                        categoryController
                                            .categoryList![
                                        index]
                                            .name ?? "",
                                        maxLines: 1,
                                        overflow: TextOverflow
                                            .ellipsis,
                                        textAlign:
                                        TextAlign.center,
                                        style: robotoMedium
                                            .copyWith(
                                            fontSize:
                                            Dimensions
                                                .fontSizeExtraSmall,
                                            color: Colors
                                                .white),
                                      ),
                                    )),
                              ]),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                      : CategoryShimmer(
                      categoryController: categoryController),
                ),
              ),
              ResponsiveHelper.isMobile(context)
                  ? SizedBox()
                  : categoryController.categoryList != null
                  ? Column(
                children: [
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (con) => Dialog(
                              child: Container(
                                  height: 550,
                                  width: 600,
                                  child: CategoryPopUp(
                                    categoryController:
                                    categoryController,
                                  ))));
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: Dimensions
                              .paddingSizeSmall),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Theme.of(context)
                            .primaryColor,
                        child: Text('view_all'.tr,
                            style: TextStyle(
                                fontSize: Dimensions
                                    .paddingSizeDefault,
                                color: Theme.of(context)
                                    .cardColor)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              )
                  : CategoryAllShimmer(
                  categoryController: categoryController)
            ],
          ),
        ],
      );
    });
  }
}

class CategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  CategoryShimmer({required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: ListView.builder(
        itemCount: 14,
        padding: EdgeInsets.only(left: Dimensions.paddingSizeSmall),
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 1),
            child: SizedBox(
              width: 75,
              child: Container(
                height: 65,
                width: 65,
                margin: EdgeInsets.only(
                  left: index == 0 ? 0 : Dimensions.paddingSizeExtraSmall,
                  right: Dimensions.paddingSizeExtraSmall,
                ),
                child: Shimmer(
                  duration: Duration(seconds: 2),
                  enabled: categoryController.categoryList == null,
                  child: Container(
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius:
                      BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryAllShimmer extends StatelessWidget {
  final CategoryController categoryController;
  CategoryAllShimmer({required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: Padding(
        padding: EdgeInsets.only(right: Dimensions.paddingSizeSmall),
        child: Shimmer(
          duration: Duration(seconds: 2),
          enabled: categoryController.categoryList == null,
          child: Column(children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
            ),
            SizedBox(height: 5),
            Container(height: 10, width: 50, color: Colors.grey[300]),
          ]),
        ),
      ),
    );
  }
}
