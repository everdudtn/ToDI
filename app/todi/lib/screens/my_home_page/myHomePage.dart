import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:todi/models/calendar_model.dart';
import 'package:todi/screens/my_home_page/myDiaryPage/myDiaryPage.dart';
import 'package:todi/services/api_service.dart';
import 'task.dart';
import 'hive_helper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyHomePage> {
  String input = " ";
  String wiseSaying = '';
  List<Meeting> showCalendarList = [];
  List editCalendar = [];
  String? username, nickname;

  double myAchievements = 0;
  int myAchievementsNum = 0;

  int rankNumber = 0;

  String? ranker1, ranker2, ranker3;
  // Future<dynamic>? achievements;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    username = await _secureStorage.read(key: 'username');
    nickname = await _secureStorage.read(key: 'nickname');

    getWiseSaying();
    showCalendarList = await getCalendarList();
    setState(() {});
  }

  Future<List<Meeting>> getCalendarList() async {
    ApiService api = ApiService();

    String myname = nickname ?? '';
    List<CalendarModel> calendarList = await api.getCalendar(myname);

    setState(() {
      editCalendar = calendarList;
    });

    List<Meeting> meetings = [];
    for (var calendar in calendarList) {
      meetings.add(Meeting(
        calendar.table_title,
        DateTime.parse(calendar.start),
        DateTime.parse(calendar.end),
        Colors.amber.shade300,
        false,
      ));
    }

    return meetings;
  }

  Future<dynamic> getAchievementsButton() async {
    ApiService api = ApiService();

    String myname = nickname ?? '';
    print(myname);
    List<dynamic> result = await api.getAchievements(myname);
    if (result.isNotEmpty) {
      double achievement = result[0]["own_completion_rate"];
      myAchievements = achievement;
      myAchievementsNum = achievement.toInt();
      int rank = result[0]['own_rank'];
      rankNumber = rank;

      ranker1 = result[0]['top_users'][0]['username'];
      ranker2 = result[0]['top_users'][1]['username'];
      ranker3 = result[0]['top_users'][2]['username'];

      print(ranker2);

      print(result[0]['own_username']);

      return result[0];
    } else {
      return [];
    }
  }

  void getWiseSaying() async {
    ApiService api = ApiService();

    String getWiseSaying = await api.getWiseSaying();

    if (getWiseSaying.isNotEmpty) {
      setState(() {
        wiseSaying = getWiseSaying;
      });
      return;
    }

    return;
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFEFFD1),
          contentPadding: const EdgeInsets.only(
            left: 0,
            right: 0,
          ),
          title: const Text('Add to List'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              height: 120,
              child: Column(
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    width: 270,
                    child: TextField(
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '내용을 입력해주세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(25),
                          ),
                        ),
                      ),
                      autofocus: true,
                      onChanged: (String text) {
                        input = text;
                      },
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 300,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF99F),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          HiveHelper().create(Task(input));
                        });
                        input = '';
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
    double screenHeight = screenSize.height;

    void showAchievements() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              title: const Text(
                'Achievements',
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '달성률',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Stack(
                        children: [
                          Container(
                            width: screenWidth / 2.8,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black12,
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: myAchievements * 0.01,
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.amber.shade300,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: screenWidth / 6.5,
                            top: screenWidth / 55,
                            child: Text(
                              '$myAchievementsNum%',
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    height: screenHeight / 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEFFD1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        width: 1,
                        color: Colors.black,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '당신은 $rankNumber등 입니다.',
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      top: 20,
                    ),
                    child: const Text(
                      'Rank',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 12,
                      bottom: 13,
                    ),
                    margin: const EdgeInsets.only(
                      top: 10,
                    ),
                    width: screenWidth / 1.3,
                    height: screenHeight / 2.8,
                    decoration: const BoxDecoration(),
                    child: Row(
                      children: [
                        SizedBox(
                          width: screenWidth / 6,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 10,
                                  ),
                                  width: screenWidth / 5.5,
                                  height: screenWidth / 5.5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.amber.shade300,
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.topCenter,
                                padding: const EdgeInsets.only(top: 10),
                                width: screenWidth / 5,
                                height: screenHeight / 4.3,
                                decoration: BoxDecoration(
                                  color: Colors.yellow.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '1등\n$ranker1',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: screenWidth / 18,
                          ),
                          width: screenWidth / 6,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 10,
                                  ),
                                  width: screenWidth / 5.5,
                                  height: screenWidth / 5.5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.amber.shade300,
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.topCenter,
                                padding: const EdgeInsets.only(top: 10),
                                width: screenWidth / 5,
                                height: screenHeight / 6,
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '2등\n$ranker2',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: screenWidth / 18,
                          ),
                          width: screenWidth / 6,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 10,
                                  ),
                                  width: screenWidth / 5.5,
                                  height: screenWidth / 5.5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.amber.shade300,
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.topCenter,
                                padding: const EdgeInsets.only(top: 10),
                                width: screenWidth / 5,
                                height: screenHeight / 9.5,
                                decoration: BoxDecoration(
                                  color: Colors.brown.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '3등\n$ranker3',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        },
      );
    }

    return FutureBuilder<List<Task>>(
      future: HiveHelper().read(),
      builder: (context, snapshot) {
        List<Task> tasks = snapshot.data ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFFFEFFD1),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFF99F),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: screenWidth / 7.5,
                ),
                const Text(
                  'To do',
                  style: TextStyle(
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showAchievements();
                  },
                  icon: const Icon(
                    Icons.wine_bar,
                    color: Colors.black87,
                    size: 35,
                  ),
                )
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: screenWidth / 1.1,
                      height: screenHeight / 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: RichText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              strutStyle: const StrutStyle(fontSize: 16.0),
                              text: TextSpan(
                                text: wiseSaying,
                                style: const TextStyle(
                                    color: Colors.black,
                                    height: 1.4,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'PixelFont'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight / 60,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(),
                      child: const Text(
                        'Calendar',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight / 150,
                ),
                Container(
                  height: screenHeight / 5.5,
                  decoration: const BoxDecoration(),
                  child: SfCalendar(
                    view: CalendarView.week,
                    dataSource: MeetingDataSource(showCalendarList),
                    monthViewSettings:
                        const MonthViewSettings(showAgenda: true),
                  ),
                ),
                SizedBox(
                  height: screenHeight / 80,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(),
                      child: const Text(
                        'Diary',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight / 150,
                ),
                Container(
                  width: 400,
                  height: screenHeight / 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF99F),
                  ),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyDiaryPage(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.book,
                      size: 30,
                      color: Colors.black,
                    ),
                    label: const Text(
                      '일기 작성하기',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight / 80,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(),
                      child: const Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight / 150,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: screenWidth / 1.3,
                      height: screenHeight / 4.3,
                      decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.5,
                            color: Colors.black,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(35)),
                      child: ReorderableListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 0),
                        proxyDecorator: (Widget child, int index,
                            Animation<double> animation) {
                          return TaskTile(task: tasks[index], onDeleted: () {});
                        },
                        children: <Widget>[
                          for (int index = 0; index < tasks.length; index += 1)
                            Padding(
                              key: Key('$index'),
                              padding: const EdgeInsets.all(8.0),
                              child: TaskTile(
                                task: tasks[index],
                                onDeleted: () {
                                  setState(() {});
                                },
                              ),
                            )
                        ],
                        onReorder: (int oldIndex, int newIndex) async {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          await HiveHelper().reorder(oldIndex, newIndex);
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Container(
                      height: screenHeight / 4.3,
                      width: screenWidth / 6,
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFF99F),
                          border: Border.all(
                            width: 2,
                            color: Colors.black,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(20)),
                      child: IconButton(
                        color: Colors.black54,
                        onPressed: () {
                          _showMyDialog();
                        },
                        icon: const Icon(Icons.create),
                        iconSize: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TaskTile extends StatefulWidget {
  const TaskTile({
    Key? key,
    required this.task,
    required this.onDeleted,
  }) : super(key: key);

  final Task task;
  final Function onDeleted;

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromRGBO(0, 0, 0, 0),
      child: AnimatedContainer(
        constraints: const BoxConstraints(minHeight: 60),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF99F),
          borderRadius: BorderRadius.circular(30),
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        child: Row(
          children: [
            Checkbox(
              key: widget.key,
              value: widget.task.finished,
              onChanged: (checked) {
                widget.task.finished = checked!;
                widget.task.save();
                setState(() {});
              },
              activeColor: Colors.amber.shade300,
            ),
            Expanded(
              child: Text(
                widget.task.title,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black87,
                  decoration: widget.task.finished
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.black54,
              ),
              onPressed: () {
                showDeleteDialog();
              },
            )
          ],
        ),
      ),
    );
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '삭제하시겠습니까?',
            textAlign: TextAlign.center,
          ),
          contentPadding: const EdgeInsets.only(
            top: 20,
            bottom: 20,
            left: 0,
            right: 0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: TextButton(
                  onPressed: () {
                    widget.task.delete();
                    widget.onDeleted();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.amber.shade300,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
