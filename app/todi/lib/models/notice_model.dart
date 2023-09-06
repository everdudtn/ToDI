class NoticeModel {
  final String title, content, date;

  NoticeModel.fromJson(Map<String, dynamic> json)
      : title = json['board_title'],
        content = json['board_content'],
        date = json['board_date'];
}
