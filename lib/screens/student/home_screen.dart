import 'package:eventnexus/screens/login_screen.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'event_detail_sheet.dart';
import '../../services/event_service.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTapped;
  const HomeScreen({Key? key, this.onProfileTapped}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  final Set<String> _registeredEventIds = {};

  final List<String> _categories = [
    'All',
    'Workshops',
    'Hackathons',
    'Cultural',
    'Sports',
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final user = AuthService().currentUser;
    final futures = await Future.wait([
      EventService.getAllEvents(),
      if (user != null) EventService.getRegisteredEventIds(user.id),
    ]);
    final events = futures[0] as List<Map<String, dynamic>>;
    final registeredIds =
        (user != null ? futures[1] : <String>{}) as Set<String>;
    if (mounted) {
      setState(() {
        _events = events;
        _registeredEventIds
          ..clear()
          ..addAll(registeredIds);
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredEvents {
    if (_selectedCategory == 'All') return _events;
    return _events.where((event) {
      final category = event['category'].toString().toLowerCase();
      final selected = _selectedCategory.toLowerCase();
      return category == selected ||
          '${category}s' == selected ||
          category == '${selected}s';
    }).toList();
  }

  Color _getCategoryBadgeColor(String category) {
    switch (category) {
      case 'Workshop':
        return const Color(0xFF2563EB);
      case 'Cultural':
        return const Color(0xFF8B5CF6);
      case 'Sports':
        return const Color(0xFFF97316);
      case 'Hackathon':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Future<void> _handleSignOut() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 20),
              _buildCategoryTabs(),
              const SizedBox(height: 20),
              _buildBanner(),
              const SizedBox(height: 24),
              _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    )
                  : _filteredEvents.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: Text(
                              'No events found',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              for (int i = 0;
                                  i < _filteredEvents.length;
                                  i++) ...[
                                _buildEventCard(_filteredEvents[i]),
                                if (i < _filteredEvents.length - 1)
                                  const SizedBox(height: 16),
                              ]
                            ],
                          ),
                        ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'EventNexus',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1a1a2e),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                    color: const Color(0xFF1a1a2e),
                  ),
                  Positioned(
                    top: 10,
                    right: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF1a1a2e),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onSelected: (String value) {
                  if (value == 'profile') {
                    widget.onProfileTapped?.call();
                  } else if (value == 'signout') {
                    _handleSignOut();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, size: 18),
                        SizedBox(width: 8),
                        Text('My Profile'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'signout',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.logout,
                          size: 18,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.red[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (String category in _categories) ...[
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _selectedCategory == category
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                    if (_selectedCategory == category) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 2,
                        color: const Color(0xFF2563EB),
                      ),
                    ] else
                      const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(width: 24),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&auto=format&fit=crop',
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 160,
                  color: const Color(0xFFEFF6FF),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2563EB),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 160,
                  color: const Color(0xFFEFF6FF),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                );
              },
            ),
            Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.65),
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Campus Events\nMade Easy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Discover & Book Your College Events',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Explore Events',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final bool isFree = event['price'] == 0;
    final Color statusDotColor = event['status'] == 'Ongoing'
        ? const Color(0xFF2563EB)
        : Colors.green;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFe5e7eb),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event['title']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a1a2e),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryBadgeColor(
                        event['category']?.toString() ?? ''),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event['category']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              event['description']?.toString() ?? '',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 10),
            Container(height: 1, color: const Color(0xFFe5e7eb)),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusDotColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  event['status']?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Â·',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  event['date']?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Â·',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event['venue']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isFree)
                  const Text(
                    'Free',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF22C55E),
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  Text(
                    '₹${event['price']} · ${event['seats']} seats',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                Row(
                  children: [
                    SizedBox(
                      height: 32,
                      child: OutlinedButton(
                        onPressed: () {
                          final eventId = event['id']?.toString() ?? '';
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => EventDetailSheet(
                              event: event,
                              onRegistrationSuccess: () {
                                if (mounted) {
                                  setState(() => _registeredEventIds.add(eventId));
                                }
                              },
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12),
                          side: const BorderSide(
                            color: Color(0xFF2563EB),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_registeredEventIds.contains(event['id']?.toString() ?? ''))
                      Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFdcfce7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 14, color: Color(0xFF16a34a)),
                            SizedBox(width: 4),
                            Text(
                              'Registered',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF16a34a),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (isFree)
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {
                            final eventId = event['id']?.toString() ?? '';
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => EventDetailSheet(
                                event: event,
                                onRegistrationSuccess: () {
                                  if (mounted) {
                                    setState(() => _registeredEventIds.add(eventId));
                                  }
                                },
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}