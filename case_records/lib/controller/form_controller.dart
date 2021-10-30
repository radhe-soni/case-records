import 'dart:convert' as convert;
import 'package:case_records/controller/create_sheet_controller.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../model/case_record.dart';


class FormController {
  final String SHEET_ID;
  final GoogleSignInAccount googleSignInAccount;
  final log = Logger('FormController');
  // Google App Script Web URL.
  FormController(this.googleSignInAccount, this.SHEET_ID);

  // Success Status Message
  static const STATUS_SUCCESS = "SUCCESS";

  /// Async function which saves feedback, parses [feedbackForm] parameters
  /// and sends HTTP GET request on [URL]. On successful response, [callback] is called.
  void submitForm(
      CaseRecord caseRecord, void Function(String) callback) async {
    SheetController controller = await SheetControllerSingletonExtension.instance(googleSignInAccount);
    try {
      print(caseRecord.toJson());
      Map record = caseRecord.toJson();
      record['sheetId'] = SHEET_ID;
      await controller.addRecord(record);
    } catch (e) {
      print("FormController:submitForm ${e}");
    }
  }

  void fetchRecords(
      String filterDate, void Function(List<CaseRecord>) callback) async {
    SheetController controller = await SheetControllerSingletonExtension.instance(googleSignInAccount);
    Map<Object, Object> request = {'sheetId': SHEET_ID, 'filterDate': filterDate};
    try {
      List<CaseRecord> caseRecords = await controller.fetchRecords(request);
      callback(caseRecords);
    } catch (e, stacktrace) {
      log.severe("FormController:fetchRecords ${e}", stacktrace);
    }
  }

  void createBackup(void Function(List<dynamic>) callback) async{

  }
}