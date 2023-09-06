import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:todi/services/api_service.dart';
import 'cardPage.dart';

int _selectedIndex = -1;
String selectedIndexNumber = '';

String diaryTitle = '';
String diaryContent = '';

class MyDiaryPage extends StatefulWidget {
  const MyDiaryPage({super.key});

  @override
  State<MyDiaryPage> createState() => _MyDiaryPageState();
}

class _MyDiaryPageState extends State<MyDiaryPage> {
  TextEditingController diaryTitleController = TextEditingController();
  TextEditingController diaryContentController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? diaryTitleInput, diaryContentInput, nickName;

  XFile? _image; //이미지를 담을 변수 선언
  final ImagePicker picker = ImagePicker(); //ImagePicker 초기화
  List<dynamic> showDiaryList = [];

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    nickName = await _secureStorage.read(key: 'nickname');

    showDiaryList = await getDiaries();
    setState(() {});
  }

  void refreshData() async {
    showDiaryList = await getDiaries();
    print('리프레수ㅏ');
    setState(() {});
  }

  Future<List> getDiaries() async {
    ApiService api = ApiService();

    String name = nickName ?? '';
    List diaryList = await api.getDiary(name);

    if (diaryList.isNotEmpty) {
      return diaryList;
    }
    return [];
  }

  //이미지를 가져오는 함수
  Future getImage(ImageSource imageSource) async {
    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path); //가져온 이미지를 _image에 저장
      });
    }
  }

  DateTime _selectedDate = DateTime.now();

  void addDiaryButton() async {
    ApiService api = ApiService();

    String title = diaryTitleInput ?? '';
    String content = diaryContentInput ?? '';
    final date = DateFormat('yyyy-MM-dd').format(_selectedDate);
    String name = nickName ?? '';

    bool result = await api.addNewDiary(name, title, content, date);
    if (result == true) {
      refreshData();
      print(result);
    } else {
      return;
    }
  }

  void deleteDiary(int id) async {
    ApiService api = ApiService();
    bool result = await api.deleteDiary(id);
    if (result == true) {
      refreshData();
      print(result);
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    void addDairy(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          diaryTitleController.text = '';
          diaryContentController.text = '';
          diaryTitleInput = '';
          diaryContentInput = '';
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFEFFD1),
              contentPadding: const EdgeInsets.only(left: 0, right: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(45),
              ),
              title: const Text(
                'Keep a Diary',
                textAlign: TextAlign.center,
                style: TextStyle(),
              ),
              content: Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: screenHeight / 100,
                    ),
                    SizedBox(
                      width: screenHeight / 2.9,
                      height: screenHeight / 2.9,
                      child: _image != null
                          ? Container(
                              child: Image.file(
                                File(_image!.path),
                              ),
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt),
                                color: Colors.white60,
                                onPressed: () {
                                  setState(() {
                                    _image = null;
                                    showDialog2(context);
                                  });
                                },
                              ),
                            ),
                    ),
                    SizedBox(
                      height: screenHeight / 70,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                      ),
                      child: Container(
                        height: screenHeight / 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 0.5,
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      showSelectDate(context);
                                      setState(() {});
                                    },
                                    icon: const Icon(
                                      Icons.calendar_month,
                                      color: Colors.black87,
                                    ),
                                    label: const Text(
                                      '날짜 선택',
                                      style: TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    DateFormat('yyyy.MM.dd')
                                        .format(_selectedDate),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight / 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        right: 20,
                      ),
                      child: SizedBox(
                        width: screenHeight / 2.8,
                        child: TextField(
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '제목을 입력해주세요',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(25),
                              ),
                            ),
                          ),
                          onChanged: (String value) {
                            setState(() {
                              diaryTitleInput = value;
                              diaryTitle = value;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight / 70,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        right: 20,
                      ),
                      child: SizedBox(
                        width: screenHeight / 2.9,
                        child: TextField(
                          maxLines: 5,
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
                          onChanged: (String value) {
                            diaryContentInput = value;
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight / 50,
                    ),
                    Center(
                      child: Container(
                        width: screenWidth,
                        height: screenHeight / 13,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF99F),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(45),
                              bottomRight: Radius.circular(45)),
                        ),
                        child: TextButton(
                          onPressed: () {
                            addDiaryButton();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Add',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        },
      );
    }

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
          'Diary',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: screenHeight / 1.4,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: showDiaryList.length,
              itemBuilder: (context, index) {
                final diaries = showDiaryList[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: TextButton(
                    onPressed: () {
                      _selectedDate = DateTime.now();
                      addDairy(context);
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      color: Colors.amber.shade300,
                      child: ListTile(
                        contentPadding: const EdgeInsets.only(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                        ),
                        onTap: () {
                          _selectedIndex = index;
                          if (_selectedIndex == 0) {
                            selectedIndexNumber = '1';
                          } else {
                            selectedIndexNumber = '2';
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CardPage(
                                title: diaries.title,
                                content: diaries.content,
                                date: diaries.diaryDate,
                                image: diaries.image,
                                id: diaries.id,
                                setDataCallback: refreshData,
                              ),
                            ),
                          );
                        },
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: screenHeight / 12,
                              height: screenHeight / 12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.black45,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                                left: 15.0,
                              ),
                              child: Text(
                                diaries.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.black45,
                            ),
                            onPressed: () {
                              deleteDiary(diaries.id);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: screenWidth / 1.1,
            decoration: BoxDecoration(
                border: Border.all(
              width: 0.5,
            )),
          ),
          SizedBox(
            height: screenHeight / 70,
          ),
          Container(
            width: screenWidth / 1.1,
            height: screenHeight / 8,
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextButton.icon(
              onPressed: () {
                addDairy(context);
                _selectedDate = DateTime.now();
              },
              icon: const Icon(
                Icons.add,
                size: 40,
                color: Colors.white,
              ),
              label: const Text(
                '일기 추가하기',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void onDateChanged(DateTime newDate) {
    setState(() {
      // 상태 변경을 알리는 함수 호출
      _selectedDate = newDate; // 새로운 날짜 값으로 상태 업데이트
    });
  }

  void showSelectDate(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext builder) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  initialDateTime: _selectedDate,
                  onDateTimeChanged: (DateTime newDate) {
                    onDateChanged(newDate);
                  },
                  minimumYear: _selectedDate.year - 100,
                  maximumYear: _selectedDate.year + 100,
                  mode: CupertinoDatePickerMode.date,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showDialog2(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Select',
            textAlign: TextAlign.center,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                ),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      getImage(ImageSource.camera);
                    });
                  },
                  child: Text(
                    '카메라',
                    style: TextStyle(
                      color: Colors.amber.shade500,
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                ),
                child: TextButton(
                  onPressed: () {
                    getImage(ImageSource.gallery);
                  },
                  child: Text(
                    '갤러리',
                    style: TextStyle(
                      color: Colors.amber.shade500,
                      fontSize: 25,
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
