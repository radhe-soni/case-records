import 'package:case_records/controller/form_controller.dart';
import 'package:case_records/model/case_record.dart';
import 'package:case_records/service/form_controller_factory.dart';
import 'package:case_records/view/form_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CaseRecords extends StatefulWidget {
  final Function(CaseRecord caseRecord) onChange;
  final GoogleSignInAccount googleSignInAccount;

  const CaseRecords(
      {Key? key, required this.onChange, required this.googleSignInAccount})
      : super(key: key);

  @override
  _CaseRecordsState createState() => _CaseRecordsState();
}

class _CaseRecordsState extends State<CaseRecords> with RestorationMixin {

  late RestorableRouteFuture<DateTime> nextHearingDatePicker;
  final TextEditingController _selectedDateController =
      new TextEditingController();
  final TextEditingController _clientNameController =
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
      String filterDate = "${selectedDate.toLocal()}".split(' ')[0];
      setState(() {
        _selectedDateController.text = filterDate;
      });
      FormControllerFactory.FACTORY.getInstance(widget.googleSignInAccount)
          .then((FormController formController) {
        formController.fetchRecords(filterDate, (List<CaseRecord> response) {
          fillRecordsInTable(response);
        });
      });
    }
  }

  void fillRecordsInTable(List<CaseRecord> caseRecords) {
    List<TableRow> trs = [];
    if (caseRecords.isNotEmpty) {
      trs = [tableHeader()];
      trs.addAll(caseRecords
          .asMap()
          .entries
          .map((entry) => tableRowFromCaseRecord(entry.key, entry.value))
          .toList());
    } else {
      trs = [
        TableRow(children: <Widget>[
          TableCell(
            child:
                Text("No Records Found!!!", textAlign: TextAlign.center),
          )
        ])
      ];
    }

    setState(() {
      tableRows = trs;
    });
  }

  TableRow tableHeader() {
    TextStyle headerStyle = TextStyle(fontWeight: FontWeight.bold);
    return TableRow(
      children: <Widget>[
        TableCell(
          child: Text("S.No.", style: headerStyle, textAlign: TextAlign.center),
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

  static const PADDING_CELL = 1.0;

  TableRow tableRowFromCaseRecord(int index, CaseRecord caseRecord) {
    return TableRow(
      children: <Widget>[
        TableCell(
          child: Padding(
              padding: const EdgeInsets.all(PADDING_CELL),
              child: Text((index + 1).toString())),
        ),
        TableCell(
          child: Padding(
              padding: const EdgeInsets.all(PADDING_CELL),
              child: Text(caseRecord.clientName)),
        ),
        TableCell(
          child: Padding(
              padding: const EdgeInsets.all(PADDING_CELL),
              child: Text(caseRecord.caseDescription)),
        ),
        TableCell(
          child: Padding(
              padding: const EdgeInsets.all(PADDING_CELL),
              child: Text(caseRecord.filingDate.split('T')[0])),
        ),
        TableCell(
          child: Padding(
              padding: const EdgeInsets.all(PADDING_CELL),
              child: Text(caseRecord.previousHearingDate.split('T')[0])),
        ),
        TableCell(
            child: Padding(
          padding: const EdgeInsets.all(PADDING_CELL),
          child: Text(caseRecord.remark),
        )),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: PADDING_CELL),
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

  _table() {
    return Container(
      width: 600.0,
      margin: EdgeInsets.all(10),
      child: Table(
        columnWidths: {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(6),
          3: FlexColumnWidth(4),
          4: FlexColumnWidth(4),
          5: FlexColumnWidth(5),
          6: FlexColumnWidth(2),
        },
        border: TableBorder.all(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: tableRows,
      ),
    );
  }

  bool isNameSearch = false;

  @override
  Widget build(BuildContext context) {
    FocusNode nameNode = new FocusNode();

    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            SwitchListTile(
                title: isNameSearch? const Text('Name Search') : const Text('Date Search'),
                value: isNameSearch,
                onChanged: (check) {
                  setState(() {
                    isNameSearch = check;
                    if(check){
                      FocusScope.of(context).requestFocus(nameNode);
                    }
                  });
                }),
            TextField(
                focusNode: nameNode,
                decoration: isNameSearch
                ? createLeadingTextInputDecoration("Client Name")
                : createLeadingTextInputDecoration("Filing Date"),
                controller: isNameSearch
                    ? _clientNameController
                    : _selectedDateController),
            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                  _table(),
                ])),
            TextButton(
              onPressed: () {
                if (isNameSearch)
                  _fetchCaseRecordsByName();
                  else
                    nextHearingDatePicker.present();
              },
              child: Text("Fetch Records"),
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  primary: Colors.white,
                  textStyle: const TextStyle(fontSize: 20),
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.8)),
              // icon: Icon(Icons.download),
            ),
          ],
        ));
  }

  void _fetchCaseRecordsByName() {
    setState(() {
      tableRows = [];
    });
    String clientName = _clientNameController.text;
    if (clientName.isNotEmpty) {

      FormControllerFactory.FACTORY.getInstance(widget.googleSignInAccount)
          .then((FormController formController) {
        formController.fetchRecordsByName(clientName, (List<CaseRecord> response) {
          fillRecordsInTable(response);
        });
      });
    }
  }
}
