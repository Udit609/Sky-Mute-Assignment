import 'package:flutter/material.dart';
import 'package:sky_mute/screens/camera_screen.dart';
import 'package:sky_mute/screens/gallery_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);

  List<Widget> screens = [
    GalleryScreen(),
    CameraScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void onNavButtonTapped(int index) {
    setState(() {
      currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: onPageChanged,
            children: screens,
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: navigationButton(),
          ),
        ],
      ),
    );
  }

  Widget navigationButton() {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 3.5, vertical: 20.0),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            decoration: BoxDecoration(
              color: currentIndex == 0 ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: IconButton(
              icon: Icon(
                Icons.photo,
                color: currentIndex == 0 ? Colors.white : Colors.blue,
                size: 32,
              ),
              onPressed: () => onNavButtonTapped(0),
            ),
          ),
          SizedBox(width: 10.0),
          Container(
            height: 40,
            width: 1.0,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          SizedBox(width: 10.0),
          Container(
            decoration: BoxDecoration(
              color: currentIndex == 1 ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: IconButton(
              icon: Icon(
                Icons.camera_alt,
                color: currentIndex == 1 ? Colors.white : Colors.blue,
                size: 32,
              ),
              onPressed: () => onNavButtonTapped(1),
            ),
          ),
        ],
      ),
    );
  }
}
