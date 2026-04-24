import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../services/event_service.dart';

class BookingsScreen extends StatefulWidget {
  final int refreshKey;

  const BookingsScreen({Key? key, this.refreshKey = 0}) : super(key: key);

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  // Color palette
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkNavy = Color(0xFF1a1a2e);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color purpleCategory = Color(0xFF8B5CF6);
  static const Color orangeCategory = Color(0xFFF97316);
  static const Color greenCategory = Color(0xFF10B981);
  static const Color grayCategory = Color(0xFF6B7280);

  // Status colors
  static const Color upcomingBg = Color(0xFFdcfce7);
  static const Color upcomingText = Color(0xFF166534);
  static const Color ongoingBg = Color(0xFFdbeafe);
  static const Color ongoingText = Color(0xFF1e40af);
  static const Color completedBg = Color(0xFFf3f4f6);
  static const Color completedText = Color(0xFF374151);

  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  void didUpdateWidget(BookingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) {
      _loadBookings();
    }
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final user = AuthService().currentUser;
    if (user == null) {
      debugPrint('[BookingsScreen] No logged-in user found');
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    debugPrint('[BookingsScreen] Loading bookings for userId: ${user.id}');
    try {
      final bookings = await EventService.getUserRegistrations(user.id);
      debugPrint('[BookingsScreen] Got ${bookings.length} bookings');
      if (mounted) {
        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[BookingsScreen] Error loading bookings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'workshop':
        return primaryBlue;
      case 'cultural':
        return purpleCategory;
      case 'sports':
        return orangeCategory;
      case 'hackathon':
        return greenCategory;
      default:
        return grayCategory;
    }
  }

  Map<String, Color> _getStatusColors(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return {'bg': upcomingBg, 'text': upcomingText};
      case 'ongoing':
        return {'bg': ongoingBg, 'text': ongoingText};
      case 'completed':
        return {'bg': completedBg, 'text': completedText};
      default:
        return {'bg': upcomingBg, 'text': upcomingText};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Bookings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkNavy,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your registered events',
                style: TextStyle(
                  fontSize: 13,
                  color: gray400,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: primaryBlue,
                        ),
                      )
                    : _errorMessage != null
                        ? _buildErrorState(_errorMessage!)
                        : _bookings.isEmpty
                            ? _buildEmptyState()
                            : RefreshIndicator(
                                onRefresh: _loadBookings,
                                color: primaryBlue,
                                child: _buildBookingsList(),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Failed to load bookings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkNavy,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error,
              style: const TextStyle(fontSize: 11, color: gray400),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadBookings,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 60,
            color: gray400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No bookings yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkNavy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Register for events to see them here',
            style: TextStyle(
              fontSize: 13,
              color: gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList() {
    return ListView.separated(
      itemCount: _bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildBookingCard(_bookings[index]);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    // Supabase join: booking has 'events' nested object
    final event = (booking['events'] as Map<String, dynamic>?) ?? {};

    final title = event['title']?.toString() ?? 'Event';
    final category = event['category']?.toString() ?? 'Event';
    final date = event['date']?.toString() ?? 'TBD';
    final venue = event['venue']?.toString() ?? 'TBD';
    final status = event['status']?.toString() ?? 'Upcoming';
    final price = (event['price'] as num?)?.toInt() ?? 0;
    final isFree = price == 0;
    final bookingId = booking['booking_id']?.toString() ?? 'N/A';
    final statusColors = _getStatusColors(status);

    return GestureDetector(
      onTap: () => _showBookingDetails(booking),
      child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: gray400.withOpacity(0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: darkNavy,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.confirmation_num_outlined,
                size: 14,
                color: primaryBlue,
              ),
              const SizedBox(width: 6),
              Text(
                'Booking ID: $bookingId',
                style: const TextStyle(
                  fontSize: 12,
                  color: primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: gray400.withOpacity(0.2), thickness: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: gray400),
              const SizedBox(width: 6),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: gray600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: gray400),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  venue,
                  style: const TextStyle(fontSize: 12, color: gray600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isFree ? 'Free' : '₹$price',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isFree ? const Color(0xFF22c55e) : darkNavy,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColors['bg'],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColors['text'],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: gray400,
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

  void _showBookingDetails(Map<String, dynamic> booking) {
    final event = (booking['events'] as Map<String, dynamic>?) ?? {};
    final bookingId = booking['booking_id']?.toString() ?? 'N/A';
    final registeredAt = booking['created_at']?.toString() ?? '';
    final title = event['title']?.toString() ?? 'Event';
    final category = event['category']?.toString() ?? '';
    final date = event['date']?.toString() ?? 'TBD';
    final venue = event['venue']?.toString() ?? 'TBD';
    final organizer = event['organizer']?.toString() ?? 'College Department';
    final description = event['description']?.toString() ?? 'No description available.';
    final status = event['status']?.toString() ?? 'Upcoming';
    final price = (event['price'] as num?)?.toInt() ?? 0;
    final isFree = price == 0;
    final seatsLeft = event['seats_left'];
    final totalSeats = event['total_seats'];
    final statusColors = _getStatusColors(status);

    // Format registered date
    String registeredDisplay = '';
    if (registeredAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(registeredAt).toLocal();
        registeredDisplay =
            '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        registeredDisplay = registeredAt;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.82,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: gray400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColors['bg'],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColors['text'],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkNavy,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Booking confirmation banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFf0fdf4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF86efac)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF16a34a), size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Registration Confirmed',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF16a34a),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        'ID: $bookingId',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: primaryBlue,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(text: bookingId));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Booking ID copied'),
                                              duration: Duration(seconds: 1),
                                              backgroundColor: Color(0xFF16a34a),
                                            ),
                                          );
                                        },
                                        child: const Icon(
                                          Icons.copy_rounded,
                                          size: 14,
                                          color: primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Details section
                      const Text(
                        'Event Details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: darkNavy,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _detailRow(Icons.calendar_today_outlined, 'Date & Time', date),
                      const SizedBox(height: 12),
                      _detailRow(Icons.location_on_outlined, 'Venue', venue),
                      const SizedBox(height: 12),
                      _detailRow(Icons.person_outline, 'Organizer', organizer),
                      const SizedBox(height: 12),
                      _detailRow(
                        Icons.event_seat_outlined,
                        'Seats',
                        seatsLeft != null && totalSeats != null
                            ? '$seatsLeft of $totalSeats available'
                            : 'N/A',
                      ),
                      if (registeredDisplay.isNotEmpty) ...
                        [
                          const SizedBox(height: 12),
                          _detailRow(Icons.access_time_rounded, 'Registered On', registeredDisplay),
                        ],
                      const SizedBox(height: 20),
                      Divider(color: gray400.withOpacity(0.25)),
                      const SizedBox(height: 16),
                      const Text(
                        'About this event',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: darkNavy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: gray400,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              // Bottom bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: gray400.withOpacity(0.15)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Entry Fee',
                          style: TextStyle(fontSize: 11, color: gray400),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isFree ? 'Free' : '₹$price',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isFree ? const Color(0xFF22c55e) : darkNavy,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFdcfce7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 16, color: Color(0xFF16a34a)),
                          SizedBox(width: 6),
                          Text(
                            'You\'re Registered',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF16a34a),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryBlue, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: gray400,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: darkNavy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
