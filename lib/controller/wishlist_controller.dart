import 'package:sixam_mart/controller/location_controller.dart';
import 'package:sixam_mart/controller/splash_controller.dart';
import 'package:sixam_mart/data/api/api_checker.dart';
import 'package:sixam_mart/data/model/response/item_model.dart';
import 'package:sixam_mart/data/model/response/store_model.dart';
import 'package:sixam_mart/data/repository/item_repo.dart';
import 'package:sixam_mart/data/repository/wishlist_repo.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';
import 'package:get/get.dart';

class WishListController extends GetxController implements GetxService {
  final WishListRepo wishListRepo;
  final ItemRepo itemRepo;
  WishListController({required this.wishListRepo, required this.itemRepo});

  List<Item?>? _wishItemList;
  List<Store?>? _wishStoreList;
  List<int?> _wishItemIdList = [];
  List<int?> _wishStoreIdList = [];
  bool _isRemoving = false;

  List<Item?>? get wishItemList => _wishItemList;
  List<Store?>? get wishStoreList => _wishStoreList;
  List<int?> get wishItemIdList => _wishItemIdList;
  List<int?> get wishStoreIdList => _wishStoreIdList;
  bool get isRemoving => _isRemoving;

  void addToWishList(Item? product, Store? store, bool isStore, {bool getXSnackBar = false}) async {
    if(isStore) {
      _wishStoreIdList.add(store!.id);
      _wishStoreList!.add(store);
    }else{
      _wishItemList!.add(product);
      _wishItemIdList.add(product!.id);
    }
    Response response = await wishListRepo.addWishList(isStore ? store!.id : product!.id, isStore);
    if (response.statusCode == 200) {
      // if(isStore) {
      //   _wishStoreIdList.forEach((storeId) {
      //     if(storeId == store.id){
      //       _wishStoreIdList.removeAt(_wishStoreIdList.indexOf(storeId));
      //     }
      //   });
      //   _wishStoreIdList.add(store.id);
      //   _wishStoreList.add(store);
      // }else {
      //   _wishItemIdList.forEach((productId) {
      //     if(productId == product.id){
      //       _wishItemIdList.removeAt(_wishItemIdList.indexOf(productId));
      //     }
      //   });
      //   _wishItemList.add(product);
      //   _wishItemIdList.add(product.id);
      // }
      showCustomSnackBar(response.body['message'], isError: false, getXSnackBar: getXSnackBar);
    } else {
      if(isStore) {
        for (var storeId in _wishStoreIdList) {
          if (storeId == store!.id) {
            _wishStoreIdList.removeAt(_wishStoreIdList.indexOf(storeId));
          }
        }
      }else{
        for (var productId in _wishItemIdList) {
          if(productId == product!.id){
            _wishItemIdList.removeAt(_wishItemIdList.indexOf(productId));
          }
        }
      }
      ApiChecker.checkApi(response, getXSnackBar: getXSnackBar);
    }
    update();
  }

  void removeFromWishList(int? id, bool isStore, {bool getXSnackBar = false}) async {
    _isRemoving = true;
    update();

    int idIndex = -1;
    int? storeId, itemId;
    Store? store;
    Item? item;
    if(isStore) {
      idIndex = _wishStoreIdList.indexOf(id);
      if(idIndex != -1) {
        storeId = id;
        _wishStoreIdList.removeAt(idIndex);
        store = _wishStoreList![idIndex];
        _wishStoreList!.removeAt(idIndex);
      }
    }else {
      idIndex = _wishItemIdList.indexOf(id);
      if(idIndex != -1) {
        itemId = id;
        _wishItemIdList.removeAt(idIndex);
        item = _wishItemList![idIndex];
        _wishItemList!.removeAt(idIndex);
      }
    }
    Response response = await wishListRepo.removeWishList(id, isStore);
    if (response.statusCode == 200) {
      showCustomSnackBar(response.body['message'], isError: false, getXSnackBar: getXSnackBar);
    }
    else {
      ApiChecker.checkApi(response, getXSnackBar: getXSnackBar);
      if(isStore) {
        _wishStoreIdList.add(storeId);
        _wishStoreList!.add(store);
      }else {
        _wishItemIdList.add(itemId);
        _wishItemList!.add(item);
      }
    }
    _isRemoving = false;
    update();
  }

  Future<void> getWishList() async {

    _wishItemList = null;
    _wishStoreList = null;

    Response response = await wishListRepo.getWishList();
    if (response.statusCode == 200) {
      update();

      _wishItemList = [];
      _wishStoreList = [];
      _wishStoreIdList = [];
      _wishItemIdList = [];

      if(response.body['item'] != null){
        response.body['item'].forEach((item) async {
          if(item['module_type'] == null || !Get.find<SplashController>().getModuleConfig(item['module_type']).newVariation!
              || item['variations'] == null || item['variations'].isEmpty
              || (item['food_variations'] != null && item['food_variations'].isNotEmpty)){

            Item i = Item.fromJson(item);
            if(Get.find<SplashController>().module == null){
              for (var zone in Get.find<LocationController>().getUserAddress()!.zoneData!) {
                for (var module in zone.modules!) {
                  if(module.id == i.moduleId){
                    if(module.pivot!.zoneId == i.zoneId){
                      _wishItemList!.add(i);
                      _wishItemIdList.add(i.id);
                    }
                  }
                }
              }
            }else{
              _wishItemList!.add(i);
              _wishItemIdList.add(i.id);
            }
          }
        });
      }

      response.body['store'].forEach((store) async {
        if(Get.find<SplashController>().module == null){
          for (var zone in Get.find<LocationController>().getUserAddress()!.zoneData!) {
            for (var module in zone.modules!) {
              if(module.id == Store.fromJson(store).moduleId){
                if(module.pivot!.zoneId == Store.fromJson(store).zoneId){
                  _wishStoreList!.add(Store.fromJson(store));
                  _wishStoreIdList.add(Store.fromJson(store).id);
                }
              }
            }
          }
        }else{
          Store? s;
          try{
            s = Store.fromJson(store);
          }catch(_){}
          if(s != null && Get.find<SplashController>().module!.id == s.moduleId) {
            _wishStoreList!.add(s);
            _wishStoreIdList.add(s.id);
          }
        }

      });
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void removeWishes() {
    _wishItemIdList = [];
    _wishStoreIdList = [];
  }
}
