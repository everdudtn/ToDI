import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:todi/models/calendar_model.dart';
import 'package:todi/services/api_service.dart';

class MyPlanPage extends StatefulWidget {
  const MyPlanPage({Key? key}) : super(key: key);

  @override
  State<MyPlanPage> createState() => MyPlanState();
}

class MyPlanState extends State<MyPlanPage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? username, nickname;
  List<Meeting> showCalendarList = [];
  List editCalendar = [];

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    username = await _secureStorage.read(key: 'username');
    nickname = await _secureStorage.read(key: 'nickname');

    showCalendarList = await getCalendarList();

    setState(() {});
  }

  void refreshData() async {
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

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController changeTitleController = TextEditingController();

    String? titleInput, changeTitleInput;
    DateTime changeStartDate = DateTime.now();
    DateTime changeEndDate = DateTime.now();
    TimeOfDay changeStartTime = TimeOfDay.now();
    TimeOfDay changeEndTime = TimeOfDay.now();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay.now();
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    void onClose() {
      Navigator.pop(context);
    }

    void addSchedule() async {
      ApiService api = ApiService();

      String title = titleInput ?? '';
      String name = nickname ?? '';
      final start =
          '${DateFormat('yyyy-MM-dd').format(startDate)} ${startTime.hour}:${startTime.minute}';
      final end =
          '${DateFormat('yyyy-MM-dd').format(endDate)} ${endTime.hour}:${endTime.minute}';

      bool result = await api.postCalendar(title, start, end, name);

      if (result == true) {
        refreshData();
        onClose();
      } else {
        return;
      }
    }

    void addToSchedule(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "일정 추가",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        // 다른 위젯을 오른쪽에 추가할 수 있습니다.
                      ],
                    ),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          hintText: 'Add to Schedule',
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        controller: titleController,
                        onChanged: (value) {
                          setState(() {
                            titleInput = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text(
                                '시작',
                                style: TextStyle(fontSize: 24),
                              ),
                              OutlinedButton(
                                onPressed: () async {
                                  Future<DateTime?> future = showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2023),
                                    lastDate: DateTime(2030),
                                    initialEntryMode:
                                        DatePickerEntryMode.calendarOnly,
                                    builder:
                                        (BuildContext context, Widget? picker) {
                                      return Theme(
                                        data: ThemeData(),
                                        child: picker!,
                                      );
                                    },
                                  );
                                  future.then((date) {
                                    if (date != null) {
                                      setState(() {
                                        startDate = date;
                                      });
                                    }
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) {
                                    // If the button is pressed, return green, otherwise blue
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return const Color.fromARGB(
                                          255, 231, 231, 231);
                                    }
                                    return const Color.fromARGB(
                                        255, 231, 231, 231);
                                  }),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  DateFormat('yyyy년 MM월 dd일').format(startDate),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () async {
                                  Future<TimeOfDay?> time = showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                    builder:
                                        (BuildContext context, Widget? picker) {
                                      return Theme(
                                        data: ThemeData(),
                                        child: picker!,
                                      );
                                    },
                                  );
                                  time.then((date) {
                                    if (date != null) {
                                      setState(() {
                                        startTime = date;
                                      });
                                    }
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) {
                                    // If the button is pressed, return green, otherwise blue
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return const Color.fromARGB(
                                          255, 231, 231, 231);
                                    }
                                    return const Color.fromARGB(
                                        255, 231, 231, 231);
                                  }),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '${startTime.hour}시 ${startTime.minute}분',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text(
                                '종료',
                                style: TextStyle(fontSize: 24),
                              ),
                              OutlinedButton(
                                onPressed: () async {
                                  Future<DateTime?> future = showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2023),
                                    lastDate: DateTime(2030),
                                    initialEntryMode:
                                        DatePickerEntryMode.calendarOnly,
                                    builder:
                                        (BuildContext context, Widget? picker) {
                                      return Theme(
                                        data: ThemeData(),
                                        child: picker!,
                                      );
                                    },
                                  );
                                  future.then((date) {
                                    if (date != null) {
                                      setState(() {
                                        endDate = date;
                                      });
                                    }
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) {
                                    // If the button is pressed, return green, otherwise blue
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return const Color.fromARGB(
                                          255, 231, 231, 231);
                                    }
                                    return const Color.fromARGB(
                                        255, 231, 231, 231);
                                  }),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  DateFormat('yyyy년 MM월 dd일').format(endDate),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  Future<TimeOfDay?> time = showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                    builder:
                                        (BuildContext context, Widget? picker) {
                                      return Theme(
                                        data: ThemeData(),
                                        child: picker!,
                                      );
                                    },
                                  );
                                  time.then((date) {
                                    if (date != null) {
                                      setState(() {
                                        endTime = date;
                                      });
                                    }
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) {
                                    // If the button is pressed, return green, otherwise blue
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return const Color.fromARGB(
                                          255, 231, 231, 231);
                                    }
                                    return const Color.fromARGB(
                                        255, 231, 231, 231);
                                  }),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '${endTime.hour}시 ${endTime.minute}분',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(255, 249, 159, 1),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                addSchedule();
                              },
                              child: const Text(
                                '추가하기',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
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

    void deleteSchedule(id) async {
      ApiService api = ApiService();

      bool result = await api.deleteCalendar(id);

      if (result == true) {
        refreshData();
        onClose();
      } else {
        return;
      }
    }

    void putSchedule(int id) async {
      ApiService api = ApiService();

      String name = nickname ?? '';
      String putTitle = changeTitleInput ?? '';
      final putStart =
          '${DateFormat('yyyy-MM-dd').format(changeStartDate)} ${changeStartTime.hour}:${changeStartTime.minute}';
      final putEnd =
          '${DateFormat('yyyy-MM-dd').format(changeEndDate)} ${changeEndTime.hour}:${changeEndTime.minute}';
      bool result = await api.putCalendar(putTitle, putStart, putEnd, name, id);

      if (result == true) {
        refreshData();
        onClose();
      } else {
        return;
      }
    }

    void checkSchedule(
        String title, String start, String end, int id, int checks) async {
      ApiService api = ApiService();

      String name = nickname ?? '';
      int checked = checks == 1 ? 0 : 1;
      bool result =
          await api.checkCalendar(title, start, end, name, id, checked);

      if (result == true) {
        refreshData();
        onClose();
      } else {
        return;
      }
    }

    void putToSchedule(BuildContext context, String title, String startDate,
        String endDate, int calendarId) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "일정 변경",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        // 다른 위젯을 오른쪽에 추가할 수 있습니다.
                      ],
                    ),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0,
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          hintText: title,
                          labelStyle: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        controller: changeTitleController,
                        onChanged: (value) {
                          setState(() {
                            changeTitleInput = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text(
                                '시작',
                                style: TextStyle(fontSize: 24),
                              ),
                              OutlinedButton(
                                onPressed: () async {
                                  Future<DateTime?> future = showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    // initialDate: DateTime.now(),
                                    firstDate: DateTime(2023),
                                    lastDate: DateTime(2030),
                                    initialEntryMode:
                                        DatePickerEntryMode.calendarOnly,
                                    builder:
                                        (BuildContext context, Widget? picker) {
                                      return Theme(
                                        data: ThemeData(),
                                        child: picker!,
                                      );
                                    },
                                  );
                                  future.then((date) {
                                    if (date != null) {
                                      setState(() {
                                        changeStartDate = date;
                                      });
                                    }
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) {
                                    // If the button is pressed, return green, otherwise blue
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return const Color.fromARGB(
                                          255, 231, 231, 231);
                                    }
                                    return const Color.fromARGB(
                                        255, 231, 231, 231);
                                  }),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  DateFormat('yyyy년 MM월 dd일')
                                      .format(changeStartDate),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () async {
                                  Future<TimeOfDay?> time = showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                    builder:
                                        (BuildContext context, Widget? picker) {
                                      return Theme(
                                        data: ThemeData(),
                                        child: picker!,
                                      );
                                    },
                                  );
                                  time.then((date) {
                                    if (date != null) {
                                      setState(() {
                                        startTime = date;
                                      });
                                    }
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) {
                                    // If the button is pressed, return green, otherwise blue
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return const Color.fromARGB(
                                          255, 231, 231, 231);
                                    }
                                    return const Color.fromARGB(
                                        255, 231, 231, 231);
                                  }),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '${changeStartTime.hour}시 ${changeStartTime.minute}분',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text(
                                '종료',
                                style: TextStyle(fontSize: 24),
                              ),
                              OutlinedButton(
                                onPressed: () async {
                                  Future<DateTime?> future = showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2023),
                                    lastDate: DateTime(2030),
                                    initialEntryMode:
                                        DatePickerEntryMode.calendarOnly,
                                    builder:
                                        (BuildContext context, Widget? picker) {
                                      return Theme(
                                        data: ThemeData(),
                                        child: picker!,
                                      );
                                    },
                                  );
                                  future.then((date) {
                                    if (date != null) {
                                      setState(() {
                                        changeEndDate = date;
                                      });
                                    }
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) {
                                    // If the button is pressed, return green, otherwise blue
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return const Color.fromARGB(
                                          255, 231, 231, 231);
                                    }
                                    return const Color.fromARGB(
                                        255, 231, 231, 231);
                                  }),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  DateFormat('yyyy년 MM월 dd일')
                                      .format(changeEndDate),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  Future<TimeOfDay?> time = showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                    builder:
                                        (BuildContext context, Widget? picker) {
                                      return Theme(
                                        data: ThemeData(),
                                        child: picker!,
                                      );
                                    },
                                  );
                                  time.then((date) {
                                    if (date != null) {
                                      setState(() {
                                        endTime = date;
                                      });
                                    }
                                  });
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return const Color.fromARGB(
                                          255, 231, 231, 231);
                                    }
                                    return const Color.fromARGB(
                                        255, 231, 231, 231);
                                  }),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '${changeEndTime.hour}시 ${changeEndTime.minute}분',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(255, 249, 159, 1),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                putSchedule(
                                  calendarId,
                                );
                              },
                              child: const Text(
                                '수정하기',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
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

    void editToCalendar(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "일정 수정 및 삭제",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: screenHeight / 3,
                        width: screenWidth - 50,
                        child: ListView.builder(
                          itemCount: editCalendar.length,
                          itemBuilder: (context, index) {
                            final list = editCalendar[index];

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    checkSchedule(list.table_title, list.start,
                                        list.end, list.id, list.checks);
                                  },
                                  icon: Icon(
                                    list.checks == 1
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    size: 22,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  list.table_title.length > 10
                                      ? '${list.table_title.substring(0, 10)}...'
                                      : list.table_title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${DateFormat('MM월dd일').format(DateTime.parse(list.start))} ',
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        putToSchedule(context, list.table_title,
                                            list.start, list.end, list.id);
                                      },
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 22,
                                        color: Colors.black,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        deleteSchedule(list.id);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 22,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
      ),
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment(
                Alignment.bottomRight.x, Alignment.bottomRight.y - 0.2),
            child: FloatingActionButton(
              backgroundColor: const Color(0xFFFEFFD1),
              onPressed: () {
                editToCalendar(context);
              }, // 버튼을 누를 경우
              tooltip: 'Put & Delete', // 플로팅 액션 버튼 설명
              child: const Icon(
                Icons.edit,
                color: Colors.black,
              ), // + 모양 아이콘
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFFFEFFD1),
              onPressed: () {
                addToSchedule(context);
              }, // 버튼을 누를 경우
              tooltip: 'Add Plan', // 플로팅 액션 버튼 설명
              child: const Icon(
                Icons.add,
                color: Colors.black,
              ), // + 모양 아이콘
            ),
          ),
        ],
      ),
      body: SfCalendar(
        view: CalendarView.month,
        dataSource: MeetingDataSource(showCalendarList),
        monthViewSettings: const MonthViewSettings(
          showAgenda: true,
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        ),
        headerDateFormat: "yyyy년 M월",
        appointmentTimeTextFormat: 'HH:mm',
        todayHighlightColor: Colors.amber.shade300,
        headerStyle: const CalendarHeaderStyle(
          textAlign: TextAlign.center,
          textStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        appointmentTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headerHeight: 80,
        showNavigationArrow: true,
        showTodayButton: true,
      ),
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
