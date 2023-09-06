import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todi/services/api_service.dart';

class SearchUserList extends StatefulWidget {
  final List? searchList;
  const SearchUserList({Key? key, required this.searchList}) : super(key: key);

  @override
  State<SearchUserList> createState() => _SearchFriendState();
}

class _SearchFriendState extends State<SearchUserList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF99F),
        title: const Text(
          '친구 검색 결과',
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 36,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: widget.searchList?.length ?? 0,
        itemBuilder: (context, index) {
          final list = widget.searchList![index];

          return FriendCard(
            name: list.nickname,
            receiver: list.username,
          );
        },
      ),
    );
  }
}

class FriendCard extends StatefulWidget {
  final String name, receiver;

  const FriendCard({
    Key? key,
    required this.name,
    required this.receiver,
  }) : super(key: key);

  @override
  State<FriendCard> createState() => _FriendCardState();
}

class _FriendCardState extends State<FriendCard> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? username;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    username = await _secureStorage.read(key: 'username');
    setState(() {});
  }

  void friendRequest() async {
    ApiService api = ApiService();

    String request = username ?? '';

    bool result = await api.sendFriendRequest(request, widget.receiver);
    if (result == true) {
      closeRequest();
    } else {
      return;
    }
  }

  void closeRequest() {
    Navigator.pop(context);
  }

  void onCardPressed(BuildContext context) {
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
                              friendRequest();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              '친구 요청',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600),
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

    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Card(
        color: const Color(0xFFFEFFD1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => onCardPressed(context),
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
      ),
    );
  }
}
