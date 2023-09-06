class DiaryModel {
  final String title, content, diaryDate;
  final String? image;
  final int id;
  // final DateTime diaryDate;

  DiaryModel.fromJson(Map<String, dynamic> json)
      : id = json['diary_id'],
        title = json['title'],
        content = json['content'],
        diaryDate = json['diary_date'],
        image = json['diary_image'];
}
