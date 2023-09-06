import 'package:flutter/material.dart';
import 'package:todi/screens/set_profile.dart';
import 'package:todi/services/api_service.dart';

class Authentication extends StatefulWidget {
  final String? phone;
  final Function(bool) loginCallback;
  const Authentication(
      {super.key, required this.phone, required this.loginCallback});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  TextEditingController authNumberController = TextEditingController();
  String? authNumber;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    void goMainPage() {
      // Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SetProfile(),
        ),
      );
    }

    void onSignup() async {
      ApiService api = ApiService();

      String phone = widget.phone ?? '';
      String code = (authNumber ?? '');
      bool Result = await api.phoneAuth(phone, code);
      if (Result == true) {
        widget.loginCallback(true);
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
                controller: authNumberController,
                onChanged: (value) {
                  setState(() {
                    authNumber = value;
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
                    labelText: '인증번호',
                    labelStyle: TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            OutlinedButton(
              onPressed: () {
                onSignup();
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
                    color: Colors.black, // 테두리의 색상
                    width: 3.0, // 테두리의 두께
                  ),
                ),
              ),
              child: const Text(
                '회원가입',
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
