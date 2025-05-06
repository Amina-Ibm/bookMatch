import 'package:bookmatch/screens/homeView.dart';
import 'package:bookmatch/screens/recommendationsScreen.dart';
import 'package:bookmatch/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:bookmatch/screens/searchBookScreen.dart';
import 'package:bookmatch/screens/readingListScreen.dart';

import '../widgets/appDrawer.dart';
import 'bookScannerScreen.dart';

class mainScreen extends StatefulWidget {
  @override
  _mainScreenState createState() => _mainScreenState();
}

class _mainScreenState extends State<mainScreen> {
  int _selectedIndex = 0;


  final List<Widget> _screens = [
    HomeScreen(),
    searchBookScreen(),
    readingListScreen(),
    RecommendationsScreen(),
    BookScannerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(onLogout: AuthService().logout,),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
        child: GNav(
          gap: 4,
          activeColor: Colors.white,
          color: Colors.grey[800],
          backgroundColor: Colors.white,
          tabBackgroundColor: Colors.blue,
          padding: const EdgeInsets.all(12),
          tabs: [
            GButton(
              iconActiveColor: Colors.red,
              iconColor: Colors.black,
              textColor: Colors.red,
              backgroundColor: Colors.red.withOpacity(.2),
              iconSize: 24,
              icon: Icons.home,
              text: 'Home',
            ),
            GButton(
              iconActiveColor: Colors.purple,
              iconColor: Colors.black,
              textColor: Colors.purple,
              backgroundColor: Colors.purple.withOpacity(.2),
              iconSize: 24,
              icon: Icons.search,
              text: 'Search',
            ),
            GButton(
              iconActiveColor: Colors.pink,
              iconColor: Colors.black,
              textColor: Colors.pink,
              backgroundColor: Colors.pink.withOpacity(.2),
              iconSize: 24,
              icon: Icons.library_books,
              text: 'List',
            ),
            GButton(
              iconActiveColor: Colors.blue,
              iconColor: Colors.black,
              textColor: Colors.blue,
              backgroundColor: Colors.blue.withOpacity(.2),
              iconSize: 24,
              icon: Icons.book,
              text: 'Recs',
            ),
            GButton(
              iconActiveColor: Colors.green,
              iconColor: Colors.black,
              textColor: Colors.green,
              backgroundColor: Colors.green.withOpacity(.2),
              iconSize: 24,
              icon: Icons.barcode_reader,
              text: 'Scanner',
            ),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });

          },
        ),
      ),
    );
  }
}
