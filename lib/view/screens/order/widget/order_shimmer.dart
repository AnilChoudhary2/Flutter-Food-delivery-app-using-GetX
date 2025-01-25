import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class OrderShimmer extends StatelessWidget {
  final OrderController orderController;
  const OrderShimmer({Key? key, required this.orderController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return Center(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: orderController.runningOrderModel == null,
              child: Column(children: [

                Row(children: [
                  Container(
                    height: 60, width: 60,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.grey[300]),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(height: 15, width: 100, color: Colors.grey[300]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Container(height: 15, width: 150, color: Colors.grey[300]),
                  ])),
                  Column(children: [
                    Container(
                      height: 20, width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        color: Colors.grey[300],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Container(
                      height: 20, width: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        color: Colors.grey[300],
                      ),
                    )
                  ]),
                ]),

                Divider(
                  color: Theme.of(context).disabledColor, height: Dimensions.paddingSizeLarge,
                ),

              ]),
            ),
          ),
        );
      },
    );
  }
}
