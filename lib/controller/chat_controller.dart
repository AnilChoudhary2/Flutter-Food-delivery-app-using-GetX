import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_compression_flutter/image_compression_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/data/api/api_checker.dart';
import 'package:sixam_mart/data/api/api_client.dart';
import 'package:sixam_mart/data/model/body/notification_body.dart';
import 'package:sixam_mart/data/model/response/conversation_model.dart';
import 'package:sixam_mart/data/model/response/chat_model.dart';
import 'package:sixam_mart/data/repository/chat_repo.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';

class ChatController extends GetxController implements GetxService {
  final ChatRepo chatRepo;
  ChatController({required this.chatRepo});

  List<bool>? _showDate;
  bool _isSendButtonActive = false;
  final bool _isSeen = false;
  final bool _isSend = true;
  bool _isMe = false;
  bool _isLoading= false;
  final List<Message>  _deliveryManMessage = [];
  final List<Message>  _adminManMessage = [];
  List <XFile>_chatImage = [];
  List <Uint8List>_chatRawImage = [];
  ChatModel?  _messageModel;
  ConversationsModel? _conversationModel;
  ConversationsModel? _searchConversationModel;
  bool _hasAdmin = true;

  bool get isLoading => _isLoading;
  List<bool>? get showDate => _showDate;
  bool get isSendButtonActive => _isSendButtonActive;
  bool get isSeen => _isSeen;
  bool get isSend => _isSend;
  bool get isMe => _isMe;
  List<Message> get deliveryManMessage => _deliveryManMessage;
  List<Message> get adminManMessages => _adminManMessage;
  List<XFile> get chatImage => _chatImage;
  List<Uint8List> get chatRawImage => _chatRawImage;
  ChatModel? get messageModel => _messageModel;
  ConversationsModel? get conversationModel => _conversationModel;
  ConversationsModel? get searchConversationModel => _searchConversationModel;
  bool get hasAdmin => _hasAdmin;

