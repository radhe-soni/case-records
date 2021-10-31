import 'package:case_records/google/GoogleAuthClient.dart';
import 'package:case_records/model/case_record.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as spreadSheet;
import 'package:logging/logging.dart';

const SPREADSHEET_NAME = 'CASE_RECORD';
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
  static Future<SheetController> instance(googleSignInAccount) async {
    print("Creating new controller instance");
    final authHeaders = await googleSignInAccount.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    return new SheetController(authenticateClient);
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
      id = await findSheet(id);
    } catch (err) {
      id = await createNewSpreadSheet(err, id);
    }
    log.info("_createSheet: Calling call back function, id: ${id}");
    callBack(id);
  }

  _getCurrentSheetName() {
    return DateTime.now().year.toString();
  }

  Future<String> createNewSpreadSheet(Object err, String id) async {
    log.warning("Spreadsheet not present creating new one", err);
    spreadSheet.Spreadsheet newSS = new spreadSheet.Spreadsheet();
    newSS = await sheetsApi.spreadsheets.create(newSS);
    id = newSS.spreadsheetId!;
    drive.File request = new drive.File();
    request.mimeType = 'application/vnd.google-apps.spreadsheet';
    request.parents = ["root"];
    request.name = SPREADSHEET_NAME;
    drive.File spreadSheetFile = await driveApi.files.copy(request, id);
    // spreadSheetFile = await driveApi.files.create(request);
    log.info("sheet file id " + id);
    log.info("drive file id " + spreadSheetFile.id!);
    driveApi.files.delete(id);
    id = spreadSheetFile.id!;
    await addSheet(_getCurrentSheetName(), id);
    Map<Object, Object> record = {'sheetId': id};
    COLUMN_NAMES.values.forEach((COLUMN_NAMES element) {
      record[element] = COLUMN_NAMES_Extenstion.name[element]!;
    });
    addRecord(record);
    return id;
  }

  Future<String> findSheet(String id) async {
    drive.FileList fileList = await driveApi.files.list(
        q: "mimeType='application/vnd.google-apps.spreadsheet' and name='${SPREADSHEET_NAME}'");
    drive.File spreadSheetFile = fileList.files!.first;
    id = spreadSheetFile.id!;
    return id;
  }

  Future<void> addRecord(record) async {
    try {
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
      log.info('sheet id: ${record['sheetId']} record_id: ${recordToSend}');
      spreadSheet.ValueRange request = new spreadSheet.ValueRange.fromJson({
        "values": [recordToSend],
        "majorDimension": "ROWS"
      });
      var sheetName = _getCurrentSheetName();
      sheetsApi.spreadsheets.values.append(
          request, record['sheetId'], '${sheetName}!A:G',
          valueInputOption: 'USER_ENTERED');
    } catch (exc, stacktrace) {
      log.severe("addRecord: ", exc, stacktrace);
      // If error occurs, throw exception
      throw exc;
      //result = {"status": "FAILED", "message": exc};
    }
  }

  Future<void> _addTempSheet(sheetId, query) async {
    await addSheet('temp', sheetId);

    spreadSheet.ValueRange request = createTempSheetDataRequest(query);
    sheetsApi.spreadsheets.values.append(request, sheetId, 'temp!A1:A1',
        valueInputOption: 'USER_ENTERED');
    log.info("added new temp sheet");
  }

  Future<void> addSheet(String sheetName, sheetId) async {
    var addSheetRequest = new spreadSheet.AddSheetRequest(
        properties: new spreadSheet.SheetProperties(title: sheetName));
    spreadSheet.BatchUpdateSpreadsheetRequest updateSheet =
        new spreadSheet.BatchUpdateSpreadsheetRequest(
            includeSpreadsheetInResponse: true,
            requests: [new spreadSheet.Request(addSheet: addSheetRequest)]);
    await sheetsApi.spreadsheets.batchUpdate(updateSheet, sheetId);
  }

  spreadSheet.ValueRange createTempSheetDataRequest(query) {
    spreadSheet.ValueRange request = new spreadSheet.ValueRange(values: [
      [query]
    ], range: 'temp!A1:A1', majorDimension: "ROWS");
    return request;
  }

  Future<void> _updateTempSheet(sheetId, query) async {
    spreadSheet.ValueRange request = createTempSheetDataRequest(query);
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
    String remark = row.length > 5 ? row[COLUMN_NAMES.remark.index] : 'N/A';
    return new CaseRecord(
        row[COLUMN_NAMES.clientName.index],
        row[COLUMN_NAMES.caseDescription.index],
        row[COLUMN_NAMES.filingDate.index],
        row[COLUMN_NAMES.previousHearingDate.index],
        row[COLUMN_NAMES.nextHearingDate.index],
        remark: remark);
  }

  List<CaseRecord> _toCaseRecords(List<List<Object>> response) {
    return response
        .where((row) => row.length > 1)
        .map((row) => row.map((ele) => ele.toString()).toList())
        .map((row) => _toCaseRecord(row))
        .toList();
  }

  _getSheetNameByDate(String filterDate) {
    return filterDate.substring(0, 4);
  }

  Future<List<CaseRecord>> fetchRecords(request) async {
    log.info("Fetching records for ${request}");
    var sheetName = _getSheetNameByDate(request['filterDate']);
    String query =
        '=QUERY(${sheetName}!A2:F; "select A, B, C, D, E, F where E = date\'${request['filterDate']}\'")';
    try {
      await _addTempSheet(request['sheetId'], query);
    } catch (error) {
      log.info("Sheet already exists", error);
      await _updateTempSheet(request['sheetId'], query);
    }
    List<List<Object>> response = await _fetchTempSheetData(request['sheetId']);
    log.info("Fetched records ${response}");
    return _toCaseRecords(response);
  }

  int generateRecordId() {
    return new DateTime.now().millisecond;
  }

  Future<List<CaseRecord>> fetchRecordsByName(request) async {
    log.info("Fetching records for ${request}");
    spreadSheet.Spreadsheet sheet =
        await sheetsApi.spreadsheets.get(request['sheetId']);
    List<CaseRecord> records = [];
    if (sheet.sheets != null && sheet.sheets!.isNotEmpty) {
      List<Future<List<CaseRecord>>> futureResponses = sheet.sheets!
          .map((sheet) => sheet.properties!.title!)
          .where((name) => name != 'temp')
          .map((sheetName) => _fetchRecordBySheetAndByName(request, sheetName))
          .toList();
      List<List<CaseRecord>> responses = await Future.wait(futureResponses);
      records = responses.expand((element) => element).toList();
    }
    return records;
  }

  Future<List<CaseRecord>> _fetchRecordBySheetAndByName(
      request, sheetName) async {
    String query =
        '=QUERY(${sheetName}!A2:F; "select A, B, C, D, E, F where A = \'${request['clientName']}\'")';
    try {
      await _addTempSheet(request['sheetId'], query);
    } catch (error) {
      log.info("Sheet already exists", error);
      await _updateTempSheet(request['sheetId'], query);
    }
    var response = await _fetchTempSheetData(request['sheetId']);
    log.info("Fetched records from sheet:${sheetName} =>  ${response}");
    return _toCaseRecords(response);
  }
}
