import 'dart:async';
import 'dart:math' as math;
import 'package:case_records/controller/form_controller.dart';
import 'package:case_records/model/case_record.dart';
import 'package:case_records/service/form_controller_factory.dart';
import 'package:case_records/service/storage_service.dart';
import 'package:case_records/view/case_record_form.dart';
import 'package:case_records/view/case_records_view.dart';
import 'package:case_records/view/form_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert' as convert;

final Color PRIMARY_COLOR = Colors.lightGreen[900]!;
final String SHEET_ID = "1hIou3IG2sD4xvtfHaHceZfLmtvLjHRN2xi3ZqL4m2AQ";

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Home();
  }
}

class Home extends StatefulWidget {
  final AbstractStorage storage = FormControllerSingletonExtension.storage;

  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool dbInitialised = false;

  ValueNotifier<CaseRecord> _selectedRecord =
      ValueNotifier(CaseRecord.defaultRecord());

  // This widget is the root of your application.

  void modifySelectedRecord(CaseRecord selectedRecord) {
    _selectedRecord.value = selectedRecord;
  }

  Text createAppBar() {
    return Text("Case Record",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ));
  }

  TabBar createTabBar() {
    return TabBar(
      tabs: [
        Tab(icon: Icon(Icons.home)),
        Tab(icon: Icon(Icons.list_alt)),
      ],
    );
  }

  NestedScrollViewHeaderSliversBuilder createHeaderSliverBuilder() {
    return (BuildContext context, bool innerBoxIsScrolled) {
      return <Widget>[
        SliverAppBar(
          floating: true,
          pinned: true,
          snap: false,
          primary: true,
          forceElevated: innerBoxIsScrolled,
          title: createAppBar(),
          bottom: createTabBar(),
        )
      ];
    };
  }

  Widget getTabContent(tabChanger) {
    return TabBarView(
      // These are the contents of the tab views, below the tabs.
      children: <Widget>[
        CaseRecordForm(
            onChange: modifySelectedRecord, caseRecord: _selectedRecord),
        CaseRecords(onChange: tabChanger),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!dbInitialised) {
      widget.storage.readData().then((String dbData) {
        if (!["", null, false, 0].contains(dbData)) {
          setState(() {
            dbInitialised = true;
          });
        }
      });
      return AppScriptForm(onSubmit: () {
        setState(() {
          dbInitialised = true;
        });
      });
    }
    return MaterialApp(
        home: Material(
            child: Scaffold(
                body: DefaultTabController(
                    length: 2,
                    child: Builder(builder: (BuildContext innerContext) {
                      var tabChanger = (CaseRecord selectRecord) {
                        modifySelectedRecord(selectRecord);
                        DefaultTabController.of(innerContext)!.animateTo(0);
                      };
                      return NestedScrollView(
                        headerSliverBuilder: createHeaderSliverBuilder(),
                        body: getTabContent(tabChanger),
                      );
                    })))));
  }
}

class AppScriptForm extends StatefulWidget {
  final Function? onSubmit;
  const AppScriptForm({Key? key, this.onSubmit}) : super(key: key);
  @override
  _AppScriptFormState createState() => _AppScriptFormState();
}

class _AppScriptFormState extends State<AppScriptForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController appScriptUrlController =
      new TextEditingController();
  final TextEditingController sheetIdController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Material(
            child: Scaffold(
                body: Form(
                    key: _formKey,
                    child: Container(
                        margin: EdgeInsets.all(30),
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: Column(children: <Widget>[
                          TextFormField(
                            key: Key("app_script_url"),
                            controller: appScriptUrlController,
                            decoration: createInputDecoration("App Script URL"),
                            validator: (value) {
                              if (value == null || value == "")
                                return "App Script URL is Required";
                              return null;
                            },
                          ),
                          TextFormField(
                            key: Key("sheet_id"),
                            controller: sheetIdController,
                            decoration: createInputDecoration("Sheet ID"),
                            validator: (value) {
                              if (value == null || value == "")
                                return "Sheet Id is Required";
                              return null;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              child: const Text('Submit'),
                            ),
                          )
                        ]))))));
  }

  void _submitForm() async {
    // Validate returns true if the form is valid, or false
    // otherwise.
    if (_formKey.currentState!.validate()) {
      var appScriptUrl = appScriptUrlController.text;
      var sheetId = sheetIdController.text;
      dynamic dbData = {'appScriptUrl': appScriptUrl, 'sheetId': sheetId};
      await FormControllerSingletonExtension.storage
          .writeData(convert.jsonEncode(dbData))
          .then((any) {
            if(widget.onSubmit != null){
              widget.onSubmit!();
            }
      });
    }
  }
}
