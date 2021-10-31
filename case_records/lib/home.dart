import 'package:case_records/controller/create_sheet_controller.dart';
import 'package:case_records/model/case_record.dart';
import 'package:case_records/service/form_controller_factory.dart';
import 'package:case_records/service/storage_service.dart';
import 'package:case_records/view/cal_view.dart';
import 'package:case_records/view/case_record_form.dart';
import 'package:case_records/view/case_records_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import 'dart:convert' as convert;

class Home extends StatefulWidget {
  final AbstractStorage storage = FormControllerSingletonExtension.storage;
  final GoogleSignInAccount googleSignInAccount;

  Home({Key? key, required this.googleSignInAccount}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool dbInitialised = false;
  final log = Logger('_HomeState');
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
        Tab(icon: Icon(Icons.calendar_view_month)),
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
            onChange: modifySelectedRecord, caseRecord: _selectedRecord, googleSignInAccount: widget.googleSignInAccount),
        CaseRecords(onChange: tabChanger, googleSignInAccount: widget.googleSignInAccount),
        CaseCalendar(googleSignInAccount: widget.googleSignInAccount)
      ],
    );
  }

  void setDBInitializedStatus(bool status) {
    setState(() {
      dbInitialised = status;
    });
  }
  void _storeSheetId(sheetId) async {
    // Validate returns true if the form is valid, or false
    // otherwise.
      dynamic dbData = {'sheetId': sheetId};
      await FormControllerSingletonExtension.storage
          .writeData(convert.jsonEncode(dbData));
  }

  Future<void> _fetchSheetId() async{
    log.info("Fetching sheet Id");
      SheetController controller = await SheetControllerSingletonExtension.instance(widget.googleSignInAccount);
      controller.createSheet(_storeSheetId);
  }
  @override
  void initState() {
    super.initState();
    
    if (!dbInitialised) {
      widget.storage.readData().then((String dbData) {
        if (!["", null, false, 0].contains(dbData)) {
          setDBInitializedStatus(true);
        }
      });
      _fetchSheetId().whenComplete(() => setDBInitializedStatus(true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Material(
            child: Scaffold(
                body: DefaultTabController(
                    length: 3,
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
