import 'dart:async';
import 'package:case_records/controller/form_controller.dart';
import 'package:case_records/model/case_record.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final Color PRIMARY_COLOR = Colors.lightGreen[900]!;

class CaseRecordForm extends StatefulWidget {
  final Function(CaseRecord caseRecord) onChange;
  final ValueListenable<CaseRecord> caseRecord;

  CaseRecordForm({Key? key, required this.onChange, required this.caseRecord})
      : super(key: key);

  @override
  _CaseRecordFormState createState() => _CaseRecordFormState();
}

class _CaseRecordFormState extends State<CaseRecordForm> with RestorationMixin {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final _formLabelStyle = TextStyle(
    color: Colors.black87,
    fontSize: 17,
    fontWeight: FontWeight.bold,
  );
  final _focusedBorder = UnderlineInputBorder(
    borderSide: BorderSide(color: PRIMARY_COLOR, width: 2.0),
  );
  final _enabledBorder = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 1.0));

  InputDecoration createInputDecoration(String label) {
    return InputDecoration(
        labelText: label,
        labelStyle: _formLabelStyle,
        focusedBorder: _focusedBorder,
        enabledBorder: _enabledBorder);
  }

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

  final TextEditingController _clientNameController =
      new TextEditingController();
  final TextEditingController _caseDescriptionController =
      new TextEditingController();
  final TextEditingController _fileDateController = new TextEditingController();
  final TextEditingController _previousDateController =
      new TextEditingController();
  final TextEditingController _nextDateController = new TextEditingController();
  final RestorableDateTime _filingDate = RestorableDateTime(DateTime.now());
  final RestorableDateTime _previousDate = RestorableDateTime(DateTime.now());
  final RestorableDateTime _nextDate = RestorableDateTime(DateTime.now());
  late RestorableRouteFuture<DateTime> filingDatePicker;
  late RestorableRouteFuture<DateTime> previousDatePicker;
  late RestorableRouteFuture<DateTime> nextHearingDatePicker;

  @override
  String get restorationId => 'case_record_form';

  @override
  void initState() {
    super.initState();

    filingDatePicker = RestorableRouteFuture<DateTime>(
      onComplete: _selectFilingDate,
      onPresent: (navigator, arguments) {
        return navigator.restorablePush(
          _datePickerRoute,
          arguments: _filingDate.value.millisecondsSinceEpoch,
        );
      },
    );
    previousDatePicker = RestorableRouteFuture<DateTime>(
      onComplete: _selectPreviousDate,
      onPresent: (navigator, arguments) {
        return navigator.restorablePush(
          _datePickerRoute,
          arguments: _previousDate.value.millisecondsSinceEpoch,
        );
      },
    );
    nextHearingDatePicker = RestorableRouteFuture<DateTime>(
      onComplete: _selectNextHearingDate,
      onPresent: (navigator, arguments) {
        return navigator.restorablePush(
          _datePickerRoute,
          arguments: _nextDate.value.millisecondsSinceEpoch,
        );
      },
    );
    CaseRecord caseRecord = widget.caseRecord.value;
    _clientNameController.text = caseRecord.clientName;
    _caseDescriptionController.text = caseRecord.caseDescription;
    _fileDateController.text = caseRecord.filingDate;
    _previousDateController.text = caseRecord.previousHearingDate;
    _nextDateController.text = caseRecord.nextHearingDate;
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_filingDate, 'filing_date');
    registerForRestoration(_previousDate, 'previous_date');
    registerForRestoration(_nextDate, 'next_hearing_date');
    registerForRestoration(
      filingDatePicker,
      'filing_date_picker',
    );
    registerForRestoration(
      previousDatePicker,
      'previous_date_picker',
    );
    registerForRestoration(
      nextHearingDatePicker,
      'next_hearing_date_picker',
    );
  }

  void _selectFilingDate(DateTime? selectedDate) {
    if (selectedDate != null && selectedDate != _filingDate.value) {
      print("selected date is ${selectedDate}");
      String newValue = "${selectedDate.toLocal()}".split(' ')[0];
      widget.onChange(widget.caseRecord.value.withFilingDate(newValue));
      setState(() {
        _filingDate.value = selectedDate;
        _fileDateController.text = widget.caseRecord.value.filingDate;
      });
    }
  }

  void _selectPreviousDate(DateTime? selectedDate) {
    if (selectedDate != null && selectedDate != _previousDate.value) {
      print("selected date is ${selectedDate}");
      String newValue = "${selectedDate.toLocal()}".split(' ')[0];
      widget
          .onChange(widget.caseRecord.value.withPreviousHearingDate(newValue));
      setState(() {
        _previousDate.value = selectedDate;
        _previousDateController.text =
            widget.caseRecord.value.previousHearingDate;
      });
    }
  }

  void _selectNextHearingDate(DateTime? selectedDate) {
    if (selectedDate != null && selectedDate != _nextDate.value) {
      print("selected date is ${selectedDate}");
      String newValue = "${selectedDate.toLocal()}".split(' ')[0];
      widget.onChange(widget.caseRecord.value.withNextHearingDate(newValue));
      setState(() {
        _nextDate.value = selectedDate;
        _nextDateController.text = widget.caseRecord.value.nextHearingDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.all(30),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: Column(children: <Widget>[
              TextFormField(
                key: Key("client_name"),
                controller: _clientNameController,
                decoration: createInputDecoration("Client Name"),
                validator: (value) {
                  if(value == null || value == "")
                    return "Client Name is Required";
                  return null;
                },
                onChanged: (newValue) => widget
                    .onChange(widget.caseRecord.value.withClientName(newValue)),
              ),
              TextFormField(
                  key: Key("case_description"),
                  controller: _caseDescriptionController,
                  decoration: createInputDecoration("Case Description"),
                  validator: (value) {
                    return null;
                  },
                  onChanged: (newValue) => widget.onChange(
                      widget.caseRecord.value.withCaseDescription(newValue))),
              TextFormField(
                key: Key("case_filed_date"),
                controller: _fileDateController,
                decoration: createInputDecoration("Case Filed Date"),
                validator: (value) {
                  return null;
                },
                onTap: () {
                  filingDatePicker.present();
                },
              ),
              TextFormField(
                key: Key("previous_hearing_date"),
                controller: _previousDateController,
                decoration: createInputDecoration("Previous Hearing Date"),
                validator: (value) {
                  return null;
                },
                onTap: () {
                  previousDatePicker.present();
                },
              ),
              TextFormField(
                key: Key("next_hearing_date"),
                controller: _nextDateController,
                decoration: createInputDecoration("Next Hearing Date"),
                validator: (value) {
                  return null;
                },
                onTap: () {
                  nextHearingDatePicker.present();
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _submitForm ,
                  child: const Text('Submit'),
                ),
              )
            ]),
          ),
        ));
  }

  void _submitForm() async{
    // Validate returns true if the form is valid, or false
    // otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, proceed.
      CaseRecord feedbackForm = widget.caseRecord.value;
      clearForm();
      FormController formController = FormController();

      _showSnackbar("Submitting Feedback");

      // Submit 'feedbackForm' and save it in Google Sheets.
      formController.submitForm(feedbackForm, (String response) {
        print("Response: $response");
        if (response == FormController.STATUS_SUCCESS) {
          // Feedback is saved succesfully in Google Sheets.
          showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: const Text('Record Saved'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {

                          Navigator.pop(context, 'OK');
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ));
        } else {
          // Error Occurred while saving data in Google Sheets.
          _showSnackbar("Error Occurred!");
        }
      });
    }
  }

  void clearForm(){
    setState(() {
      widget.onChange(CaseRecord.defaultRecord());
      _filingDate.value = DateTime.now();
      _fileDateController.text = widget.caseRecord.value.filingDate;
      _previousDate.value = DateTime.now();
      _previousDateController.text =
          widget.caseRecord.value.previousHearingDate;
      _nextDate.value = DateTime.now();
      _nextDateController.text = widget.caseRecord.value.nextHearingDate;
      _clientNameController.text = "";
      _caseDescriptionController.text= "";

    });
  }

  _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    if (_scaffoldKey.currentState != null)
      _scaffoldKey.currentState!.showSnackBar(snackBar);
  }
}
