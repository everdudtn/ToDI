import 'package:flutter/material.dart';
import 'package:todi/screens/authentication.dart';
import 'package:todi/services/api_service.dart';

class SignupPage extends StatefulWidget {
  final Function(bool) loginCallback;
  const SignupPage({super.key, required this.loginCallback});

  @override
  State<SignupPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<SignupPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String? usernameInput, passwordInput, confirmInput, phoneInput;

  @override
  Widget build(BuildContext context) {
    void goAuthentication() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Authentication(
            phone: phoneInput,
            loginCallback: widget.loginCallback,
          ),
        ),
      );
    }

    void onAuthButtonPressed() async {
      ApiService api = ApiService();

      String id = usernameInput ?? '';
      String password = passwordInput ?? '';
      String phone = phoneInput ?? '';
      bool authResult = await api.auth(id, password, phone);
      if (authResult == true) {
        goAuthentication();
      } else {
        return;
      }
    }

    return Scaffold(
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
          const SizedBox(
            height: 50,
          ),
          InputBox(
            name: '아이디',
            controller: usernameController,
            obscureText: false,
            onChanged: (value) {
              setState(() {
                usernameInput = value;
              });
            },
          ),
          const SizedBox(
            height: 20,
          ),
          InputBox(
            name: '비밀번호',
            controller: passwordController,
            obscureText: true,
            onChanged: (value) {
              setState(() {
                passwordInput = value;
              });
            },
          ),
          const SizedBox(
            height: 20,
          ),
          InputBox(
            name: '비밀번호 확인',
            controller: confirmController,
            obscureText: true,
            onChanged: (value) {
              setState(() {
                confirmInput = value;
              });
            },
          ),
          const SizedBox(
            height: 20,
          ),
          InputBox(
            name: '전화번호',
            controller: phoneController,
            obscureText: false,
            onChanged: (value) {
              setState(() {
                phoneInput = value;
              });
            },
          ),
          const SizedBox(
            height: 20,
          ),
          OutlinedButton(
            onPressed: () {
              if (passwordInput == confirmInput) {
                onAuthButtonPressed();
              } else {
                // alert -> 비밀번호 불일치
              }
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
              '인증',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InputBox extends StatefulWidget {
  final String name;
  final TextEditingController? controller;
  final bool obscureText;
  final Function(String)? onChanged;

  const InputBox({
    Key? key,
    required this.name,
    this.controller,
    this.onChanged,
    required this.obscureText,
  }) : super(key: key);

  @override
  State<InputBox> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        obscureText: widget.obscureText,
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                width: 3.0,
                color: Colors.black,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                width: 3.0,
                color: Colors.black,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            labelText: widget.name,
            labelStyle: const TextStyle(color: Colors.black)),
      ),
    );
  }
}
