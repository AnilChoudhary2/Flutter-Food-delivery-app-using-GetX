import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/data/model/response/config_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/screens/checkout/widget/slot_widget.dart';
class TimeSlotBottomSheet extends StatelessWidget {
  final bool tomorrowClosed;
  final bool todayClosed;
  final Module? module;
  const TimeSlotBottomSheet({Key? key, required this.tomorrowClosed, required this.todayClosed, required this.module}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: ResponsiveHelper.isMobile(context) ? const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge))
            : const BorderRadius.all(Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          !ResponsiveHelper.isDesktop(context) ? InkWell(
            onTap: ()=> Get.back(),
            child: Container(
              height: 4, width: 35,
              margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(color: Theme.of(context).disabledColor, borderRadius: BorderRadius.circular(10)),
            ),
          ) : const SizedBox(),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeLarge),
              child: GetBuilder<OrderController>(
                  builder: (orderController) {
                    return GetBuilder<StoreController>(
                      builder: (storeController) {
                        return Column(mainAxisSize: MainAxisSize.min, children: [

                          Row(children: [
                            Expanded(
                              child: tobView(context:context, title: 'today'.tr, isSelected: orderController.selectedDateSlot == 0, onTap: (){
                                orderController.updateDateSlot(0, Get.find<StoreController>().store!.orderPlaceToScheduleInterval);
                              }),
                            ),

                            Expanded(
                              child: tobView(context:context, title: 'tomorrow'.tr, isSelected: orderController.selectedDateSlot == 1, onTap: (){
                                orderController.updateDateSlot(1, Get.find<StoreController>().store!.orderPlaceToScheduleInterval);
                              }),
                            ),
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          ((orderController.selectedDateSlot == 0 && todayClosed) || (orderController.selectedDateSlot == 1 && tomorrowClosed))
                            ? Center(child: Text(module!.showRestaurantText! ? 'restaurant_is_closed'.tr : 'store_is_closed'.tr))
                              : orderController.timeSlots != null
                            ? orderController.timeSlots!.isNotEmpty ? GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: Dimensions.paddingSizeSmall,
                                crossAxisSpacing: Dimensions.paddingSizeExtraSmall,
                                childAspectRatio: 3
                              ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: orderController.timeSlots!.length,
                              itemBuilder: (context, index){
                                String time = (index == 0 && orderController.selectedDateSlot == 0
                                    && storeController.isStoreOpenNow(storeController.store!.active!, storeController.store!.schedules)
                                    && (Get.find<SplashController>().configModel!.moduleConfig!.module!.orderPlaceToScheduleInterval! ? storeController.store!.orderPlaceToScheduleInterval == 0 : true))
                                    ? 'instance'.tr : '${DateConverter.dateToTimeOnly(orderController.timeSlots![index].startTime!)} '
                                    '- ${DateConverter.dateToTimeOnly(orderController.timeSlots![index].endTime!)}';
                            return SlotWidget(
                              title: time,
                              isSelected: orderController.selectedTimeSlot == index,
                              onTap: () {
                                orderController.updateTimeSlot(index);
                                orderController.setPreferenceTimeForView(time);
                              },
                            );
                          }) : Center(child: Text('no_slot_available'.tr)) : const Center(child: CircularProgressIndicator()),

                        ]);
                      }
                    );
                  }
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge, vertical: Dimensions.paddingSizeSmall),
            child: Row(children: [
              Expanded(
                child: CustomButton(
                  buttonText: 'cancel'.tr,
                  color: Theme.of(context).disabledColor,
                  onPressed: () => Get.back(),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: CustomButton(
                  buttonText: 'schedule'.tr,
                  onPressed: () => Get.back(),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget tobView({required BuildContext context, required String title, required bool isSelected, required Function() onTap}){
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(title, style: isSelected ? robotoBold.copyWith(color: Theme.of(context).primaryColor) : robotoMedium),
          Divider(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, thickness: isSelected ? 2 : 1),
        ],
      ),
    );
  }
}
