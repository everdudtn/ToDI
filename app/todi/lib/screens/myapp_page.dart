import 'package:flutter/material.dart';
import 'package:todi/screens/my_home_page/myHomePage.dart';
import 'package:todi/screens/my_info_page.dart';
import 'community_page.dart';
import 'my_plan_page.dart';

class MyAppPage extends StatefulWidget {
  final Function(bool) loginCallback;
  const MyAppPage({super.key, required this.loginCallback});

  @override
  State<MyAppPage> createState() => MyAppState();
}

class MyAppState extends State<MyAppPage> {
  // 바텀 네비게이션 바 인덱스
  int _selectedIndex = 0;
  late List<Widget> _navIndex; // late 키워드 사용

  @override
  void initState() {
    super.initState();
    _navIndex = [
      const MyHomePage(),
      const MyPlanPage(),
      const CommunityPage(),
      MyInfoPage(loginCallback: widget.loginCallback),
    ];
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _navIndex.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 35,
        selectedFontSize: 0,
        fixedColor: Colors.black,
        backgroundColor: const Color(0xFFFFF99F),
        unselectedItemColor: Colors.black38,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}
