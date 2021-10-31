import 'package:case_records/controller/create_sheet_controller.dart';

class CaseRecord {
  final String clientName;
  final String caseDescription;
  final String filingDate;
  final String previousHearingDate;
  final String nextHearingDate;
  final String remark;

  CaseRecord(this.clientName, this.caseDescription, this.filingDate,
      this.previousHearingDate, this.nextHearingDate, {this.remark = 'N/A'});

  factory CaseRecord.fromJson(dynamic json) {
    return CaseRecord(
        "${json['clientName']}",
        "${json['caseDescription']}",
        "${json['filingDate']}",
        "${json['previousHearingDate']}",
        "${json['nextHearingDate']}",
        remark: "${json['remark']}");
  }

  factory CaseRecord.defaultRecord() {
    String defaultDate = "${DateTime.now().toLocal()}".split(' ')[0];
    return CaseRecord("", "", defaultDate, defaultDate, defaultDate, remark: "N/A");
  }

  // Method to make GET parameters.
  Map toJson() => {
    COLUMN_NAMES.clientName: clientName,
    COLUMN_NAMES.caseDescription: caseDescription,
    COLUMN_NAMES.filingDate: filingDate,
    COLUMN_NAMES.previousHearingDate: previousHearingDate,
    COLUMN_NAMES.nextHearingDate: nextHearingDate,
    COLUMN_NAMES.remark: remark,
      };

  CaseRecord withFilingDate(String newValue) {
    return CaseRecord(this.clientName, this.caseDescription, newValue,
        this.previousHearingDate, this.nextHearingDate, remark: this.remark);
  }

  CaseRecord withPreviousHearingDate(String newValue) {
    return CaseRecord(this.clientName, this.caseDescription, this.filingDate,
        newValue, this.nextHearingDate, remark: this.remark);
  }

  CaseRecord withNextHearingDate(String newValue) {
    return CaseRecord(this.clientName, this.caseDescription, this.filingDate,
        this.previousHearingDate, newValue, remark: this.remark);
  }

  CaseRecord withClientName(String newValue) {
    return CaseRecord(newValue, this.caseDescription, this.filingDate,
        this.previousHearingDate, this.nextHearingDate, remark: this.remark);
  }

  CaseRecord withCaseDescription(String newValue) {
    return CaseRecord(this.clientName, newValue, this.filingDate,
        this.previousHearingDate, this.nextHearingDate, remark: this.remark);
  }

  CaseRecord withRemark(String newValue) {
    return CaseRecord(this.clientName, this.caseDescription, this.filingDate,
        this.previousHearingDate, this.nextHearingDate, remark: newValue);
  }
}
