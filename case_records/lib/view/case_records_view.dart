import 'dart:async';
import 'package:case_records/controller/form_controller.dart';
import 'package:case_records/model/case_record.dart';
import 'package:case_records/service/form_controller_factory.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CaseRecords extends StatefulWidget {
  final Function(CaseRecord caseRecord) onChange;
  final GoogleSignInAccount googleSignInAccount;
  const CaseRecords({Key? key, required this.onChange, required this.googleSignInAccount}) : super(key: key);

  @override
  _CaseRecordsState createState() => _CaseRecordsState();
}

class _CaseRecordsState extends State<CaseRecords> with RestorationMixin {
  final _formKey = GlobalKey<FormState>();

  late RestorableRouteFuture<DateTime> nextHearingDatePicker;
  final TextEditingController _selectedDateController =
      new TextEditingController();

  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments as int),
          firstDate: DateTime(2015, 1),
          lastDate: DateTime(2100),
        );
      },
    );
  }

  @override
  String get restorationId => 'case_records_list';

  @override
  void initState() {
    super.initState();
    print("initializing records view");
    nextHearingDatePicker = RestorableRouteFuture<DateTime>(
      onComplete: _fetchCaseRecords,
      onPresent: (navigator, arguments) {
        return navigator.restorablePush(
          _datePickerRoute,
          arguments: DateTime.now().millisecondsSinceEpoch,
        );
      },
    );
  }

  List<TableRow> tableRows = [];

  void _fetchCaseRecords(DateTime? selectedDate) {
    setState(() {
      tableRows = [];
    });
    if (selectedDate != null) {
      List<CaseRecord> caseRecords = [];
      String filterDate = "${selectedDate.toLocal()}".split(' ')[0];
      setState(() {
        _selectedDateController.text = filterDate;
      });
      FormControllerSingletonExtension.getInstance(widget.googleSignInAccount)
          .then((FormController formController) {
        formController.fetchRecords(filterDate, (List<CaseRecord> response) {
          caseRecords.addAll(response);
          List<TableRow> trs = [];
          if(caseRecords.isNotEmpty){
            trs = [tableHeader()];
            trs.addAll(
                caseRecords
                    .asMap()
                    .entries
                    .map((entry) =>
                    tableRowFromCaseRecord(entry.key, entry.value))
                    .toList());
          }
          else{
            trs = [TableRow(
                children: <Widget>[
                  TableCell(
                    child: Text("No Records Found!!!",
                        textAlign: TextAlign.center),
                  )])];
          }

          setState(() {
            tableRows = trs;
          });
        });
      });
    }
  }

  TableRow tableHeader() {
    TextStyle headerStyle = TextStyle(fontWeight: FontWeight.bold);
    return TableRow(
      children: <Widget>[
        TableCell(
          child: Text("S.No.",
              style: headerStyle, textAlign: TextAlign.center),
        ),
        TableCell(
          child: Text("Client Name",
              style: headerStyle, textAlign: TextAlign.center),
        ),
        TableCell(
          child: Text("Case Description",
              style: headerStyle, textAlign: TextAlign.center),
        ),
        TableCell(
          child: Text("Filing Date",
              style: headerStyle, textAlign: TextAlign.center),
        ),
        TableCell(
          child: Text("Previous Hearing Date",
              style: headerStyle, textAlign: TextAlign.center),
        ),
        TableCell(
          child:
              Text("Remark", style: headerStyle, textAlign: TextAlign.center),
        ),
        TableCell(
          child:
              Text("Action", style: headerStyle, textAlign: TextAlign.center),
        ),
      ],
    );
  }

  TableRow tableRowFromCaseRecord(int index, CaseRecord caseRecord) {
    return TableRow(
      children: <Widget>[
        TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text((index+1).toString())),
        ),
        TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(caseRecord.clientName)),
        ),
        TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(caseRecord.caseDescription)),
        ),
        TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(caseRecord.filingDate.split('T')[0])),
        ),
        TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(caseRecord.previousHearingDate.split('T')[0])),
        ),
        TableCell(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(caseRecord.remark),
        )),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: TextButton(
              onPressed: () {
                widget.onChange(caseRecord);
              },
              child: const Text('Edit'),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(
      nextHearingDatePicker,
      'next_hearing_date_picker',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
            child: Column(
          children: <Widget>[
            TextField(readOnly: true, controller: _selectedDateController),
            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Table(
                      columnWidths: {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(3),
                        2: FlexColumnWidth(8),
                        3: FlexColumnWidth(2),
                        4: FlexColumnWidth(2),
                        5: FlexColumnWidth(8),
                        6: FlexColumnWidth(1),
                      },
                      border: TableBorder.all(),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: tableRows,
                    ),
                  ),
                ])),
            FloatingActionButton.extended(
              onPressed: () {
                nextHearingDatePicker.present();
              },
              icon: Icon(Icons.download),
              label: Text("Fetch Records"),
            ),
          ],
        )));
  }
}
