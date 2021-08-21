import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../model/case_record.dart';


class FormController {
  final String URL;
  final String SHEET_ID;
  // Google App Script Web URL.
  FormController(this.URL, this.SHEET_ID);

  // Success Status Message
  static const STATUS_SUCCESS = "SUCCESS";

  /// Async function which saves feedback, parses [feedbackForm] parameters
  /// and sends HTTP GET request on [URL]. On successful response, [callback] is called.
  void submitForm(
      CaseRecord caseRecord, void Function(String) callback) async {
    try {
      print(caseRecord.toJson());
      await http.post(Uri.parse(urlWithSheetId()), body: caseRecord.toJson()).then((response) async {
        if (response.statusCode == 302) {
          String url = response.headers['location']!;
          await http.get(Uri.parse(url)).then((response) {
            callback(convert.jsonDecode(response.body)['status']);
          });
        } else {
          callback(convert.jsonDecode(response.body)['status']);
        }
      });
    } catch (e) {
      print("FormController:submitForm ${e}");
    }
  }

  String urlWithSheetId() => URL+"?sheetId="+SHEET_ID;

  void fetchRecords(
      String filterDate, void Function(List<dynamic>) callback) async {
    try {
      print("fetching records for" + filterDate);
      await http.get(Uri.parse(urlWithSheetId()+"&filterDate="+filterDate)).then((response) async {
        if (response.statusCode == 302) {
          String url = response.headers['location']!;
          await http.get(Uri.parse(url)).then((response) {
            callback(convert.jsonDecode(response.body));
          });
        } else {
          print(response.body);
          callback(convert.jsonDecode(response.body));
        }
      });
    } catch (e) {
      print("FormController:fetchRecords ${e}");
    }
  }

  void createBackup(void Function(List<dynamic>) callback) async{

  }
}