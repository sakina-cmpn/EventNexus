import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';

class EventRegistrationsScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const EventRegistrationsScreen({
    Key? key,
    required this.eventId,
    required this.eventTitle,
  }) : super(key: key);

  @override
  State<EventRegistrationsScreen> createState() =>
      _EventRegistrationsScreenState();
}

class _EventRegistrationsScreenState extends State<EventRegistrationsScreen> {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkNavy = Color(0xFF1a1a2e);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color greenSuccess = Color(0xFF22c55e);

  List<Map<String, dynamic>> _registrations = [];
  bool _isLoading = true;
  String _searchQuery = '';
  Map<String, dynamic>? _eventData;

  @override
  void initState() {
    super.initState();
    _loadRegistrations();
  }

  Future<void> _loadRegistrations() async {
    setState(() => _isLoading = true);

    try {
      final result = await AdminService.getEventWithRegistrations(widget.eventId);

      if (mounted) {
        setState(() {
          _eventData = result?['event'] as Map<String, dynamic>?;
          _registrations = List<Map<String, dynamic>>.from(result?['registrations'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[EventRegistrations] Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredRegistrations {
    if (_searchQuery.isEmpty) return _registrations;

    final query = _searchQuery.toLowerCase();
    return _registrations.where((reg) {
      final name = (reg['user_name']?.toString() ?? '').toLowerCase();
      final email = (reg['user_email']?.toString() ?? '').toLowerCase();
      final bookingId = (reg['booking_id']?.toString() ?? '').toLowerCase();

      return name.contains(query) ||
             email.contains(query) ||
             bookingId.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalSeats = (_eventData?['total_seats'] as num?)?.toInt() ?? 0;
    final seatsLeft = (_eventData?['seats_left'] as num?)?.toInt() ?? 0;
    final filledSeats = totalSeats - seatsLeft;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.eventTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '$filledSeats registrations',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRegistrations,
            color: Colors.white,
          ),
          IconButton(
            icon: Badge(
              label: Text(_registrations.length.toString()),
              child: const Icon(Icons.download_outlined),
            ),
            onPressed: () {
              // TODO: Export to CSV
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('TODO: Export to CSV (teammate task)'),
                  backgroundColor: primaryBlue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            color: Colors.white,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryBlue),
            )
          : Column(
              children: [
                _buildSearchBar(),
                _buildStatsRow(),
                Expanded(
                  child: _filteredRegistrations.isEmpty
                      ? _buildEmptyState()
                      : _buildRegistrationsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search by name, email, or booking ID',
          hintStyle: const TextStyle(color: gray400, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: primaryBlue, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final registeredCount = _registrations.length;
    final seatsLeft = (_eventData?['seats_left'] as num?)?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, primaryBlue.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Registrations',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$registeredCount',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seats Remaining',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$seatsLeft',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.confirmation_number,
              color: Colors.white,
              size: 30,
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
            Icons.people_outline,
            size: 80,
            color: gray400.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No registrations yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: gray600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Registrations will appear here',
            style: TextStyle(
              fontSize: 13,
              color: gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredRegistrations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final reg = _filteredRegistrations[index];
        final userName = reg['user_name']?.toString() ?? 'Unknown';
        final userEmail = reg['user_email']?.toString() ?? '';
        final bookingId = reg['booking_id']?.toString() ?? '';
        final registeredAt = reg['registered_at'] as String?;

        String timeAgo = 'Just now';
        String fullDate = '';
        if (registeredAt != null) {
          try {
            final dt = DateTime.parse(registeredAt);
            final diff = DateTime.now().difference(dt);
            if (diff.inHours < 1) {
              timeAgo = '${diff.inMinutes}m ago';
            } else if (diff.inDays < 1) {
              timeAgo = '${diff.inHours}h ago';
            } else {
              timeAgo = '${diff.inDays}d ago';
            }
            fullDate = DateFormat('MMM dd, yyyy • h:mm a').format(dt);
          } catch (_) {}
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryBlue.withOpacity(0.2),
                      primaryBlue.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: darkNavy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: const TextStyle(
                        fontSize: 12,
                        color: gray400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: greenSuccess.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.tag,
                                size: 10,
                                color: greenSuccess,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                bookingId,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: greenSuccess,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time, size: 12, color: gray400),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            fontSize: 11,
                            color: gray400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // More info button
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: gray400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: primaryBlue),
                        SizedBox(width: 10),
                        Text('View Details'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'copy',
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 18, color: primaryBlue),
                        SizedBox(width: 10),
                        Text('Copy Booking ID'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'email',
                    child: Row(
                      children: [
                        Icon(Icons.email_outlined, size: 18, color: primaryBlue),
                        SizedBox(width: 10),
                        Text('Send Email'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'details':
                      _showRegistrationDetails(reg, fullDate);
                      break;
                    case 'copy':
                      // Copy booking ID to clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied: $bookingId'),
                          backgroundColor: greenSuccess,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                      break;
                    case 'email':
                      // TODO: Open email client
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('TODO: Open email client'),
                          backgroundColor: primaryBlue,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      break;
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRegistrationDetails(Map<String, dynamic> reg, String registeredDate) {
    final userName = reg['user_name']?.toString() ?? 'Unknown';
    final userEmail = reg['user_email']?.toString() ?? '';
    final bookingId = reg['booking_id']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Registration Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkNavy,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                    color: gray400,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _detailCard(
                    icon: Icons.person,
                    title: 'Student Name',
                    content: userName,
                  ),
                  const SizedBox(height: 12),
                  _detailCard(
                    icon: Icons.email,
                    title: 'Email Address',
                    content: userEmail,
                  ),
                  const SizedBox(height: 12),
                  _detailCard(
                    icon: Icons.tag,
                    title: 'Booking ID',
                    content: bookingId,
                    isMonospace: true,
                  ),
                  const SizedBox(height: 12),
                  _detailCard(
                    icon: Icons.event,
                    title: 'Event',
                    content: widget.eventTitle,
                  ),
                  const SizedBox(height: 12),
                  _detailCard(
                    icon: Icons.access_time,
                    title: 'Registered At',
                    content: registeredDate.isNotEmpty
                        ? registeredDate
                        : 'Unknown',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('TODO: Mark attendance (teammate task)'),
                            backgroundColor: primaryBlue,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Mark as Attended'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenSuccess,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard({
    required IconData icon,
    required String title,
    required String content,
    bool isMonospace = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: primaryBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: gray400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: darkNavy,
              fontWeight: FontWeight.w500,
              fontFamily: isMonospace ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }
}
