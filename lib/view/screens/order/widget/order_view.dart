import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/order_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/no_data_screen.dart';
import 'package:sixam_mart/view/base/paginated_list_view.dart';
import 'package:sixam_mart/view/screens/order/order_details_screen.dart';
import 'package:sixam_mart/view/screens/order/widget/order_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderView extends StatelessWidget {
  final bool isRunning;
  const OrderView({Key? key, required this.isRunning}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Scaffold(
      body: GetBuilder<OrderController>(builder: (orderController) {
        PaginatedOrderModel? paginatedOrderModel;
        if(orderController.runningOrderModel != null && orderController.historyOrderModel != null) {
          paginatedOrderModel = isRunning ? orderController.runningOrderModel : orderController.historyOrderModel;
        }

        return paginatedOrderModel != null ? paginatedOrderModel.orders!.isNotEmpty ? RefreshIndicator(
          onRefresh: () async {
            if(isRunning) {
              await orderController.getRunningOrders(1, isUpdate: true);
            }else {
              await orderController.getHistoryOrders(1, isUpdate: true);
            }
          },
          child: Scrollbar(controller: scrollController, child: SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: FooterView(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: PaginatedListView(
                  scrollController: scrollController,
                  onPaginate: (int? offset) {
                    if(isRunning) {
                      Get.find<OrderController>().getRunningOrders(offset!, isUpdate: true);
                    }else {
                      Get.find<OrderController>().getHistoryOrders(offset!, isUpdate: true);
                    }
                  },
                  totalSize: paginatedOrderModel.totalSize,
                  offset: paginatedOrderModel.offset,
                  itemView: ListView.builder(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    itemCount: paginatedOrderModel.orders!.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      bool isParcel = paginatedOrderModel!.orders![index].orderType == 'parcel';
                      bool isPrescription = paginatedOrderModel.orders![index].prescriptionOrder!;

                      return InkWell(
                        onTap: () {
                          Get.toNamed(
                            RouteHelper.getOrderDetailsRoute(paginatedOrderModel!.orders![index].id),
                            arguments: OrderDetailsScreen(
                              orderId: paginatedOrderModel.orders![index].id,
                              orderModel: paginatedOrderModel.orders![index],
                            ),
                          );
                        },
                        child: Container(
                          padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.all(Dimensions.paddingSizeSmall) : null,
                          margin: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall) : null,
                          decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
                            color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, blurRadius: 5, spreadRadius: 1)],
                          ) : null,
                          child: Column(children: [

                            Row(children: [

                              Stack(children: [
                                Container(
                                  height: 60, width: 60, alignment: Alignment.center,
                                  decoration: isParcel ? BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                                  ) : null,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    child: CustomImage(
                                      image: isParcel ? '${Get.find<SplashController>().configModel!.baseUrls!.parcelCategoryImageUrl}'
                                          '/${paginatedOrderModel.orders![index].parcelCategory != null ? paginatedOrderModel.orders![index].parcelCategory!.image : ''}'
                                          : '${Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl}/${paginatedOrderModel.orders![index].store != null
                                          ? paginatedOrderModel.orders![index].store!.logo : ''}',
                                      height: isParcel ? 35 : 60, width: isParcel ? 35 : 60, fit: isParcel ? null : BoxFit.cover,
                                    ),
                                  ),
                                ),
                                isParcel ? Positioned(left: 0, top: 10, child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(Dimensions.radiusSmall)),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  child: Text('parcel'.tr, style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall, color: Colors.white,
                                  )),
                                )) : const SizedBox(),

                                isPrescription ? Positioned(left: 0, top: 10, child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(Dimensions.radiusSmall)),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  child: Text('prescription'.tr, style: robotoMedium.copyWith(
                                    fontSize: 10, color: Colors.white,
                                  )),
                                )) : const SizedBox(),
                              ]),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(children: [
                                    Text(
                                      '${isParcel ? 'delivery_id'.tr : 'order_id'.tr}:',
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                    Text('#${paginatedOrderModel.orders![index].id}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                  ]),
                                  const SizedBox(height: Dimensions.paddingSizeSmall),
                                  Text(
                                    DateConverter.dateTimeStringToDateTime(paginatedOrderModel.orders![index].createdAt!),
                                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                                  ),
                                ]),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  ),
                                  child: Text(paginatedOrderModel.orders![index].orderStatus!.tr, style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor,
                                  )),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                isRunning ? InkWell(
                                  onTap: () => Get.toNamed(RouteHelper.getOrderTrackingRoute(paginatedOrderModel!.orders![index].id)),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                                    ),
                                    child: Row(children: [
                                      Image.asset(Images.tracking, height: 15, width: 15, color: Theme.of(context).primaryColor),
                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                      Text(isParcel ? 'track_delivery'.tr : 'track_order'.tr, style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).primaryColor,
                                      )),
                                    ]),
                                  ),
                                ) : Text(
                                  '${paginatedOrderModel.orders![index].detailsCount} ${paginatedOrderModel.orders![index].detailsCount! > 1 ? 'items'.tr : 'item'.tr}',
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                                ),
                              ]),

                            ]),

                            (index == paginatedOrderModel.orders!.length-1 || ResponsiveHelper.isDesktop(context)) ? const SizedBox() : Padding(
                              padding: const EdgeInsets.only(left: 70),
                              child: Divider(
                                color: Theme.of(context).disabledColor, height: Dimensions.paddingSizeLarge,
                              ),
                            ),

                          ]),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          )),
        ) : NoDataScreen(text: 'no_order_found'.tr, showFooter: true) : OrderShimmer(orderController: orderController);
      }),
    );
  }
}
