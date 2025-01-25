import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:hypersdkflutter/hypersdkflutter.dart';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/order_model.dart';
import 'package:sixam_mart/data/model/response/zone_response_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:sixam_mart/view/screens/checkout/widget/payment_failed_dialog.dart';
import 'package:uuid/uuid.dart';

class PaymentScreen extends StatefulWidget {
  final OrderModel orderModel;
  final bool isCashOnDelivery;
  const PaymentScreen({Key? key, required this.orderModel, required this.isCashOnDelivery}) : super(key: key);

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  // late String selectedUrl;
  // double value = 0.0;
  // final bool _isLoading = true;
  // PullToRefreshController? pullToRefreshController;
  // late MyInAppBrowser browser;
  // double? _maximumCodOrderAmount;
  //
  // @override
  // void initState() {
  //   super.initState();
  //
  // //  selectedUrl = '${AppConstants.baseUrl}/payment-mobile?customer_id=${widget.orderModel.userId}&order_id=${widget.orderModel.id}';
  //
  //   //_initData();
  // }
  //
  // void _initData() async {
  //   for(ZoneData zData in Get.find<LocationController>().getUserAddress()!.zoneData!) {
  //     for(Modules m in zData.modules!) {
  //       if(m.id == Get.find<SplashController>().module!.id) {
  //         _maximumCodOrderAmount = m.pivot!.maximumCodOrderAmount;
  //         break;
  //       }
  //     }
  //   }
  //
  //   browser = MyInAppBrowser(orderID: widget.orderModel.id.toString(), orderType: widget.orderModel.orderType, orderAmount: widget.orderModel.orderAmount, maxCodOrderAmount: _maximumCodOrderAmount, isCashOnDelivery: widget.isCashOnDelivery);
  //
  //   if (Platform.isAndroid) {
  //     await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  //
  //     bool swAvailable = await AndroidWebViewFeature.isFeatureSupported(AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
  //     bool swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);
  //
  //     if (swAvailable && swInterceptAvailable) {
  //       AndroidServiceWorkerController serviceWorkerController = AndroidServiceWorkerController.instance();
  //       await serviceWorkerController.setServiceWorkerClient(AndroidServiceWorkerClient(
  //         shouldInterceptRequest: (request) async {
  //           return null;
  //         },
  //       ));
  //     }
  //   }
  //
  //   pullToRefreshController = PullToRefreshController(
  //     options: PullToRefreshOptions(
  //       color: Colors.black,
  //     ),
  //     onRefresh: () async {
  //       if (Platform.isAndroid) {
  //         browser.webViewController.reload();
  //       } else if (Platform.isIOS) {
  //         browser.webViewController.loadUrl(urlRequest: URLRequest(url: await browser.webViewController.getUrl()));
  //       }
  //     },
  //   );
  //   browser.pullToRefreshController = pullToRefreshController;
  //
  //   await browser.openUrlRequest(
  //     urlRequest: URLRequest(url: Uri.parse(selectedUrl)),
  //     options: InAppBrowserClassOptions(
  //       crossPlatform: InAppBrowserOptions(hideUrlBar: true, hideToolbarTop: true),
  //       inAppWebViewGroupOptions: InAppWebViewGroupOptions(
  //         crossPlatform: InAppWebViewOptions(useShouldOverrideUrlLoading: true, useOnLoadResource: true),
  //       ),
  //     ),
  //   );
  // }
  final hyperSDK = HyperSDK();


  @override
  void initState() {
    super.initState();

    initiateHyperSDK();

    //  selectedUrl = '${AppConstants.baseUrl}/payment-mobile?customer_id=${widget.orderModel.userId}&order_id=${widget.orderModel.id}';

    //_initData();
  }


