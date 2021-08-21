
import 'dart:convert' as convert;
import 'package:case_records/controller/form_controller.dart';
import 'package:case_records/service/storage_service.dart';
import 'package:case_records/service/web_storage_dummy.dart' if(dart.library.html) 'package:case_records/service/webstorage.dart' as webstorage;
import 'package:flutter/foundation.dart';

enum FormControllerSingleton{
  INSTANCE
}
extension FormControllerSingletonExtension on FormControllerSingleton{
  static final AbstractStorage storage = createStorageObject();

  static FormController? _formControllerCached;
  static Future<FormController> get formController {
    if(_formControllerCached != null)
      return SynchronousFuture(_formControllerCached!);
    print('Creating formcontroller instance');
    return storage.readData().then((String dbData){
      if(["", null, false, 0].contains(dbData)){
        throw new Exception("DB not initialised. App script url and sheet id not configured");
      }
      dynamic dbObject = convert.jsonDecode(dbData);
      _formControllerCached = FormController(dbObject['appScriptUrl'], dbObject['sheetId']);
      return _formControllerCached!;
    });
  }

  static AbstractStorage createStorageObject(){
    if (kIsWeb) {
      return webstorage.WebStorage();
    } else {
      return FileStorage();
    }
  }
}