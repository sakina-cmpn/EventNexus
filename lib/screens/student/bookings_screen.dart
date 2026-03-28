import 'package:flutter/material.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({Key? key}) : super(key: key);

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

  final List<Map<String, dynamic>> _dummyBookings = [
    {
      'bookingId': 'EN-ABC123',
      'title': 'Tech Workshop',
      'category': 'Workshop',
      'date': '12 Feb, 2PM',
      'venue': 'Auditorium A',
      'status': 'Upcoming',
      'price': 50,
    },
    {
      'bookingId': 'EN-XYZ789',
      'title': 'Cultural Fest',
      'category': 'Cultural',
      'date': '15 Feb, 6PM',
      'venue': 'Main Hall',
      'status': 'Upcoming',
      'price': 0,
    },
  ];

  /// Get category badge color
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

  /// Get status pill colors
  Map<String, Color> _getStatusColors(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return {'bg': upcomingBg, 'text': upcomingText};
      case 'ongoing':
        return {'bg': ongoingBg, 'text': ongoingText};
      case 'completed':
        return {'bg': completedBg, 'text': completedText};
      default:
        return {'bg': completedBg, 'text': completedText};
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
              // Title
              const Text(
                'My Bookings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkNavy,
                ),
              ),
              const SizedBox(height: 4),
              // Subtitle
              const Text(
                'Your registered events',
                style: TextStyle(
                  fontSize: 13,
                  color: gray400,
                ),
              ),
              const SizedBox(height: 20),
              // Bookings list or empty state
              Expanded(
                child: _dummyBookings.isEmpty
                    ? _buildEmptyState()
                    : _buildBookingsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build empty state widget
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
          Text(
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

  /// Build bookings list
  Widget _buildBookingsList() {
    return ListView.separated(
      itemCount: _dummyBookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = _dummyBookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  /// Build booking card
  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final isFree = (booking['price'] as int?) == 0;
    final price = booking['price'] as int? ?? 0;
    final statusColors = _getStatusColors(booking['status']?.toString() ?? '');

    return Container(
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
          // Top row: Event title + category badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Expanded(
                child: Text(
                  booking['title']?.toString() ?? 'Event',
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
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    booking['category']?.toString() ?? 'Default',
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking['category']?.toString() ?? 'Event',
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
          // Booking ID row
          Row(
            children: [
              const Icon(
                Icons.confirmation_num_outlined,
                size: 14,
                color: primaryBlue,
              ),
              const SizedBox(width: 6),
              Text(
                'Booking ID: ${booking['bookingId']?.toString() ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Divider
          Divider(
            color: gray400.withOpacity(0.2),
            thickness: 1,
          ),
          const SizedBox(height: 10),
          // Date row
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: gray400,
              ),
              const SizedBox(width: 6),
              Text(
                booking['date']?.toString() ?? 'TBD',
                style: const TextStyle(
                  fontSize: 12,
                  color: gray600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Venue row
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: gray400,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  booking['venue']?.toString() ?? 'TBD',
                  style: const TextStyle(
                    fontSize: 12,
                    color: gray600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bottom row: Price + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price
              Text(
                isFree ? 'Free' : '₹$price',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isFree ? const Color(0xFF22c55e) : darkNavy,
                ),
              ),
              // Status pill
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
                  booking['status']?.toString() ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColors['text'],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
