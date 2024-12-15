import 'package:flutter/material.dart';
import 'kor_to_eng.dart';
import 'loadname.dart';
import 'util/util.dart';

void main() {
  runApp(const MyApp());
}

// Stless 선언
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My First App",
      home: MyHomepage(),
    );
  }
}

// MyHomePage
class MyHomepage extends StatefulWidget {
  const MyHomepage({super.key});

  @override
  State<MyHomepage> createState() => _MyHomepageState();
}

class _MyHomepageState extends State<MyHomepage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _index = 0;
  final TextEditingController _searchController = TextEditingController(); // 추가


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _navItems.length, vsync: this);
    _tabController.addListener(tabListener);
  }

  @override
  void dispose() {
    _tabController.removeListener(tabListener);
    _tabController.dispose(); // TabController 메모리 해제
    super.dispose();
  }

  void tabListener() {
    setState(() {
      _index = _tabController.index;
    });
  }

  // 검색 결과 파싱

  @override
  Widget build(BuildContext context) {

    // 앱바 디자인
    _appBar(height) => PreferredSize(
      preferredSize:  Size(MediaQuery.of(context).size.width, height+80 ),
      child: Stack(
        children: <Widget>[
          Container(     // Background
            child: Center(
              child: Text("주소마스터", style: TextStyle(fontSize: 25.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),),),
            color:Theme.of(context).primaryColor,
            height: height+35,
            width: MediaQuery.of(context).size.width,
          ),

          Container(),   // Required some widget in between to float AppBar

          Positioned(    // To take AppBar Size only
            top: 70.0,
            left: 20.0,
            right: 20.0,
            child: AppBar(
              backgroundColor: Colors.white,
              primary: false,
              title: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                      hintText: "주소",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey))),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search, color: Theme.of(context).primaryColor), onPressed: () {
                    String searchText = _searchController.text;
                    search(searchText); // search 함수에 입력된 텍스트 전달
                },),
              ],
            ),
          )

        ],
      ),
    );


    return Scaffold(
      // Appbar
      appBar: _appBar(AppBar().preferredSize.height),

      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          // defaultPage(), 어떻게 만들지 고민
          KorToEngPage(),
          LoadNamePage(),
          // 추가 NavItem은 여기에도 기입
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor, // 선택된 아이템 색상
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이템 색상

        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
        ),
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          _tabController.animateTo(index);
        },
        currentIndex: _index,
        items: _navItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(
              _index == item.index ? item.activeIcon : item.inactiveIcon,
              color: _index == item.index ? Theme.of(context).primaryColor : Colors.grey,
            ),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class NavItem {
  final int index;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const NavItem({
    required this.index,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}

const _navItems = [
  // NavItem(
  //   index: 0,
  //   activeIcon: Icons.home,
  //   inactiveIcon: Icons.home_outlined,
  //   label: 'default',
  // ),
  NavItem(
    index: 0,
    activeIcon: Icons.home,
    inactiveIcon: Icons.home_outlined,
    label: '영문주소변환',
  ),
  NavItem(
    index: 1,
    activeIcon: Icons.calendar_today,
    inactiveIcon: Icons.calendar_today_outlined,
    label: '도로명주소',
  ),
  // 추가적인 NavItem을 여기에 추가할 수 있습니다.
];