import 'package:flutter/material.dart';
import 'package:admin/account/AccountPage.dart';
import 'package:admin/data/dataClient.dart';
import 'package:admin/data/dataPenyuluh.dart';
import 'package:admin/auth/LoginPage.dart'; // ✅ Import halaman login

class HomePageAdmin extends StatefulWidget {
  @override
  _HomePageAdminState createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DataClient(),
    DataPenyuluh(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrator'),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
        foregroundColor: Colors.white,

        /// ✅ Tambahkan tombol kembali
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Client',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.engineering),
            label: 'Penyuluh',
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
