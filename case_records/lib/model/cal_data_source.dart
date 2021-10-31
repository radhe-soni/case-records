

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class DayOverviewCalendarDataSource extends CalendarDataSource{
  DayOverviewCalendarDataSource(List<DayOverview> daysOverview){
    appointments = daysOverview;
  }
  @override
  DateTime getStartTime(int index) {
    return appointments![index].date;
  }
  @override
  Color getColor(int index) {
    return appointments![index].background;
  }
  @override
  DateTime getEndTime(int index) {
    return appointments![index].date;
  }
  @override
  bool isAllDay(int index) {
    return true;
  }
}
const Map<int, Color> COLOR_MAP = {
  1: Colors.lightGreenAccent,
  3: Colors.lightGreen,
  4: Colors.amber,
  5: Colors.orangeAccent,
  6: Colors.redAccent,
  7: Colors.red
};
class DayOverview {
  final int numberOfCases;
  final DateTime date;
  DayOverview({this.numberOfCases=0, required this.date });
  Color get background {
    switch(numberOfCases){
      case 2: return COLOR_MAP[3]!;
      case 3: return COLOR_MAP[3]!;
      default: {
        if(numberOfCases >= 7){
          return COLOR_MAP[7]!;
        }
        return COLOR_MAP[numberOfCases]!;
      }
    }
  }
  static DayOverview from(List<Object> entry){
    return DayOverview(numberOfCases:int.parse(entry[0].toString()), date: DateTime.parse(entry[1].toString()));
  }


}

Widget monthCellBuilder(
    BuildContext buildContext, MonthCellDetails details) {
  final Color backgroundColor = details.appointments.length > 0? (details.appointments[0] as DayOverview).background: Colors.white;
  final Color defaultColor = Colors.white;
  return Container(
    decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: defaultColor, width: 0.5),
        shape: BoxShape.circle,
    ),

    child: Center(
      child: Text(
        details.date.day.toString(),
        style: TextStyle(backgroundColor: backgroundColor),
      ),
    ),
  );
}