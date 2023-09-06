import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:todi/models/calendar_model.dart';
import 'package:todi/services/api_service.dart';

class FriendCalendar extends StatefulWidget {
  final String nickname;
  const FriendCalendar({Key? key, required this.nickname}) : super(key: key);

  @override
  State<FriendCalendar> createState() => FriendCalendarState();
}

class FriendCalendarState extends State<FriendCalendar> {
  List<Meeting> showCalendarList = [];

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    showCalendarList = await getCalendarList();

    setState(() {});
  }

  void refreshData() async {
    showCalendarList = await getCalendarList();
    setState(() {});
  }

  Future<List<Meeting>> getCalendarList() async {
    ApiService api = ApiService();

    String myname = widget.nickname;
    List<CalendarModel> calendarList = await api.getCalendar(myname);

    List<Meeting> meetings = [];
    for (var calendar in calendarList) {
      meetings.add(Meeting(
        calendar.table_title,
        DateTime.parse(calendar.start),
        DateTime.parse(calendar.end),
        Colors.amber.shade300,
        false,
      ));
    }

    return meetings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF99F),
      ),
      body: SfCalendar(
        view: CalendarView.month,
        dataSource: MeetingDataSource(showCalendarList),
        monthViewSettings: const MonthViewSettings(
          showAgenda: true,
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        ),
        headerDateFormat: "yyyy년 M월",
        appointmentTimeTextFormat: 'HH:mm',
        todayHighlightColor: Colors.amber.shade300,
        headerStyle: const CalendarHeaderStyle(
          textAlign: TextAlign.center,
          textStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        appointmentTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headerHeight: 80,
        showNavigationArrow: true,
        showTodayButton: true,
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
