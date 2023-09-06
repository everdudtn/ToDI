class WiseSayingModel {
  final String author, message;

  WiseSayingModel.fromJson(Map<String, dynamic> json)
      : author = json['author'],
        message = json['message'];
}
