import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todi/screens/notice.dart';
import 'package:todi/screens/setting.dart';
import 'package:todi/services/api_service.dart';

class MyInfoPage extends StatefulWidget {
  final Function(bool) loginCallback;
  const MyInfoPage({super.key, required this.loginCallback});

  @override
  State<MyInfoPage> createState() => _MyInfoPageState();
}

class _MyInfoPageState extends State<MyInfoPage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? username, nickname;
  TextEditingController changeController = TextEditingController();
  String? changeInput;
  String? image;
  void refreshData() async {
    setState(() {
      getProfile();
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    username = await _secureStorage.read(key: 'username');

    getProfile();
    setState(() {});
  }

  void getProfile() async {
    ApiService api = ApiService();

    String myname = username ?? '';
    List profile = await api.getProfile(myname);

    if (profile.isNotEmpty) {
      setState(() {
        nickname = profile[0]['nickname'];

        const backendBaseUrl = 'http://172.16.101.144:8000';
        if (profile[0]['image'] == null) {
          return;
        } else {
          image = backendBaseUrl + profile[0]['image'];
        }
      });
    } else {
      return;
    }
  }

  void onClose() {
    Navigator.pop(context);
  }

  void changeProfile() async {
    ApiService api = ApiService();

    String name = username ?? '';
    String changeName = changeInput ?? '';

    bool result = await api.putProfile(name, changeName);
    if (result == true) {
      refreshData();
      onClose();
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    void profileSetting(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          changeController.text = '';
          changeInput = '';
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: const Color.fromRGBO(254, 255, 209, 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Profile",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 200,
                          height: 200,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Expanded(
                                  child: SizedBox(
                                height: 5,
                              )),
                            ],
                          ),
                          Center(
                            child: SizedBox(
                              width: 200,
                              height: 50,
                              child: TextField(
                                controller: changeController,
                                onChanged: (value) {
                                  setState(() {
                                    changeInput = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: nickname,
                                  labelStyle: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
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
                                },
                                child: const Text(
                                  '취소하기',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  changeProfile();
                                },
                                child: const Text(
                                  '변경하기',
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
          });
        },
      );
    }

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
          'My Page',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  size: 36,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Setting(loginCallback: widget.loginCallback),
                    ),
                  );
                },
              ),
              const SizedBox(
                width: 8,
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 255, 252, 189), // 좌우 배경색 설정
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  image != null
                      ? Image.network(
                          image!,
                          width: 250,
                          height: 250,
                        )
                      : Image.asset(
                          'assets/images/logo.png',
                          width: 250,
                          height: 250,
                        ),
                  Text(
                    nickname ?? '',
                    style: const TextStyle(fontSize: 26),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      profileSetting(context);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      minimumSize:
                          const MaterialStatePropertyAll(Size(200, 50)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      side: MaterialStateProperty.all<BorderSide>(
                        const BorderSide(
                          color: Colors.grey, // 테두리의 색상
                          width: 1.0, // 테두리의 두께
                        ),
                      ),
                    ),
                    child: const Text(
                      '프로필 설정',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Notice(),
                  ),
                );
              },
              child: const Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '공지사항',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 1,
            color: Colors.black,
          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {},
              child: const Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '이용안내',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
