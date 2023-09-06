import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todi/services/api_service.dart';

class SetProfile extends StatefulWidget {
  const SetProfile({super.key});

  @override
  State<SetProfile> createState() => _SetProfileState();
}

class _SetProfileState extends State<SetProfile> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? getUsername;
  TextEditingController nicknameController = TextEditingController();
  String? nicknameInput;
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    getUsername = await _secureStorage.read(key: 'username');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;

    void onSubmit() async {
      ApiService api = ApiService();
      String username = getUsername ?? '';
      String nickname = nicknameInput ?? '';
      void goMainPage() {
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      }

      bool result = await api.setProfile(username, nickname);
      if (result == true) {
        goMainPage();
      } else {
        return;
      }
    }

    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFEFFD1),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 200,
                height: 200,
              ),
            ),
            SizedBox(
              width: screenWidth / 2,
              child: TextField(
                controller: nicknameController,
                onChanged: (value) {
                  setState(() {
                    nicknameInput = value;
                  });
                },
                decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 3.0,
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 3.0,
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    labelText: '닉네임',
                    labelStyle: TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            OutlinedButton(
              onPressed: () {
                onSubmit();
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color(0xFFFFF99F)),
                minimumSize: const MaterialStatePropertyAll(Size(150, 60)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                side: MaterialStateProperty.all<BorderSide>(
                  const BorderSide(
                    color: Colors.black,
                    width: 3.0,
                  ),
                ),
              ),
              child: const Text(
                '프로필 생성',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
