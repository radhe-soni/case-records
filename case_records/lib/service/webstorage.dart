
import 'dart:html';
import 'package:case_records/service/storage_service.dart';
import 'package:flutter/foundation.dart';

class WebStorage implements AbstractStorage{
  final Storage _localStorage = window.localStorage;
  Future<String> readData() async {
    var dbData = _localStorage['case_record'];
    if(dbData == null)
      dbData = "";
    return SynchronousFuture(dbData);
  }

  Future<void> writeData(String data) async {
    _localStorage['case_record'] = data;
  }
}