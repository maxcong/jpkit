/*
* Author : Max.Cong
* Date : 2019-01-08
* */

enum JPHttpMethod {
  GET,
  POST,
  PUT,
  DELETE
}

class JPRequest {
  String path;
  JPHttpMethod method;
  dynamic params;
  bool isAuthRequest = false;

  JPRequest(String path, [JPHttpMethod method, dynamic params]) {
    if(method != null) {
      this.method = method;
    } else {
      this.method = JPHttpMethod.GET;
    }
    this.path = path;
    this.params = params;
  }

  // ignore: non_constant_identifier_names
  static JPRequest GET(String path) {
    return new JPRequest(path, JPHttpMethod.GET, null);
  }

  // ignore: non_constant_identifier_names
  static JPRequest POST(String path, Map params) {
    return new JPRequest(path, JPHttpMethod.POST, params);
  }
}