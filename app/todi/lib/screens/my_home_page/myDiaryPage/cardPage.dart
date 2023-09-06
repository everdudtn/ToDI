import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todi/services/api_service.dart';

int _selectedIndex = -1;
String selectedIndexNumber = '';

String diaryTitle = '';
String diaryContent = '';

class CardPage extends StatefulWidget {
  final String title, content, date;
  final String? image;
  final int id;
  final Function setDataCallback;
  const CardPage(
      {super.key,
      required this.title,
      required this.content,
      required this.date,
      required this.id,
      this.image,
      required this.setDataCallback});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  TextEditingController diaryTitleController = TextEditingController();
  TextEditingController diaryContentController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? diaryTitleInput, diaryContentInput;
  XFile? _image; //이미지를 담을 변수 선언
  final ImagePicker picker = ImagePicker();
  String? nickname = '';

  DateTime _selectedDate = DateTime.now();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    nickname = await _secureStorage.read(key: 'nickname');
  }

  Future getImage(ImageSource imageSource) async {
    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path); //가져온 이미지를 _image에 저장
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    void goBack() {
      Navigator.pop(context);
    }

    void putDiaryButton() async {
      ApiService api = ApiService();

      String title = diaryTitleInput ?? '';
      String content = diaryContentInput ?? '';
      String name = nickname ?? '';
      final date = DateFormat('yyyy-MM-dd').format(_selectedDate);
      int diaryId = widget.id;

      bool result = await api.putDiary(title, content, date, diaryId, name);
      if (result == true) {
        goBack();
        widget.setDataCallback();
        print(result);
      } else {
        return;
      }
    }

    void changeDairy(BuildContext context) {
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
                            putDiaryButton();
                            widget.setDataCallback();
                          },
                          child: const Text(
                            'Edit',
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
        actions: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  changeDairy(context);
                },
                icon: const Icon(
                  Icons.edit,
                  size: 36,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
            ],
          ),
        ],
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black87,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFEFFD1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: screenHeight / 2.5,
            decoration: const BoxDecoration(
              color: Colors.black45,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 25,
                  ),
                ),
                Text(
                  widget.date.toString(),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: screenWidth / 20,
              right: screenWidth / 20,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.5,
                  color: Colors.black38,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              widget.content,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
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
