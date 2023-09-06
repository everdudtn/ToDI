import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todi/screens/friend_calendar.dart';
import 'package:todi/screens/friend_request.dart';
import 'package:todi/screens/search_user_list.dart';
import 'package:todi/services/api_service.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => CommunityState();
}

typedef RefreshCallback = Future<void> Function();

class CommunityState extends State<CommunityPage> {
  TextEditingController friendNameController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  List<dynamic> showFriendList = [];
  List<dynamic> showRequestList = [];
  String? friendName, username;
  bool isLoading = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    username = await _secureStorage.read(key: 'username');

    showFriendList = await getFriendList();
    showRequestList = await getRequestList();
    setState(() {
      isLoading = true;
    });
  }

  void refreshData() async {
    setState(() {
      isLoading = false;
    });

    showFriendList = await getFriendList();
    showRequestList = await getRequestList();

    setState(() {
      isLoading = true;
    });
  }

  Future<List> getFriendList() async {
    ApiService api = ApiService();

    String myname = username ?? '';
    List friendList = await api.getFriendList(myname);

    if (friendList.isNotEmpty) {
      return friendList;
    }
    return [];
  }

  Future<List> getRequestList() async {
    ApiService api = ApiService();

    String myname = username ?? '';
    List friendList = await api.requestFriendList(myname);

    if (friendList.isNotEmpty) {
      return friendList;
    }

    return [];
  }

  void successSearch(userList) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchUserList(
          searchList: userList,
        ),
      ),
    );
  }

  void searchFriend() async {
    ApiService api = ApiService();

    String searchName = friendName ?? '';

    List userList = await api.searchUser(searchName);
    if (userList.isNotEmpty) {
      successSearch(userList);
    } else {
      return;
    }
  }

  void _addToFriend(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        friendNameController.text = '';
        friendName = '';

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color(0xFFFEFFD1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Add to Friends",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    // Add any other widgets you want on the right side
                  ],
                ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: friendNameController,
                    onChanged: (value) {
                      setState(() {
                        friendName = value;
                      });
                    },
                    decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1.0,
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1.0,
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        hintText: '친구추가 할 닉네임을 입력해주세요.',
                        labelStyle: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF99F),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            searchFriend();
                          },
                          child: const Text(
                            '검색하기',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    // double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF99F),
        leading: IconButton(
          icon: Image.asset(
            'assets/images/logo.png',
          ),
          onPressed: null,
        ),
        title: const Text(
          'Friend',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FriendRequest(
                        requestList: showRequestList,
                        setDataCallback: refreshData,
                      ), // 상세 페이지 위젯
                    ),
                  );
                },
                icon: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 36,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFEFFD1),
        onPressed: () {
          _addToFriend(context);
        },
        tooltip: 'Add Friend',
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? showFriendList.isNotEmpty
                    ? SizedBox(
                        height: screenHeight - 30,
                        child: ListView.builder(
                          itemCount: showFriendList.length,
                          itemBuilder: (context, index) {
                            final username = showFriendList[index];

                            return Padding(
                              padding: const EdgeInsets.only(top: 5, bottom: 5),
                              child: FriendCard(
                                name: username.nickname,
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Column(
                        children: [
                          SizedBox(
                            height: screenHeight / 3,
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '우측 하단',
                                style: TextStyle(fontSize: 26),
                              ),
                              Icon(
                                Icons.add,
                                color: Colors.black,
                                size: 26,
                              ),
                              Text(
                                '를 클릭해',
                                style: TextStyle(fontSize: 26),
                              )
                            ],
                          ),
                          SizedBox(
                            height: screenHeight / 60,
                          ),
                          const Text(
                            '친구를 찾아보세요 !',
                            style: TextStyle(
                              fontSize: 26,
                            ),
                          ),
                        ],
                      ))
                : const Center(
                    child: Text('Loading...'),
                  )
          ],
        ),
      ),
    );
  }
}

class FriendCard extends StatefulWidget {
  final String name;

  const FriendCard({
    Key? key,
    required this.name,
  }) : super(key: key);

  @override
  State<FriendCard> createState() => _FriendCardState();
}

class _FriendCardState extends State<FriendCard> {
  void _onCardPressed(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color(0xFFFEFFD1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  width: 350,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                child: Text(
                                  widget.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // const SizedBox(height: 8),
                              // Center(
                              //   child: Text(
                              //     widget.statusMessage,
                              //     style: const TextStyle(
                              //       fontSize: 16,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF99F),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FriendCalendar(nickname: widget.name),
                                ),
                              );
                            },
                            child: const Text(
                              '일정보기',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;

    return Card(
      color: const Color(0xFFFEFFD1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _onCardPressed(context),
        child: SizedBox(
          height: 80,
          width: screenWidth - 20,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  height: 80,
                  width: (screenWidth - 20) * 0.25,
                  child: Image.asset(
                    'assets/images/logo.png',
                  ),
                ),
              ),
              SizedBox(
                height: 80,
                width: (screenWidth - 20) * 0.75,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
