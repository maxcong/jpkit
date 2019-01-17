/*
* Author : Max.Cong
* Date : 2019-01-08
*/
import 'package:dio/dio.dart';
import 'package:jpkit/src/net/auth.dart';
import 'package:jpkit/src/net/request.dart';
import 'dart:convert';
// import 'package:jpkit/src/net/response.dart';

///
/// 网络请求的核心逻辑处理类
/// JPClient 单例
/// 可以通过类方法GET/POST/PUT/DELETE直接创建网络请求
/// 整个网络请求会被放在单例中类中，以后方便扩展多请求
///
class JPClient {

  /// 单例化
  factory JPClient() => _getInstance();
  static JPClient _instance;
  static JPClient get instance => _getInstance();
  JPClient._internal() {
    // 初始化
  }

  // 单例
  static JPClient _getInstance() {
    if (_instance == null) {
      _instance = new JPClient._internal();
    }
    return _instance;
  }

  /// 类方法：GET请求
  static Future<Response> GET({String path, responseCallback(Response response, Error e)}) async { // ignore: non_constant_identifier_names
    Future future = JPClient.instance.send(request:JPRequest.GET(path), responseCallback: responseCallback);
    return future;
  }

  /// 类方法：POST请求
  static Future<Response> POST({String path, Map<String, dynamic> params, responseCallback(Response response, Error e)}) async { // ignore: non_constant_identifier_names
    Future future = JPClient.instance.send(request:JPRequest.POST(path, params), responseCallback: responseCallback);
    return future;
  }

  /// 外部调用方法，可以直接采用send进行网络请求的调用发送
  /// 带有两个回调:
  /// 1. responseCallback: (response) {}
  /// 2. errorCallback: (error) {}
  Future<Response> send({JPRequest request, responseCallback(Response response, Error e)}) async {
    Future future = this.performRequest(request: request);
    future.then((response) {
      if(responseCallback != null) {
        responseCallback(response, null);
      }
    }).catchError((e) {
      if(responseCallback != null) {
        responseCallback(null, e);
      }
    });
    return future;
  }

  /// 执行发送网络请求的命令
  /// 注意：没有回调方法，只是包装request所需要的所有参数
  Future<Response> performRequest({JPRequest request}) async {
    String method;
    switch (request.method) {
      case JPHttpMethod.GET:
        method = "GET";
        break;
      case JPHttpMethod.POST:
        method = "POST";
        break;
      case JPHttpMethod.PUT:
        method = "PUT";
        break;
      case JPHttpMethod.DELETE:
        method = "DELETE";
        break;
    }
    Options options = new Options(method: method);
    JPOAuthToken token = JPAuthorization().token;
    Map headers = Map<String, dynamic>();
    if(!request.isAuthRequest) {
      if (token != null) {
        headers["Authorization"] = token.tokenType + " " + token.accessToken;
      }
    }

    headers["X-Huoban-Build-Code"] = "380";
    options.headers = headers;
    options.data = request.params;

    Dio dio = new Dio();

    // The interceptor override
    dio.interceptor.request.onSend = (Options options) {
      _printCURL(options);
      return options;
    };
    try {
      Response response = await dio.request(request.path, options: options);
      return response;
    } catch(e) {
      return new Future.error(e);
    }
  }



  /// 打印CURL或普通网络请求可查看格式
  void _printCURL(Options options) {
    String descPrefix = "";
    String methodPrefix = "";
    if(options.method != "GET") {
      methodPrefix = "-X \'${options.method}\'";
    }
    String headerString = "";
    if(options.headers != null) {
      for(String headerKey in options.headers.keys) {
        headerString += " -H \'$headerKey : ${options.headers[headerKey]}\'";
      }
    }
    String jsonData = "";
    if(options.data != null) {
      jsonData = JsonEncoder().convert(options.data);
      if(jsonData != null) {
        jsonData = " -d \$\'"+ jsonData + "\'";
      }
    }
    print(descPrefix + "\ncurl $methodPrefix \""+options.path+"\""+headerString+" "+jsonData+" \r\n\n");
  }
}