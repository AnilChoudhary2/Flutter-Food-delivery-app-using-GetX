import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/order_controller.dart';
import 'package:sixam_mart/controller/rider_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_app_bar.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/base/not_logged_in_screen.dart';
import 'package:sixam_mart/view/screens/order/widget/order_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/screens/taxi_booking/trip_history/widget/trip_history_list.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({Key? key}) : super(key: key);

  @override
  TripHistoryScreenState createState() => TripHistoryScreenState();
}

class TripHistoryScreenState extends State<TripHistoryScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoggedIn = Get.find<AuthController>().isLoggedIn();

  @override
  void initState() {
    super.initState();

    initCall();
  }

  initCall(){
    if(_isLoggedIn) {
      _tabController = TabController(length: 3, initialIndex: 0, vsync: this);
      Get.find<RiderController>().getRunningTripList(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return Scaffold(
      appBar: CustomAppBar(title: 'trip_history'.tr),
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      body: _isLoggedIn ? GetBuilder<OrderController>(
        builder: (orderController) {
          return Column(children: [

            Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: TabBar(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  controller: _tabController,
                  indicatorColor: Theme.of(context).primaryColor,
                  indicatorWeight: 3,
                  indicatorPadding: const EdgeInsets.only(bottom: 10),
                  indicatorSize: TabBarIndicatorSize.label ,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Theme.of(context).textTheme.bodyLarge!.color,
                  unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeDefault),
                  labelStyle: robotoBold.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeDefault,
                  ),
                  tabs: [
                    Tab(text: 'ongoing'.tr),
                    Tab(text: 'past_trips'.tr),
                    Tab(text: 'canceled'.tr),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault,),
            Expanded(child: TabBarView(
              controller: _tabController,
              children: const [
                TripHistoryList(type: 'onGoing'),
                OrderView(isRunning: false),
                OrderView(isRunning: false),
              ],
            )),

          ]);
        },
      ) : NotLoggedInScreen(callBack: (value){
        initCall();
        setState(() {});
      }),
    );
  }
}
