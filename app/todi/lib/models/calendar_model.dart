class CalendarModel {
  final String table_title, start, end;
  final int id;
  final int? checks;

  CalendarModel.fromJson(Map<String, dynamic> json)
      : table_title = json['table_title'],
        start = json['start_date'],
        end = json['end_date'],
        id = json['calendar_id'],
        checks = json['checks'];
}
