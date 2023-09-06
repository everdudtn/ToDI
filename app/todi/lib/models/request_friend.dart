class RequestFriendModel {
  final int id;
  final Profile sender;
  final Profile receiver;
  final String status;

  RequestFriendModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        sender = Profile.fromJson(json['sender']),
        receiver = Profile.fromJson(json['receiver']),
        status = json['status'];
}

class Profile {
  final int id;
  final String nickname;
  // final String image;
  final String username;

  Profile.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        nickname = json['nickname'],
        // image = json['image'],
        username = json['username'];
}
