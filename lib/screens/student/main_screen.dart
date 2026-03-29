import 'package:flutter/material.dart';
import './home_screen.dart';
import './search_screen.dart';
import './bookings_screen.dart';
import './profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// Current selected tab index
  int _currentIndex = 0;

  /// Incremented each time the Bookings tab is activated, so BookingsScreen reloads
  int _bookingsRefreshKey = 0;

  /// PageController for instant page switching without animation
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Handle bottom nav tab tap
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 2) _bookingsRefreshKey++;
    });
    // Jump to page without animation
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // PageView for instant switching between screens
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          HomeScreen(onProfileTapped: () => _onTabTapped(3)),
          const SearchScreen(),
          BookingsScreen(refreshKey: _bookingsRefreshKey),
          const ProfileScreen(),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey[200] ?? const Color(0xFFF0F0F0),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.white,
          elevation: 0,
          // Styling for labels
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          selectedItemColor: const Color(0xFF2563EB), // Blue
          unselectedItemColor: const Color(0xFF9CA3AF), // Gray
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
