import 'dart:async';

import 'package:photo_view/photo_view.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/body/notification_body.dart';
import 'package:sixam_mart/data/model/response/conversation_model.dart';
import 'package:sixam_mart/data/model/response/order_details_model.dart';
import 'package:sixam_mart/data/model/response/order_model.dart';
import 'package:sixam_mart/data/model/response/review_model.dart';
import 'package:sixam_mart/data/model/response/zone_response_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/confirmation_dialog.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/rating_bar.dart';
import 'package:sixam_mart/view/screens/chat/widget/image_dialog.dart';
import 'package:sixam_mart/view/screens/order/widget/cancellation_dialogue.dart';
import 'package:sixam_mart/view/screens/order/widget/delivery_details.dart';
import 'package:sixam_mart/view/screens/order/widget/order_item_widget.dart';
import 'package:sixam_mart/view/screens/parcel/widget/details_widget.dart';
import 'package:sixam_mart/view/screens/review/rate_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/screens/store/widget/review_dialog.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel? orderModel;
  final int? orderId;
  final bool fromNotification;
  const OrderDetailsScreen({Key? key, required this.orderModel, required this.orderId, this.fromNotification = false}) : super(key: key);

  @override
  OrderDetailsScreenState createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Timer? _timer;
  double? _maxCodOrderAmount;
  bool? _isCashOnDeliveryActive = false;

  void _loadData(BuildContext context, bool reload) async {
    await Get.find<OrderController>().trackOrder(widget.orderId.toString(), reload ? null : widget.orderModel, false);
    Get.find<OrderController>().timerTrackOrder(widget.orderId.toString());
    Get.find<OrderController>().getOrderDetails(widget.orderId.toString());
  }

  void _startApiCall(){
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      Get.find<OrderController>().timerTrackOrder(widget.orderId.toString());
    });
  }

  @override
  void initState() {
    super.initState();

    _loadData(context, false);
    _startApiCall();
  }

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
          return true;
        } else {
          Get.back();
          return true;
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'order_details'.tr, onBackPressed: () {
          if(widget.fromNotification) {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          } else {
            Get.back();
          }
        }),
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        backgroundColor: Theme.of(context).cardColor,
        body: SafeArea(child: GetBuilder<OrderController>(builder: (orderController) {
          double deliveryCharge = 0;
          double itemsPrice = 0;
          double discount = 0;
          double couponDiscount = 0;
          double tax = 0;
          double addOns = 0;
          double dmTips = 0;
          OrderModel? order = orderController.trackModel;
          bool parcel = false;
          bool prescriptionOrder = false;
          bool taxIncluded = false;
          bool ongoing = false;
          if(orderController.orderDetails != null  && order != null) {
            parcel = order.orderType == 'parcel';
            prescriptionOrder = order.prescriptionOrder!;
            deliveryCharge = order.deliveryCharge!;
            couponDiscount = order.couponDiscountAmount!;
            discount = order.storeDiscountAmount!;
            tax = order.totalTaxAmount!;
            dmTips = order.dmTips!;
            taxIncluded = order.taxStatus!;
            if(prescriptionOrder) {
              double orderAmount = order.orderAmount ?? 0;
              itemsPrice = (orderAmount + discount) - ((taxIncluded ? 0 : tax) + deliveryCharge) - dmTips;
            } else{
              for(OrderDetailsModel orderDetails in orderController.orderDetails!) {
                for(AddOn addOn in orderDetails.addOns!) {
                  addOns = addOns + (addOn.price! * addOn.quantity!);
                }
                itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.quantity!);
              }
            }

            if(!parcel && order.store != null) {
              for(ZoneData zData in Get.find<LocationController>().getUserAddress()!.zoneData!) {
                if(zData.id == order.store!.zoneId){
                  _isCashOnDeliveryActive = zData.cashOnDelivery;
                }
                for(Modules m in zData.modules!) {
                  if(m.id == order.store!.moduleId) {
                    _maxCodOrderAmount = m.pivot!.maximumCodOrderAmount;
                    break;
                  }
                }
              }
            }

            ongoing = (order.orderStatus != 'delivered' && order.orderStatus != 'failed'
                && order.orderStatus != 'canceled' && order.orderStatus != 'refund_requested' && order.orderStatus != 'refunded'
                && order.orderStatus != 'refund_request_canceled' );
          }
          double subTotal = itemsPrice + addOns;
          double total = itemsPrice + addOns - discount + (taxIncluded ? 0 : tax) + deliveryCharge - couponDiscount + dmTips;

          return orderController.orderDetails != null && order != null ? Column(children: [

            Expanded(child: Scrollbar(child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: FooterView(child: SizedBox(width: Dimensions.webMaxWidth, child: Stack(
                children: [

                  Column(children: [
                    DateConverter.isBeforeTime(order.scheduleAt) && Get.find<SplashController>().getModuleConfig(order.moduleType).newVariation!
                        ? ongoing ? Column(children: [

                      ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset(
                        order.orderStatus == 'pending' ? Images.pendingFoodOrderDetails : (order.orderStatus == 'confirmed' || order.orderStatus == 'processing' || order.orderStatus == 'handover')
                            ? Images.preparingFoodOrderDetails : Images.ongoingAnimation, fit: BoxFit.contain, height: 200,
                      )),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      Text('your_food_will_delivered_within'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor)),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Center(
                        child: Row(mainAxisSize: MainAxisSize.min, children: [

                          Text(
                            DateConverter.differenceInMinute(order.store!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt) < 5 ? '1 - 5'
                                : '${DateConverter.differenceInMinute(order.store!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt)-5} '
                                '- ${DateConverter.differenceInMinute(order.store!.deliveryTime, order.createdAt, order.processingTime, order.scheduleAt)}',
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge), textDirection: TextDirection.ltr,
                          ),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          Text('min'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor)),
                        ]),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    ]) : CustomImage(image: '${Get.find<SplashController>().configModel!.baseUrls!.storeCoverPhotoUrl}/${order.store!.coverPhoto}', height: 150, width: double.infinity) : const SizedBox(),

                    parcel ? (ongoing && order.orderStatus == 'pending') ? Image.asset(Images.pendingOrderDetails, height: 160, width: double.infinity) : Center(child: CustomImage(image: '${Get.find<SplashController>().configModel!.baseUrls!.parcelCategoryImageUrl}/${order.parcelCategory!.image}', height: 160)) : const SizedBox(),

                    prescriptionOrder ? ongoing ? Image.asset(
                      order.orderStatus == 'pending' ? Images.pendingOrderDetails : (order.orderStatus == 'confirmed' || order.orderStatus == 'processing' || order.orderStatus == 'handover')
                          ? Images.preparingGroceryOrderDetails : Images.ongoingAnimation, height: 160, width: double.infinity,
                    )
                        : CustomImage(image: '${Get.find<SplashController>().configModel!.baseUrls!.storeCoverPhotoUrl}/${order.store!.coverPhoto}', height: 160, width: double.infinity)
                        : const SizedBox(),

                    orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemDetails!.moduleType == 'grocery'
                        ? (ongoing && order.orderStatus == 'pending') ? Image.asset(Images.pendingOrderDetails, height: 160, width: double.infinity)
                        : CustomImage(image: '${Get.find<SplashController>().configModel!.baseUrls!.storeCoverPhotoUrl}/${order.store!.coverPhoto}', height: 160, width: double.infinity)
                        : const SizedBox(),

                    orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemDetails!.moduleType == 'pharmacy'
                        ?(ongoing && order.orderStatus == 'pending') ? Image.asset(Images.pendingOrderDetails, height: 160, width: double.infinity)
                        : CustomImage(image: '${Get.find<SplashController>().configModel!.baseUrls!.storeCoverPhotoUrl}/${order.store!.coverPhoto}', height: 160, width: double.infinity)
                        : const SizedBox(),

                    orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemDetails!.moduleType == 'ecommerce'
                        ?(ongoing && order.orderStatus == 'pending') ? Image.asset(Images.pendingOrderDetails, height: 160, width: double.infinity)
                        : CustomImage(image: '${Get.find<SplashController>().configModel!.baseUrls!.storeCoverPhotoUrl}/${order.store!.coverPhoto}', height: 160, width: double.infinity)
                        : const SizedBox(),

                  ]),

                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    SizedBox(height: DateConverter.isBeforeTime(order.scheduleAt) && Get.find<SplashController>().getModuleConfig(order.moduleType).newVariation!
                        ? (order.orderStatus != 'delivered' && order.orderStatus != 'failed'
                        && order.orderStatus != 'canceled' && order.orderStatus != 'refund_requested' && order.orderStatus != 'refunded'
                        && order.orderStatus != 'refund_request_canceled' ) ? 280 : 140 :
                    parcel || prescriptionOrder || (orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemDetails!.moduleType == 'grocery')
                        || (orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemDetails!.moduleType == 'ecommerce')
                        || (orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemDetails!.moduleType == 'pharmacy')
                        ? 140 : 0),

                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
                        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Text('general_info'.tr, style: robotoMedium),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        Row(children: [
                          Text(parcel ? 'delivery_id'.tr : 'order_id'.tr, style: robotoRegular),
                          const Expanded(child: SizedBox()),

                          Text('#${order.id}', style: robotoBold),
                        ]),
                        const Divider(height: Dimensions.paddingSizeLarge),

                        Row(children: [
                          Text('order_date'.tr, style: robotoRegular),
                          const Expanded(child: SizedBox()),

                          Text(
                            DateConverter.dateTimeStringToDateTime(order.createdAt!),
                            style: robotoRegular,
                          ),
                        ]),

                        order.scheduled == 1 ? const Divider(height: Dimensions.paddingSizeLarge) : const SizedBox(),
                        order.scheduled == 1 ? Row(children: [
                          Text('${'scheduled_at'.tr}:', style: robotoRegular),
                          const Expanded(child: SizedBox()),
                          Text(DateConverter.dateTimeStringToDateTime(order.scheduleAt!), style: robotoMedium),
                        ]) : const SizedBox(),

                        Get.find<SplashController>().configModel!.orderDeliveryVerification! ? const Divider(height: Dimensions.paddingSizeLarge) : const SizedBox(),
                        Get.find<SplashController>().configModel!.orderDeliveryVerification! ? Row(children: [
                          Text('${'delivery_verification_code'.tr}:', style: robotoRegular),
                          const Expanded(child: SizedBox()),
                          Text(order.otp!, style: robotoMedium),
                        ]) : const SizedBox(),
                        const Divider(height: Dimensions.paddingSizeLarge),

                        Row(children: [
                          Text(order.orderType!.tr, style: robotoMedium),
                          const Expanded(child: SizedBox()),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            child: Text(
                              order.paymentMethod == 'cash_on_delivery' ? 'cash_on_delivery'.tr : order.paymentMethod == 'wallet' ? 'wallet_payment'.tr : 'digital_payment'.tr,
                              style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall),
                            ),
                          ),
                        ]),

                        const Divider(height: Dimensions.paddingSizeLarge),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                          child: Row(children: [
                            Text('${parcel ? 'charge_pay_by'.tr : 'item'.tr}:', style: robotoRegular),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                            Text(
                              parcel ? order.chargePayer!.tr : orderController.orderDetails!.length.toString(),
                              style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                            ),
                            const Expanded(child: SizedBox()),
                            Container(height: 7, width: 7, decoration: BoxDecoration(
                              color: (order.orderStatus == 'failed' || order.orderStatus == 'canceled' || order.orderStatus == 'refund_request_canceled')
                                  ? Colors.red : order.orderStatus == 'refund_requested' ? Colors.yellow : Colors.green,
                              shape: BoxShape.circle,
                            )),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                            Text(
                              order.orderStatus == 'delivered' ? '${'delivered_at'.tr} ${DateConverter.dateTimeStringToDateTime(order.delivered!)}'
                                  : order.orderStatus!.tr,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                            ),
                          ]),
                        ),

                        Get.find<SplashController>().getModuleConfig(order.moduleType).newVariation!
                            ? Column(children: [
                          const Divider(height: Dimensions.paddingSizeLarge),

                          Row(children: [
                            Text('${'cutlery'.tr}: ', style: robotoRegular),
                            const Expanded(child: SizedBox()),

                            Text(
                              order.cutlery! ? 'yes'.tr : 'no'.tr,
                              style: robotoRegular,
                            ),
                          ]),
                        ]) : const SizedBox(),

                        order.unavailableItemNote != null ? Column(
                          children: [
                            const Divider(height: Dimensions.paddingSizeLarge),

                            Row(children: [
                              Text('${'unavailable_item_note'.tr}: ', style: robotoMedium),

                              Text(
                                order.unavailableItemNote!,
                                style: robotoRegular,
                              ),
                            ]),
                          ],
                        ) : const SizedBox(),

                        order.deliveryInstruction != null ? Column(children: [
                          const Divider(height: Dimensions.paddingSizeLarge),

                          Row(children: [
                            Text('${'delivery_instruction'.tr}: ', style: robotoMedium),

                            Text(
                              order.deliveryInstruction!,
                              style: robotoRegular,
                            ),
                          ]),
                        ]) : const SizedBox(),
                        SizedBox(height: order.deliveryInstruction != null ? Dimensions.paddingSizeSmall : 0),

                        order.orderStatus == 'canceled' ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Divider(height: Dimensions.paddingSizeLarge),
                          Text('${'cancellation_note'.tr}:', style: robotoMedium),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          InkWell(
                            onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: order.cancellationReason), fromOrderDetails: true)),
                            child: Text(
                              order.cancellationReason ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                            ),
                          ),

                        ]) : const SizedBox(),

                        (order.orderStatus == 'refund_requested' || order.orderStatus == 'refund_request_canceled') ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Divider(height: Dimensions.paddingSizeLarge),

                          order.orderStatus == 'refund_requested' ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                            RichText(text: TextSpan(children: [
                              TextSpan(text: '${'refund_note'.tr}:', style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
                              TextSpan(text: '(${(order.refund != null) ? order.refund!.customerReason : ''})', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
                            ])),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            (order.refund != null && order.refund!.customerNote != null) ? InkWell(
                              onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: order.refund!.customerNote), fromOrderDetails: true)),
                              child: Text(
                                '${order.refund!.customerNote}', maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                              ),
                            ) : const SizedBox(),
                            SizedBox(height: (order.refund != null && order.refund!.image != null) ? Dimensions.paddingSizeSmall : 0),

                            (order.refund != null && order.refund!.image != null && order.refund!.image!.isNotEmpty) ? InkWell(
                              onTap: () => showDialog(context: context, builder: (context) {
                                return ImageDialog(imageUrl: '${Get.find<SplashController>().configModel!.baseUrls!.refundImageUrl}/${order.refund!.image!.isNotEmpty ? order.refund!.image![0] : ''}');
                              }),
                              child: CustomImage(
                                height: 40, width: 40, fit: BoxFit.cover,
                                image: order.refund != null ? '${Get.find<SplashController>().configModel!.baseUrls!.refundImageUrl}/${order.refund!.image!.isNotEmpty ? order.refund!.image![0] : ''}' : '',
                              ),
                            ) : const SizedBox(),
                          ]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${'refund_cancellation_note'.tr}:', style: robotoMedium),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            InkWell(
                              onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: order.refund!.adminNote), fromOrderDetails: true)),
                              child: Text(
                                '${order.refund != null ? order.refund!.adminNote : ''}', maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                              ),
                            ),

                          ]),
                        ]) : const SizedBox(),

                      ]),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    parcel || orderController.orderDetails!.isNotEmpty ? Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                      child: parcel ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        DetailsWidget(title: 'sender_details'.tr, address: order.deliveryAddress),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        DetailsWidget(title: 'receiver_details'.tr, address: order.receiverDetails),
                      ]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Text('item_info'.tr, style: robotoMedium),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: orderController.orderDetails!.length,
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                          itemBuilder: (context, index) {
                            return OrderItemWidget(order: order, orderDetails: orderController.orderDetails![index]);
                          },
                        ),
                      ]),
                    ) : const SizedBox(),
                    SizedBox(height: parcel &&  orderController.orderDetails!.isNotEmpty ? Dimensions.paddingSizeLarge : 0),

                    (Get.find<SplashController>().getModuleConfig(order.moduleType).orderAttachment! && order.orderAttachment != null
                        && order.orderAttachment!.isNotEmpty) ? Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('prescription'.tr, style: robotoRegular),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        SizedBox(
                          child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 1,
                                crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 5,
                              ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: order.orderAttachment!.length,
                              itemBuilder: (BuildContext context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: InkWell(
                                    onTap: () => openDialog(context, '${Get.find<SplashController>().configModel!.baseUrls!.orderAttachmentUrl}/${order.orderAttachment![index]}'),
                                    child: Center(child: ClipRRect(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      child: CustomImage(
                                        image: '${Get.find<SplashController>().configModel!.baseUrls!.orderAttachmentUrl}/${order.orderAttachment![index]}',
                                        width: 100, height: 100,
                                      ),
                                    )),
                                  ),
                                );
                              }),
                        ),

                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        SizedBox(width: (Get.find<SplashController>().getModuleConfig(order.moduleType).orderAttachment!
                            && order.orderAttachment != null && order.orderAttachment!.isNotEmpty) ? Dimensions.paddingSizeSmall : 0),

                        (order.orderNote  != null && order.orderNote!.isNotEmpty) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('additional_note'.tr, style: robotoRegular),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          InkWell(
                            onTap: () => Get.dialog(ReviewDialog(review: ReviewModel(comment: order.orderNote), fromOrderDetails: true)),
                            child: Text(
                              order.orderNote!, overflow: TextOverflow.ellipsis, maxLines: 3,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ]) : const SizedBox(),
                      ]),
                    ) : const SizedBox(),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    (!parcel && order.store != null) ? Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('delivery_details'.tr, style: robotoMedium),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        DeliveryDetails(from: true, address: order.store!.address),
                        const Divider(height: Dimensions.paddingSizeLarge),

                        DeliveryDetails(from: false, address: order.deliveryAddress!.address),
                      ]),
                    ) : const SizedBox(),
                    SizedBox(height: !parcel ? Dimensions.paddingSizeSmall : 0),

                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(parcel ? 'parcel_category'.tr : Get.find<SplashController>().getModuleConfig(order.moduleType).showRestaurantText!
                            ? 'restaurant_details'.tr : 'store_details'.tr, style: robotoMedium),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        (parcel && order.parcelCategory == null) ? Text(
                            'no_parcel_category_data_found'.tr, style: robotoMedium
                        ) : (!parcel && order.store == null) ? Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                          child: Text('no_restaurant_data_found'.tr, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                        )) : Row(children: [

                          ClipOval(child: CustomImage(
                            image: parcel ? '${Get.find<SplashController>().configModel!.baseUrls!.parcelCategoryImageUrl}/${order.parcelCategory!.image}'
                                : '${Get.find<SplashController>().configModel!.baseUrls!.storeImageUrl}/${order.store!.logo}',
                            height: 35, width: 35, fit: BoxFit.cover,
                          )),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              parcel ? order.parcelCategory!.name! : order.store!.name!, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                            ),
                            Text(
                              parcel ? order.parcelCategory!.description! : order.store?.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                            ),
                          ])),

                          (!parcel && order.orderType == 'take_away' && (order.orderStatus == 'pending' || order.orderStatus == 'accepted'
                              || order.orderStatus == 'confirmed' || order.orderStatus == 'processing' || order.orderStatus == 'handover'
                              || order.orderStatus == 'picked_up')) ? TextButton.icon(onPressed: () async {
                            if(!parcel) {
                              String url ='https://www.google.com/maps/dir/?api=1&destination=${order.store!.latitude}'
                                  ',${order.store!.longitude}&mode=d';
                              if (await canLaunchUrlString(url)) {
                                await launchUrlString(url);
                              }else {
                                showCustomSnackBar('unable_to_launch_google_map'.tr);
                              }
                            }
                          }, icon: const Icon(Icons.directions), label: Text('direction'.tr),

                          ) : const SizedBox(),

                          (!parcel && order.orderStatus != 'delivered' && order.orderStatus != 'failed' && order.orderStatus != 'canceled' && order.orderStatus != 'refunded') ? InkWell(
                            onTap: () async {
                              await Get.toNamed(RouteHelper.getChatRoute(
                                notificationBody: NotificationBody(orderId: order.id, restaurantId: order.store!.vendorId),
                                user: User(id: order.store!.vendorId, fName: order.store!.name, lName: '', image: order.store!.logo),
                              ));
                            },
                            child: Image.asset(Images.chatOrderDetails, height: 20, width: 20),
                          ) : const SizedBox(),

                          (Get.find<SplashController>().configModel!.refundActiveStatus! && order.orderStatus == 'delivered' && !parcel
                              && (parcel || (orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemCampaignId == null))) ? InkWell(
                            onTap: () => Get.toNamed(RouteHelper.getRefundRequestRoute(order.id.toString())),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: Dimensions.paddingSizeSmall),
                              child: Text('refund_this_order'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                            ),
                          ) : const SizedBox(),

                        ]),
                      ]),
                    ),
                    SizedBox(height: !parcel ? Dimensions.paddingSizeSmall : 0),

                    order.deliveryMan != null ? Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('delivery_man_details'.tr, style: robotoMedium),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Row(children: [

                          ClipOval(child: CustomImage(
                            image: '${Get.find<SplashController>().configModel!.baseUrls!.deliveryManImageUrl}/${order.deliveryMan!.image}',
                            height: 35, width: 35, fit: BoxFit.cover,
                          )),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              '${order.deliveryMan!.fName} ${order.deliveryMan!.lName}', maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                            ),
                            RatingBar(
                              rating: order.deliveryMan!.avgRating, size: 10,
                              ratingCount: order.deliveryMan!.ratingCount,
                            ),
                          ])),

                          (order.orderStatus != 'delivered' && order.orderStatus != 'failed' && order.orderStatus != 'canceled' && order.orderStatus != 'refunded')
                              ? Row(children: [

                            InkWell(
                              onTap: () async{
                                _timer?.cancel();
                                await Get.toNamed(RouteHelper.getChatRoute(
                                  notificationBody: NotificationBody(deliverymanId: order.deliveryMan!.id, orderId: int.parse(order.id.toString())),
                                  user: User(id: order.deliveryMan!.id, fName: order.deliveryMan!.fName, lName: order.deliveryMan!.lName, image: order.deliveryMan!.image),
                                ));
                                _startApiCall();
                              },
                              child: Image.asset(Images.chatOrderDetails, height: 20, width: 20),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            InkWell(
                              onTap: () async {
                                if(await canLaunchUrlString('tel:${order.deliveryMan!.phone}')) {
                                  launchUrlString('tel:${order.deliveryMan!.phone}', mode: LaunchMode.externalApplication);
                                }else {
                                  showCustomSnackBar('${'can_not_launch'.tr} ${order.deliveryMan!.phone}');
                                }
                              },
                              child: Image.asset(Images.phoneOrderDetails, height: 20, width: 20),
                            ),

                          ]) : const SizedBox(),

                        ]),
                      ]),
                    ) : const SizedBox(),
                    SizedBox(height: order.deliveryMan != null ? Dimensions.paddingSizeLarge : 0),

                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.05), blurRadius: 10)],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('payment_method'.tr, style: robotoMedium),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Row(children: [

                          Image.asset(
                            order.paymentMethod == 'cash_on_delivery' ? Images.codIcon : order.paymentMethod == 'wallet' ? Images.wallet : Images.digitalPayment,
                            width: 20, height: 20,
                            color: Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          Expanded(
                            child: Text(
                              order.paymentMethod == 'cash_on_delivery' ? 'cash'.tr
                                  : order.paymentMethod == 'wallet' ? 'wallet'.tr : 'digital'.tr,
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                            ),
                          ),

                        ]),
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    // Total
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                      child: Column(
                        children: [
                          parcel ? const SizedBox() : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('item_price'.tr, style: robotoRegular),
                              Text(PriceConverter.convertPrice(itemsPrice), style: robotoRegular, textDirection: TextDirection.ltr),
                            ]),
                            const SizedBox(height: 10),

                            Get.find<SplashController>().getModuleConfig(order.moduleType).addOn! ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('addons'.tr, style: robotoRegular),
                                Text('(+) ${PriceConverter.convertPrice(addOns)}', style: robotoRegular, textDirection: TextDirection.ltr),
                              ],
                            ) : const SizedBox(),

                            Get.find<SplashController>().getModuleConfig(order.moduleType).addOn! ? Divider(
                              thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5),
                            ) : const SizedBox(),

                            Get.find<SplashController>().getModuleConfig(order.moduleType).addOn! ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${'subtotal'.tr} ${taxIncluded ? 'tax_included'.tr : ''}', style: robotoMedium),
                                Text(PriceConverter.convertPrice(subTotal), style: robotoMedium, textDirection: TextDirection.ltr),
                              ],
                            ) : const SizedBox(),
                            SizedBox(height: Get.find<SplashController>().getModuleConfig(order.moduleType).addOn! ? 10 : 0),

                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('discount'.tr, style: robotoRegular),
                              Text('(-) ${PriceConverter.convertPrice(discount)}', style: robotoRegular, textDirection: TextDirection.ltr),
                            ]),
                            const SizedBox(height: 10),

                            couponDiscount > 0 ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('coupon_discount'.tr, style: robotoRegular),
                              Text(
                                '(-) ${PriceConverter.convertPrice(couponDiscount)}',
                                style: robotoRegular, textDirection: TextDirection.ltr,
                              ),
                            ]) : const SizedBox(),
                            SizedBox(height: couponDiscount > 0 ? 10 : 0),

                            !taxIncluded ?  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('${'vat_tax'.tr} (${order.taxPercentage ?? 0}%)', style: robotoRegular),
                              Text('(+) ${PriceConverter.convertPrice(tax)}', style: robotoRegular, textDirection: TextDirection.ltr),
                            ]) : const SizedBox(),
                            SizedBox(height: taxIncluded ? 0 : 10),

                            (dmTips > 0) ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('delivery_man_tips'.tr, style: robotoRegular),
                                Text('(+) ${PriceConverter.convertPrice(dmTips)}', style: robotoRegular, textDirection: TextDirection.ltr),
                              ],
                            ) : const SizedBox(),
                            SizedBox(height: dmTips > 0 ? 10 : 0),

                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('delivery_fee'.tr, style: robotoRegular),
                              deliveryCharge > 0 ? Text(
                                '(+) ${PriceConverter.convertPrice(deliveryCharge)}', style: robotoRegular, textDirection: TextDirection.ltr,
                              ) : Text('free'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
                            ]),
                          ]),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: Divider(thickness: 1, color: Theme.of(context).hintColor.withOpacity(0.5)),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('total_amount'.tr, style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor,
                        )),
                        Text(
                          PriceConverter.convertPrice(total), textDirection: TextDirection.ltr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                        ),
                      ]),
                    ),

                    SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),
                    ResponsiveHelper.isDesktop(context) ? _bottomView(orderController, order, parcel, total) : const SizedBox(),

                  ]),

                ],
              ))),
            ))),

            ResponsiveHelper.isDesktop(context) ? const SizedBox() : _bottomView(orderController, order, parcel, total),

          ]) : const Center(child: CircularProgressIndicator());
        })),
      ),
    );
  }

  void openDialog(BuildContext context, String imageUrl) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
        child: Stack(children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            child: PhotoView(
              tightMode: true,
              imageProvider: NetworkImage(imageUrl),
              heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
            ),
          ),

          Positioned(top: 0, right: 0, child: IconButton(
            splashRadius: 5,
            onPressed: () => Get.back(),
            icon: const Icon(Icons.cancel, color: Colors.red),
          )),

        ]),
      );
    },
  );

  Widget _bottomView(OrderController orderController, OrderModel order, bool parcel, double totalPrice) {
    return Column(children: [
      !orderController.showCancelled ? Center(
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: Row(children: [
            ((order.orderStatus == 'pending' && order.paymentMethod != 'digital_payment') || order.orderStatus == 'accepted' || order.orderStatus == 'confirmed'
            || order.orderStatus == 'processing' || order.orderStatus == 'handover'|| order.orderStatus == 'picked_up') ? Expanded(
              child: CustomButton(
                buttonText: parcel ? 'track_delivery'.tr : 'track_order'.tr,
                margin: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.all(Dimensions.paddingSizeSmall),
                onPressed: () async{
                  _timer?.cancel();
                  await Get.toNamed(RouteHelper.getOrderTrackingRoute(order.id));
                  _startApiCall();
                },
              ),
            ) : const SizedBox(),

            (order.orderStatus == 'pending' && order.paymentStatus == 'unpaid' && order.paymentMethod == 'digital_payment' && _isCashOnDeliveryActive!) ?
            Expanded(
              child: CustomButton(
                buttonText: 'switch_to_cod'.tr,
                margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                onPressed: () {
                  Get.dialog(ConfirmationDialog(
                      icon: Images.warning, description: 'are_you_sure_to_switch'.tr,
                      onYesPressed: () {

                        if((((_maxCodOrderAmount != null && totalPrice < _maxCodOrderAmount!) || _maxCodOrderAmount == null || _maxCodOrderAmount == 0) && !parcel) || parcel){
                          orderController.switchToCOD(order.id.toString());
                        }else{
                          if(Get.isDialogOpen!) {
                            Get.back();
                          }
                          showCustomSnackBar('${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(_maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
                        }
                      }
                  ));
                },
              ),
            ): const SizedBox(),

            order.orderStatus == 'pending' ? Expanded(child: Padding(
              padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(1, 50), shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault), side: BorderSide(width: 2, color: Theme.of(context).disabledColor),
                )),
                onPressed: () {
                  orderController.setOrderCancelReason('');
                  Get.dialog(CancellationDialogue(orderId: order.id));
                },
                child: Text(parcel ? 'cancel_delivery'.tr : 'cancel_order'.tr, style: robotoBold.copyWith(
                  color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeLarge,
                )),
              ),
            )) : const SizedBox(),

          ]),
        ),
      ) : Center(
        child: Container(
          width: Dimensions.webMaxWidth,
          height: 50,
          margin: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.all(Dimensions.paddingSizeSmall),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 2, color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Text('order_cancelled'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
        ),
      ),

      (order.orderStatus == 'delivered' && (parcel ? order.deliveryMan != null : (orderController.orderDetails!.isNotEmpty && orderController.orderDetails![0].itemCampaignId == null))) ? Center(
        child: Container(
          width: Dimensions.webMaxWidth,
          padding: ResponsiveHelper.isDesktop(context) ? null : const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: CustomButton(
            buttonText: 'review'.tr,
            onPressed: () {
              List<OrderDetailsModel> orderDetailsList = [];
              List<int?> orderDetailsIdList = [];
              for (var orderDetail in orderController.orderDetails!) {
                if(!orderDetailsIdList.contains(orderDetail.itemDetails!.id)) {
                  orderDetailsList.add(orderDetail);
                  orderDetailsIdList.add(orderDetail.itemDetails!.id);
                }
              }
              Get.toNamed(RouteHelper.getReviewRoute(), arguments: RateReviewScreen(
                orderDetailsList: orderDetailsList, deliveryMan: order.deliveryMan, orderID: order.id,
              ));
            },
          ),
        ),
      ) : const SizedBox(),

      (order.orderStatus == 'failed' && Get.find<SplashController>().configModel!.cashOnDelivery!) ? Center(
        child: Container(
          width: Dimensions.webMaxWidth,
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: CustomButton(
            buttonText: 'switch_to_cash_on_delivery'.tr,
            onPressed: () {
              Get.dialog(ConfirmationDialog(
                  icon: Images.warning, description: 'are_you_sure_to_switch'.tr,
                  onYesPressed: () {
                    orderController.switchToCOD(order.id.toString()).then((isSuccess) {
                      Get.back();
                      if(isSuccess) {
                        Get.back();
                      }
                    });
                  }
              ));
            },
          ),
        ),
      ) : const SizedBox(),
    ]);
  }

}