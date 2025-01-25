import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:sixam_mart/controller/auth_controller.dart';
import 'package:sixam_mart/controller/localization_controller.dart';
import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/body/signup_body.dart';
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
import 'package:sixam_mart/view/screens/auth/sign_in_screen.dart';
import 'package:sixam_mart/view/screens/auth/widget/condition_check_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/view/screens/auth/widget/pass_view.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../base/footer_view.dart';
import '../../base/web_menu_bar.dart';

/*  class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _referCodeFocus = FocusNode();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _referCodeController = TextEditingController();
  String? _countryDialCode;

  @override
  void initState() {
    super.initState();

    _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
    if(Get.find<AuthController>().showPassView){
      Get.find<AuthController>().showHidePass(isUpdate: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).cardColor,
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      body: SafeArea(child: Scrollbar(
        child: Center(
          child: Container(
            width: context.width > 700 ? 700 : context.width,
            padding: context.width > 700 ? const EdgeInsets.all(40) : const EdgeInsets.all(Dimensions.paddingSizeLarge),
            margin: context.width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : null,
            decoration: context.width > 700 ? BoxDecoration(
              color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              // boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, blurRadius: 5, spreadRadius: 1)],
            ) : null,
            child: GetBuilder<AuthController>(builder: (authController) {

              return SingleChildScrollView(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                  ResponsiveHelper.isDesktop(context) ? Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.clear),
                    ),
                  ) : const SizedBox(),

                  Image.asset(Images.logo, width: 125),
                  // SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                  // Center(child: Text(AppConstants.APP_NAME, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge))),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  Align(
                    alignment: Alignment.topLeft,
                    child: Text('sign_up'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Row(children: [
                    Expanded(
                      child: CustomTextField(
                        titleText: 'first_name'.tr,
                        hintText: 'ex_jhon'.tr,
                        controller: _firstNameController,
                        focusNode: _firstNameFocus,
                        nextFocus: _lastNameFocus,
                        inputType: TextInputType.name,
                        capitalization: TextCapitalization.words,
                        prefixIcon: Icons.person,
                        showTitle: ResponsiveHelper.isDesktop(context),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(
                      child: CustomTextField(
                        titleText: 'last_name'.tr,
                        hintText: 'ex_doe'.tr,
                        controller: _lastNameController,
                        focusNode: _lastNameFocus,
                        nextFocus: _phoneFocus,
                        inputType: TextInputType.name,
                        capitalization: TextCapitalization.words,
                        prefixIcon: Icons.person,
                        showTitle: ResponsiveHelper.isDesktop(context),
                      ),
                    )
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Row(children: [
                    ResponsiveHelper.isDesktop(context) ? Expanded(
                      child: CustomTextField(
                        titleText: 'email'.tr,
                        hintText: 'enter_email'.tr,
                        controller: _emailController,
                        focusNode: _emailFocus,
                        nextFocus: _passwordFocus,
                        inputType: TextInputType.emailAddress,
                        prefixImage: Images.mail,
                        showTitle: ResponsiveHelper.isDesktop(context),
                      ),
                    ) : const SizedBox(),
                    SizedBox(width: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),

                    Expanded(
                      child: CustomTextField(
                        titleText: ResponsiveHelper.isDesktop(context) ? 'phone'.tr : 'enter_phone_number'.tr,
                        controller: _phoneController,
                        focusNode: _phoneFocus,
                        nextFocus: _emailFocus,
                        inputType: TextInputType.phone,
                        isPhone: true,
                        showTitle: ResponsiveHelper.isDesktop(context),
                        onCountryChanged: (CountryCode countryCode) {
                          _countryDialCode = countryCode.dialCode;
                        },
                        countryDialCode: _countryDialCode != null ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code
                            : Get.find<LocalizationController>().locale.countryCode,
                      ),
                    ),

                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  !ResponsiveHelper.isDesktop(context) ? CustomTextField(
                    titleText: 'email'.tr,
                    hintText: 'enter_email'.tr,
                    controller: _emailController,
                    focusNode: _emailFocus,
                    nextFocus: _passwordFocus,
                    inputType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail,
                  ) : const SizedBox(),
                  SizedBox(height: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),

                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Expanded(
                      child: Column(children: [
                        CustomTextField(
                          titleText: 'password'.tr,
                          hintText: '8_character'.tr,
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          nextFocus: _confirmPasswordFocus,
                          inputType: TextInputType.visiblePassword,
                          prefixIcon: Icons.lock,
                          isPassword: true,
                          showTitle: ResponsiveHelper.isDesktop(context),
                          onChanged: (value){
                            if(value != null && value.isNotEmpty){
                              if(!authController.showPassView){
                                authController.showHidePass();
                              }
                              authController.validPassCheck(value);
                            }else{
                              if(authController.showPassView){
                                authController.showHidePass();
                              }
                            }
                          },
                        ),

                        authController.showPassView ? const PassView() : const SizedBox(),
                      ]),
                    ),
                    SizedBox(width: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),

                    ResponsiveHelper.isDesktop(context) ? Expanded(child: CustomTextField(
                      titleText: 'confirm_password'.tr,
                      hintText: '8_character'.tr,
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocus,
                      nextFocus: Get.find<SplashController>().configModel!.refEarningStatus == 1 ? _referCodeFocus : null,
                      inputAction: Get.find<SplashController>().configModel!.refEarningStatus == 1 ? TextInputAction.next : TextInputAction.done,
                      inputType: TextInputType.visiblePassword,
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      showTitle: ResponsiveHelper.isDesktop(context),
                      onSubmit: (text) => (GetPlatform.isWeb) ? _register(authController, _countryDialCode!) : null,
                    )) : const SizedBox()

                  ]),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  !ResponsiveHelper.isDesktop(context) ? CustomTextField(
                    titleText: 'confirm_password'.tr,
                    hintText: '8_character'.tr,
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    nextFocus: Get.find<SplashController>().configModel!.refEarningStatus == 1 ? _referCodeFocus : null,
                    inputAction: Get.find<SplashController>().configModel!.refEarningStatus == 1 ? TextInputAction.next : TextInputAction.done,
                    inputType: TextInputType.visiblePassword,
                    prefixIcon: Icons.lock,
                    isPassword: true,
                    onSubmit: (text) => (GetPlatform.isWeb) ? _register(authController, _countryDialCode!) : null,
                  ) : const SizedBox(),
                  SizedBox(height: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),

                  (Get.find<SplashController>().configModel!.refEarningStatus == 1 ) ? CustomTextField(
                    titleText: 'refer_code'.tr,
                    hintText: 'enter_refer_code'.tr,
                    controller: _referCodeController,
                    focusNode: _referCodeFocus,
                    inputAction: TextInputAction.done,
                    inputType: TextInputType.text,
                    capitalization: TextCapitalization.words,
                    prefixImage: Images.referCode,
                    prefixSize: 14,
                    showTitle: ResponsiveHelper.isDesktop(context),
                  ) : const SizedBox(),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  ConditionCheckBox(authController: authController, fromSignUp: true),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  CustomButton(
                    buttonText: 'sign_up'.tr,
                    isLoading: authController.isLoading,
                    onPressed: authController.acceptTerms ? () => _register(authController, _countryDialCode!) : null,
                  ),

                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('already_have_account'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),

                    InkWell(
                      onTap: () {
                        if(ResponsiveHelper.isDesktop(context)){
                          Get.back();
                          Get.dialog(const SignInScreen(exitFromApp: false, backFromThis: false));
                        }else{
                          Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.signUp));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                        child: Text('sign_in'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                      ),
                    ),
                  ]),

                ]),
              );
            }),
          ),
        ),
      )),
    );
  }

 void _register(AuthController authController, String countryCode) async {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String number = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String referCode = _referCodeController.text.trim();

    String numberWithCountryCode = countryCode+number;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (firstName.isEmpty) {
      showCustomSnackBar('enter_your_first_name'.tr);
    }else if (lastName.isEmpty) {
      showCustomSnackBar('enter_your_last_name'.tr);
    }else if (email.isEmpty) {
      showCustomSnackBar('enter_email_address'.tr);
    }else if (!GetUtils.isEmail(email)) {
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    }else if (number.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    }else if (!phoneValid.isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    }else if (password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    }else if (password.length < 6) {
      showCustomSnackBar('password_should_be'.tr);
    }else if (password != confirmPassword) {
      showCustomSnackBar('confirm_password_does_not_matched'.tr);
    }else {
      SignUpBody signUpBody = SignUpBody(
        fName: firstName, lName: lastName, email: email, phone: numberWithCountryCode,
        password: password, refCode: referCode,
      );
      authController.registration(signUpBody).then((status) async {
        if (status.isSuccess) {
          if(Get.find<SplashController>().configModel!.customerVerification!) {
            List<int> encoded = utf8.encode(password);
            String data = base64Encode(encoded);
            Get.toNamed(RouteHelper.getVerificationRoute(numberWithCountryCode, status.message, RouteHelper.signUp, data));
          }else {
            Get.find<LocationController>().navigateToLocationScreen(RouteHelper.signUp);
          }
        }else {
          showCustomSnackBar(status.message);
        }
      });
    }
  }*/

