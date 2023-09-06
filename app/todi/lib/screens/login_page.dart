import 'package:flutter/material.dart';
import 'package:todi/services/api_service.dart';

class LoginPage extends StatefulWidget {
  final Function(bool) loginCallback;

  const LoginPage({Key? key, required this.loginCallback}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? usernameInput, passwordInput;

  void onLoginButtonPressed() async {
    ApiService api = ApiService();

    String id = usernameInput ?? '';
    String password = passwordInput ?? '';

    bool loginResult = await api.login(id, password);
    if (loginResult == true) {
      widget.loginCallback(true);
      goMainPage();
    } else {
      return;
    }
  }

  void goMainPage() {
    Navigator.pop(context);
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
          OutlinedButton(
            onPressed: () {
              onLoginButtonPressed();
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
              '로그인',
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
  final bool obscureText;
  final TextEditingController? controller;
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
          labelStyle: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
