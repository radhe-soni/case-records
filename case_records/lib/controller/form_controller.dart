import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../model/case_record.dart';


class FormController {

  // Google App Script Web URL.
  static String URL = "https://script.google.com/macros/s/AKfycbwKAvsFyORfWYK7pWN768gT0j6XDa8csVl9t4S38OHmMPs11ew2dgtXKKPML4lq8_X6/exec";

  // Success Status Message
  static const STATUS_SUCCESS = "SUCCESS";

  /// Async function which saves feedback, parses [feedbackForm] parameters
  /// and sends HTTP GET request on [URL]. On successful response, [callback] is called.
  void submitForm(
      CaseRecord caseRecord, void Function(String) callback) async {
    try {
      print(caseRecord.toJson());
      await http.post(Uri.parse(URL), body: caseRecord.toJson()).then((response) async {
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

  void fetchRecords(
      String filterDate, void Function(List<dynamic>) callback) async {
    try {
      print("fetching records for" + filterDate);
      await http.get(Uri.parse(URL+"?filterDate="+filterDate)).then((response) async {
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
}