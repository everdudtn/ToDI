import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/my_home_page/hive_helper.dart';
import 'screens/my_home_page/task.dart';
import 'package:todi/screens/myapp_page.dart';
import 'package:todi/screens/auth_selection_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await HiveHelper().openBox();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // String? username;
  bool isLogin = false;
  void loginCallback(bool value) {
    setState(() {
      isLogin = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          fontFamily: 'PixelFont',
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          // Locale('en', 'US'),
          Locale('ko', 'KR'),
        ],
        home: isLogin
            ? MyAppPage(loginCallback: loginCallback)
            : AuthSelectionPage(loginCallback: loginCallback));
  }
}
