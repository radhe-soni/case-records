class CaseRecord {
  final String clientName;
  final String caseDescription;
  final String filingDate;
  final String previousHearingDate;
  final String nextHearingDate;

  CaseRecord(this.clientName, this.caseDescription, this.filingDate, this.previousHearingDate, this.nextHearingDate);


  factory CaseRecord.fromJson(dynamic json) {
    return CaseRecord("${json['clientName']}", "${json['caseDescription']}",
        "${json['filingDate']}", "${json['previousHearingDate']}", "${json['nextHearingDate']}");
  }

  factory CaseRecord.defaultRecord(){
    String defaultDate = "${DateTime.now().toLocal()}".split(' ')[0];
    return CaseRecord("", "", defaultDate, defaultDate, defaultDate);
  }
  // Method to make GET parameters.
  Map toJson() => {
    'clientName': clientName,
    'caseDescription': caseDescription,
    'filingDate': filingDate,
    'previousHearingDate': previousHearingDate,
    'nextHearingDate': nextHearingDate
  };

  CaseRecord withFilingDate(String newValue) {
    return CaseRecord(this.clientName, this.caseDescription, newValue, this.previousHearingDate, this.nextHearingDate);
  }

  CaseRecord withPreviousHearingDate(String newValue) {
    return CaseRecord(this.clientName, this.caseDescription, this.filingDate, newValue, this.nextHearingDate);
  }

  CaseRecord withNextHearingDate(String newValue) {
    return CaseRecord(this.clientName, this.caseDescription, this.filingDate, this.previousHearingDate, newValue);
  }

  CaseRecord withClientName(String newValue) {
    return CaseRecord(newValue, this.caseDescription, this.filingDate, this.previousHearingDate, this.nextHearingDate);
  }

  CaseRecord withCaseDescription(String newValue) {
    return CaseRecord(this.clientName, newValue, this.filingDate, this.previousHearingDate, this.nextHearingDate);
  }
}
