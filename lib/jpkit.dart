/*
  author : Max.cong
  create dateline : 2019-01-08
  lastest modify dateline : 2019-01-9
* */

library jpkit;


export 'package:jpkit/src/config.dart';                   // 配置参数
export 'package:jpkit/src/net/auth.dart';                 // 登录验证
export 'package:jpkit/src/net/client.dart';               // 网络请求
export 'package:jpkit/src/net/request.dart';              // 请求体
export 'package:jpkit/src/net/response.dart';             // 返回值
export 'package:jpkit/src/db/db.dart';                    // 数据库封装

// /// 其他关键工具
export 'package:jpkit/src/misc/notification_center.dart'; // 广播
export 'package:jpkit/src/bloc/observable.dart';          // 观察者模式，基于rxdart的简易化包装
export 'package:jpkit/src/bloc/bloc_provider.dart';          // 观察者模式，基于rxdart的简易化包装

// /// 其他辅助工具
export 'package:jpkit/src/misc/color.dart';

class Jpkit {
  jpkit() {
    // return Future.value("jpkit");
  }

  Future<String> fetch() async {
    return Future.value("jpkit");
  }
}