class SignUpScreen extends StatefulWidget {
  String? otp;
  String? phone;

  SignUpScreen({this.otp, this.phone});
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _referCodeFocus = FocusNode();
  bool showContent = false;
  int toggleIndex = 1;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _referCodeController = TextEditingController();
  String? _countryDialCode;

  @override
  void initState() {
    super.initState();

    _countryDialCode = CountryCode.fromCountryCode(
        Get.find<SplashController>().configModel!.country!)
        .dialCode;
    //
    // widget.phone = widget.phone!.startsWith('+')
    //     ? widget.phone : '+' + widget.phone!.substring(1, widget.phone?.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? WebMenuBar() : null,
      endDrawer: MenuDrawer(),
      body: SafeArea(
          child: Scrollbar(
            child: SingleChildScrollView(
              padding: ResponsiveHelper.isDesktop(context)
                  ? EdgeInsets.zero
                  : EdgeInsets.all(Dimensions.paddingSizeSmall),
              physics: BouncingScrollPhysics(),
              child: FooterView(
                child: Center(
                  child: Container(
                    width: context.width > 700 ? 700 : context.width,
                    padding: context.width > 700
                        ? EdgeInsets.all(Dimensions.paddingSizeDefault)
                        : null,
                    margin: context.width > 700
                        ? EdgeInsets.all(Dimensions.paddingSizeDefault)
                        : null,
                    decoration: context.width > 700
                        ? BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                      BorderRadius.circular(Dimensions.radiusSmall),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[Get.isDarkMode ? 700 : 300]!,
                            blurRadius: 5,
                            spreadRadius: 1)
                      ],
                    )
                        : null,
                    child: GetBuilder<AuthController>(builder: (authController) {
                      return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(children: [
                            SizedBox(height: 50),
                            Text(
                              'Registration'.tr,
                              style: robotoRegular.copyWith(
                                  fontSize: 20,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 50),
                            (Get.find<SplashController>()
                                .configModel!
                                .refEarningStatus! ==
                                1)
                                ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    Text(
                                      "Do you have a ",
                                      style: robotoRegular.copyWith(
                                          color: Colors.grey),
                                    ),
                                    Text("Referal Code : ",
                                        style: robotoMedium),
                                    ToggleSwitch(
                                      minWidth: 50.0,
                                      minHeight: 30.0,
                                      initialLabelIndex: toggleIndex,
                                      //activeBgColor: Color.pinkAccent,
                                      activeFgColor: Colors.white,
                                      inactiveBgColor: Colors.grey,
                                      inactiveFgColor: Colors.white,
                                      labels: ['Yes', 'No'],
                                      onToggle: (index) {
                                        setState(() {
                                          toggleIndex = index!;
                                          showContent = index == 0 ? true : false;
                                        });
                                      },
                                    ).paddingOnly(left: 10),
                                  ],
                                ))
                                : SizedBox(),
                            (Get.find<SplashController>()
                                .configModel!
                                .refEarningStatus ==
                                1)
                                ? Visibility(
                              child: CustomTextField(
                                hintText: 'refer_code'.tr,
                                controller: _referCodeController,
                                focusNode: _referCodeFocus,
                                inputAction: TextInputAction.done,
                                inputType: TextInputType.text,
                                capitalization: TextCapitalization.words,
                                prefixImage: Images.referCode,
                                divider: false,
                                prefixSize: 14,
                                //radius: BorderRadius.circular(20),
                              ),
                              visible: showContent,
                            )
                                : SizedBox(),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              child: Text(
                                "Please enter your personal information",
                                style: robotoRegular.copyWith(color: Colors.grey),
                              ),
                              width: double.infinity,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(children: [
                                CustomTextField(
                                  titleText: 'first_name'.tr,
                                  controller: _firstNameController,
                                  focusNode: _firstNameFocus,
                                  nextFocus: _lastNameFocus,
                                  inputType: TextInputType.name,
                                  capitalization: TextCapitalization.words,
                                  prefixImage: Images.user,
                                  divider: true,
                               //  radius: BorderRadius.circular(20),
                                ),
                                SizedBox(height: 14),
                                CustomTextField(
                                  titleText: 'last_name'.tr,
                                  controller: _lastNameController,
                                  focusNode: _lastNameFocus,
                                  nextFocus: _emailFocus,
                                  inputType: TextInputType.name,
                                  capitalization: TextCapitalization.words,
                                  prefixImage: Images.user,
                                  divider: true,
                                //  radius: BorderRadius.circular(20),
                                ),
                                SizedBox(height: 14),

                                CustomTextField(
                                  titleText: 'email'.tr,
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  inputType: TextInputType.emailAddress,
                                  prefixImage: Images.mail,
                                  divider: false,
                                ),
                              ]),
                            ),
                            SizedBox(height: Dimensions.paddingSizeLarge),

                            InkWell(
                                onTap: () {
                                  //Get.toNamed(RouteHelper.getSignUpRoute());
                                  _register(authController, "");
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      vertical: authController.isLoading ? 5 : 15),
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Color(0xffeb6277),
                                            Color(0xffee984f)
                                          ])),
                                  child: Center(
                                      child: authController.isLoading
                                          ? CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                          : Text(
                                        "CONFIRM",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )),
                                )),
                            // SizedBox(height: 20),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     Text("By Signing up you agree to our ,"),
                            //     InkWell(
                            //       child: Text(
                            //         "Terms of Use",
                            //         style: TextStyle(
                            //             decoration: TextDecoration.underline),
                            //       ),
                            //       onTap: () {
                            //         Get.toNamed(RouteHelper.getHtmlRoute(
                            //             'terms-and-condition'));
                            //       },
                            //     )
                            //   ],
                            // ),
                            SizedBox(height: 20),
                          ]));
                    }),
                  ),
                ),
              ),
            ),
          )),
    );
  }

  void _register(AuthController authController, String countryCode) async {
    String _firstName = _firstNameController.text.trim();
    String _lastName = _lastNameController.text.trim();
    String _email = _emailController.text.trim();
    String _referCode = _referCodeController.text.trim();
    print(widget.phone);
    print("+{widget.phone}");
    print("+${widget.phone}".replaceAll(' ', ''));
    if (_firstName.isEmpty) {
      showCustomSnackBar('enter_your_first_name'.tr);
    } else if (_lastName.isEmpty) {
      showCustomSnackBar('enter_your_last_name'.tr);
    } else if (_email.isEmpty) {
      showCustomSnackBar('enter_email_address'.tr);
    } else if (!GetUtils.isEmail(_email)) {
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    } else if (_referCode.isNotEmpty && _referCode.length != 10) {
      showCustomSnackBar('invalid_refer_code'.tr);
    } else {
      SignUpBody signUpBody = SignUpBody(
        fName: _firstName,
        lName: _lastName,
        email: _email,
        refCode: _referCode,
        phone: "+${widget.phone}".replaceAll(' ', ''),//6078
       otp: widget.otp,
      );
      authController.registration(signUpBody).then((status) async {
        if (status.isSuccess) {
         // Get.toNamed(RouteHelper.getAccessLocationRoute(RouteHelper.signUp));
          // save token
          Get.offNamed(RouteHelper
              .getAccessLocationRoute(
              'successfull'));
        } else {
          print(status);
          print(status.message.toString());
          showCustomSnackBar(status.message);
        }
      });
    }
  }
}

