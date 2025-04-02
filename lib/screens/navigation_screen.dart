import 'package:flutter/material.dart';
import 'package:sky_mute/screens/camera_screen.dart';
import 'package:sky_mute/screens/gallery_screen.dart';
import 'package:sky_mute/screens/home_screen.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  List<Widget> screens = [
    HomeScreen(),
    GalleryScreen(),
    CameraScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.4),
              blurRadius: 3.0,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: StylishBottomBar(
          backgroundColor: Colors.black,
          option: AnimatedBarOptions(
            barAnimation: BarAnimation.fade,
            iconStyle: IconStyle.Default,
            iconSize: 32,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          items: [
            BottomBarItem(
              icon: const Icon(Icons.home),
              title: Text(''),
              selectedColor: Colors.blue,
              unSelectedColor: Colors.white,
            ),
            BottomBarItem(
              icon: const Icon(Icons.photo),
              title: Text(''),
              selectedColor: Colors.blue,
              unSelectedColor: Colors.white,
            ),
            BottomBarItem(
              icon: const Icon(Icons.camera_alt),
              title: Text(''),
              selectedColor: Colors.blue,
              unSelectedColor: Colors.white,
            ),
          ],
          hasNotch: true,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
