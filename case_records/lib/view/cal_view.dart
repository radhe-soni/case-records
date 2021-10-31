

import 'package:case_records/controller/form_controller.dart';
import 'package:case_records/model/cal_data_source.dart';
import 'package:case_records/service/form_controller_factory.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CaseCalendar extends StatefulWidget {
  final GoogleSignInAccount googleSignInAccount;

  const CaseCalendar(
      {Key? key,  required this.googleSignInAccount})
      : super(key: key);

  @override
  _CaseCalendar createState() => _CaseCalendar();
}

class _CaseCalendar extends State<CaseCalendar>  {
  final log = Logger('_CaseCalendar');
  List<DayOverview> _daysOverview = [];
  @override
  void initState() {
    super.initState();
    print("initializing calendar view");
    fetchDaysOverviewForDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {

    return Container(
          margin: EdgeInsets.all(20),
          child: SfCalendar(
              view: CalendarView.month,
              dataSource: DayOverviewCalendarDataSource(_daysOverview),
              onViewChanged: fetchDaysOverview,
              monthCellBuilder: monthCellBuilder,
              showNavigationArrow: true
          ),
        );
  }

  void fetchDaysOverview(ViewChangedDetails viewChangedDetails){
    int index = (viewChangedDetails.visibleDates.length/2).toInt();
    DateTime monthAndYear = viewChangedDetails.visibleDates[index];
    fetchDaysOverviewForDate(monthAndYear);
  }

  void fetchDaysOverviewForDate(DateTime monthAndYear) {
    log.finest("fetchDaysOverview: monthAndYear => ${monthAndYear}");
    FormControllerFactory.FACTORY.getInstance(widget.googleSignInAccount)
        .then((FormController formController) {
      formController.fetchDaysOverview(monthAndYear, (List<DayOverview> response){
        setState((){
          _daysOverview = response;
        });
      });
    });
  }
}
