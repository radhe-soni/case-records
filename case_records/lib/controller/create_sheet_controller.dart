import 'dart:developer';

import 'package:case_records/google/GoogleAuthClient.dart';
import 'package:case_records/model/case_record.dart';
import 'package:case_records/view/case_records_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as spreadSheet;
import 'package:logging/logging.dart';

// void createSheet(String appScriptURL,GoogleSignInAccount googleSignInAccount, void Function(String) callback) async {
//   try {
//     var authHeaders = await googleSignInAccount.authHeaders;
//     print("Create Sheet ${authHeaders}");
//     await http.post(Uri.parse(appScriptURL+'?action=createSheet'),
//       headers: await googleSignInAccount.authHeaders,).then((response) async {
//       if (response.statusCode == 302) {
//         String url = response.headers['location']!;
//         await http.get(Uri.parse(url)).then((response) {
//           callback(response.body);
//         });
//       } else {
//         callback('###ERROR###');
//         print(response.body);
//       }
//     });
//   } catch (e) {
//     print("Create Sheet: ${e}");
//   }
// }
const SHEET_NAME = 'CASE_RECORD';
const APP_ROOT_FOLDER = 'case_record';
enum COLUMN_NAMES {
  clientName,
  caseDescription,
  filingDate,
  previousHearingDate,
  nextHearingDate,
  remark,
  id,
}

extension COLUMN_NAMES_Extenstion on COLUMN_NAMES {
  static const name = {
    COLUMN_NAMES.clientName: 'CLIENT NAME',
    COLUMN_NAMES.caseDescription: 'CASE DESCRIPTION',
    COLUMN_NAMES.filingDate: 'FILING DATE',
    COLUMN_NAMES.previousHearingDate: 'PREVIOUS HEARING DATE',
    COLUMN_NAMES.nextHearingDate: 'NEXT HEARING DATE',
    COLUMN_NAMES.remark: 'REMARK',
    COLUMN_NAMES.id: 'RECORD ID',
  };
}

extension SheetControllerSingletonExtension on SheetController {
  static SheetController? controller;

  static Future<SheetController> instance(googleSignInAccount) async {
    if (controller == null) {
      final authHeaders = await googleSignInAccount.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      SheetController newInstance = new SheetController(authenticateClient);
      controller = newInstance;
    }
    return controller!;
  }
}

class SheetController {
  final log = Logger('SheetController');
  final GoogleAuthClient authenticateClient;
  late final drive.DriveApi driveApi;
  late final spreadSheet.SheetsApi sheetsApi;

  SheetController(this.authenticateClient) {
    driveApi = drive.DriveApi(authenticateClient);
    sheetsApi = spreadSheet.SheetsApi(authenticateClient);
  }

  Future<void> createSheet(Function(String) callBack) async {
    try {
      _createSheet(callBack);
    } catch (err) {
      print("Create Sheet ${err}");
    }
  }

  void _createSheet(Function(String) callBack) async {
    log.info("_createSheet: creating new sheet");
    String id = '';
    try {
      drive.FileList fileList = await driveApi.files.list(
          q: "mimeType='application/vnd.google-apps.spreadsheet' and name='${SHEET_NAME}'");
      drive.File spreadSheetFile = fileList.files!.first;
      id = spreadSheetFile.id!;
    } catch (err) {
      log.warning("Spreadsheet not present creating new one", err);
      spreadSheet.Spreadsheet newSS = new spreadSheet.Spreadsheet();
      newSS = await sheetsApi.spreadsheets.create(newSS);
      id = newSS.spreadsheetId!;
      drive.File request = new drive.File();
      request.mimeType = 'application/vnd.google-apps.spreadsheet';
      request.parents = ["root"];
      request.name = SHEET_NAME;
      drive.File spreadSheetFile = await driveApi.files.copy(request, id);
      // spreadSheetFile = await driveApi.files.create(request);
      log.info("sheet file id " + id);
      log.info("drive file id " + spreadSheetFile.id!);
      driveApi.files.delete(id);
      id = spreadSheetFile.id!;
      Map<Object, Object> record = {'sheetId': id};
      COLUMN_NAMES.values.forEach((COLUMN_NAMES element) {
        record[element] = COLUMN_NAMES_Extenstion.name[element]!;
      });
      addRecord(record);
    }
    log.info("_createSheet: Calling call back function, id: ${id}");
    callBack(id);
  }

