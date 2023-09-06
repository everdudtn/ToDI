import 'package:flutter/material.dart';
import 'package:todi/services/api_service.dart';

class Setting extends StatefulWidget {
  final Function(bool) loginCallback;
  const Setting({super.key, required this.loginCallback});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  void logout() async {
    widget.loginCallback(false);
    Navigator.pop(context);
    await storage.deleteAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFFD1),
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
          '설정',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Forms(
              title: '로그아웃',
              func: logout,
            ),
          ],
        ),
      ),
    );
  }
}

class Forms extends StatefulWidget {
  final String title;
  final Function func;

  const Forms({
    super.key,
    required this.title,
    required this.func,
  });

  @override
  State<Forms> createState() => _FormsState();
}

class _FormsState extends State<Forms> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: SizedBox(
            height: 80,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      widget.func();
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                            child: Text(
                          widget.title,
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w600),
                        ))),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 1,
          color: Colors.black,
        )
      ],
    );
  }
}
