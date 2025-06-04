import 'package:flutter/material.dart';
import 'package:admin/account/AccountPage.dart';
import 'package:admin/chat/PertanyaanPage.dart';

class HomePagePenyuluh extends StatefulWidget {
  @override
  _HomePagePenyuluhState createState() => _HomePagePenyuluhState();
}

class _HomePagePenyuluhState extends State<HomePagePenyuluh> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
  PertanyaanPage(),
  AccountPage(),
];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penyuluh'),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