  Future<void> addRecord(record) async {
    try {
      print(record);
      spreadSheet.Spreadsheet sheet =
          await sheetsApi.spreadsheets.get(record['sheetId']);
      var recordToSend = [
        record[COLUMN_NAMES.clientName],
        record[COLUMN_NAMES.caseDescription],
        record[COLUMN_NAMES.filingDate],
        record[COLUMN_NAMES.previousHearingDate],
        record[COLUMN_NAMES.nextHearingDate],
        record[COLUMN_NAMES.remark],
        record[COLUMN_NAMES.id] != null
            ? record[COLUMN_NAMES.id]
            : DateTime.now().millisecondsSinceEpoch
      ];
      log.info('sheet id: ${sheet.spreadsheetId} record_id: ${recordToSend}');
      spreadSheet.ValueRange request = new spreadSheet.ValueRange.fromJson({
        "values": [recordToSend],
        "range": 'A:G',
        "majorDimension": "ROWS"
      });
      sheetsApi.spreadsheets.values.append(request, sheet.spreadsheetId!, 'A:G',
          valueInputOption: 'USER_ENTERED');
    } catch (exc, stacktrace) {
      log.severe("addRecord: ", exc, stacktrace);
      // If error occurs, throw exception
      throw exc;
      //result = {"status": "FAILED", "message": exc};
    }
  }

  Future<void> _addTempSheet(sheetId, filterDate) async {
    var addSheetRequest = new spreadSheet.AddSheetRequest(
        properties: new spreadSheet.SheetProperties(title: 'temp'));
    spreadSheet.BatchUpdateSpreadsheetRequest updateSheet =
        new spreadSheet.BatchUpdateSpreadsheetRequest(
            includeSpreadsheetInResponse: true,
            requests: [new spreadSheet.Request(addSheet: addSheetRequest)]);
    spreadSheet.BatchUpdateSpreadsheetResponse batchUpdate =
        await sheetsApi.spreadsheets.batchUpdate(updateSheet, sheetId);
    spreadSheet.ValueRange request = createTempSheetDataRequest(filterDate);
    sheetsApi.spreadsheets.values.append(request, sheetId, 'temp!A1:A1',
        valueInputOption: 'USER_ENTERED');
    log.info("added new temp sheet");
  }

  spreadSheet.ValueRange createTempSheetDataRequest(filterDate) {
    spreadSheet.ValueRange request = new spreadSheet.ValueRange.fromJson({
      "values": [
        [
          '=QUERY(2021!A2:F; "select A, B, C, D, E, F where E = date\'${filterDate}\'")'
        ]
      ],
      "range": 'temp!A1:A1',
      "majorDimension": "ROWS"
    });
    return request;
  }

  Future<void> _updateTempSheet(sheetId, filterDate) async {
    spreadSheet.ValueRange request = createTempSheetDataRequest(filterDate);
    await sheetsApi.spreadsheets.values.update(request, sheetId, 'temp!A1:A1',
        valueInputOption: 'USER_ENTERED');
    log.info("updated temp sheet");
  }

  Future<List<List<Object>>> _fetchTempSheetData(sheetId) {
    List<spreadSheet.DataFilter> dataFilters = [
      spreadSheet.DataFilter(a1Range: 'temp!A1:F')
    ];
    var batchGetValuesByDataFilterRequest =
        new spreadSheet.BatchGetValuesByDataFilterRequest(
            dataFilters: dataFilters,
            majorDimension: 'ROWS',
            valueRenderOption: 'UNFORMATTED_VALUE',
            dateTimeRenderOption: 'FORMATTED_STRING');
    return sheetsApi.spreadsheets.values
        .batchGetByDataFilter(batchGetValuesByDataFilterRequest, sheetId)
        .then((res) => res.valueRanges!)
        .then((ranges) => ranges
            .where((range) => range.valueRange != null)
            .map((range) => range.valueRange!))
        .then((valueRanges) => valueRanges
            .where((vRange) => vRange.values != null)
            .expand((vRange) => vRange.values!)
            .toList());
  }
  CaseRecord _toCaseRecord(row) {
    return new CaseRecord(
        row[COLUMN_NAMES.clientName.index],
        row[COLUMN_NAMES.caseDescription.index],
        row[COLUMN_NAMES.filingDate.index],
        row[COLUMN_NAMES.previousHearingDate.index],
        row[COLUMN_NAMES.nextHearingDate.index],
        row[COLUMN_NAMES.remark.index]);
  }

  List<CaseRecord> _toCaseRecords(List<List<Object>> response) {
    return response
        .where((row) =>  row.length>1)
        .map((row) => row.map((ele) => ele.toString()).toList())
        .map((row) => _toCaseRecord(row)).toList();
  }

  Future<List<CaseRecord>> fetchRecords(request) async {
    log.info("Fetching records for ${request}");
    try {
      await _addTempSheet(request['sheetId'], request['filterDate']);
    } catch (error) {
      log.info("Sheet already exists", error);
      await _updateTempSheet(request['sheetId'], request['filterDate']);
    }
    List<List<Object>> response = await _fetchTempSheetData(request['sheetId']);
    log.info("Fetched records ${response}");
    return _toCaseRecords(response);
  }

  int generateRecordId() {
    return new DateTime.now().millisecond;
  }
}
