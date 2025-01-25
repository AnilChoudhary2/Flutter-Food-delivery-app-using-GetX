import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/data/model/body/review_body.dart';
import 'package:sixam_mart/data/model/response/order_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/footer_view.dart';
import 'package:sixam_mart/view/base/my_text_field.dart';
import 'package:sixam_mart/view/screens/review/widget/delivery_man_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryManReviewWidget extends StatefulWidget {
  final DeliveryMan? deliveryMan;
  final String orderID;
  const DeliveryManReviewWidget({Key? key, required this.deliveryMan, required this.orderID}) : super(key: key);

  @override
  State<DeliveryManReviewWidget> createState() => _DeliveryManReviewWidgetState();
}

class _DeliveryManReviewWidgetState extends State<DeliveryManReviewWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      return Scrollbar(child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        physics: const BouncingScrollPhysics(),
        child: FooterView(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          widget.deliveryMan != null ? DeliveryManWidget(deliveryMan: widget.deliveryMan) : const SizedBox(),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: [BoxShadow(
                color: Colors.grey[Get.isDarkMode ? 700 : 300]!,
                blurRadius: 5, spreadRadius: 1,
              )],
            ),
            child: Column(children: [
              Text(
                'rate_his_service'.tr,
                style: robotoMedium.copyWith(color: Theme.of(context).disabledColor), overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              SizedBox(
                height: 30,
                child: ListView.builder(
                  itemCount: 5,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    return InkWell(
                      child: Icon(
                        itemController.deliveryManRating < (i + 1) ? Icons.star_border : Icons.star,
                        size: 25,
                        color: itemController.deliveryManRating < (i + 1) ? Theme.of(context).disabledColor
                            : Theme.of(context).primaryColor,
                      ),
                      onTap: () {
                        itemController.setDeliveryManRating(i + 1);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text(
                'share_your_opinion'.tr,
                style: robotoMedium.copyWith(color: Theme.of(context).disabledColor), overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              MyTextField(
                maxLines: 5,
                capitalization: TextCapitalization.sentences,
                controller: _controller,
                hintText: 'write_your_review_here'.tr,
                fillColor: Theme.of(context).disabledColor.withOpacity(0.05),
              ),
              const SizedBox(height: 40),

              // Submit button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                child: Column(
                  children: [
                    !itemController.isLoading ? CustomButton(
                      buttonText: 'submit'.tr,
                      onPressed: () {
                        if (itemController.deliveryManRating == 0) {
                          showCustomSnackBar('give_a_rating'.tr);
                        } else if (_controller.text.isEmpty) {
                          showCustomSnackBar('write_a_review'.tr);
                        } else {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          ReviewBody reviewBody = ReviewBody(
                            deliveryManId: widget.deliveryMan!.id.toString(),
                            rating: itemController.deliveryManRating.toString(),
                            comment: _controller.text,
                            orderId: widget.orderID,
                          );
                          itemController.submitDeliveryManReview(reviewBody).then((value) {
                            if (value.isSuccess) {
                              showCustomSnackBar(value.message, isError: false);
                              _controller.text = '';
                            } else {
                              showCustomSnackBar(value.message);
                            }
                          });
                        }
                      },
                    ) : const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ]),
          ),

        ]))),
      ));
    });
  }
}
