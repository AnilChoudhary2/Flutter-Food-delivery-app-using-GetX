import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/helper/custom_validator.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/view/base/custom_button.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:sixam_mart/view/base/custom_text_field.dart';
import 'package:sixam_mart/view/base/menu_drawer.dart';
import 'package:sixam_mart/view/screens/auth/sign_up_screen.dart';
import 'package:sixam_mart/view/screens/auth/widget/condition_check_box.dart';
import 'package:sixam_mart/view/screens/auth/widget/guest_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/screens/auth/widget/social_login_widget.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  const SignInScreen({Key? key, required this.exitFromApp, required this.backFromThis}) : super(key: key);

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _countryDialCode;
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  void initState() {
    super.initState();

    _countryDialCode = Get.find<AuthController>().getUserCountryCode().isNotEmpty ? Get.find<AuthController>().getUserCountryCode()
        : CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
    _phoneController.text =  Get.find<AuthController>().getUserNumber();
    _passwordController.text = Get.find<AuthController>().getUserPassword();

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(widget.exitFromApp) {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            } else {
              Navigator.pushNamed(context, RouteHelper.getInitialRoute());
            }
            return Future.value(false);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('back_press_again_to_exit'.tr, style: const TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            ));
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
            return Future.value(false);
          }
        }else {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).cardColor,
        appBar: (ResponsiveHelper.isDesktop(context) ? null : !widget.exitFromApp ? AppBar(leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).textTheme.bodyLarge!.color),
        ), elevation: 0, backgroundColor: Colors.transparent,
        actions: const [SizedBox()],
        ) : null),
        endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
        body: SafeArea(child: Scrollbar(
          child: Center(
            child: Container(
              width: context.width > 700 ? 500 : context.width,
              padding: context.width > 700 ? const EdgeInsets.all(50) : const EdgeInsets.all(Dimensions.paddingSizeExtremeLarge),
              margin: context.width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : EdgeInsets.zero,
              decoration: context.width > 700 ? BoxDecoration(
                color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                boxShadow: ResponsiveHelper.isDesktop(context) ? null : [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, blurRadius: 5, spreadRadius: 1)],
              ) : null,
              child: GetBuilder<AuthController>(builder: (authController) {

                return Center(
                  child: SingleChildScrollView(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                      ResponsiveHelper.isDesktop(context) ? Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.clear),
                        ),
                      ) : const SizedBox(),

                      Image.asset(Images.new_logo),
                      // SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                      // Center(child: Text(AppConstants.APP_NAME, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge))),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      Align(
                        alignment: Alignment.topLeft,
                        child: Text('sign_in'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      CustomTextField(
                        titleText: ResponsiveHelper.isDesktop(context) ? 'phone'.tr : 'enter_phone_number'.tr,
                        hintText: ' ',
                        controller: _phoneController,
                        focusNode: _phoneFocus,
                        //nextFocus: _passwordFocus,
                        inputType: TextInputType.phone,
                        isPhone: true,
                        divider: false,
                        onCountryChanged: (CountryCode countryCode) {
                          _countryDialCode = countryCode.dialCode;
                        },
                        //countryDialCode: _countryDialCode ?? Get.find<LocalizationController>().locale.countryCode,
                        countryDialCode: '+91',
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      // CustomTextField(
                      //   titleText: ResponsiveHelper.isDesktop(context) ? 'password'.tr : 'enter_your_password'.tr,
                      //   hintText: 'enter_your_password'.tr,
                      //   controller: _passwordController,
                      //   focusNode: _passwordFocus,
                      //   inputAction: TextInputAction.done,
                      //   inputType: TextInputType.visiblePassword,
                      //   prefixIcon: Icons.lock,
                      //   isPassword: true,
                      //   showTitle: ResponsiveHelper.isDesktop(context),
                      //   onSubmit: (text) => (GetPlatform.isWeb) ? _login(authController, _countryDialCode!) : null,
                      // ),
                      // const SizedBox(height: Dimensions.paddingSizeDefault),

                      // Row(children: [
                      //   Expanded(
                      //     child: ListTile(
                      //       onTap: () => authController.toggleRememberMe(),
                      //       leading: Checkbox(
                      //         visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      //         activeColor: Theme.of(context).primaryColor,
                      //         value: authController.isActiveRememberMe,
                      //         onChanged: (bool? isChecked) => authController.toggleRememberMe(),
                      //       ),
                      //       title: Text('remember_me'.tr),
                      //       contentPadding: EdgeInsets.zero,
                      //       visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                      //       dense: true,
                      //       horizontalTitleGap: 0,
                      //     ),
                      //   ),
                      //   TextButton(
                      //     onPressed: () => Get.toNamed(RouteHelper.getForgotPassRoute(false, null)),
                      //     child: Text('${'forgot_password'.tr}?', style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
                      //   ),
                      // ]),
                      // const SizedBox(height: Dimensions.paddingSizeLarge),

                      ConditionCheckBox(authController: authController, fromSignUp: false),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      CustomButton(
                        buttonText: 'sign_in'.tr,
                        onPressed: () => _login(authController, _countryDialCode!),
                        isLoading: authController.isLoading,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                     /* Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('do_not_have_account'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),

                        InkWell(
                          onTap: () {
                            if(ResponsiveHelper.isDesktop(context)){
                              Get.back();
                              Get.dialog( SignUpScreen());
                            }else{
                             // Get.toNamed(RouteHelper.getSignUpRoute());
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            child: Text('sign_up'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                          ),
                        ),
                      ]),*/
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      //
                      // const SocialLoginWidget(),

                      const GuestButton(),

                    ]),
                  ),
                );
              }),
            ),
          ),
        )),
      ),
    );
  }

  void _login(AuthController authController, String countryDialCode) async {
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String numberWithCountryCode = countryDialCode+phone;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (phone.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    }else if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    }/*else if (password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    }else if (password.length < 6) {
      showCustomSnackBar('password_should_be'.tr);
    }*/else {
      authController.login(numberWithCountryCode, "Anil@9928", alreadyInApp: widget.backFromThis).then((status) async {
        if (status.isSuccess) {
          if (authController.isActiveRememberMe) {
            authController.saveUserNumberAndPassword(phone, password, countryDialCode);
          } else {
            authController.clearUserNumberAndPassword();
          }
          String token = status.message!.substring(1, status.message!.length);
       //   if(Get.find<SplashController>().configModel!.customerVerification! && int.parse(status.message![0]) == 0) {
            List<int> encoded = utf8.encode(password);
            String data = base64Encode(encoded);
            Get.toNamed(RouteHelper.getVerificationRoute(numberWithCountryCode, token, RouteHelper.signUp, data));
          // }else {
          //   if(widget.backFromThis) {
          //     Get.back();
          //   }else{
          //     Get.find<LocationController>().navigateToLocationScreen('sign-in', offNamed: true);
          //   }
          // }
        }else {
          showCustomSnackBar(status.message);
        }
      });
    }
  }
}
