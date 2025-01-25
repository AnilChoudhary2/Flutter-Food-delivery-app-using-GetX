import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/chat_controller.dart';
import 'package:sixam_mart/controller/notification_controller.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/data/model/body/notification_body.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class NotificationHelper {

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()!.requestPermission();
    flutterLocalNotificationsPlugin.initialize(initializationsSettings, onDidReceiveNotificationResponse: (NotificationResponse load) async {
      try{
        NotificationBody payload;
        if(load.payload!.isNotEmpty) {
          payload = NotificationBody.fromJson(jsonDecode(load.payload!));
          if(payload.notificationType == NotificationType.order) {
            Get.offAllNamed(RouteHelper.getOrderDetailsRoute(int.parse(payload.orderId.toString()), fromNotification: true));
          } else if(payload.notificationType == NotificationType.general) {
            Get.offAllNamed(RouteHelper.getNotificationRoute(fromNotification: true));
          } else{
            Get.offAllNamed(RouteHelper.getChatRoute(notificationBody: payload, conversationID: payload.conversationId, fromNotification: true));
          }
        }
      }catch (_) {}
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("onMessage: ${message.notification!.title}/${message.notification!.body}/${message.notification!.titleLocKey}");
        print("onMessage type: ${message.data['type']}/${message.data}");
      }
      if(message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.messages)) {
        if(Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1);
          if(Get.find<ChatController>().messageModel!.conversation!.id.toString() == message.data['conversation_id'].toString()) {
            Get.find<ChatController>().getMessages(
              1, NotificationBody(
              notificationType: NotificationType.message, adminId: message.data['sender_type'] == AppConstants.admin ? 0 : null,
              restaurantId: message.data['sender_type'] == AppConstants.vendor ? 0 : null,
              deliverymanId: message.data['sender_type'] == AppConstants.deliveryMan ? 0 : null,
            ),
              null, int.parse(message.data['conversation_id'].toString()),
            );
          }else {
            NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, false);
          }
        }
      }else if(message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.conversation)) {
        if(Get.find<AuthController>().isLoggedIn()) {
          Get.find<ChatController>().getConversationList(1);
        }
        NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, false);
      }else {
        NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, false);
        if(Get.find<AuthController>().isLoggedIn()) {
          Get.find<OrderController>().getRunningOrders(1);
          Get.find<OrderController>().getHistoryOrders(1);
          Get.find<NotificationController>().getNotificationList(true);

        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("onOpenApp: ${message.notification!.title}/${message.notification!.body}/${message.notification!.titleLocKey}");
      }
      try{
        if(/*message.data != null ||*/ message.data.isNotEmpty) {
          NotificationBody notificationBody = convertNotification(message.data);
          if(notificationBody.notificationType == NotificationType.order) {
            Get.offAllNamed(RouteHelper.getOrderDetailsRoute(int.parse(message.data['order_id']), fromNotification: true));
          } else if(notificationBody.notificationType == NotificationType.general) {
            Get.offAllNamed(RouteHelper.getNotificationRoute(fromNotification: true));
          } else{
            Get.offAllNamed(RouteHelper.getChatRoute(notificationBody: notificationBody, conversationID: notificationBody.conversationId, fromNotification: true));
          }
        }
      }catch (_) {}
    });
  }

  static Future<void> showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin fln, bool data) async {
    if(!GetPlatform.isIOS) {
      String? title;
      String? body;
      String? orderID;
      String? image;
      NotificationBody notificationBody = convertNotification(message.data);
      if(data) {
        title = message.data['title'];
        body = message.data['body'];
        orderID = message.data['order_id'];
        image = (message.data['image'] != null && message.data['image'].isNotEmpty)
            ? message.data['image'].startsWith('http') ? message.data['image']
            : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}' : null;
      }else {
        title = message.notification!.title;
        body = message.notification!.body;
        orderID = message.notification!.titleLocKey;
        if(GetPlatform.isAndroid) {
          image = (message.notification!.android!.imageUrl != null && message.notification!.android!.imageUrl!.isNotEmpty)
              ? message.notification!.android!.imageUrl!.startsWith('http') ? message.notification!.android!.imageUrl
              : '${AppConstants.baseUrl}/storage/app/public/notification/${message.notification!.android!.imageUrl}' : null;
        }else if(GetPlatform.isIOS) {
          image = (message.notification!.apple!.imageUrl != null && message.notification!.apple!.imageUrl!.isNotEmpty)
              ? message.notification!.apple!.imageUrl!.startsWith('http') ? message.notification!.apple!.imageUrl
              : '${AppConstants.baseUrl}/storage/app/public/notification/${message.notification!.apple!.imageUrl}' : null;
        }
      }

      if(image != null && image.isNotEmpty) {
        try{
          await showBigPictureNotificationHiddenLargeIcon(title, body, orderID, notificationBody, image, fln);
        }catch(e) {
          await showBigTextNotification(title, body!, orderID, notificationBody, fln);
        }
      }else {
        await showBigTextNotification(title, body!, orderID, notificationBody, fln);
      }
    }
  }

  static Future<void> showTextNotification(String title, String body, String orderID, NotificationBody? notificationBody, FlutterLocalNotificationsPlugin fln) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '6ammart', '6ammart', playSound: true,
      importance: Importance.max, priority: Priority.max, sound: RawResourceAndroidNotificationSound('notification'),
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<void> showBigTextNotification(String? title, String body, String? orderID, NotificationBody? notificationBody, FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body, htmlFormatBigText: true,
      contentTitle: title, htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '6ammart', '6ammart', importance: Importance.max,
      styleInformation: bigTextStyleInformation, priority: Priority.max, playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(String? title, String? body, String? orderID, NotificationBody? notificationBody, String image, FlutterLocalNotificationsPlugin fln) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true,
      contentTitle: title, htmlFormatContentTitle: true,
      summaryText: body, htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '6ammart', '6ammart',
      largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max, playSound: true,
      styleInformation: bigPictureStyleInformation, importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static NotificationBody convertNotification(Map<String, dynamic> data){
    if(data['type'] == 'general') {
      return NotificationBody(notificationType: NotificationType.general);
    }else if(data['type'] == 'order_status') {
      return NotificationBody(notificationType: NotificationType.order, orderId: int.parse(data['order_id']));
    }else {
      return NotificationBody(
        notificationType: NotificationType.message,
        deliverymanId: data['sender_type'] == 'delivery_man' ? 0 : null,
        adminId: data['sender_type'] == 'admin' ? 0 : null,
        restaurantId: data['sender_type'] == 'vendor' ? 0 : null,
        conversationId: int.parse(data['conversation_id'].toString()),
      );
    }
  }

}

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("onBackground: ${message.notification!.title}/${message.notification!.body}/${message.notification!.titleLocKey}");
  }
  // var androidInitialize = new AndroidInitializationSettings('notification_icon');
  // var iOSInitialize = new IOSInitializationSettings();
  // var initializationsSettings = new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // flutterLocalNotificationsPlugin.initialize(initializationsSettings);
  // NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, true);
}