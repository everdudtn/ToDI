class SearchFriendModel {
  final String username, nickname;

  SearchFriendModel.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        nickname = json['nickname'];
}
