import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

abstract class AbstractStorage{
  Future<String> readData();
  Future<void> writeData(String data);
}
class FileStorage implements AbstractStorage{
  Future<String> get localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    File file = new File('$path/db.txt');
    if(! await file.exists()){
      file.create(recursive: true);
    }
    return File('$path/db.txt');
  }

  Future<String> readData() async {
    try {
      final file = await localFile;
      String body = await file.readAsString();
      return body;
    } catch (e) {
      throw e;
    }
  }

  Future<File> _writeData(String data) async {
    final file = await localFile;
    return file.writeAsString("$data");
  }

  Future<void> writeData(String data) async {
    await _writeData(data);
  }

}

