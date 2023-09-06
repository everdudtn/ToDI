import 'package:flutter/material.dart';
import 'package:todi/services/api_service.dart';

class Notice extends StatefulWidget {
  const Notice({super.key});

  @override
  State<Notice> createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  List<dynamic> showNotices = [];

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    showNotices = await getNoticeList();
    setState(() {});
  }

  Future<List> getNoticeList() async {
    ApiService api = ApiService();

    List noticeList = await api.getNotice();

    if (noticeList.isNotEmpty) {
      return noticeList;
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    // double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
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
          '공지사항',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: screenHeight - 30,
              child: ListView.builder(
                itemCount: showNotices.length,
                itemBuilder: (context, index) {
                  final list = showNotices[index];

                  return Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Notices(
                      title: list.title,
                      content: list.content,
                      date: list.date,
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Notices extends StatefulWidget {
  final String title, content, date;

  const Notices({
    super.key,
    required this.title,
    required this.content,
    required this.date,
  });

  @override
  State<Notices> createState() => _NoticesState();
}

class _NoticesState extends State<Notices> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    // double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    String displayedContent = widget.content;
    if (widget.content.length > 20) {
      displayedContent = '${widget.content.substring(0, 20)}...';
    }
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: SizedBox(
            height: screenHeight / 8,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.date,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            displayedContent,
                          )
                        ],
                      ),
                    ),
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
