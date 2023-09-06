import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:todi/models/calendar_model.dart';
import 'package:todi/models/diary_model.dart';
import 'package:todi/models/friend_model.dart';
import 'package:todi/models/notice_model.dart';
import 'package:todi/models/request_friend.dart';
import 'package:todi/models/search_friend_model.dart';

const storage = FlutterSecureStorage();

class ApiService {
  //서버 주소에 맞게 변경
  final String baseUrl = 'http://localhost:8000/ToDI';

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/user_login/'); // 로그인 URL
    final headers = {'Content-Type': 'application/json'};
    final body =
        jsonEncode({'username': username, 'password': password}); // 요청 본문

    try {
      final response = await http.post(url, headers: headers, body: body);
      print(body);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        print(responseData);
        final access = responseData['access_token'];
        final refresh = responseData['refresh_token'];
        final username = responseData['username'];
        final nickname = responseData['nickname'];
        // SecureStorage 인스턴스 생성
        // const storage = FlutterSecureStorage();
        // // access_token과 refresh_token을 저장

        await storage.write(key: 'access_token', value: access);
        await storage.write(key: 'refresh_token', value: refresh);
        await storage.write(key: 'username', value: username);
        await storage.write(key: 'nickname', value: nickname);
        return true; // 로그인 성공
      } else {
        return false; // 로그인 실패
      }
    } catch (e) {
      // 예외 발생 (네트워크 오류 등)
      return false; // 로그인 실패
    }
  }

  Future<bool> auth(String username, String password, String phone) async {
    final url = Uri.parse('$baseUrl/signup/'); // 로그인 URL
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'username': username,
      'password': password,
      'phone_number': phone
    }); // 요청 본문
    print(body);
    try {
      print(url);
      final response = await http.post(url, headers: headers, body: body);
      print(response.statusCode);
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('회원가입');
        print(responseData);
        final access = responseData['access_token'];
        final refresh = responseData['refresh_token'];
        final username = responseData['username'];
        print(username);
        // SecureStorage 인스턴스 생성
        // const storage = FlutterSecureStorage();
        // // access_token과 refresh_token을 저장

        await storage.write(key: 'access_token', value: access);
        await storage.write(key: 'refresh_token', value: refresh);
        await storage.write(key: 'username', value: username);

        return true; // 로그인 성공
      } else {
        return false; // 로그인 실패
      }
    } catch (e) {
      // 예외 발생 (네트워크 오류 등)
      return false; // 로그인 실패
    }
  }

  Future<bool> phoneAuth(String phone, String vertification) async {
    final url = Uri.parse('$baseUrl/login_with_verification/'); // 로그인 URL
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'phone_number': phone,
      'verification_code': vertification,
    }); // 요청 본문
    print(body);
    try {
      print(url);
      final response = await http.post(url, headers: headers, body: body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        final username = responseData['username'];
        print(username);

        await storage.write(key: 'username', value: username);
        return true; // 로그인 성공
      } else {
        return false; // 로그인 실패
      }
    } catch (e) {
      // 예외 발생 (네트워크 오류 등)
      return false; // 로그인 실패
    }
  }

  Future<bool> setProfile(String username, String nickname) async {
    final url = Uri.parse('$baseUrl/users/'); // 로그인 URL
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'username': username,
      'nickname': nickname,
    }); // 요청 본문
    print(body);
    try {
      print(url);
      final response = await http.post(url, headers: headers, body: body);
      print(response.statusCode);
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print(responseData);
        await storage.write(key: 'nickname', value: nickname);

        return true; // 로그인 성공
      } else {
        return false; // 로그인 실패
      }
    } catch (e) {
      // 예외 발생 (네트워크 오류 등)
      return false; // 로그인 실패
    }
  }

  Future<List> getProfile(String username) async {
    final url = Uri.parse('$baseUrl/users/?username=$username');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        print(responseData[0]['nickname']);
        // String message = responseData["nickname"];

        // print(message);
        return responseData;
      } else {
        return [];
      }
    } catch (e) {
      // 예외 발생 (네트워크 오류 등)
      return [];
    }
  }

  Future<bool> putProfile(String username, String nickname) async {
    final url = Uri.parse('$baseUrl/users/'); // 로그인 URL
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'username': username,
      'nickname': nickname,
    }); // 요청 본문
    print(body);
    try {
      print(url);
      final response = await http.put(url, headers: headers, body: body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        await storage.write(key: 'nickname', value: nickname);

        return true; // 로그인 성공
      } else {
        return false; // 로그인 실패
      }
    } catch (e) {
      // 예외 발생 (네트워크 오류 등)
      return false; // 로그인 실패
    }
  }

  Future<bool> postCalendar(
      String title, String start, String end, String nickname) async {
    final url = Uri.parse('$baseUrl/calendars/');
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      "table_title": title,
      "start_date": start,
      "end_date": end,
      "nickname": nickname,
      "checks": 0,
    });
    print(url);
    print(body);
    try {
      final response = await http.post(url, headers: headers, body: body);
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print(responseData);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCalendar(int id) async {
    final url = Uri.parse('$baseUrl/calendars/?calendar_id=$id');
    final headers = {'Content-Type': 'application/json'};

    // final body = jsonEncode({"calendar_id": id});
    print(url);
    // print(body);
    try {
      final response = await http.delete(url, headers: headers);
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 204) {
        // final responseData = json.decode(response.body);
        // print(responseData);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> putCalendar(
      String title, String start, String end, String nickname, int id) async {
    final url = Uri.parse('$baseUrl/calendars/?calendar_id=$id');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'table_title': title,
      'start_date': start,
      'end_date': end,
      'nickname': nickname,
      // 'checks': 1,
    }); // 요청 본문
    print(body);
    try {
      print(url);
      final response = await http.put(url, headers: headers, body: body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);

        return true; // 로그인 성공
      } else {
        return false; // 로그인 실패
      }
    } catch (e) {
      // 예외 발생 (네트워크 오류 등)
      return false; // 로그인 실패
    }
  }

  Future<bool> checkCalendar(String title, String start, String end,
      String nickname, int id, int checked) async {
    final url = Uri.parse('$baseUrl/calendars/?calendar_id=$id');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'table_title': title,
      'start_date': start,
      'end_date': end,
      'nickname': nickname,
      'checks': checked,
    }); // 요청 본문
    print(body);
    try {
      print(url);
      final response = await http.put(url, headers: headers, body: body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);

        return true; // 로그인 성공
      } else {
        return false; // 로그인 실패
      }
    } catch (e) {
      // 예외 발생 (네트워크 오류 등)
      return false; // 로그인 실패
    }
  }

  Future<List<CalendarModel>> getCalendar(String nickname) async {
    List<CalendarModel> calendarInstances = [];
    final url = Uri.parse('$baseUrl/calendars/?nickname=$nickname');
    final response = await http.get(url);
    print(url);

    if (response.statusCode == 200) {
      final List<dynamic> calendars =
          jsonDecode(utf8.decode(response.bodyBytes));
      for (var calendar in calendars) {
        calendarInstances.add(CalendarModel.fromJson(calendar));
      }
      return calendarInstances;
    } else {
      return [];
    }
  }

  Future<List<SearchFriendModel>> searchUser(String? friendName) async {
    List<SearchFriendModel> userInstances = [];
    if (friendName != '') {
      final url = Uri.parse('$baseUrl/user/?nickname=$friendName');
      print(url);

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> friends =
            json.decode(utf8.decode(response.bodyBytes));
        for (var friend in friends) {
          userInstances.add(SearchFriendModel.fromJson(friend));
        }
        return userInstances;
      }
      throw Exception('Failed to fetch data from the API');
    } else {
      return [];
    }
  }

  Future<List<FriendModel>> getFriendList(String username) async {
    List<FriendModel> friendInstances = [];
    final url = Uri.parse('$baseUrl/accepts/$username');
    final response = await http.get(url);
    print(url);

    if (response.statusCode == 200) {
      final List<dynamic> friends = jsonDecode(utf8.decode(response.bodyBytes));
      for (var friend in friends) {
        friendInstances.add(FriendModel.fromJson(friend));
      }
      return friendInstances;
    } else {
      return [];
    }
  }

  Future<bool> sendFriendRequest(String sender, String receiver) async {
    final url = Uri.parse('$baseUrl/send_friend_request/'); // 로그인 URL
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(
        {'sender_username': sender, 'receiver_username': receiver}); // 요청 본문

    try {
      final response = await http.post(url, headers: headers, body: body);
      print(response.body);
      if (response.statusCode == 200) {
        return true; // 로그인 성공
      } else {
        return false; // 로그인 실패
      }
    } catch (e) {
      // 예외 발생 (네트워크 오류 등)
      return false; // 로그인 실패
    }
  }

  Future<List<RequestFriendModel>> requestFriendList(String username) async {
    List<RequestFriendModel> requestInstances = [];
    final url = Uri.parse('$baseUrl/pending/$username');
    print(url);
    final response = await http.get(url);
    // print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> friends =
          json.decode(utf8.decode(response.bodyBytes));
      for (var friend in friends) {
        requestInstances.add(RequestFriendModel.fromJson(friend));
      }
      return requestInstances;
    } else {
      return [];
    }
  }

  Future<bool> friendRequestAccept(String username, String sender) async {
    final url = Uri.parse('$baseUrl/friend_accept/$username/'); // 로그인 URL
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'sender_username': sender}); // 요청 본문
    print(body);

    try {
      final response = await http.put(url, headers: headers, body: body);
      print(response.body);
      if (response.statusCode == 200) {
        return true; // 로그인 성공
      } else {
        return false; // 로그인 실패
      }
    } catch (e) {
      // 예외 발생 (네트워크 오류 등)
      return false; // 로그인 실패
    }
  }

  Future<String> getWiseSaying() async {
    final url = Uri.parse('$baseUrl/data/');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        String message = responseData["message"];

        print(message);
        return message;
      } else {
        return '';
      }
    } catch (e) {
      // 예외 발생 (네트워크 오류 등)
      return '';
    }
  }

  Future<List<NoticeModel>> getNotice() async {
    List<NoticeModel> noticeInstances = [];
    final url = Uri.parse('$baseUrl/boards/');
    final response = await http.get(url);
    print(url);

    if (response.statusCode == 200) {
      final List<dynamic> notices = jsonDecode(utf8.decode(response.bodyBytes));
      for (var notice in notices) {
        if (notice['board_type'] == '공지사항') {
          print(notice);
          noticeInstances.add(NoticeModel.fromJson(notice));
        } else {}
      }
      return noticeInstances;
    } else if (response.statusCode == 404) {
      return [];
    }
    throw Exception('Failed to fetch data from the API');
  }

  Future<bool> addNewDiary(
      String nickname, String title, String content, String diaryDate) async {
    final url = Uri.parse('$baseUrl/diaries/'); // 로그인 URL
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'nickname': nickname,
      'title': title,
      'content': content,
      'diary_date': diaryDate,
    }); // 요청 본문
    print(body);

    try {
      final response = await http.post(url, headers: headers, body: body);
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 201) {
        return true; // 로그인 성공
      } else {
        return false; // 로그인 실패
      }
    } catch (e) {
      // 예외 발생 (네트워크 오류 등)
      return false; // 로그인 실패
    }
  }

  Future<List<DiaryModel>> getDiary(String nickname) async {
    List<DiaryModel> diaryInstances = [];
    final url = Uri.parse('$baseUrl/diaries/?nickname=$nickname');
    final response = await http.get(url);
    print(url);
    print(response.statusCode);
    if (response.statusCode == 200) {
      final List<dynamic> diaries = jsonDecode(utf8.decode(response.bodyBytes));
      for (var diary in diaries) {
        print(diary);
        diaryInstances.add(DiaryModel.fromJson(diary));
      }
      return diaryInstances;
    } else if (response.statusCode == 404) {
      return [];
    }
    throw Exception('Failed to fetch data from the API');
  }

  Future<bool> deleteDiary(int id) async {
    final url = Uri.parse('$baseUrl/diaries/?diary_id=$id');
    final headers = {'Content-Type': 'application/json'};

    // final body = jsonEncode({"calendar_id": id});
    print(url);
    // print(body);
    try {
      final response = await http.delete(url, headers: headers);
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 204) {
        // final responseData = json.decode(response.body);
        // print(responseData);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> putDiary(String title, String content, String date, int id,
      String nickname) async {
    final url = Uri.parse('$baseUrl/diaries/?diary_id=$id');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'title': title,
      'content': content,
      'diary_date': date,
      'nickname': nickname,
    }); // 요청 본문
    print(body);
    try {
      print(url);
      final response = await http.put(url, headers: headers, body: body);
      print(response);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);

        return true; // 로그인 성공
      } else {
        return false; // 로그인 실패
      }
    } catch (e) {
      // 예외 발생 (네트워크 오류 등)
      return false; // 로그인 실패
    }
  }

  Future<List<dynamic>> getAchievements(String nickname) async {
    final url = Uri.parse('$baseUrl/statistics/$nickname');
    final headers = {'Content-Type': 'application/json'};

    // final body = jsonEncode({"calendar_id": id});
    print(url);
    // print(body);
    try {
      final response = await http.get(url, headers: headers);
      // print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        // print(responseData);

        return [responseData];
      } else {
        return [false];
      }
    } catch (e) {
      return [false];
    }
  }
}
