import 'dart:async';
import 'package:case_records/controller/form_controller.dart';
import 'package:case_records/model/case_record.dart';
import 'package:flutter/material.dart';

class CaseRecords extends StatefulWidget {
  final Function(CaseRecord caseRecord) onChange;

  const CaseRecords({Key? key, required this.onChange}) : super(key: key);

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
    FormController formController = FormController();
    if (selectedDate != null) {
      List<CaseRecord> caseRecords = [];
      String filterDate = "${selectedDate.toLocal()}".split(' ')[0];
      setState(() {
        _selectedDateController.text = filterDate;
      });
      formController.fetchRecords(filterDate, (response) {
        for (int i = 0; i < response.length; i++) {
          caseRecords.add(CaseRecord.fromJson(response[i]));
        }
        List<TableRow> trs = [tableHeader()];
        trs.addAll(
            caseRecords.map((rec) => tableRowFromCaseRecord(rec)).toList());
        print(caseRecords);
        setState(() {
          tableRows = trs;
        });
      });
    }
  }

  TableRow tableHeader() {
    TextStyle headerStyle = TextStyle(fontWeight: FontWeight.bold);
    return TableRow(
      children: <Widget>[
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
              Text("Action", style: headerStyle, textAlign: TextAlign.center),
        ),
      ],
    );
  }

  TableRow tableRowFromCaseRecord(CaseRecord caseRecord) {
    return TableRow(
      children: <Widget>[
        TableCell(
          child: Text(caseRecord.clientName),
        ),
        TableCell(
          child: Text(caseRecord.caseDescription),
        ),
        TableCell(
          child: Text(caseRecord.filingDate.split('T')[0]),
        ),
        TableCell(
          child: Text(caseRecord.previousHearingDate.split('T')[0]),
        ),
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
