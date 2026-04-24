import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../config/admin_access.dart';
import './home_screen.dart';
import './search_screen.dart';
import './bookings_screen.dart';
import './profile_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

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

  /// Check if current user is admin
  bool get _isAdmin {
    final email = AuthService().currentUser?.email ?? '';
    return AdminAccess.isAdminEmail(email);
  }

  @override
  void initState() {
    super.initState();
    final isAdmin = _isAdmin;
    final maxIndex = isAdmin ? 4 : 3;
    _currentIndex = widget.initialIndex.clamp(0, maxIndex).toInt();
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
    // Admin gets a 5th tab for Admin Dashboard
    final isAdmin = _isAdmin;

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
          HomeScreen(onProfileTapped: () => _onTabTapped(isAdmin ? 3 : 2)),
          const SearchScreen(),
          BookingsScreen(refreshKey: _bookingsRefreshKey),
          if (isAdmin) ...[
            const ProfileScreen(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.admin_panel_settings, size: 80, color: Color(0xFF2563EB)),
                  const SizedBox(height: 24),
                  const Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a1a2e),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap the button below to manage events',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const AdminDashboardScreen(),
                          transitionsBuilder: (_, animation, __, child) =>
                              FadeTransition(opacity: animation, child: child),
                          transitionDuration: const Duration(milliseconds: 400),
                        ),
                      );
                    },
                    icon: const Icon(Icons.dashboard),
                    label: const Text('Open Admin Panel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else
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
          type: BottomNavigationBarType.fixed,
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
          items: isAdmin
              ? const [
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
                  BottomNavigationBarItem(
                    icon: Icon(Icons.admin_panel_settings),
                    label: 'Admin',
                  ),
                ]
              : const [
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
