import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/services.dart';
import 'package:hypersdkflutter/hypersdkflutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/cart_controller.dart';
import 'package:sixam_mart/controller/coupon_controller.dart';
import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/controller/parcel_controller.dart';
import 'package:sixam_mart/controller/store_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/data/model/body/place_order_body.dart';
import 'package:sixam_mart/data/model/response/address_model.dart';
import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/data/model/response/config_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/zone_response_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_dropdown.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/custom_text_field.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/image_picker_widget.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/not_logged_in_screen.dart';
import 'package:sixam_mart/view/screens/address/widget/address_widget.dart';
import 'package:sixam_mart/view/screens/cart/widget/delivery_option_button.dart';
import 'package:sixam_mart/view/screens/checkout/widget/condition_check_box.dart';
import 'package:sixam_mart/view/screens/checkout/widget/coupon_bottom_sheet.dart';
import 'package:sixam_mart/view/screens/checkout/widget/delivery_instruction_view.dart';
import 'package:sixam_mart/view/screens/checkout/widget/payment_method_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/view/screens/checkout/widget/time_slot_bottom_sheet.dart';
import 'package:sixam_mart/view/screens/checkout/widget/tips_widget.dart';
import 'package:sixam_mart/view/screens/home/home_screen.dart';
import 'package:sixam_mart/view/screens/store/widget/camera_button_sheet.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../cart/widget/cart_item_widget.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel?>? cartList;
  final bool fromCart;
  final int? storeId;


  const CheckoutScreen(
      {Key? key,
      required this.fromCart,
      required this.cartList,
      required this.storeId})
      : super(key: key);

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

Future<Map<String, dynamic>> makeApiCall(amount) async {
  var url = Uri.parse('https://api.juspay.in/session');

  var headers = {
    'Authorization':
        'Basic ${base64.encode(utf8.encode('BC2164B43484A71A5F57EA52374D11'))}',
    'x-merchantid': 'shopcizer',
    'Content-Type': 'application/json',
  };

  var rng = new Random();
  var number = rng.nextInt(900000) + 100000;

  var requestBody = {
    "order_id": "test" + number.toString(),
    "amount": amount,
    "customer_id": Get.find<UserController>().userInfoModel!.id.toString(),
    "customer_email": Get.find<UserController>().userInfoModel!.email,
    "customer_phone": Get.find<UserController>().userInfoModel!.phone,
    "payment_page_client_id": "shopcizer",
    "action": "paymentPage",
    "return_url": "https://shop.merchant.com",
    "description": "Complete your payment",
    "first_name": Get.find<UserController>().userInfoModel!.fName,
    "last_name": Get.find<UserController>().userInfoModel!.lName
  };
/*  var requestBody = {
  "requestId": "87aab75cf12b45659fbf8ad5874460a8",
  "service": "in.juspay.hyperpay",
  "payload": {
  "clientId": "shopcizer",
  "amount": "1.0",
  "merchantId": "shopcizer",
  "clientAuthToken": "tkn_0d65f0c17419484790959379267badb1",
  "clientAuthTokenExpiry": "2023-11-17T11:59:36Z",
  "environment": "production",
  "lastName": "wick",
  "action": "paymentPage",
  "customerId": "testing-customer-one",
  "returnUrl": "https://shop.merchant.com",
  "currency": "INR",
  "firstName": "John",
  "customerPhone": "9876543210",
  "customerEmail": "test@mail.com",
  "orderId": "1234",
  "description": "Complete your payment"
  }
  };*/

  var response =
      await http.post(url, headers: headers, body: jsonEncode(requestBody));

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse['sdk_payload'];
  } else {
    debugPrint('data: ${response.body}');
    debugPrint('data: ${response.reactive}');
    debugPrint('data: ${response.headers}');
    debugPrint('data: ${response.request}');
    debugPrint('data: ${response.runtimeType}');
    response.printError();
    response.printInfo();
    throw Exception('API call failed with status code ${response.statusCode}');
  }
}

class CheckoutScreenState extends State<CheckoutScreen> {
  final hyperSDK = HyperSDK();
  OrderController? oc;
  StoreController? sc;
  double total= 0.0;
  double discount = 0.0 ;
  double  tax = 0.0 ;
  DateTime? scheduleEndDate;
  AddressModel? finalAddress;
  double? maxCodOrderAmount;

  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _streetNumberController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _tipController = TextEditingController();
  final FocusNode _streetNode = FocusNode();
  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();

  final ScrollController _scrollController = ScrollController();

  double? _taxPercent = 0;
  bool? _isCashOnDeliveryActive = false;
  bool? _isDigitalPaymentActive = false;
  List<CartModel?>? _cartList;
  late bool _isWalletActive;

  List<AddressModel> address = [];
  bool firstTime = true;
  final tooltipController1 = JustTheController();
  final tooltipController2 = JustTheController();
  final tooltipController3 = JustTheController();

  var processCalled = false;
  var amount = "1.0";

  @override
  void initState() {
    super.initState();
    initCall();
  }

