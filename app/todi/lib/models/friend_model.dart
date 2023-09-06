class FriendModel {
  final String username, nickname;

  FriendModel.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        nickname = json['nickname'];
}
