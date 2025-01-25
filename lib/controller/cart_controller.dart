import 'package:sixam_mart/controller/item_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/model/response/cart_model.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/module_model.dart';
import 'package:sixam_mart/data/repository/cart_repo.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';

class CartController extends GetxController implements GetxService {
  final CartRepo cartRepo;
  CartController({required this.cartRepo});

  List<CartModel> _cartList = [];

  double _subTotal = 0;
  double _itemPrice = 0;
  double _itemDiscountPrice = 0;
  double _addOns = 0;
  List<List<AddOns>> _addOnsList = [];
  List<bool> _availableList = [];
  List<String> notAvailableList = ['Remove it from my cart', 'I’ll wait until it’s restocked', 'Please cancel the order', 'Call me ASAP', 'Notify me when it’s back'];
  bool _addCutlery = false;
  int _notAvailableIndex = -1;

  List<CartModel> get cartList => _cartList;
  double get subTotal => _subTotal;
  double get itemPrice => _itemPrice;
  double get itemDiscountPrice => _itemDiscountPrice;
  double get addOns => _addOns;
  List<List<AddOns>> get addOnsList => _addOnsList;
  List<bool> get availableList => _availableList;
  bool get addCutlery => _addCutlery;
  int get notAvailableIndex => _notAvailableIndex;


  void setAvailableIndex(int index, {bool isUpdate = true}){
    if(_notAvailableIndex == index){
      _notAvailableIndex = -1;
    }else {
      _notAvailableIndex = index;
    }
    if(isUpdate) {
      update();
    }
  }

  void updateCutlery({bool isUpdate = true}){
    _addCutlery = !_addCutlery;
    if(isUpdate) {
      update();
    }
  }

  void forcefullySetModule(int moduleId){
    if(Get.find<SplashController>().module == null){
      if(Get.find<SplashController>().moduleList != null) {
        for(ModuleModel module in Get.find<SplashController>().moduleList!) {
          if(module.id == moduleId) {
            Get.find<SplashController>().setModule(module);
            break;
          }
        }
      }
    }
  }

  double calculationCart() {
    _addOnsList = [];
    _availableList = [];
    _itemPrice = 0;
    _itemDiscountPrice = 0;
    _addOns = 0;
    for (var cartModel in cartList) {

      List<AddOns> addOnList = [];
      for (var addOnId in cartModel.addOnIds!) {
        for(AddOns addOns in cartModel.item!.addOns!) {
          if(addOns.id == addOnId.id) {
            addOnList.add(addOns);
            break;
          }
        }
      }
      _addOnsList.add(addOnList);

      _availableList.add(DateConverter.isAvailable(cartModel.item!.availableTimeStarts, cartModel.item!.availableTimeEnds));

      for(int index=0; index<addOnList.length; index++) {
        _addOns = _addOns + (addOnList[index].price! * cartModel.addOnIds![index].quantity!);
      }
      _itemPrice = _itemPrice + (cartModel.price! * cartModel.quantity!);
      _itemDiscountPrice = _itemDiscountPrice + ((cartModel.price! - cartModel.discountedPrice!) * cartModel.quantity!);
    }
    _subTotal = (_itemPrice - _itemDiscountPrice) + _addOns;

    return _subTotal;
  }

  void getCartData() {
    _cartList = [];
    _cartList.addAll(cartRepo.getCartList());
    calculationCart();
  }

  void addToCart(CartModel cartModel, int? index) {
    if(index != null && index != -1) {
      _cartList.replaceRange(index, index+1, [cartModel]);
    }else {
      _cartList.add(cartModel);
    }
    Get.find<ItemController>().setExistInCart(cartModel.item, notify: true);
    cartRepo.addToCartList(_cartList);

    calculationCart();
    update();
  }

  void setQuantity(bool isIncrement, int cartIndex, int? stock) {
    if (isIncrement) {
      if(Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! && cartList[cartIndex].quantity! >= stock!) {
        showCustomSnackBar('out_of_stock'.tr);
      }else {
        _cartList[cartIndex].quantity = _cartList[cartIndex].quantity! + 1;
      }
    } else {
      _cartList[cartIndex].quantity = _cartList[cartIndex].quantity! - 1;
    }
    cartRepo.addToCartList(_cartList);

    calculationCart();

    update();
  }

  void removeFromCart(int index) {
    _cartList.removeAt(index);
    cartRepo.addToCartList(_cartList);
    if(Get.find<ItemController>().item != null) {
      Get.find<ItemController>().setExistInCart(Get.find<ItemController>().item, notify: true);
    }
    calculationCart();
    update();
  }

  void removeAddOn(int index, int addOnIndex) {
    _cartList[index].addOnIds!.removeAt(addOnIndex);
    cartRepo.addToCartList(_cartList);
    calculationCart();
    update();
  }

  void clearCartList() {
    _cartList = [];
    cartRepo.addToCartList(_cartList);
    calculationCart();
    update();
  }

  int isExistInCart(int? itemID, String variationType, bool isUpdate, int? cartIndex) {
    for(int index=0; index<_cartList.length; index++) {
      if(_cartList[index].item!.id == itemID && (_cartList[index].variation!.isNotEmpty ? _cartList[index].variation![0].type
          == variationType : true)) {
        if((isUpdate && index == cartIndex)) {
          return -1;
        }else {
          return index;
        }
      }
    }
    return -1;
  }

  bool existAnotherStoreItem(int? storeID, int? moduleId) {
    for(CartModel cartModel in _cartList) {
      if(cartModel.item!.storeId != storeID && cartModel.item!.moduleId == moduleId) {
        return true;
      }
    }
    return false;
  }

  void removeAllAndAddToCart(CartModel cartModel) async {
    _cartList = [];
    for(CartModel cartItem in cartRepo.getCartList()) {
      if(cartItem.item!.moduleId != cartModel.item!.moduleId) {
        _cartList.add(cartItem);
      }
    }
    _cartList.add(cartModel);
    await cartRepo.addToCartList(_cartList);
    getCartData();
    calculationCart();
    Get.find<ItemController>().setExistInCart(cartModel.item, notify: true);
    update();
  }

}
