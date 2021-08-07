import 'dart:async';
import 'dart:math' as math;
import 'package:case_records/controller/form_controller.dart';
import 'package:case_records/model/case_record.dart';
import 'package:case_records/view/case_record_form.dart';
import 'package:case_records/view/case_records_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

final Color PRIMARY_COLOR = Colors.lightGreen[900]!;
final String SHEET_ID = "1hIou3IG2sD4xvtfHaHceZfLmtvLjHRN2xi3ZqL4m2AQ";

void main() {
  runApp(Home());
}

class Home extends StatelessWidget {
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
            onChange: modifySelectedRecord,
            caseRecord: _selectedRecord),
        CaseRecords(onChange: tabChanger),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
