import 'package:get/get.dart';
import 'package:sixam_mart/controller/user_controller.dart';
import 'package:sixam_mart/data/api/api_checker.dart';
import 'package:sixam_mart/data/model/response/wallet_model.dart';
import 'package:sixam_mart/data/repository/wallet_repo.dart';
import 'package:sixam_mart/view/base/custom_snackbar.dart';

class WalletController extends GetxController implements GetxService{
  final WalletRepo walletRepo;
  WalletController({required this.walletRepo});

  List<Transaction>? _transactionList;
  List<String> _offsetList = [];
  int _offset = 1;
  int? _pageSize;
  bool _isLoading = false;

  List<Transaction>? get transactionList => _transactionList;
  int? get popularPageSize => _pageSize;
  bool get isLoading => _isLoading;
  int get offset => _offset;

  void setOffset(int offset) {
    _offset = offset;
  }
  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  Future<void> getWalletTransactionList(String offset, bool reload, bool isWallet) async {
    if(offset == '1' || reload) {
      _offsetList = [];
      _offset = 1;
      _transactionList = null;
      if(reload) {
        update();
      }

    }
    if (!_offsetList.contains(offset)) {
      _offsetList.add(offset);
      Response response;
      if(isWallet){
        response = await walletRepo.getWalletTransactionList(offset);
      }else{
        response = await walletRepo.getLoyaltyTransactionList(offset);
      }

      if (response.statusCode == 200) {
        if (offset == '1') {
          _transactionList = [];
        }
        _transactionList!.addAll(WalletModel.fromJson(response.body).data!);
        _pageSize = WalletModel.fromJson(response.body).totalSize;

        _isLoading = false;
        update();
      } else {
        ApiChecker.checkApi(response);
      }
    } else {
      if(isLoading) {
        _isLoading = false;
        update();
      }
    }
  }

  Future<void> pointToWallet(int point, bool fromWallet) async {
    _isLoading = true;
    update();
    Response response = await walletRepo.pointToWallet(point: point);
    if (response.statusCode == 200) {
      Get.back();
      getWalletTransactionList('1', true, fromWallet);
      Get.find<UserController>().getUserInfo();
      showCustomSnackBar('converted_successfully_transfer_to_your_wallet'.tr, isError: false);
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }



}