  Future<void> getConversationList(int offset) async {
    _hasAdmin = true;
    _searchConversationModel = null;
    Response response = await chatRepo.getConversationList(offset);
    if(response.statusCode == 200) {
      if(offset == 1) {
        _conversationModel = ConversationsModel.fromJson(response.body);
      }else {
        _conversationModel!.totalSize = ConversationsModel.fromJson(response.body).totalSize;
        _conversationModel!.offset = ConversationsModel.fromJson(response.body).offset;
        _conversationModel!.conversations!.addAll(ConversationsModel.fromJson(response.body).conversations!);
      }
      int index0 = -1;
      late bool sender;
      for(int index=0; index<_conversationModel!.conversations!.length; index++) {
        if(_conversationModel!.conversations![index]!.receiverType == AppConstants.admin) {
          index0 = index;
          sender = false;
          break;
        }else if(_conversationModel!.conversations![index]!.receiverType == AppConstants.admin) {
          index0 = index;
          sender = true;
          break;
        }
      }
      _hasAdmin = false;
      if(index0 != -1) {
        _hasAdmin = true;
        if(sender) {
          _conversationModel!.conversations![index0]!.sender = User(
            id: 0, fName: Get.find<SplashController>().configModel!.businessName, lName: '',
            phone: Get.find<SplashController>().configModel!.phone, email: Get.find<SplashController>().configModel!.email,
            image: Get.find<SplashController>().configModel!.logo,
          );
        }else {
          _conversationModel!.conversations![index0]!.receiver = User(
            id: 0, fName: Get.find<SplashController>().configModel!.businessName, lName: '',
            phone: Get.find<SplashController>().configModel!.phone, email: Get.find<SplashController>().configModel!.email,
            image: Get.find<SplashController>().configModel!.logo,
          );
        }
      }
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> searchConversation(String name) async {
    _searchConversationModel = ConversationsModel();
    update();
    Response response = await chatRepo.searchConversationList(name);
    if(response.statusCode == 200) {
      _searchConversationModel = ConversationsModel.fromJson(response.body);
      int index0 = -1;
      late bool sender;
      for(int index=0; index<_searchConversationModel!.conversations!.length; index++) {
        if(_searchConversationModel!.conversations![index]!.receiverType == AppConstants.admin) {
          index0 = index;
          sender = false;
          break;
        }else if(_searchConversationModel!.conversations![index]!.receiverType == AppConstants.admin) {
          index0 = index;
          sender = true;
          break;
        }
      }
      if(index0 != -1) {
        if(sender) {
          _searchConversationModel!.conversations![index0]!.sender = User(
            id: 0, fName: Get.find<SplashController>().configModel!.businessName, lName: '',
            phone: Get.find<SplashController>().configModel!.phone, email: Get.find<SplashController>().configModel!.email,
            image: Get.find<SplashController>().configModel!.logo,
          );
        }else {
          _searchConversationModel!.conversations![index0]!.receiver = User(
            id: 0, fName: Get.find<SplashController>().configModel!.businessName, lName: '',
            phone: Get.find<SplashController>().configModel!.phone, email: Get.find<SplashController>().configModel!.email,
            image: Get.find<SplashController>().configModel!.logo,
          );
        }
      }
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void removeSearchMode() {
    _searchConversationModel = null;
    update();
  }

  Future<void> getMessages(int offset, NotificationBody? notificationBody, User? user, int? conversationID, {bool firstLoad = false}) async {
    Response? response;
    if(firstLoad) {
      _messageModel = null;
      _isSendButtonActive = false;
      _isLoading = false;
    }
    if(notificationBody == null || notificationBody.adminId != null) {
      response = await chatRepo.getMessages(offset, 0, AppConstants.admin, null);
    } else if(notificationBody.restaurantId != null) {
      response = await chatRepo.getMessages(offset, notificationBody.restaurantId, AppConstants.vendor, conversationID);
    } else if(notificationBody.deliverymanId != null) {
      response = await chatRepo.getMessages(offset, notificationBody.deliverymanId, AppConstants.deliveryMan, conversationID);
    }

    if (response != null && response.body['messages'] != {} && response.statusCode == 200) {
      if (offset == 1) {

        /// Unread-read
        if(conversationID != null && _conversationModel != null) {
          int index0 = -1;
          for(int index=0; index<_conversationModel!.conversations!.length; index++) {
            if(conversationID == _conversationModel!.conversations![index]!.id) {
              index0 = index;
              break;
            }
          }
          if(index0 != -1) {
            _conversationModel!.conversations![index0]!.unreadMessageCount = 0;
          }
        }

        if(Get.find<UserController>().userInfoModel == null) {
          await Get.find<UserController>().getUserInfo();
        }
        /// Manage Receiver
        _messageModel = ChatModel.fromJson(response.body);
        if(_messageModel!.conversation == null) {
          _messageModel!.conversation = Conversation(sender: User(
            id: Get.find<UserController>().userInfoModel!.id, image: Get.find<UserController>().userInfoModel!.image,
            fName: Get.find<UserController>().userInfoModel!.fName, lName: Get.find<UserController>().userInfoModel!.lName,
          ), receiver: notificationBody!.adminId != null ? User(
            id: 0, fName: Get.find<SplashController>().configModel!.businessName, lName: '',
            image: Get.find<SplashController>().configModel!.logo,
          ) : user);
        }
        _sortMessage(notificationBody!.adminId);
      }else {
        _messageModel!.totalSize = ChatModel.fromJson(response.body).totalSize;
        _messageModel!.offset = ChatModel.fromJson(response.body).offset;
        _messageModel!.messages!.addAll(ChatModel.fromJson(response.body).messages!);
      }
    } else {
      ApiChecker.checkApi(response!);
    }
    update();
  }


  void pickImage(bool isRemove) async {
    if(isRemove) {
      _chatImage = [];
      _chatRawImage = [];
    }else {
      List<XFile> imageFiles = await ImagePicker().pickMultiImage(imageQuality: 40);
      for(XFile xFile in imageFiles) {
        if(_chatImage.length >= 3) {
          showCustomSnackBar('can_not_add_more_than_3_image'.tr);
          break;
        }else {
          XFile file = await compressImage(xFile);
          _chatImage.add(file);
          _chatRawImage.add(await file.readAsBytes());
        }
      }
      _isSendButtonActive = true;
    }
    update();
  }

  void removeImage(int index, String messageText){
    _chatImage.removeAt(index);
    _chatRawImage.removeAt(index);
    if(_chatImage.isEmpty && messageText.isEmpty) {
      _isSendButtonActive = false;
    }
    update();
  }

  Future<Response?> sendMessage({required String message, required NotificationBody? notificationBody,
    required int? conversationID, required int? index}) async {
    Response? response;
    _isLoading = true;
    update();

    List<MultipartBody> myImages = [];
    for (var image in _chatImage) {
      myImages.add(MultipartBody('image[]', image));
    }

    if(notificationBody == null || notificationBody.adminId != null) {
      response = await chatRepo.sendMessage(message, myImages, 0, AppConstants.admin, null);
    } else if(notificationBody.restaurantId != null) {
      response = await chatRepo.sendMessage(message, myImages, notificationBody.restaurantId, AppConstants.vendor, conversationID);
    } else if(notificationBody.deliverymanId != null) {
      response = await chatRepo.sendMessage(message, myImages, notificationBody.deliverymanId, AppConstants.deliveryMan, conversationID);
    }
    if (response!.statusCode == 200) {
      _chatImage = [];
      _chatRawImage = [];
      _isSendButtonActive = false;
      _isLoading = false;
      _messageModel = ChatModel.fromJson(response.body);
      if(index != null && _searchConversationModel != null) {
        _searchConversationModel!.conversations![index]!.lastMessageTime = DateConverter.isoStringToLocalString(_messageModel!.messages![0].createdAt!);
      }else if(index != null && _conversationModel != null) {
        _conversationModel!.conversations![index]!.lastMessageTime = DateConverter.isoStringToLocalString(_messageModel!.messages![0].createdAt!);
      }
      if(_conversationModel != null && !_hasAdmin && (_messageModel!.conversation!.senderType == AppConstants.admin || _messageModel!.conversation!.receiverType == AppConstants.admin)) {
        _conversationModel!.conversations!.add(_messageModel!.conversation);
        _hasAdmin = true;
      }
      if(Get.find<UserController>().userInfoModel!.userInfo == null) {
        Get.find<UserController>().updateUserWithNewData(_messageModel!.conversation!.sender);
      }
      _sortMessage(notificationBody!.adminId);
      Future.delayed(const Duration(seconds: 2),() {
        getMessages(1, notificationBody, null, conversationID);
      });
    }
    update();
    return response;
  }

  void _sortMessage(int? adminId) {
    if(_messageModel!.conversation != null && (_messageModel!.conversation!.receiverType == AppConstants.user
        || _messageModel!.conversation!.receiverType == AppConstants.customer)) {
      User? receiver = _messageModel!.conversation!.receiver;
      _messageModel!.conversation!.receiver = _messageModel!.conversation!.sender;
      _messageModel!.conversation!.sender = receiver;
    }
    if(adminId != null) {
      _messageModel!.conversation!.receiver = User(
        id: 0, fName: Get.find<SplashController>().configModel!.businessName, lName: '',
        image: Get.find<SplashController>().configModel!.logo,
      );
    }
  }

  void toggleSendButtonActivity() {
    _isSendButtonActive = !_isSendButtonActive;
    update();
  }

  void setIsMe(bool value) {
    _isMe = value;
  }

  void reloadConversationWithNotification(int conversationID) {
    int index0 = -1;
    Conversation? conversation;
    for(int index=0; index<_conversationModel!.conversations!.length; index++) {
      if(_conversationModel!.conversations![index]!.id == conversationID) {
        index0 = index;
        conversation = _conversationModel!.conversations![index];
        break;
      }
    }
    if(index0 != -1) {
      _conversationModel!.conversations!.removeAt(index0);
    }
    conversation!.unreadMessageCount = conversation.unreadMessageCount! + 1;
    _conversationModel!.conversations!.insert(0, conversation);
    update();
  }

  void reloadMessageWithNotification(Message message) {
    _messageModel!.messages!.insert(0, message);
    update();
  }

  Future<XFile> compressImage(XFile file) async {
    final ImageFile input = ImageFile(filePath: file.path, rawBytes: await file.readAsBytes());
    final Configuration config = Configuration(
      outputType: ImageOutputType.webpThenPng,
      useJpgPngNativeCompressor: false,
      quality: (input.sizeInBytes/1048576) < 2 ? 50 : (input.sizeInBytes/1048576) < 5
          ? 30 : (input.sizeInBytes/1048576) < 10 ? 2 : 1,
    );
    final ImageFile output = await compressor.compress(ImageFileConfiguration(input: input, config: config));
    if(kDebugMode) {
      print('Input size : ${input.sizeInBytes / 1048576}');
      print('Output size : ${output.sizeInBytes / 1048576}');
    }
    return XFile.fromData(output.rawBytes);
  }

}