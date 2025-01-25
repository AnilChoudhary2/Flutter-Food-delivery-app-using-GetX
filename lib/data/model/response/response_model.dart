class ResponseModel {
  final bool _isSuccess;
  final String? _message;
  ResponseModel(this._isSuccess, this._message);

  String? get message => _message;
  bool get isSuccess => _isSuccess;
}

class OtpResponseModel {
  bool _isSuccess;
  String? _message;
  String _token;
  OtpResponseModel(this._isSuccess, this._message, this._token);

  String? get message => _message;
  bool get isSuccess => _isSuccess;
  String get token => _token;
}