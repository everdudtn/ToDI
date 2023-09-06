import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todi/services/api_service.dart';

class FriendRequest extends StatefulWidget {
  final List? requestList;
  final Function setDataCallback;

  const FriendRequest(
      {super.key, required this.requestList, required this.setDataCallback});

  @override
  State<FriendRequest> createState() => _FriendRequestState();
}

class _FriendRequestState extends State<FriendRequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF99F),
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
        title: const Text(
          '받은 친구 요청',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.requestList?.length ?? 0,
        itemBuilder: (context, index) {
          final userInfo = widget.requestList![index];

          return RequestCard(
            name: userInfo.sender.username,
            nickname: userInfo.sender.nickname,
            setDataCallback: widget.setDataCallback,
          );
        },
      ),
    );
  }
}

class RequestCard extends StatefulWidget {
  final String name, nickname;
  final Function setDataCallback;

  const RequestCard({
    Key? key,
    required this.name,
    required this.setDataCallback,
    required this.nickname,
  }) : super(key: key);

  @override
  State<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<RequestCard> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? username;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    username = await _secureStorage.read(key: 'username');

    setState(() {});
  }

  void acceptRequest(String sender) async {
    ApiService api = ApiService();

    String myname = username ?? '';

    bool result = await api.friendRequestAccept(myname, sender);
    if (result == true) {
      Navigator.pop(context);
      widget.setDataCallback();
    } else {
      return;
    }
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
                                  widget.nickname,
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
                              // Navigator.pop(context);
                              // friendRequest();
                              acceptRequest(widget.name);
                            },
                            child: const Text(
                              '친구 수락',
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
                          widget.nickname,
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
