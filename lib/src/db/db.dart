import 'dart:io';
import 'package:objectdb_flutter/objectdb_flutter.dart';
import 'package:path_provider/path_provider.dart' as Path;

class JPDB {

  /// 单例化
  factory JPDB() => _getInstance();
  static JPDB _instance;
  static JPDB get instance => _getInstance();
  static JPDB _getInstance() {
    if (_instance == null) {
      _instance = new JPDB._internal();
    }
    return _instance;
  }

  JPDB._internal() {
    // 初始化
  }

  Map<String, ObjectDB> _dbs; // 缓存的数据库链接

  /// 创建缓存数据连接
  Future<ObjectDB> db(String entityName) async {
    if(_dbs == null) {
      _dbs = Map();
    }
  
    if(_dbs[entityName] == null) {
      Directory appDocDir = await Path.getApplicationDocumentsDirectory();
      String dbFilePath = [appDocDir.path, entityName + '.db'].join('/');
      // File dbFile = File(dbFilePath);
      // var isNew = !await dbFile.exists();
        //  if (!isNew) dbFile.deleteSync();
      _dbs[entityName] = ObjectDB(dbFilePath);
    }
    _dbs[entityName].open();
    return _dbs[entityName];
  }

  /// 基于DBModel指定的entityName查询
  Future<List> queryByModel(DBModel model, Map op) async {
    return await this.query(model.entityName, op);
  }

/// 基于entityName查询
  Future<List> query(String entityName, Map op) async {
    ObjectDB db = await this.db(entityName);
    return db.find(op); 
  }

}

class DBBaseModel {}

abstract class DBModel extends DBBaseModel {
  get primaryKeys => <List<String>>[];
  get entityName => this.runtimeType.toString();
  
  Map _apiData;
  get apiData => _apiData;
  set apiData (Map apiData) {
    _apiData = apiData;
    if(!hasAllPrimaryKeys()) {
      _apiData = null;
    }
  }
  
  Map<String, dynamic> toJson();

  Future<bool> saveModel() async {
    apiData = toJson();
    return await this.save();
  }

  /// 存
  Future<bool> save() async {
    if(_apiData == null) return false;
    Map op = primaryKeysQueryOption();
    if(op == null) return false;
    
    ObjectDB db = await JPDB().db(entityName);
    List results = await db.find({Op.and:op});
    if(results.length == 0) {
      ObjectId id = await db.insert(apiData);
      print(entityName + " db has saved. query option is " + op.toString());
      return id != null ? true : false;
    } else {
      int updateId = await db.update({Op.and:op}, apiData, true);
      print(entityName + " db has saved and updated. query option is " + op.toString());
      return updateId != null ? true : false;
    }
  }

  /// 删
  void delete() async {
    ObjectDB db = await JPDB().db(entityName);
    db.remove({Op.and:primaryKeysQueryOption()});
    _apiData = null;
  }

  /// 查
  Future<List<Map>> query(Map op) async {
    return await JPDB().queryByModel(this, op);
  }

  /// 自动生成primaryKeys的查询
  Map primaryKeysQueryOption() {
    if(_apiData == null) return {};
    Map op = Map();
    for (dynamic primaryKey in primaryKeys) {
      dynamic value = apiData[primaryKey];
      if(value != null) {
        op[primaryKey] = apiData[primaryKey];
      }
    }
    return op;
  }

  /// 验证数据是否符合包含primaryKey的标准
  bool hasAllPrimaryKeys() {
    if(_apiData == null) return false;
    return (primaryKeysQueryOption().length == primaryKeys.length);
  }
}