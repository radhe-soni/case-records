function doPost(request){
  // Open Google Sheet using ID
  var result = {"status": "SUCCESS"};
  try{
    var sheet = SpreadsheetApp.openById("1hIou3IG2sD4xvtfHaHceZfLmtvLjHRN2xi3ZqL4m2AQ");
    // Get all Parameters
    var parameters = request.parameter;
    var clientName = parameters.clientName;
    var caseDescription = parameters.caseDescription;
    var filingDate = parameters.filingDate;
    var previousHearingDate = parameters.previousHearingDate;
    var nextHearingDate = parameters.nextHearingDate;
    var record_id = new Date().getTime();
    // Append data on Google Sheet
    var rowData = sheet.appendRow([clientName, caseDescription, filingDate, previousHearingDate, nextHearingDate, record_id]);

  }catch(exc){
    // If error occurs, throw exception
    throw exc;
    //result = {"status": "FAILED", "message": exc};
  }

  // Return result
  return ContentService
  .createTextOutput(JSON.stringify(result))
  .setMimeType(ContentService.MimeType.JSON);
}
function testGet(){
  doGet({parameter: {filterDate: '2021-08-07'} })
}
function doGet(request){
  var filterDate = request.parameter.filterDate;
  // Open Google Sheet using ID
  var sheet = SpreadsheetApp.openById("1hIou3IG2sD4xvtfHaHceZfLmtvLjHRN2xi3ZqL4m2AQ");
  // Get all values in active sheet
  var values = query(sheet, `=QUERY(2021!A2:E; \"select A, B, C, D, E where E = date'${filterDate}'\")`);
  var data = [];

  // Iterate values in descending order
  for (var i = values.length - 1; i >= 0; i--) {

    // Get each row
    var row = values[i];

    // Create object
    var feedback = {};

    feedback['clientName'] = row[0];
    feedback['caseDescription'] = row[1];
    feedback['filingDate'] = toYYYYMMDD(new Date(row[2]));
    feedback['previousHearingDate'] = toYYYYMMDD(new Date(row[3]));
    feedback['nextHearingDate'] = toYYYYMMDD(new Date(row[4]));

    // Push each row object in data
    data.push(feedback);
  }

  // Return result
  return ContentService
  .createTextOutput(JSON.stringify(data))
  .setMimeType(ContentService.MimeType.JSON);
}

function toYYYYMMDD(sampleDate){
  let month = '0' + sampleDate.getMonth();
  month = month.length > 2 ? month.substr(1) : month;
  let day = '0' + sampleDate.getDate();
  day = day.length > 2 ? day.substr(1) : day;
  return sampleDate.getFullYear() + '-' + month + '-' + day;
}

function query(sp, request) {
  var sheet = sp.insertSheet();
  var r = sheet.getRange(1, 1).setFormula(request);

  var reply = sheet.getDataRange().getValues();
  sp.deleteSheet(sheet);

  return reply;
}
