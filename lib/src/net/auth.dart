import 'dart:convert';
import "package:shared_preferences/shared_preferences.dart";  // shared saved
import 'package:jpkit/src/config.dart';
import 'package:jpkit/src/misc/notification_center.dart';
import 'package:jpkit/src/net/request.dart';
import 'package:jpkit/src/net/client.dart';

const String NotificationKeyJPAuthorizationIsInitialize = "JPAuthorization.isInitialize";
const String NotificationKeyJPAuthorizationIsAuthenticated = "JPAuthorization.isAuthenticated";

///
/// OAuth 2.0 验证授权操作类
class JPAuthorization {
  /// 单例化
  factory JPAuthorization() => _getInstance();
  static JPAuthorization _instance;
  static JPAuthorization get instance => _getInstance();
  JPAuthorization._internal() {
    _initToken();
  }
  static JPAuthorization _getInstance() {
    if (_instance == null) {
      _instance = new JPAuthorization._internal();
    }
    return _instance;
  }

  /// 是否已经初始化
  bool _isInitialize = false;
  get isInitialize => _isInitialize;
  set isInitialize(bool isInitialize) {
    _isInitialize = isInitialize;
    // 发送全局广播
    NotificationCenter.post("JPAuthorization.isInitialize", isInitialize);
  }

  /// 存储登录Token
  JPOAuthToken _token;
  get token => _token;
  set token(JPOAuthToken token) {
    _token = token;
    if(token == null) {
      _delete("token");
    } else {
      _save("token", jsonEncode(token.apiData));
    }
    NotificationCenter.post("JPAuthorization.isAuthenticated");
  }

  /// 初始化Token(异步、发送全局广播)
  void _initToken() async {
    // 初始化
    if(this.isInitialize == false) {
      String tokenJson = await _get("token");
      if(tokenJson != null) {
          Map tempToken = jsonDecode(tokenJson);
          if (tempToken != null) {
            JPOAuthToken token = JPOAuthToken(tempToken);
            this.token = token;
          } else {
            this.token = null;
          }
        }
        this.isInitialize = true; // 登录信息初始化完毕
    }
  }

  /// 是否已经验证登录身份
  bool isAuthenticated() => (token != null);

  static authenticate({String username, String password}) {
    // assert
    assert(JPConfig.apiUrl != null);
    assert(JPConfig.authPath != null);
    assert(JPConfig.clientId != null);
    assert(JPConfig.clientApiSecret != null);


    Map params = Map<String, dynamic>();
    params["client_id"] = JPConfig.clientId;
    params["client_secret"] = JPConfig.clientApiSecret;
    params["grant_type"] = "password";
    params["username"] = username;
    params["password"] = password;

    JPRequest request = JPRequest.POST(JPConfig.apiUrl+JPConfig.authPath, params);
    request.isAuthRequest = true;

    JPClient.instance.send(request: request, responseCallback: (response, error) {
      if(error != null) {
        print("----------error------------");
        print(error);
        print("----------error end--------");
      } else {
        JPOAuthToken token = JPOAuthToken(response.data);
        JPAuthorization.instance.token = token;
      }
    });
  }

  void logout() {
    token = null;
  }

  /// 工具函数
  void _save(String key, String value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(key, value);
  }

  void _delete(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.remove(key);
  }

  Future<String> _get(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(key);
  }
}

/// OAuth 2.0 验证结果Model
class JPOAuthToken {
  String accessToken;
  String refreshToken;
  String tokenType;
  int expiresIn;
  int expires;
  int userId;

  JPOAuthToken(Map apiData) {
    this.apiData = apiData;
  }

  Map _apiData;
  get apiData => _apiData;
  set apiData(Map apiData) {
    _apiData = apiData;
    accessToken = apiData["access_token"];
    refreshToken = apiData["refresh_token"];
    tokenType = apiData["token_type"];
    expiresIn = apiData["expires_in"];
    expires = apiData["expires"];
    userId = apiData["user_id"];
  }
}