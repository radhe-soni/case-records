
import 'package:case_records/service/storage_service.dart';

class WebStorage implements AbstractStorage{
  @override
  Future<String> readData() {
    throw UnimplementedError();
  }

  @override
  Future<void> writeData(String data) {
    throw UnimplementedError();
  }
  
}