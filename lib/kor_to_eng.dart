import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'util/util.dart';

class KorToEngPage extends StatefulWidget {
  const KorToEngPage({super.key});

  @override
  State<KorToEngPage> createState() => _KorToEngPageState();
}

class _KorToEngPageState extends State<KorToEngPage> {
  late TextEditingController _controller;
  List<Map<String, dynamic>> result = [];

  int currentPage = 0;
  final int pageSize = 6;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String value) async {
    List<dynamic> searchResult = await search(value);
    setState(() {
      result = searchResult.cast<Map<String, dynamic>>();
      currentPage = 0;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$text가 클립보드에 복사되었습니다.')),
      );
    });
  }

  List<Map<String, dynamic>> getCurrentPageData() {
    int startIndex = currentPage * pageSize;
    int endIndex = startIndex + pageSize;
    return result.sublist(startIndex, endIndex > result.length ? result.length : endIndex);
  }

  void _goToPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (result.length / pageSize).ceil();

    int startPage = (currentPage > 2) ? currentPage - 2 : 0;
    int endPage = (startPage + 5 < totalPages) ? startPage + 5 : totalPages;

    if (endPage - startPage < 5 && startPage > 0) {
      startPage = endPage - 5;
    }

    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: "주소입력",
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(5),
          ),
          onSubmitted: (String value) {
            _search(value);
          },
        ),
        Container(height: 10),
        Expanded(
          child: result.isNotEmpty
              ? SingleChildScrollView(
            child: Column(
              children: [
                DataTable(
                  columns: [
                    DataColumn(label: Container(width: 50, child: Text('우편번호', style: TextStyle(fontSize: 10)))),
                    DataColumn(label: Text('한국주소', style: TextStyle(fontSize: 10))),
                    DataColumn(label: Text('영문주소', style: TextStyle(fontSize: 10))),
                  ],
                  rows: getCurrentPageData().map<DataRow>((item) {
                    return DataRow(cells: [
                      DataCell(
                        Container(
                          width: 40,
                          child: GestureDetector(
                            onTap: () => _copyToClipboard(item['zipNo'] ?? ''),
                            child: Text(item['zipNo'] ?? '', style: TextStyle(fontSize: 10)),
                          ),
                        ),
                      ),
                      DataCell(
                        GestureDetector(
                          onTap: () => _copyToClipboard(item['korAddr'] ?? ''),
                          child: Text(item['korAddr'] ?? '', style: TextStyle(fontSize: 10)),
                        ),
                      ),
                      DataCell(
                        GestureDetector(
                          onTap: () => _copyToClipboard(item['roadAddr'] ?? ''),
                          child: Text(item['roadAddr'] ?? '', style: TextStyle(fontSize: 10)),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),

                SizedBox(height: 10),

                // 페이지 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(endPage - startPage, (index) {
                    int pageIndex = startPage + index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: ElevatedButton(
                        onPressed: () => _goToPage(pageIndex),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        ),
                        child: Text(
                          '${pageIndex + 1}',
                          style: TextStyle(
                            fontSize: (currentPage == pageIndex) ? 14 : 12,
                            fontWeight: (currentPage == pageIndex) ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          )
              : Center(child: Text('검색 결과가 없습니다.')),
        ),
      ],
    );
  }
}