  void initCall() {
    if (Get.find<AuthController>().isLoggedIn()) {
      _streetNumberController.text =
          Get.find<LocationController>().getUserAddress()!.streetNumber ?? '';
      _houseController.text =
          Get.find<LocationController>().getUserAddress()!.house ?? '';
      _floorController.text =
          Get.find<LocationController>().getUserAddress()!.floor ?? '';

      Get.find<LocationController>().getZone(
          Get.find<LocationController>().getUserAddress()!.latitude,
          Get.find<LocationController>().getUserAddress()!.longitude,
          false,
          updateInAddress: true);
      if (Get.find<UserController>().userInfoModel == null) {
        Get.find<UserController>().getUserInfo();
      }
      Get.find<CouponController>().getCouponList();
      if (Get.find<LocationController>().addressList == null) {
        Get.find<LocationController>().getAddressList();
      }
      if (widget.storeId == null) {
        _cartList = [];
        widget.fromCart
            ? _cartList!.addAll(Get.find<CartController>().cartList)
            : _cartList!.addAll(widget.cartList!);
        Get.find<StoreController>()
            .initCheckoutData2(_cartList![0]!.item!.storeId);
      }
      if (widget.storeId != null) {
        Get.find<StoreController>().initCheckoutData2(widget.storeId);
        Get.find<StoreController>()
            .pickPrescriptionImage(isRemove: true, isCamera: false);
        Get.find<CouponController>().removeCouponData(false);
      }
      _isWalletActive =
          Get.find<SplashController>().configModel!.customerWalletStatus == 1;
      Get.find<OrderController>().updateTips(
        Get.find<AuthController>().getDmTipIndex().isNotEmpty
            ? int.parse(Get.find<AuthController>().getDmTipIndex())
            : 1,
        notify: false,
      );
      _tipController.text = Get.find<OrderController>().selectedTips != -1
          ? AppConstants.tips[Get.find<OrderController>().selectedTips]
          : '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    _streetNumberController.dispose();
    _houseController.dispose();
    _floorController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initiateHyperSDK();

    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    Module? module =
        Get.find<SplashController>().configModel!.moduleConfig!.module;

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(title: 'checkout'.tr),
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        body: isLoggedIn
            ? GetBuilder<LocationController>(builder: (locationController) {
                return GetBuilder<StoreController>(builder: (storeController) {
                  List<DropdownItem<int>> addressList = [];
                  address = [];

                  addressList.add(DropdownItem<int>(
                      value: 0,
                      child: SizedBox(
                        width: context.width > Dimensions.webMaxWidth
                            ? Dimensions.webMaxWidth - 50
                            : context.width - 50,
                        child: AddressWidget(
                          address:
                              Get.find<LocationController>().getUserAddress(),
                          fromAddress: false,
                          fromCheckout: true,
                        ),
                      )));
                  address.add(locationController.getUserAddress()!);
                  if (locationController.addressList != null &&
                      storeController.store != null) {
                    for (int index = 0;
                        index < locationController.addressList!.length;
                        index++) {
                      if (locationController.addressList![index].zoneIds!
                          .contains(storeController.store!.zoneId)) {
                        address.add(locationController.addressList![index]);

                        addressList.add(DropdownItem<int>(
                            value: index + 1,
                            child: SizedBox(
                              width: context.width > Dimensions.webMaxWidth
                                  ? Dimensions.webMaxWidth - 50
                                  : context.width - 50,
                              child: AddressWidget(
                                address: locationController.addressList![index],
                                fromAddress: false,
                                fromCheckout: true,
                              ),
                            )));
                      }
                    }
                  }

                  bool todayClosed = false;
                  bool tomorrowClosed = false;
                  Pivot? moduleData;
                  if (storeController.store != null) {
                    for (ZoneData zData in Get.find<LocationController>()
                        .getUserAddress()!
                        .zoneData!) {
                      if (zData.id == storeController.store!.zoneId) {
                        _isCashOnDeliveryActive = zData.cashOnDelivery! &&
                            Get.find<SplashController>()
                                .configModel!
                                .cashOnDelivery!;
                        _isDigitalPaymentActive = zData.digitalPayment! &&
                            Get.find<SplashController>()
                                .configModel!
                                .digitalPayment!;
                        if (firstTime) {
                          Get.find<OrderController>().setPaymentMethod(
                              _isDigitalPaymentActive!
                                  ? 1
                                  : _isCashOnDeliveryActive!
                                      ? 0
                                      : 2,
                              isUpdate: false);
                          firstTime = false;
                        }
                      }
                      for (Modules m in zData.modules!) {
                        if (m.id == Get.find<SplashController>().module!.id) {
                          moduleData = m.pivot;
                          break;
                        }
                      }
                    }
                    todayClosed = storeController.isStoreClosed(
                        true,
                        storeController.store!.active!,
                        storeController.store!.schedules);
                    tomorrowClosed = storeController.isStoreClosed(
                        false,
                        storeController.store!.active!,
                        storeController.store!.schedules);
                    _taxPercent = storeController.store!.tax;
                  }
                  return GetBuilder<CouponController>(
                      builder: (couponController) {
                    return GetBuilder<OrderController>(
                        builder: (orderController) {
                          oc= orderController;
                          sc= storeController;
                      double? deliveryCharge = -1;
                      double? charge = -1;

                      if (storeController.store != null &&
                          orderController.distance != null &&
                          orderController.distance != -1 &&
                          storeController.store!.selfDeliverySystem == 1) {
                        deliveryCharge = orderController.distance! *
                            storeController.store!.perKmShippingCharge!;
                        charge = orderController.distance! *
                            storeController.store!.perKmShippingCharge!;
                        double? maximumCharge =
                            storeController.store!.maximumShippingCharge;

                        if (deliveryCharge < storeController.store!.minimumShippingCharge!) {
                          deliveryCharge =
                              storeController.store!.minimumShippingCharge;
                          charge = storeController.store!.minimumShippingCharge;
                        } else if (maximumCharge != null &&
                            deliveryCharge > maximumCharge) {
                          deliveryCharge = maximumCharge;
                          charge = maximumCharge;
                        }
                      } else if (storeController.store != null &&
                          orderController.distance != null &&
                          orderController.distance != -1) {
                        deliveryCharge = orderController.distance! *
                            moduleData!.perKmShippingCharge!;
                        charge = orderController.distance! *
                            moduleData.perKmShippingCharge!;

                        if (deliveryCharge < moduleData.minimumShippingCharge!) {
                          deliveryCharge = moduleData.minimumShippingCharge;
                          charge = moduleData.minimumShippingCharge;
                        } else if (moduleData.maximumShippingCharge != null &&
                            deliveryCharge >
                                moduleData.maximumShippingCharge!) {
                          deliveryCharge = moduleData.maximumShippingCharge;
                          charge = moduleData.maximumShippingCharge;
                        }
                      }

                      if (storeController.store != null &&
                          storeController.store!.selfDeliverySystem == 0 &&
                          orderController.extraCharge != null) {
                        deliveryCharge =
                            deliveryCharge! + orderController.extraCharge!;
                        charge = charge! + orderController.extraCharge!;
                      }

                      if (moduleData != null) {
                        maxCodOrderAmount = moduleData.maximumCodOrderAmount;
                      }

                      double price = 0;
                       discount = 0;
                      double couponDiscount = couponController.discount!;
                       tax = 0;
                      bool taxIncluded = Get.find<SplashController>()
                              .configModel!
                              .taxIncluded ==
                          1;
                      double addOns = 0;
                      double subTotal = 0;
                      double orderAmount = 0;
                      if (storeController.store != null && _cartList != null) {
                        for (var cartModel in _cartList!) {
                          List<AddOns> addOnList = [];
                          for (var addOnId in cartModel!.addOnIds!) {
                            for (AddOns addOns in cartModel.item!.addOns!) {
                              if (addOns.id == addOnId.id) {
                                addOnList.add(addOns);
                                break;
                              }
                            }
                          }

                          for (int index = 0;
                              index < addOnList.length;
                              index++) {
                            addOns = addOns +
                                (addOnList[index].price! *
                                    cartModel.addOnIds![index].quantity!);
                          }
                          price =
                              price + (cartModel.price! * cartModel.quantity!);
                          double? dis = (storeController.store!.discount !=
                                      null &&
                                  DateConverter.isAvailable(
                                      storeController
                                          .store!.discount!.startTime,
                                      storeController.store!.discount!.endTime))
                              ? storeController.store!.discount!.discount
                              : cartModel.item!.discount;
                          String? disType = (storeController.store!.discount !=
                                      null &&
                                  DateConverter.isAvailable(
                                      storeController
                                          .store!.discount!.startTime,
                                      storeController.store!.discount!.endTime))
                              ? 'percent'
                              : cartModel.item!.discountType;
                          discount = discount! +
                              ((cartModel.price! -
                                      PriceConverter.convertWithDiscount(
                                          cartModel.price, dis, disType)!) *
                                  cartModel.quantity!);
                        }
                        if (storeController.store != null &&
                            storeController.store!.discount != null) {
                          if (storeController.store!.discount!.maxDiscount !=
                                  0 &&
                              storeController.store!.discount!.maxDiscount! <
                                  discount!) {
                            discount = storeController.store!.discount!.maxDiscount ?? 0.0;
                          }
                          if (storeController.store!.discount!.minPurchase !=
                                  0 &&
                              storeController.store!.discount!.minPurchase! >
                                  (price + addOns)) {
                            discount = 0;
                          }
                        }

                        price = PriceConverter.toFixed(price);
                        addOns = PriceConverter.toFixed(addOns);
                        discount = PriceConverter.toFixed(discount!);
                        couponDiscount = PriceConverter.toFixed(couponDiscount);

                        subTotal = price + addOns;
                        orderAmount =
                            (price - discount) + addOns - couponDiscount;
                      }

                      if (orderController.orderType == 'take_away' ||
                          (storeController.store != null &&
                              storeController.store!.freeDelivery!) ||
                          (Get.find<SplashController>()
                                      .configModel!
                                      .freeDeliveryOver !=
                                  null &&
                              orderAmount >=
                                  Get.find<SplashController>()
                                      .configModel!
                                      .freeDeliveryOver!) ||
                          couponController.freeDelivery) {
                        deliveryCharge = 0;
                      }

                      if (taxIncluded) {
                        tax = orderAmount * _taxPercent! / (100 + _taxPercent!);
                      } else {
                        tax = PriceConverter.calculation(
                            orderAmount, _taxPercent, 'percent', 1);
                      }
                      tax = PriceConverter.toFixed(tax);
                      deliveryCharge = PriceConverter.toFixed(deliveryCharge!);
                       total = subTotal +
                          deliveryCharge -
                          discount -
                          couponDiscount +
                          (taxIncluded ? 0 : tax) +
                          ((orderController.orderType != 'take_away' &&
                                  Get.find<SplashController>()
                                          .configModel!
                                          .dmTipsStatus ==
                                      1)
                              ? orderController.tips
                              : 0);
                      total = PriceConverter.toFixed(total);

                      return (orderController.distance != null &&
                              locationController.addressList != null &&
                              storeController.store != null)
                          ? Column(
                              children: [
                                Expanded(
                                    child: Scrollbar(
                                        controller: _scrollController,
                                        child: SingleChildScrollView(
                                          controller: _scrollController,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          child: FooterView(
                                              child: SizedBox(
                                            width: Dimensions.webMaxWidth,
                                            child: ResponsiveHelper.isDesktop(
                                                    context)
                                                ? Padding(
                                                    padding: const EdgeInsets
                                                            .only(
                                                        top: Dimensions
                                                            .paddingSizeLarge),
                                                    child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                              child: topSection(
                                                                  storeController,
                                                                  charge!,
                                                                  deliveryCharge,
                                                                  orderController,
                                                                  locationController,
                                                                  addressList,
                                                                  tomorrowClosed,
                                                                  todayClosed,
                                                                  module,
                                                                  price,
                                                                  discount,
                                                                  addOns)),
                                                          const SizedBox(
                                                              width: Dimensions
                                                                  .paddingSizeLarge),
                                                          Expanded(
                                                              child: bottomSection(
                                                                  orderController,
                                                                  total,
                                                                  module!,
                                                                  subTotal,
                                                                  discount,
                                                                  couponController,
                                                                  taxIncluded,
                                                                  tax,
                                                                  deliveryCharge,
                                                                  storeController,
                                                                  locationController,
                                                                  todayClosed,
                                                                  tomorrowClosed,
                                                                  orderAmount,
                                                                  maxCodOrderAmount)),
                                                        ]),
                                                  )
                                                : Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                        // CheckoutTopSection(
                                                        //     storeController: storeController, charge: charge!, deliveryCharge: deliveryCharge, orderController: orderController,
                                                        //   locationController: locationController, addressList: addressList, tomorrowClosed: tomorrowClosed, todayClosed: todayClosed,
                                                        //   module: module, price: price, discount: discount, addOns: addOns, storeId: widget.storeId, streetNumberController: _streetNumberController,
                                                        //   houseController: _houseController, floorController: _floorController, tooltipController1: tooltipController1, address: _address,streetNode: _streetNode,
                                                        //   houseNode: _houseNode, floorNode: _floorNode, cartList: _cartList, tooltipController2: tooltipController2, tooltipController3: tooltipController3,
                                                        //   couponTextEditingController: _couponController, tipController: _tipController,
                                                        // ),
                                                        topSection(
                                                            storeController,
                                                            charge!,
                                                            deliveryCharge,
                                                            orderController,
                                                            locationController,
                                                            addressList,
                                                            tomorrowClosed,
                                                            todayClosed,
                                                            module,
                                                            price,
                                                            discount,
                                                            addOns),

                                                        bottomSection(
                                                            orderController,
                                                            total,
                                                            module!,
                                                            subTotal,
                                                            discount,
                                                            couponController,
                                                            taxIncluded,
                                                            tax,
                                                            deliveryCharge,
                                                            storeController,
                                                            locationController,
                                                            todayClosed,
                                                            tomorrowClosed,
                                                            orderAmount,
                                                            maxCodOrderAmount),
                                                      ]),
                                          )),
                                        ))),
                                ResponsiveHelper.isDesktop(context)
                                    ? const SizedBox()
                                    : Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.1),
                                                blurRadius: 10)
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets
                                                      .symmetric(
                                                  horizontal: Dimensions
                                                      .paddingSizeLarge,
                                                  vertical: Dimensions
                                                      .paddingSizeExtraSmall),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'total_amount'.tr,
                                                      style: robotoMedium.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeLarge,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                    ),
                                                    Text(
                                                      PriceConverter
                                                          .convertPrice(total),
                                                      textDirection:
                                                          TextDirection.ltr,
                                                      style: robotoMedium.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeLarge,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                    ),
                                                  ]),
                                            ),
                                            _orderPlaceButton(
                                                orderController,
                                                storeController,
                                                locationController,
                                                todayClosed,
                                                tomorrowClosed,
                                                orderAmount,
                                                deliveryCharge,
                                                tax,
                                                discount,
                                                total,
                                                maxCodOrderAmount),
                                          ],
                                        ),
                                      ),
                              ],
                            )
                          : const Center(child: CircularProgressIndicator());
                    });
                  });
                });
              })
            : NotLoggedInScreen(callBack: (value) {
                initCall();
                setState(() {});
              }),
      ),
    );
  }

  void initiateHyperSDK() async {
    // Check whether hyperSDK is already initialised
    if (!await hyperSDK.isInitialised()) {
      // Getting initiate payload
      // block:start:get-initiate-payload
      var initiatePayload = {
        "requestId": const Uuid().v4(),
        "service": "in.juspay.hyperpay",
        "payload": {
          "action": "initiate",
          "merchantId": "shopcizer",
          "clientId": "shopcizer",
          "environment": "production"
        }
      };
      // block:end:get-initiate-payload

      // Calling initiate on hyperSDK instance to boot up payment engine.
      // block:start:initiate-sdk
      await hyperSDK.initiate(initiatePayload, initiateCallbackHandler);
      // block:end:initiate-sdk
    }
  }

  // Define handler for inititate callback
  // block:start:initiate-callback-handler
  void initiateCallbackHandler(MethodCall methodCall) {
    debugPrint("asdf${methodCall.method}");

    if (methodCall.method == "initiate_result") {
      debugPrint('initiate_result');
      // check initiate result
    }
  }

  Widget topSection(
      StoreController storeController,
      double charge,
      double deliveryCharge,
      OrderController orderController,
      LocationController locationController,
      List<DropdownItem<int>> addressList,
      bool tomorrowClosed,
      bool todayClosed,
      Module? module,
      double price,
      double discount,
      double addOns) {
    bool takeAway = orderController.orderType == 'take_away';

    return Container(
      decoration: ResponsiveHelper.isDesktop(context)
          ? BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[Get.isDarkMode ? 700 : 300]!,
                    blurRadius: 5,
                    spreadRadius: 1)
              ],
            )
          : null,
      child: Column(children: [
        GetBuilder<CartController>(builder: (cartController) {
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: cartController.cartList.length,
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            itemBuilder: (context, index) {
              return CartItemWidget(
                  isOpenBottomSheet: false,
                  cart: cartController.cartList[index],
                  cartIndex: index,
                  addOns: cartController.addOnsList[index],
                  isAvailable: cartController.availableList[index]);
            },
          );
        }),

        widget.storeId != null
            ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        blurRadius: 10)
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeSmall),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text('your_prescription'.tr, style: robotoMedium),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        JustTheTooltip(
                          backgroundColor: Colors.black87,
                          controller: tooltipController1,
                          preferredDirection: AxisDirection.right,
                          tailLength: 14,
                          tailBaseWidth: 20,
                          content: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('prescription_tool_tip'.tr,
                                style: robotoRegular.copyWith(
                                    color: Colors.white)),
                          ),
                          child: InkWell(
                            onTap: () => tooltipController1.showTooltip(),
                            child: const Icon(Icons.info_outline),
                          ),
                        ),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount:
                              storeController.pickedPrescriptions.length + 1,
                          itemBuilder: (context, index) {
                            XFile? file = index ==
                                    storeController.pickedPrescriptions.length
                                ? null
                                : storeController.pickedPrescriptions[index];
                            if (index < 5 &&
                                index ==
                                    storeController
                                        .pickedPrescriptions.length) {
                              return InkWell(
                                onTap: () {
                                  if (ResponsiveHelper.isDesktop(context)) {
                                    storeController.pickPrescriptionImage(
                                        isRemove: false, isCamera: false);
                                  } else {
                                    Get.bottomSheet(const CameraButtonSheet());
                                  }
                                },
                                child: DottedBorder(
                                  color: Theme.of(context).primaryColor,
                                  strokeWidth: 1,
                                  strokeCap: StrokeCap.butt,
                                  dashPattern: const [5, 5],
                                  padding: const EdgeInsets.all(0),
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(
                                      Dimensions.radiusDefault),
                                  child: Container(
                                    height: 98,
                                    width: 98,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall),
                                    ),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.cloud_upload,
                                              color: Theme.of(context)
                                                  .disabledColor,
                                              size: 32),
                                          Text(
                                            'upload_your_prescription'.tr,
                                            style: robotoRegular.copyWith(
                                                color: Theme.of(context)
                                                    .disabledColor,
                                                fontSize:
                                                    Dimensions.fontSizeSmall),
                                            textAlign: TextAlign.center,
                                          ),
                                        ]),
                                  ),
                                ),
                              );
                            }
                            return file != null
                                ? Container(
                                    margin: const EdgeInsets.only(
                                        right: Dimensions.paddingSizeSmall),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall),
                                    ),
                                    child: DottedBorder(
                                      color: Theme.of(context).primaryColor,
                                      strokeWidth: 1,
                                      strokeCap: StrokeCap.butt,
                                      dashPattern: const [5, 5],
                                      padding: const EdgeInsets.all(0),
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(
                                          Dimensions.radiusDefault),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Stack(children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusDefault),
                                            child: GetPlatform.isWeb
                                                ? Image.network(
                                                    file.path,
                                                    width: 98,
                                                    height: 98,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.file(
                                                    File(file.path),
                                                    width: 98,
                                                    height: 98,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: InkWell(
                                              onTap: () => storeController
                                                  .removePrescriptionImage(
                                                      index),
                                              child: const Padding(
                                                padding: EdgeInsets.all(
                                                    Dimensions
                                                        .paddingSizeSmall),
                                                child: Icon(
                                                      Icons.delete_forever,
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                  )
                                : const SizedBox();
                          },
                        ),
                      ),
                    ]),
              )
            : const SizedBox(),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        // delivery option
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  blurRadius: 10)
            ],
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: Dimensions.paddingSizeSmall),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('delivery_option'.tr, style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              widget.storeId != null
                  ? DeliveryOptionButton(
                      value: 'delivery',
                      title: 'home_delivery'.tr,
                      charge: charge,
                      isFree: storeController.store!.freeDelivery,
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        Get.find<SplashController>()
                                        .configModel!
                                        .homeDeliveryStatus ==
                                    1 &&
                                storeController.store!.delivery!
                            ? DeliveryOptionButton(
                                value: 'delivery',
                                title: 'home_delivery'.tr,
                                charge: charge,
                                isFree: storeController.store!.freeDelivery,
                              )
                            : const SizedBox(),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                        Get.find<SplashController>()
                                        .configModel!
                                        .takeawayStatus ==
                                    1 &&
                                storeController.store!.takeAway!
                            ? DeliveryOptionButton(
                                value: 'take_away',
                                title: 'take_away'.tr,
                                charge: deliveryCharge,
                                isFree: true,
                              )
                            : const SizedBox(),
                      ]),
                    ),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        !takeAway
            ? Center(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${'delivery_charge'.tr}: '),
                Text(
                  storeController.store!.freeDelivery!
                      ? 'free'.tr
                      : orderController.distance != -1
                          ? PriceConverter.convertPrice(charge)
                          : 'calculating'.tr,
                  textDirection: TextDirection.ltr,
                ),
              ]))
            : const SizedBox(),
        SizedBox(height: !takeAway ? Dimensions.paddingSizeLarge : 0),

        !takeAway
            ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        blurRadius: 10)
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('deliver_to'.tr, style: robotoMedium),
                            TextButton.icon(
                              onPressed: () async {
                                var address = await Get.toNamed(
                                    RouteHelper.getAddAddressRoute(true, false,
                                        storeController.store!.zoneId));
                                if (address != null) {
                                  orderController.getDistanceInKM(
                                    LatLng(double.parse(address.latitude),
                                        double.parse(address.longitude)),
                                    LatLng(
                                        double.parse(
                                            storeController.store!.latitude!),
                                        double.parse(
                                            storeController.store!.longitude!)),
                                  );
                                  _streetNumberController.text =
                                      address.streetNumber ?? '';
                                  _houseController.text = address.house ?? '';
                                  _floorController.text = address.floor ?? '';
                                }
                              },
                              icon: const Icon(Icons.add, size: 20),
                              label: Text('add_new'.tr,
                                  style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall)),
                            ),
                          ]),
                      Container(
                        constraints: BoxConstraints(
                            minHeight:
                                ResponsiveHelper.isDesktop(context) ? 90 : 75),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                        ),
                        child: CustomDropdown<int>(
                          onChange: (int? value, int index) {
                            orderController.getDistanceInKM(
                              LatLng(
                                double.parse(address[index].latitude!),
                                double.parse(address[index].longitude!),
                              ),
                              LatLng(
                                  double.parse(
                                      storeController.store!.latitude!),
                                  double.parse(
                                      storeController.store!.longitude!)),
                            );
                            orderController.setAddressIndex(index);

                            _streetNumberController.text =
                                address[orderController.addressIndex!]
                                        .streetNumber ??
                                    '';
                            _houseController.text =
                                address[orderController.addressIndex!].house ??
                                    '';
                            _floorController.text =
                                address[orderController.addressIndex!].floor ??
                                    '';
                          },
                          dropdownButtonStyle: DropdownButtonStyle(
                            height: 45,
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.paddingSizeExtraSmall,
                              horizontal: Dimensions.paddingSizeExtraSmall,
                            ),
                            primaryColor:
                                Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                          dropdownStyle: DropdownStyle(
                            elevation: 10,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                            padding: const EdgeInsets.all(
                                Dimensions.paddingSizeExtraSmall),
                          ),
                          items: addressList,
                          child: AddressWidget(
                            address: address[orderController.addressIndex!],
                            fromAddress: false,
                            fromCheckout: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      CustomTextField(
                        titleText: 'street_number'.tr,
                        inputType: TextInputType.streetAddress,
                        focusNode: _streetNode,
                        nextFocus: _houseNode,
                        controller: _streetNumberController,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              titleText: 'house'.tr,
                              inputType: TextInputType.text,
                              focusNode: _houseNode,
                              nextFocus: _floorNode,
                              controller: _houseController,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: CustomTextField(
                              titleText: 'floor'.tr,
                              inputType: TextInputType.text,
                              focusNode: _floorNode,
                              inputAction: TextInputAction.done,
                              controller: _floorController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                    ]),
              )
            : const SizedBox(),
        SizedBox(height: !takeAway ? Dimensions.paddingSizeSmall : 0),

        //delivery instruction
        !takeAway ? const DeliveryInstructionView() : const SizedBox(),

        SizedBox(height: !takeAway ? Dimensions.paddingSizeSmall : 0),

        // Time Slot
        widget.storeId == null &&
                storeController.store!.scheduleOrder! &&
                _cartList![0]!.item!.availableDateStarts == null
            ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        blurRadius: 10)
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeSmall),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text('preference_time'.tr, style: robotoMedium),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        JustTheTooltip(
                          backgroundColor: Colors.black87,
                          controller: tooltipController2,
                          preferredDirection: AxisDirection.right,
                          tailLength: 14,
                          tailBaseWidth: 20,
                          content: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('schedule_time_tool_tip'.tr,
                                style: robotoRegular.copyWith(
                                    color: Colors.white)),
                          ),
                          child: InkWell(
                            onTap: () => tooltipController2.showTooltip(),
                            child: const Icon(Icons.info_outline),
                          ),
                        ),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      InkWell(
                        onTap: () {
                          if (ResponsiveHelper.isDesktop(context)) {
                            showDialog(
                                context: context,
                                builder: (con) => Dialog(
                                      child: TimeSlotBottomSheet(
                                        tomorrowClosed: tomorrowClosed,
                                        todayClosed: todayClosed,
                                        module: module,
                                      ),
                                    ));
                          } else {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (con) => TimeSlotBottomSheet(
                                tomorrowClosed: tomorrowClosed,
                                todayClosed: todayClosed,
                                module: module,
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 0.3),
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radiusDefault)),
                          height: 50,
                          child: Row(children: [
                            const SizedBox(width: Dimensions.paddingSizeLarge),
                            Expanded(
                                child: ((orderController.selectedDateSlot ==
                                                0 &&
                                            todayClosed) ||
                                        (orderController.selectedDateSlot ==
                                                1 &&
                                            tomorrowClosed))
                                    ? Center(
                                        child: Text(module!.showRestaurantText!
                                            ? 'restaurant_is_closed'.tr
                                            : 'store_is_closed'.tr))
                                    : Text(orderController
                                            .preferableTime.isNotEmpty
                                        ? orderController.preferableTime
                                        : 'instance'.tr)),
                            const Icon(Icons.arrow_drop_down, size: 28),
                            Icon(Icons.access_time_filled_outlined,
                                color: Theme.of(context).primaryColor),
                            const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall),
                          ]),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                    ]),
              )
            : const SizedBox(),
        SizedBox(
            height: widget.storeId == null &&
                    storeController.store!.scheduleOrder! &&
                    _cartList![0]!.item!.availableDateStarts == null
                ? Dimensions.paddingSizeSmall
                : 0),

        // Coupon
        widget.storeId == null
            ? GetBuilder<CouponController>(
                builder: (couponController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.05),
                            blurRadius: 10)
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeLarge),
                    child: Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('promo_code'.tr, style: robotoMedium),
                            InkWell(
                              onTap: () {
                                if (ResponsiveHelper.isDesktop(context)) {
                                  Get.dialog(const Dialog(
                                          child: CouponBottomSheet()))
                                      .then((value) {
                                    if (value != null) {
                                      _couponController.text = value.toString();
                                    }
                                  });
                                } else {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (con) => const CouponBottomSheet(),
                                  ).then((value) {
                                    if (value != null) {
                                      _couponController.text = value.toString();
                                    }
                                    if (_couponController.text.isNotEmpty) {
                                      if (couponController.discount! < 1 &&
                                          !couponController.freeDelivery) {
                                        if (_couponController.text.isNotEmpty &&
                                            !couponController.isLoading) {
                                          couponController
                                              .applyCoupon(
                                                  _couponController.text,
                                                  (price - discount) + addOns,
                                                  deliveryCharge,
                                                  storeController.store!.id)
                                              .then((discount) {
                                            if (discount! > 0) {
                                              _couponController.text =
                                                  'coupon_applied'.tr;
                                              showCustomSnackBar(
                                                '${'you_got_discount_of'.tr} ${PriceConverter.convertPrice(discount)}',
                                                isError: false,
                                              );
                                            }
                                          });
                                        } else if (_couponController
                                            .text.isEmpty) {
                                          showCustomSnackBar(
                                              'enter_a_coupon_code'.tr);
                                        }
                                      } else {
                                        couponController.removeCouponData(true);
                                        _couponController.text = '';
                                      }
                                    }
                                  });
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(children: [
                                  Text('add_voucher'.tr,
                                      style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color:
                                              Theme.of(context).primaryColor)),
                                  const SizedBox(
                                      width: Dimensions.paddingSizeExtraSmall),
                                  Icon(Icons.add,
                                      size: 20,
                                      color: Theme.of(context).primaryColor),
                                ]),
                              ),
                            )
                          ]),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 0.2),
                        ),
                        child: Row(children: [
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: TextField(
                                controller: _couponController,
                                style: robotoRegular.copyWith(
                                    height: ResponsiveHelper.isMobile(context)
                                        ? null
                                        : 2),
                                decoration: InputDecoration(
                                  hintText: 'enter_promo_code'.tr,
                                  hintStyle: robotoRegular.copyWith(
                                      color: Theme.of(context).hintColor),
                                  isDense: true,
                                  filled: true,
                                  enabled: couponController.discount == 0,
                                  fillColor: Theme.of(context).cardColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(
                                          Get.find<LocalizationController>()
                                                  .isLtr
                                              ? 10
                                              : 0),
                                      right: Radius.circular(
                                          Get.find<LocalizationController>()
                                                  .isLtr
                                              ? 0
                                              : 10),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Image.asset(Images.couponIcon,
                                        height: 10,
                                        width: 20,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              String couponCode = _couponController.text.trim();
                              if (couponController.discount! < 1 &&
                                  !couponController.freeDelivery) {
                                if (couponCode.isNotEmpty &&
                                    !couponController.isLoading) {
                                  couponController
                                      .applyCoupon(
                                          couponCode,
                                          (price - discount) + addOns,
                                          deliveryCharge,
                                          storeController.store!.id)
                                      .then((discount) {
                                    if (discount! > 0) {
                                      showCustomSnackBar(
                                        '${'you_got_discount_of'.tr} ${PriceConverter.convertPrice(discount)}',
                                        isError: false,
                                      );
                                    }
                                  });
                                } else if (couponCode.isEmpty) {
                                  showCustomSnackBar('enter_a_coupon_code'.tr);
                                }
                              } else {
                                couponController.removeCouponData(true);
                                _couponController.text = '';
                              }
                            },
                            child: Container(
                              height: 45,
                              width: (couponController.discount! <= 0 &&
                                      !couponController.freeDelivery)
                                  ? 100
                                  : 50,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.all(
                                  Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                color: (couponController.discount! <= 0 &&
                                        !couponController.freeDelivery)
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.radiusDefault),
                              ),
                              child: (couponController.discount! <= 0 &&
                                      !couponController.freeDelivery)
                                  ? !couponController.isLoading
                                      ? Text(
                                          'apply'.tr,
                                          style: robotoMedium.copyWith(
                                              color:
                                                  Theme.of(context).cardColor),
                                        )
                                      : const SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white)),
                                        )
                                  : Icon(Icons.clear,
                                      color:
                                          Theme.of(context).colorScheme.error),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                    ]),
                  );
                },
              )
            : const SizedBox(),
        // SizedBox(height: widget.storeId == null ? Dimensions.paddingSizeSmall : 0),

        (!takeAway &&
                Get.find<SplashController>().configModel!.dmTipsStatus == 1)
            ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                        blurRadius: 10)
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeLarge,
                    horizontal: Dimensions.paddingSizeLarge),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        GestureDetector(
                            onTap: () async {
                              // if (!processCalled) {
                              //   callProcess(amount);
                              // }

                              if (await hyperSDK.isInitialised()) {
                                callProcess(amount);
                              }
                            },
                            child: Text('delivery_man_tips'.tr,
                                style: robotoMedium)),
                        JustTheTooltip(
                          backgroundColor: Colors.black87,
                          controller: tooltipController3,
                          preferredDirection: AxisDirection.right,
                          tailLength: 14,
                          tailBaseWidth: 20,
                          content: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                'it_s_a_great_way_to_show_your_appreciation_for_their_hard_work'
                                    .tr,
                                style: robotoRegular.copyWith(
                                    color: Colors.white)),
                          ),
                          child: InkWell(
                            onTap: () => tooltipController3.showTooltip(),
                            child: const Icon(Icons.info_outline),
                          ),
                        ),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      SizedBox(
                        height: (orderController.selectedTips ==
                                    AppConstants.tips.length - 1) &&
                                orderController.canShowTipsField
                            ? 0
                            : 40,
                        child: (orderController.selectedTips ==
                                    AppConstants.tips.length - 1) &&
                                orderController.canShowTipsField
                            ? const SizedBox()
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: AppConstants.tips.length,
                                itemBuilder: (context, index) {
                                  return TipsWidget(
                                    title: (index != 0 &&
                                            index !=
                                                AppConstants.tips.length - 1)
                                        ? PriceConverter.convertPrice(
                                            double.parse(AppConstants
                                                .tips[index]
                                                .toString()),
                                            forDM: true)
                                        : AppConstants.tips[index].tr,
                                    isSelected:
                                        orderController.selectedTips == index,
                                    onTap: () {
                                      orderController.updateTips(index);
                                      if (orderController.selectedTips != 0 &&
                                          orderController.selectedTips !=
                                              AppConstants.tips.length - 1) {
                                        orderController.addTips(double.parse(
                                            AppConstants.tips[index]));
                                      }
                                      if (orderController.selectedTips ==
                                          AppConstants.tips.length - 1) {
                                        orderController.showTipsField();
                                      }
                                      _tipController.text =
                                          orderController.tips.toString();
                                    },
                                  );
                                },
                              ),
                      ),
                      SizedBox(
                          height: (orderController.selectedTips ==
                                      AppConstants.tips.length - 1) &&
                                  orderController.canShowTipsField
                              ? Dimensions.paddingSizeExtraSmall
                              : 0),
                      orderController.selectedTips ==
                              AppConstants.tips.length - 1
                          ? const SizedBox()
                          : ListTile(
                              onTap: () => orderController.toggleDmTipSave(),
                              leading: Checkbox(
                                visualDensity: const VisualDensity(
                                    horizontal: -4, vertical: -4),
                                activeColor: Theme.of(context).primaryColor,
                                value: orderController.isDmTipSave,
                                onChanged: (bool? isChecked) =>
                                    orderController.toggleDmTipSave(),
                              ),
                              title: Text('save_for_later'.tr,
                                  style: robotoMedium.copyWith(
                                      color: Theme.of(context).primaryColor)),
                              contentPadding: EdgeInsets.zero,
                              visualDensity: const VisualDensity(
                                  horizontal: 0, vertical: -4),
                              dense: true,
                              horizontalTitleGap: 0,
                            ),
                      SizedBox(
                          height: orderController.selectedTips ==
                                  AppConstants.tips.length - 1
                              ? Dimensions.paddingSizeDefault
                              : 0),
                      orderController.selectedTips ==
                              AppConstants.tips.length - 1
                          ? Row(children: [
                              Expanded(
                                child: CustomTextField(
                                  titleText: 'enter_amount'.tr,
                                  controller: _tipController,
                                  inputAction: TextInputAction.done,
                                  inputType: TextInputType.number,
                                  onSubmit: (value) {
                                    if (value.isNotEmpty) {
                                      if (double.parse(value) >= 0) {
                                        orderController
                                            .addTips(double.parse(value));
                                      } else {
                                        showCustomSnackBar(
                                            'tips_can_not_be_negative'.tr);
                                      }
                                    } else {
                                      orderController.addTips(0.0);
                                    }
                                  },
                                  onChanged: (String value) {
                                    if (value.isNotEmpty) {
                                      if (double.parse(value) >= 0) {
                                        orderController
                                            .addTips(double.parse(value));
                                      } else {
                                        showCustomSnackBar(
                                            'tips_can_not_be_negative'.tr);
                                      }
                                    } else {
                                      orderController.addTips(0.0);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(
                                  width: Dimensions.paddingSizeSmall),
                              InkWell(
                                onTap: () {
                                  orderController.updateTips(0);
                                  orderController.showTipsField();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.5),
                                  ),
                                  padding: const EdgeInsets.all(
                                      Dimensions.paddingSizeSmall),
                                  child: const Icon(Icons.clear),
                                ),
                              ),
                            ])
                          : const SizedBox(),
                    ]),
              )
            : const SizedBox.shrink(),
        SizedBox(
            height: (!takeAway &&
                    widget.storeId == null &&
                    Get.find<SplashController>().configModel!.dmTipsStatus == 1)
                ? Dimensions.paddingSizeSmall
                : 0),
      ]),
    );
  }

  Widget bottomSection(
      OrderController orderController,
      double total,
      Module module,
      double subTotal,
      double discount,
      CouponController couponController,
      bool taxIncluded,
      double tax,
      double deliveryCharge,
      StoreController storeController,
      LocationController locationController,
      bool todayClosed,
      bool tomorrowClosed,
      double orderAmount,
      double? maxCodOrderAmount) {
    bool takeAway = orderController.orderType == 'take_away';

    return Container(
      decoration: ResponsiveHelper.isDesktop(context)
          ? BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[Get.isDarkMode ? 700 : 300]!,
                    blurRadius: 5,
                    spreadRadius: 1)
              ],
            )
          : null,
      padding:
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Column(children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  blurRadius: 10)
            ],
          ),
          padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeLarge,
              horizontal: Dimensions.paddingSizeLarge),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                  widget.storeId != null
                      ? 'payment_method'.tr
                      : 'choose_payment_method'.tr,
                  style: robotoMedium),
              widget.storeId == null
                  ? InkWell(
                      onTap: () {
                        if (ResponsiveHelper.isDesktop(context)) {
                          Get.dialog(Dialog(
                              child: PaymentMethodBottomSheet(
                            isCashOnDeliveryActive: _isCashOnDeliveryActive!,
                            isDigitalPaymentActive: _isDigitalPaymentActive!,
                            isWalletActive: _isWalletActive,
                            storeId: widget.storeId,
                          )));
                        } else {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (con) => PaymentMethodBottomSheet(
                              isCashOnDeliveryActive: _isCashOnDeliveryActive!,
                              isDigitalPaymentActive: _isDigitalPaymentActive!,
                              isWalletActive: _isWalletActive,
                              storeId: widget.storeId,
                            ),
                          );
                        }
                      },
                      child: Image.asset(Images.paymentSelect,
                          height: 24, width: 24),
                    )
                  : const SizedBox(),
            ]),
            const Divider(),
            widget.storeId != null
                ? orderController.paymentMethodIndex == 0
                    ? Row(children: [
                        Image.asset(
                          Images.codIcon,
                          width: 20,
                          height: 20,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                            child: Text(
                          'cash_on_delivery'.tr,
                          style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).disabledColor),
                        )),
                        Text(
                          PriceConverter.convertPrice(total),
                          textDirection: TextDirection.ltr,
                          style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).primaryColor),
                        )
                      ])
                    : const SizedBox()
                : Row(children: [
                    Image.asset(
                      orderController.paymentMethodIndex == 0
                          ? Images.codIcon
                          : orderController.paymentMethodIndex == 1
                              ? Images.digitalPayment
                              : Images.wallet,
                      width: 20,
                      height: 20,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Text(
                        orderController.paymentMethodIndex == 0
                            ? 'cash_on_delivery'.tr
                            : orderController.paymentMethodIndex == 1
                                ? 'digital_payment'.tr
                                : 'wallet_payment'.tr,
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).disabledColor),
                      ),
                    ),
                    Text(
                      PriceConverter.convertPrice(total),
                      textDirection: TextDirection.ltr,
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: Theme.of(context).primaryColor),
                    ),
                  ]),
          ]),
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  blurRadius: 10)
            ],
          ),
          padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeDefault,
              horizontal: Dimensions.paddingSizeLarge),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('additional_note'.tr, style: robotoMedium),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            CustomTextField(
              controller: _noteController,
              titleText: 'please_provide_extra_napkin'.tr,
              maxLines: 3,
              inputType: TextInputType.multiline,
              inputAction: TextInputAction.done,
              capitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            widget.storeId == null &&
                    Get.find<SplashController>()
                        .configModel!
                        .moduleConfig!
                        .module!
                        .orderAttachment!
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text('prescription'.tr, style: robotoMedium),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(
                          '(${'max_size_2_mb'.tr})',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ]),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      ImagePickerWidget(
                        image: '',
                        rawFile: orderController.rawAttachment,
                        onTap: () => orderController.pickImage(),
                      ),
                    ],
                  )
                : const SizedBox(),
            widget.storeId == null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Text(module.addOn! ? 'subtotal'.tr : 'item_price'.tr,
                            style: robotoMedium),
                        Text(PriceConverter.convertPrice(subTotal),
                            style: robotoMedium,
                            textDirection: TextDirection.ltr),
                      ])
                : const SizedBox(),
            SizedBox(
                height:
                    widget.storeId == null ? Dimensions.paddingSizeSmall : 0),
            widget.storeId == null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Text('discount'.tr, style: robotoRegular),
                        Text('(-) ${PriceConverter.convertPrice(discount)}',
                            style: robotoRegular,
                            textDirection: TextDirection.ltr),
                      ])
                : const SizedBox(),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            (couponController.discount! > 0 || couponController.freeDelivery)
                ? Column(children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('coupon_discount'.tr, style: robotoRegular),
                          (couponController.coupon != null &&
                                  couponController.coupon!.couponType ==
                                      'free_delivery')
                              ? Text(
                                  'free_delivery'.tr,
                                  style: robotoRegular.copyWith(
                                      color: Theme.of(context).primaryColor),
                                )
                              : Text(
                                  '(-) ${PriceConverter.convertPrice(couponController.discount)}',
                                  style: robotoRegular,
                                  textDirection: TextDirection.ltr,
                                ),
                        ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                  ])
                : const SizedBox(),
            widget.storeId == null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Text(
                            '${'vat_tax'.tr} ${taxIncluded ? 'tax_included'.tr : ''} ($_taxPercent%)',
                            style: robotoRegular),
                        Text(
                            (taxIncluded ? '' : '(+) ') +
                                PriceConverter.convertPrice(tax),
                            style: robotoRegular,
                            textDirection: TextDirection.ltr),
                      ])
                : const SizedBox(),
            SizedBox(
                height:
                    widget.storeId == null ? Dimensions.paddingSizeSmall : 0),
            (!takeAway &&
                    Get.find<SplashController>().configModel!.dmTipsStatus == 1)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('delivery_man_tips'.tr, style: robotoRegular),
                      Text(
                          '(+) ${PriceConverter.convertPrice(orderController.tips)}',
                          style: robotoRegular,
                          textDirection: TextDirection.ltr),
                    ],
                  )
                : const SizedBox.shrink(),
            SizedBox(
                height: !takeAway &&
                        Get.find<SplashController>()
                                .configModel!
                                .dmTipsStatus ==
                            1
                    ? Dimensions.paddingSizeSmall
                    : 0.0),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('delivery_fee'.tr, style: robotoRegular),
              orderController.distance == -1
                  ? Text(
                      'calculating'.tr,
                      style: robotoRegular.copyWith(color: Colors.red),
                    )
                  : (deliveryCharge == 0 ||
                          (couponController.coupon != null &&
                              couponController.coupon!.couponType ==
                                  'free_delivery'))
                      ? Text(
                          'free'.tr,
                          style: robotoRegular.copyWith(
                              color: Theme.of(context).primaryColor),
                        )
                      : Text(
                          '(+) ${PriceConverter.convertPrice(deliveryCharge)}',
                          style: robotoRegular,
                          textDirection: TextDirection.ltr,
                        ),
            ]),
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeSmall),
              child: Divider(
                  thickness: 1,
                  color: Theme.of(context).hintColor.withOpacity(0.5)),
            ),
            ResponsiveHelper.isDesktop(context)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Text(
                          'total_amount'.tr,
                          style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).primaryColor),
                        ),
                        Text(
                          PriceConverter.convertPrice(total),
                          textDirection: TextDirection.ltr,
                          style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).primaryColor),
                        ),
                      ])
                : const SizedBox(),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            CheckoutCondition(
                orderController: orderController,
                parcelController: Get.find<ParcelController>()),
          ]),
        ),
        ResponsiveHelper.isDesktop(context)
            ? Padding(
                padding:
                    const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                child: _orderPlaceButton(
                  orderController,
                  storeController,
                  locationController,
                  todayClosed,
                  tomorrowClosed,
                  orderAmount,
                  deliveryCharge,
                  tax,
                  discount,
                  total,
                  maxCodOrderAmount,
                ),
              )
            : const SizedBox(),
      ]),
    );
  }

  void _callback(bool isSuccess, String? message, String orderID, int? zoneID,
      double amount, double? maximumCodOrderAmount) async {
    if (isSuccess) {
      if (widget.fromCart) {
        Get.find<CartController>().clearCartList();
      }
      if (!Get.find<OrderController>().showBottomSheet) {
        Get.find<OrderController>().showRunningOrders();
      }
      if (Get.find<OrderController>().isDmTipSave) {
        Get.find<AuthController>().saveDmTipIndex(
            Get.find<OrderController>().selectedTips.toString());
      }
      Get.find<OrderController>().stopLoader();

      HomeScreen.loadData(true);

      if (Get.find<OrderController>().paymentMethodIndex == 1) {
        if (GetPlatform.isWeb) {
          Get.back();
          String? hostname = html.window.location.hostname;
          String protocol = html.window.location.protocol;
          String selectedUrl =
              '${AppConstants.baseUrl}/payment-mobile?order_id=$orderID&&customer_id=${Get.find<UserController>().userInfoModel!.id}&&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=$orderID&status=';
          html.window.open(selectedUrl, "_self");
        } else {
          // Get.offNamed(RouteHelper.getPaymentRoute(
          //   orderID, Get.find<UserController>().userInfoModel!.id, Get.find<OrderController>().orderType, amount, _isCashOnDeliveryActive
          // ));
          //  callProcess(amount);

          Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID));
        }
      } else {
        double total = ((amount / 100) *
            Get.find<SplashController>()
                .configModel!
                .loyaltyPointItemPurchasePoint!);
        Get.find<AuthController>().saveEarningPoint(total.toStringAsFixed(0));
        Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID));
      }
      Get.find<OrderController>().clearPrevData(zoneID);
      Get.find<CouponController>().removeCouponData(false);
      Get.find<OrderController>().updateTips(
          Get.find<AuthController>().getDmTipIndex().isNotEmpty
              ? int.parse(Get.find<AuthController>().getDmTipIndex())
              : 1,
          notify: false);
    } else {
      showCustomSnackBar(message);
    }
  }

  Widget _orderPlaceButton(
      OrderController orderController,
      StoreController storeController,
      LocationController locationController,
      bool todayClosed,
      bool tomorrowClosed,
      double orderAmount,
      double? deliveryCharge,
      double tax,
      double? discount,
      double total,
      double? maxCodOrderAmount) {
    return Container(
      width: Dimensions.webMaxWidth,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeSmall,
          horizontal: Dimensions.paddingSizeLarge),
      child: SafeArea(
        child: CustomButton(
            isLoading: orderController.isLoading,
            buttonText: 'confirm_order'.tr,
            onPressed: orderController.acceptTerms
                ? () async {
                    bool isAvailable = true;
                    DateTime scheduleStartDate = DateTime.now();
                     scheduleEndDate = DateTime.now();
                    if (orderController.timeSlots == null ||
                        orderController.timeSlots!.isEmpty) {
                      isAvailable = false;
                    } else {
                      DateTime date = orderController.selectedDateSlot == 0
                          ? DateTime.now()
                          : DateTime.now().add(const Duration(days: 1));
                      DateTime startTime = orderController
                          .timeSlots![orderController.selectedTimeSlot]
                          .startTime!;
                      DateTime endTime = orderController
                          .timeSlots![orderController.selectedTimeSlot]
                          .endTime!;
                      scheduleStartDate = DateTime(date.year, date.month,
                          date.day, startTime.hour, startTime.minute + 1);
                      scheduleEndDate = DateTime(date.year, date.month,
                          date.day, endTime.hour, endTime.minute + 1);
                      if (_cartList != null) {
                        for (CartModel? cart in _cartList!) {
                          if (!DateConverter.isAvailable(
                                cart!.item!.availableTimeStarts,
                                cart.item!.availableTimeEnds,
                                time: storeController.store!.scheduleOrder!
                                    ? scheduleStartDate
                                    : null,
                              ) &&
                              !DateConverter.isAvailable(
                                cart.item!.availableTimeStarts,
                                cart.item!.availableTimeEnds,
                                time: storeController.store!.scheduleOrder!
                                    ? scheduleEndDate
                                    : null,
                              )) {
                            isAvailable = false;
                            break;
                          }
                        }
                      }
                    }
                    if (!_isCashOnDeliveryActive! &&
                        !_isDigitalPaymentActive! &&
                        !_isWalletActive) {
                      showCustomSnackBar('no_payment_method_is_enabled'.tr);
                    } else if (orderAmount <
                            storeController.store!.minimumOrder! &&
                        widget.storeId == null) {
                      showCustomSnackBar(
                          '${'minimum_order_amount_is'.tr} ${storeController.store!.minimumOrder}');
                    } else if (_tipController.text.isNotEmpty &&
                        _tipController.text != 'not_now' &&
                        double.parse(_tipController.text.trim()) < 0) {
                      showCustomSnackBar('tips_can_not_be_negative'.tr);
                    } else if ((orderController.selectedDateSlot == 0 &&
                            todayClosed) ||
                        (orderController.selectedDateSlot == 1 &&
                            tomorrowClosed)) {
                      showCustomSnackBar(Get.find<SplashController>()
                              .configModel!
                              .moduleConfig!
                              .module!
                              .showRestaurantText!
                          ? 'restaurant_is_closed'.tr
                          : 'store_is_closed'.tr);
                    } else if (orderController.paymentMethodIndex == 0 &&
                        _isCashOnDeliveryActive! &&
                        maxCodOrderAmount != null &&
                        maxCodOrderAmount != 0 &&
                        (total > maxCodOrderAmount) &&
                        widget.storeId == null) {
                      showCustomSnackBar(
                          '${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
                    } else if (orderController.paymentMethodIndex != 0 &&
                        widget.storeId != null) {
                      showCustomSnackBar('payment_method_is_not_available'.tr);
                    } else if (orderController.timeSlots == null ||
                        orderController.timeSlots!.isEmpty) {
                      if (storeController.store!.scheduleOrder!) {
                        showCustomSnackBar('select_a_time'.tr);
                      } else {
                        showCustomSnackBar(Get.find<SplashController>()
                                .configModel!
                                .moduleConfig!
                                .module!
                                .showRestaurantText!
                            ? 'restaurant_is_closed'.tr
                            : 'store_is_closed'.tr);
                      }
                    } else if (!isAvailable) {
                      showCustomSnackBar(
                          'one_or_more_products_are_not_available_for_this_selected_time'
                              .tr);
                    } else if (orderController.orderType != 'take_away' &&
                        orderController.distance == -1 &&
                        deliveryCharge == -1) {
                      showCustomSnackBar('delivery_fee_not_set_yet'.tr);
                    } else if (widget.storeId != null &&
                        storeController.pickedPrescriptions.isEmpty) {
                      showCustomSnackBar(
                          'please_upload_your_prescription_images'.tr);
                    } else if (!orderController.acceptTerms) {
                      showCustomSnackBar(
                          'please_accept_privacy_policy_trams_conditions_refund_policy_first'
                              .tr);
                    } else {
                    finalAddress = address[orderController.addressIndex!];

                      if (widget.storeId == null) {
                        List<Cart> carts = [];
                        for (int index = 0;
                            index < _cartList!.length;
                            index++) {
                          CartModel cart = _cartList![index]!;
                          List<int?> addOnIdList = [];
                          List<int?> addOnQtyList = [];
                          for (var addOn in cart.addOnIds!) {
                            addOnIdList.add(addOn.id);
                            addOnQtyList.add(addOn.quantity);
                          }

                          List<OrderVariation> variations = [];
                          if (Get.find<SplashController>()
                              .getModuleConfig(cart.item!.moduleType)
                              .newVariation!) {
                            for (int i = 0;
                                i < cart.item!.foodVariations!.length;
                                i++) {
                              if (cart.foodVariations![i].contains(true)) {
                                variations.add(OrderVariation(
                                    name: cart.item!.foodVariations![i].name,
                                    values: OrderVariationValue(label: [])));
                                for (int j = 0;
                                    j <
                                        cart.item!.foodVariations![i]
                                            .variationValues!.length;
                                    j++) {
                                  if (cart.foodVariations![i][j]!) {
                                    variations[variations.length - 1]
                                        .values!
                                        .label!
                                        .add(cart.item!.foodVariations![i]
                                            .variationValues![j].level);
                                  }
                                }
                              }
                            }
                          }
                          carts.add(Cart(
                            cart.isCampaign! ? null : cart.item!.id,
                            cart.isCampaign! ? cart.item!.id : null,
                            cart.discountedPrice.toString(),
                            '',
                            Get.find<SplashController>()
                                    .getModuleConfig(cart.item!.moduleType)
                                    .newVariation!
                                ? null
                                : cart.variation,
                            Get.find<SplashController>()
                                    .getModuleConfig(cart.item!.moduleType)
                                    .newVariation!
                                ? variations
                                : null,
                            cart.quantity,
                            addOnIdList,
                            cart.addOns,
                            addOnQtyList,
                          ));
                        }

                       /* orderController.placeOrder(
                            PlaceOrderBody(
                              cart: carts,
                              couponDiscountAmount:
                                  Get.find<CouponController>().discount,
                              distance: orderController.distance,
                              scheduleAt: !storeController.store!.scheduleOrder!
                                  ? null
                                  : (orderController.selectedDateSlot == 0 &&
                                          orderController.selectedTimeSlot == 0)
                                      ? null
                                      : DateConverter.dateToDateAndTime(
                                          scheduleEndDate!),
                              orderAmount: total,
                              orderNote: _noteController.text,
                              orderType: orderController.orderType,
                              paymentMethod:
                                  orderController.paymentMethodIndex == 0
                                      ? 'cash_on_delivery'
                                      : orderController.paymentMethodIndex == 1
                                          ? 'digital_payment'
                                          : 'wallet',
                              couponCode: (Get.find<CouponController>()
                                              .discount! >
                                          0 ||
                                      (Get.find<CouponController>().coupon !=
                                              null &&
                                          Get.find<CouponController>()
                                              .freeDelivery))
                                  ? Get.find<CouponController>().coupon!.code
                                  : null,
                              storeId: _cartList![0]!.item!.storeId,
                              address: finalAddress?.address ?? "",
                              latitude: finalAddress?.latitude,
                              longitude: finalAddress?.longitude,
                              addressType: finalAddress?.addressType,
                              contactPersonName: finalAddress?.contactPersonName ??
                                  '${Get.find<UserController>().userInfoModel!.fName} '
                                      '${Get.find<UserController>().userInfoModel!.lName}',
                              contactPersonNumber:
                                  finalAddress?.contactPersonNumber ??
                                      Get.find<UserController>()
                                          .userInfoModel!
                                          .phone,
                              streetNumber: _streetNumberController.text.trim(),
                              house: _houseController.text.trim(),
                              floor: _floorController.text.trim(),
                              discountAmount: discount,
                              taxAmount: tax,
                              receiverDetails: null,
                              parcelCategoryId: null,
                              chargePayer: null,
                              dmTips: orderController.orderType == 'take_away'
                                  ? ''
                                  : _tipController.text.trim(),
                              cutlery:
                                  Get.find<CartController>().addCutlery ? 1 : 0,
                              unavailableItemNote: Get.find<CartController>()
                                          .notAvailableIndex !=
                                      -1
                                  ? Get.find<CartController>().notAvailableList[
                                      Get.find<CartController>()
                                          .notAvailableIndex]
                                  : '',
                              deliveryInstruction:
                                  orderController.selectedInstruction != -1
                                      ? AppConstants.deliveryInstructionList[
                                          orderController.selectedInstruction]
                                      : '',
                            ),
                            storeController.store!.zoneId,
                            _callback,
                            total,
                            maxCodOrderAmount);*/


                        if (await hyperSDK.isInitialised()) {
              callProcess(total);
              /*    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('init'.tr, style: const TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            ));*/
              } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('not init'.tr,
              style: const TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              ));
              }

                      } else {
                        orderController.placePrescriptionOrder(
                            widget.storeId,
                            storeController.store!.zoneId,
                            orderController.distance,
                            finalAddress!.address!,
                            finalAddress?.longitude ?? "",
                            finalAddress?.latitude ?? "",
                            _noteController.text,
                            storeController.pickedPrescriptions,
                            _tipController.text.trim(),
                            orderController.selectedInstruction != -1
                                ? AppConstants.deliveryInstructionList[
                                    orderController.selectedInstruction]
                                : '',
                            _callback,
                            0,
                            0);
                      }
                    }
                  }
                : null),
      ),
    );
  }

  void callProcess(amount) async {
    // processCalled = true;
    var processPayload = await makeApiCall(amount);
    await hyperSDK.process(processPayload, hyperSDKCallbackHandler);
  }









  void hyperSDKCallbackHandler(MethodCall methodCall) {
    switch (methodCall.method) {
      case "hide_loader":
        setState(() {
          //showLoader = false;
        });
        break;
      case "process_result":
        var args = {};

        try {
          args = json.decode(methodCall.arguments);
        } catch (e) {
          print(e);
        }

        var error = args["error"] ?? false;

        var innerPayload = args["payload"] ?? {};

        var status = innerPayload["status"] ?? " ";
        var pi = innerPayload["paymentInstrument"] ?? " ";
        var pig = innerPayload["paymentInstrumentGroup"] ?? " ";

        if (!error) {
          switch (status) {
            case "charged":
              {
                List<Cart> carts = [];
                for (int index = 0;
                index < _cartList!.length;
                index++) {
                  CartModel cart = _cartList![index]!;
                  List<int?> addOnIdList = [];
                  List<int?> addOnQtyList = [];
                  for (var addOn in cart.addOnIds!) {
                    addOnIdList.add(addOn.id);
                    addOnQtyList.add(addOn.quantity);
                  }

                  List<OrderVariation> variations = [];
                  if (Get.find<SplashController>()
                      .getModuleConfig(cart.item!.moduleType)
                      .newVariation!) {
                    for (int i = 0;
                    i < cart.item!.foodVariations!.length;
                    i++) {
                      if (cart.foodVariations![i].contains(true)) {
                        variations.add(OrderVariation(
                            name: cart.item!.foodVariations![i].name,
                            values: OrderVariationValue(label: [])));
                        for (int j = 0;
                        j <
                            cart.item!.foodVariations![i]
                                .variationValues!.length;
                        j++) {
                          if (cart.foodVariations![i][j]!) {
                            variations[variations.length - 1]
                                .values!
                                .label!
                                .add(cart.item!.foodVariations![i]
                                .variationValues![j].level);
                          }
                        }
                      }
                    }
                  }
                  carts.add(Cart(
                    cart.isCampaign! ? null : cart.item!.id,
                    cart.isCampaign! ? cart.item!.id : null,
                    cart.discountedPrice.toString(),
                    '',
                    Get.find<SplashController>()
                        .getModuleConfig(cart.item!.moduleType)
                        .newVariation!
                        ? null
                        : cart.variation,
                    Get.find<SplashController>()
                        .getModuleConfig(cart.item!.moduleType)
                        .newVariation!
                        ? variations
                        : null,
                    cart.quantity,
                    addOnIdList,
                    cart.addOns,
                    addOnQtyList,
                  ));
                }





                oc?.placeOrder(
                    PlaceOrderBody(
                      cart: carts,
                      couponDiscountAmount:
                      Get.find<CouponController>().discount,
                      distance: oc?.distance,
                      scheduleAt: !sc!.store!.scheduleOrder!
                          ? null
                          : (oc?.selectedDateSlot == 0 &&
                          oc?.selectedTimeSlot == 0)
                          ? null
                          : DateConverter.dateToDateAndTime(scheduleEndDate!),
                      orderAmount: total,
                      orderNote: _noteController.text,
                      orderType: oc?.orderType,
                      paymentMethod:
                      oc?.paymentMethodIndex == 0
                          ? 'cash_on_delivery'
                          : oc?.paymentMethodIndex == 1
                          ? 'digital_payment'
                          : 'wallet',
                      couponCode: (Get.find<CouponController>()
                          .discount! >
                          0 ||
                          (Get.find<CouponController>().coupon !=
                              null &&
                              Get.find<CouponController>()
                                  .freeDelivery))
                          ? Get.find<CouponController>().coupon!.code
                          : null,
                      storeId: _cartList![0]!.item!.storeId,
                      address: finalAddress?.address,
                      latitude: finalAddress?.latitude,
                      longitude: finalAddress?.longitude,
                      addressType: finalAddress?.addressType,
                      contactPersonName: finalAddress?.contactPersonName ??
                          '${Get.find<UserController>().userInfoModel!.fName} '
                              '${Get.find<UserController>().userInfoModel!.lName}',
                      contactPersonNumber:
                      finalAddress?.contactPersonNumber ??
                          Get.find<UserController>()
                              .userInfoModel!
                              .phone,
                      streetNumber: _streetNumberController.text.trim(),
                      house: _houseController.text.trim(),
                      floor: _floorController.text.trim(),
                      discountAmount: discount,
                      taxAmount: tax,
                      receiverDetails: null,
                      parcelCategoryId: null,
                      chargePayer: null,
                      dmTips: oc?.orderType == 'take_away'
                          ? ''
                          : _tipController.text.trim(),
                      cutlery:
                      Get.find<CartController>().addCutlery ? 1 : 0,
                      unavailableItemNote: Get.find<CartController>()
                          .notAvailableIndex !=
                          -1
                          ? Get.find<CartController>().notAvailableList[
                      Get.find<CartController>()
                          .notAvailableIndex]
                          : '',
                      deliveryInstruction:
                      oc?.selectedInstruction != -1
                          ? AppConstants.deliveryInstructionList[oc!.selectedInstruction]
                          : '',
                    ),
                    sc?.store!.zoneId,
                    _callback,
                    total,
                    maxCodOrderAmount);

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('charged'.tr,
                      style: const TextStyle(color: Colors.white)),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                ));

                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => SuccessScreen()));
              }
              break;
            case "cod_initiated":
              {
                // User opted for cash on delivery option displayed on the Hypercheckout screen
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => SuccessScreen()));
              }
              break;
          }
        } else {
          var errorCode = args["errorCode"] ?? " ";
          var errorMessage = args["errorMessage"] ?? " ";

          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   Navigator.pushReplacement(context,
          //       MaterialPageRoute(builder: (context) => const SuccessScreen()));
          // });
          switch (status) {
            case "backpressed":
              {
                // user back-pressed from PP without initiating any txn
                showSnackbar("backpressed");
              }
              break;
            case "user_aborted":
              {
                // user initiated a txn and pressed back
                // check order status via S2S API
                showSnackbar("user_aborted");
              }
              break;
            case "pending_vbv":
              {
                showSnackbar("pending_vbv");
              }
              break;
            case "authorizing":
              {
                // txn in pending state
                // check order status via S2S API
                showSnackbar("authorizing");

              }
              break;
            case "authorization_failed":
              {
                showSnackbar("authorization_failed");
              }
              break;
            case "authentication_failed":
              {
                showSnackbar("authentication_failed");
              }
              break;
            case "api_failure":
              {
                // txn failed
                // check order status via S2S API
                showSnackbar("api_failure");
              }
              break;
            case "new":
              {
                // order created but txn failed
                // check order status via S2S API
                showSnackbar("new");
              }
              break;
            default:
              {
                showSnackbar("default");
              }
          }
        }
    }
  }

  showSnackbar(msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
    ));
  }
}
