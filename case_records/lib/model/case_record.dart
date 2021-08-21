class CaseRecord {
  final String clientName;
  final String caseDescription;
  final String filingDate;
  final String previousHearingDate;
  final String nextHearingDate;
  final String remark;

  CaseRecord(this.clientName, this.caseDescription, this.filingDate,
      this.previousHearingDate, this.nextHearingDate, this.remark);

  factory CaseRecord.fromJson(dynamic json) {
    return CaseRecord(
        "${json['clientName']}",
        "${json['caseDescription']}",
        "${json['filingDate']}",
        "${json['previousHearingDate']}",
        "${json['nextHearingDate']}",
        "${json['remark']}");
  }

  factory CaseRecord.defaultRecord() {
    String defaultDate = "${DateTime.now().toLocal()}".split(' ')[0];
    return CaseRecord("", "", defaultDate, defaultDate, defaultDate, "");
  }

  // Method to make GET parameters.
  Map toJson() => {
        'clientName': clientName,
        'caseDescription': caseDescription,
        'filingDate': filingDate,
        'previousHearingDate': previousHearingDate,
        'nextHearingDate': nextHearingDate,
        'remark': remark,
      };

  CaseRecord withFilingDate(String newValue) {
    return CaseRecord(this.clientName, this.caseDescription, newValue,
        this.previousHearingDate, this.nextHearingDate, this.remark);
  }

  CaseRecord withPreviousHearingDate(String newValue) {
    return CaseRecord(this.clientName, this.caseDescription, this.filingDate,
        newValue, this.nextHearingDate, this.remark);
  }

  CaseRecord withNextHearingDate(String newValue) {
    return CaseRecord(this.clientName, this.caseDescription, this.filingDate,
        this.previousHearingDate, newValue, this.remark);
  }

  CaseRecord withClientName(String newValue) {
    return CaseRecord(newValue, this.caseDescription, this.filingDate,
        this.previousHearingDate, this.nextHearingDate, this.remark);
  }

  CaseRecord withCaseDescription(String newValue) {
    return CaseRecord(this.clientName, newValue, this.filingDate,
        this.previousHearingDate, this.nextHearingDate, this.remark);
  }

  CaseRecord withRemark(String newValue) {
    return CaseRecord(this.clientName, this.caseDescription, this.filingDate,
        this.previousHearingDate, this.nextHearingDate, newValue);
  }
}
