import 'dart:convert' as convert;
import 'package:case_records/controller/form_controller.dart';
import 'package:case_records/service/storage_service.dart';
import 'package:case_records/service/web_storage_dummy.dart'
    if (dart.library.html) 'package:case_records/service/webstorage.dart'
    as webstorage;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum FormControllerFactory { FACTORY }

extension FormControllerSingletonExtension on FormControllerFactory {
  static AbstractStorage storage = createStorageObject();

  Future<FormController> getInstance(
      GoogleSignInAccount googleSignInAccount) async {
    print('Creating formcontroller instance');
    return storage.readData().then((String dbData) {
      if (["", null, false, 0].contains(dbData)) {
        throw new Exception("DB not initialised. Sheet id not configured");
      }
      dynamic dbObject = convert.jsonDecode(dbData);
      return new FormController(googleSignInAccount, dbObject['sheetId']);
    });
  }

  static AbstractStorage createStorageObject() {
    if (kIsWeb) {
      return webstorage.WebStorage();
    } else {
      return FileStorage();
    }
  }
}
