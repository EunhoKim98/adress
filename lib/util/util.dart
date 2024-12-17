import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

String KEY = 'U01TX0FVVEgyMDI0MTEyMjE0NTAyNjExNTI1NzU=';

// 주소 검색
Future<List> search(String address) async {
  final String url = 'https://business.juso.go.kr/addrlink/addrEngApiJsonp.do';

  // 파라미터 설정
  final Map<String, String> params = {
    'currentPage': '1',
    'countPerPage': '100',
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
      String jsonResponse = jsonpResponse.substring(
          jsonpResponse.indexOf('(') + 1, jsonpResponse.lastIndexOf(')'));

      Map<String, dynamic> data = json.decode(jsonResponse);
      data = data['results'];

      // 파싱된 데이터 출력
      // print('juso');
      return data['juso']; // 실제 데이터 반환

    } else {
      print('요청 실패: ${response.statusCode}');
      return []; // 실패 시 빈 리스트 반환
    }
  } catch (e) {
    print('예외 처리: $e');
    return []; // 예외 발생 시 빈 리스트 반환
  }
}


class BannerAdWidget extends StatefulWidget {
  final double width;
  final double height;
  final String adUnitId;

  const BannerAdWidget({
    super.key,
    required this.width,
    required this.height,
    required this.adUnitId,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState(
    width: width,
    height: height,
    adUnitId: adUnitId,
  );
}

class _BannerAdWidgetState extends State<BannerAdWidget> with WidgetsBindingObserver {
  final double width;
  final double height;
  final String adUnitId;

  BannerAd? _bannerAd;

  _BannerAdWidgetState({
    required this.width,
    required this.height,
    required this.adUnitId,
  });

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox( // SizedBox 같은거로 영역을 제한하지 않으면 오류 발생할 수 있음
      width: width,
      height: height,
      child: _bannerAd != null ? AdWidget(ad: _bannerAd!) : const Text(''),
    );
  }

  void _loadAd() {
    setState(() {
      _bannerAd = null;
    });

    BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize(
        width: width.toInt(),
        height: height.toInt(),
      ),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
        onAdOpened: (Ad ad) {},
        onAdClosed: (Ad ad) {},
        onAdImpression: (Ad ad) {},
      ),
    ).load();
  }
}