  void callProcess(amount) async {
    // processCalled = true;
    var processPayload = await makeApiCall(amount);
    // Get process payload from backend
    // block:start:fetch-process-payload
    // var processPayload = await getProcessPayload(widget.amount);
    // block:end:fetch-process-payload

    // Calling process on hyperSDK to open the Hypercheckout screen
    // block:start:process-sdk
    await hyperSDK.process(processPayload, hyperSDKCallbackHandler);
    // block:end:process-sdk
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
                // block:start:check-order-status
                // Successful Transaction
                // check order status via S2S API
                // block:end:check-order-status

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('charged'.tr, style: const TextStyle(color: Colors.white)),
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
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('cod_initiated'.tr, style: const TextStyle(color: Colors.white)),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                ));
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Placeholder()));
              }
              break;
            case "user_aborted":
              {
                // user initiated a txn and pressed back
                // check order status via S2S API
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Placeholder()));
              }
              break;
            case "pending_vbv":
              {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Placeholder()));
              }
              break;
            case "authorizing":
              {
                // txn in pending state
                // check order status via S2S API
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Placeholder()));
              }
              break;
            case "authorization_failed":
              {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Placeholder()));
              }
              break;
            case "authentication_failed":
              {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Placeholder()));
              }
              break;
            case "api_failure":
              {
                // txn failed
                // check order status via S2S API
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Placeholder()));
              }
              break;
            case "new":
              {
                // order created but txn failed
                // check order status via S2S API
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Placeholder()));
              }
              break;
            default:
              {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Placeholder()));
              }
          }
        }
    }
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

  @override
  Widget build(BuildContext context) {
    return
      // WillPopScope(
      // onWillPop: (() => _exitApp().then((value) => value!)),
      // child:
    Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: CustomAppBar(title: 'payment'.tr),
        body: InkWell(
            onTap: () async {
              // if (!processCalled) {
              //   callProcess(amount);
              // }

              if (await hyperSDK.isInitialised()) {
                callProcess(99.0);
              }
            },
            child: Center(child: Text("Pay Now ${widget.orderModel.orderAmount}",
            style: TextStyle(color: Colors.white),),

            )),
        // body: Center(
        //   child: SizedBox(
        //     width: Dimensions.webMaxWidth,
        //     child: Stack(
        //       children: [
        //         _isLoading ? Center(
        //           child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
        //         ) : const SizedBox.shrink(),
        //       ],
        //     ),
        //   ),
        // ),
      );
    //);
  }

  // Future<bool?> _exitApp() async {
  //   return Get.dialog(PaymentFailedDialog(orderID: widget.orderModel.id.toString(), orderAmount: widget.orderModel.orderAmount, maxCodOrderAmount: _maximumCodOrderAmount, orderType: widget.orderModel.orderType, isCashOnDelivery: widget.isCashOnDelivery));
  // }

  Future<Map<String, dynamic>> makeApiCall(amount) async {
    var url = Uri.parse('https://api.juspay.in/session');

    var headers = {
      'Authorization': 'Basic ${base64.encode(utf8.encode('BC2164B43484A71A5F57EA52374D11'))}',
      'x-merchantid': 'shopcizer',
      'Content-Type': 'application/json',
    };

    var rng = new Random();
    var number = rng.nextInt(900000) + 100000;

    var requestBody = {
      "order_id": "test" + number.toString(),
      "amount": amount,
      "customer_id": "9876543201",
      "customer_email": "test@mail.com",
      "customer_phone": "9876543201",
      "payment_page_client_id": "shopcizer",
      "action": "paymentPage",
      "return_url": "https://shop.merchant.com",
      "description": "Complete your payment",
      "first_name": "Anil",
      "last_name": "Choudhary"
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

    var response = await http.post(url, headers: headers, body: jsonEncode(requestBody));

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

}

// class MyInAppBrowser extends InAppBrowser {
//   final String orderID;
//   final String? orderType;
//   final double? orderAmount;
//   final double? maxCodOrderAmount;
//   final bool isCashOnDelivery;
//   MyInAppBrowser({required this.orderID, required this.orderType, required this.orderAmount, required this.maxCodOrderAmount, required this.isCashOnDelivery, int? windowId, UnmodifiableListView<UserScript>? initialUserScripts})
//       : super(windowId: windowId, initialUserScripts: initialUserScripts);
//
//   bool _canRedirect = true;
//
//   @override
//   Future onBrowserCreated() async {
//     if (kDebugMode) {
//       print("\n\nBrowser Created!\n\n");
//     }
//   }
//
//   @override
//   Future onLoadStart(url) async {
//     if (kDebugMode) {
//       print("\n\nStarted: $url\n\n");
//     }
//     _redirect(url.toString());
//   }
//
//   @override
//   Future onLoadStop(url) async {
//     pullToRefreshController?.endRefreshing();
//     if (kDebugMode) {
//       print("\n\nStopped: $url\n\n");
//     }
//     _redirect(url.toString());
//   }
//
//   @override
//   void onLoadError(url, code, message) {
//     pullToRefreshController?.endRefreshing();
//     if (kDebugMode) {
//       print("Can't load [$url] Error: $message");
//     }
//   }
//
//   @override
//   void onProgressChanged(progress) {
//     if (progress == 100) {
//       pullToRefreshController?.endRefreshing();
//     }
//     if (kDebugMode) {
//       print("Progress: $progress");
//     }
//   }
//
//   @override
//   void onExit() {
//     if(_canRedirect) {
//       Get.dialog(PaymentFailedDialog(orderID: orderID, orderAmount: orderAmount, maxCodOrderAmount: maxCodOrderAmount, orderType: orderType, isCashOnDelivery: isCashOnDelivery));
//     }
//     if (kDebugMode) {
//       print("\n\nBrowser closed!\n\n");
//     }
//   }
//
//   @override
//   Future<NavigationActionPolicy> shouldOverrideUrlLoading(navigationAction) async {
//     if (kDebugMode) {
//       print("\n\nOverride ${navigationAction.request.url}\n\n");
//     }
//     return NavigationActionPolicy.ALLOW;
//   }
//
//   @override
//   void onLoadResource(resource) {
//     if (kDebugMode) {
//       print("Started at: ${resource.startTime}ms ---> duration: ${resource.duration}ms ${resource.url ?? ''}");
//     }
//   }
//
//   @override
//   void onConsoleMessage(consoleMessage) {
//     if (kDebugMode) {
//       print("""
//     console output:
//       message: ${consoleMessage.message}
//       messageLevel: ${consoleMessage.messageLevel.toValue()}
//    """);
//     }
//   }
//
//   void _redirect(String url) {
//     if(_canRedirect) {
//       bool isSuccess = url.contains('success') && url.contains(AppConstants.baseUrl);
//       bool isFailed = url.contains('fail') && url.contains(AppConstants.baseUrl);
//       bool isCancel = url.contains('cancel') && url.contains(AppConstants.baseUrl);
//       if (isSuccess || isFailed || isCancel) {
//         _canRedirect = false;
//         close();
//       }
//       if (isSuccess) {
//         Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID));
//       } else if (isFailed || isCancel) {
//         Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID));
//       }
//     }
//   }
//
// }