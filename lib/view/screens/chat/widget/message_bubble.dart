import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/data/model/response/config_model.dart';
import 'package:sixam_mart/data/model/response/conversation_model.dart';
import 'package:sixam_mart/data/model/response/chat_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_image.dart';
import 'package:sixam_mart/view/screens/chat/widget/image_dialog.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final User? user;
  final String userType;
  const MessageBubble({Key? key, required this.message, required this.user, required this.userType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BaseUrls? baseUrl = Get.find<SplashController>().configModel!.baseUrls;
    bool isReply = message.senderId != Get.find<UserController>().userInfoModel!.userInfo!.id;

    return (isReply) ? Container(
      margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Text('${user!.fName} ${user!.lName}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: CustomImage(
              fit: BoxFit.cover, width: 40, height: 40,
              image: '${userType == AppConstants.admin ? baseUrl!.businessLogoUrl : userType == AppConstants.vendor
                  ? baseUrl!.storeImageUrl : baseUrl!.deliveryManImageUrl}/${user != null ? user!.image : ''}',
            ),
          ),
          const SizedBox(width: 10),

          Flexible(
            child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

              if(message.message != null) Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(Dimensions.radiusDefault),
                      topRight: Radius.circular(Dimensions.radiusDefault),
                      bottomLeft: Radius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                  padding: EdgeInsets.all(message.message != null ? Dimensions.paddingSizeDefault : 0),
                  child: Text(message.message ?? ''),
                ),
              ),
              const SizedBox(height: 8.0),

              (message.files != null && message.files!.isNotEmpty) ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1,
                    crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 5,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: message.files!.length,
                  itemBuilder: (BuildContext context, index) {
                    return  message.files!.isNotEmpty ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        onTap: () => showDialog(context: context, builder: (context) {
                          return ImageDialog(imageUrl: '${baseUrl.chatImageUrl}/${message.files![index]}');
                        }),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                          child: CustomImage(
                            height: 100, width: 100, fit: BoxFit.cover,
                            image: '${baseUrl.chatImageUrl}/${message.files![index]}',
                          ),
                        ),
                      ),
                    ) : const SizedBox();

                  }) : const SizedBox(),

            ]),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Text(
          DateConverter.localDateToIsoStringAMPM(DateTime.parse(message.createdAt!)),
          style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
        ),
      ]),
    ) : Container(
      padding: const EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeDefault),
      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
      child: GetBuilder<UserController>(builder: (profileController) {

        return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [

          Text(
            '${profileController.userInfoModel != null ? profileController.userInfoModel!.fName ?? '' : ''} '
                '${profileController.userInfoModel != null ? profileController.userInfoModel!.lName ?? '' : ''}',
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [

            Flexible(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [

                (message.message != null && message.message!.isNotEmpty) ? Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(Dimensions.radiusDefault),
                        bottomRight: Radius.circular(Dimensions.radiusDefault),
                        bottomLeft: Radius.circular(Dimensions.radiusDefault),
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(message.message != null ? Dimensions.paddingSizeDefault : 0),
                      child: Text(message.message ?? ''),
                    ),
                  ),
                ) : const SizedBox(),

                (message.files != null && message.files!.isNotEmpty) ? Directionality(
                  textDirection: TextDirection.rtl,
                  child: GridView.builder(
                      reverse: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 1,
                        crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 5,
                      ),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: message.files!.length,
                      itemBuilder: (BuildContext context, index){
                        return  message.files!.isNotEmpty ?
                        InkWell(
                          onTap: () => showDialog(context: context, builder: (context) {
                            return ImageDialog(imageUrl: '${baseUrl!.chatImageUrl}/${message.files![index]}');
                          }),
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: Dimensions.paddingSizeSmall , right:  0,
                                top: (message.message != null && message.message!.isNotEmpty) ? Dimensions.paddingSizeSmall : 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: CustomImage(
                                height: 100, width: 100, fit: BoxFit.cover,
                                image: '${baseUrl!.chatImageUrl}/${message.files![index]}',
                              ),
                            ),
                          ),
                        ) : const SizedBox();
                      }),
                ) : const SizedBox(),
              ]),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: CustomImage(
                fit: BoxFit.cover, width: 40, height: 40,
                image: profileController.userInfoModel != null ? '${baseUrl!.customerImageUrl}/${profileController.userInfoModel!.image}' : '',
              ),
            ),
          ]),

          Icon(
            message.isSeen == 1 ? Icons.done_all : Icons.check,
            size: 12,
            color: message.isSeen == 1 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(
            DateConverter.localDateToIsoStringAMPM(DateTime.parse(message.createdAt!)),
            style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

        ]);
      }),
    );
  }
}
