import 'dart:convert';
import 'package:http/http.dart' as http;

String KEY = 'U01TX0FVVEgyMDI0MTEyMjE0NTAyNjExNTI1NzU=';

// 주소 검색
void search(String address) async {
  print(address);
  final String url = 'https://business.juso.go.kr/addrlink/addrEngApiJsonp.do';

  // 파라미터 설정
  final Map<String, String> params = {
    'currentPage': '1',
    'countPerPage': '2',
    'resultType': 'json',
    'confmKey': KEY,
    'keyword': address // 'keyword'에 'address'를 사용
  };

  // URL에 파라미터 추가
  final uri = Uri.parse(url).replace(queryParameters: params);

  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      String jsonpResponse = response.body;
      String jsonResponse = jsonpResponse.substring(jsonpResponse.indexOf('(') + 1, jsonpResponse.lastIndexOf(')'));

      Map<String, dynamic> data = json.decode(jsonResponse);
      data = data['results'];

      final int totalCount = int.parse(data['common']['totalCount']);
      final int countPerPage =  int.parse(data['common']['countPerPage']);
      final int currentPage =  int.parse(data['common']['currentPage']);

      // 페이지네이션 생성
      List pageBar = makePagination(totalCount, countPerPage, currentPage);
      print(pageBar);

      // 파싱된 데이터 출력
      print('juso');
      print(data['juso']);
    } else {
      print('요청 실패: ${response.statusCode}');
    }
  } catch (e) {
    print('예외 처리: $e');
  }
}

List makePagination(int totalCount, int countPerPage, int currentPage) {
  final int totalPages = (totalCount / countPerPage).ceil(); // 전체 페이지 수 계산
  List<int> pages = [];
  int startPage, endPage;

  if (totalPages <= 5) {
    startPage = 1;
    endPage = totalPages;
  } else {
    startPage = (currentPage - 2 > 0) ? currentPage - 2 : 1;
    endPage = (currentPage + 2 < totalPages) ? currentPage + 2 : totalPages;

    if (endPage - startPage < 4) {
      if (startPage == 1) {
        endPage = (totalPages < 5) ? totalPages : 5; // 시작 페이지가 1일 경우 최대 5개
      } else if (endPage == totalPages) {
        startPage = totalPages - 4 > 0 ? totalPages - 4 : 1; // 마지막 페이지일 경우
      }
    }
  }

  for (int i = startPage; i <= endPage; i++) {
    pages.add(i);
  }

  // 페이지네이션 HTML 생성 (여기서는 리스트로 출력)
  return pages;
}