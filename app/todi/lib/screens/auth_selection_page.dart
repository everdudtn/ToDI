import 'package:flutter/material.dart';
import 'package:todi/screens/login_page.dart';
import 'package:todi/screens/signup_page.dart';

class AuthSelectionPage extends StatefulWidget {
  final Function(bool) loginCallback;
  const AuthSelectionPage({super.key, required this.loginCallback});

  @override
  State<AuthSelectionPage> createState() => _AuthSelectionPageState();
}

class _AuthSelectionPageState extends State<AuthSelectionPage> {
  void goLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(loginCallback: widget.loginCallback),
      ),
    );
  }

  void goSignupPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignupPage(loginCallback: widget.loginCallback),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFFD1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 230,
              height: 230,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          OutlinedButton(
            onPressed: () {
              goLoginPage();
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(const Color(0xFFFFF99F)),
              minimumSize: const MaterialStatePropertyAll(Size(300, 60)),
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
              '로그인',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          OutlinedButton(
            onPressed: () {
              goSignupPage();
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(const Color(0xFFFFF99F)),
              minimumSize: const MaterialStatePropertyAll(Size(300, 60)),
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
              '회원가입',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              '비밀번호 찾기',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
