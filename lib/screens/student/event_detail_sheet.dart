import 'package:eventnexus/services/auth_service.dart';
import 'package:eventnexus/services/event_service.dart';
import 'package:flutter/material.dart';
import '../../services/event_service.dart';
import '../../services/auth_service.dart';

class EventDetailSheet extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetailSheet({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<EventDetailSheet> createState() => _EventDetailSheetState();
}

class _EventDetailSheetState extends State<EventDetailSheet> {
  // State variables
  bool _isRegistering = false;
  bool _isAlreadyRegistered = false;

  // Color palette
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkNavy = Color(0xFF1a1a2e);
  static const Color lightGray = Color(0xFFF1F5FF);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color greenSuccess = Color(0xFF22c55e);
  static const Color purpleCategory = Color(0xFF8B5CF6);
  static const Color orangeCategory = Color(0xFFF97316);
  static const Color greenCategory = Color(0xFF10B981);
  static const Color grayCategory = Color(0xFF6B7280);

  /// Get category badge background color
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

  /// Get status dot color
  Color _getStatusColor(String status) {
    return status.toLowerCase() == 'ongoing' ? primaryBlue : greenSuccess;
  }

  /// Check if event is ongoing or upcoming
  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  /// Check if the current user is already registered for this event
  Future<void> _checkRegistrationStatus() async {
    final user = AuthService().currentUser;
    if (user == null) return;
    final eventId = widget.event['id']?.toString();
    if (eventId == null) return;
    final registered = await EventService.isUserRegistered(
      eventId: eventId,
      userId: user.id,
    );
    if (mounted) setState(() => _isAlreadyRegistered = registered);
  }

  /// Handle user registration for the event
  Future<void> _handleRegister() async {
    final user = AuthService().currentUser;
    if (user == null) return;

    final eventId = widget.event['id']?.toString();
    if (eventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isRegistering = true);

    final success = await EventService.registerForEvent(
      eventId: eventId,
      userId: user.id,
      userEmail: user.email,
      userName: user.name ?? user.email,
    );

    if (mounted) {
      setState(() {
        _isRegistering = false;
        if (success) _isAlreadyRegistered = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Successfully registered! Check your bookings.'
                : 'Already registered for this event.',
          ),
          backgroundColor:
              success ? const Color(0xFF22c55e) : Colors.orange,
        ),
      );
    }
  }

  bool _isOngoing() {
    return widget.event['status']?.toString().toLowerCase() == 'ongoing';
  }

  /// Parse seats from "50/100" format
  String _getAvailableSeats() {
    final seats = widget.event['seats']?.toString() ?? '0/0';
    final parts = seats.split('/');
    if (parts.length == 2) {
      return '${parts[0]} of ${parts[1]} available';
    }
    return seats;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetHeight = screenHeight * 0.75;
    final isFree = (widget.event['price'] as int?) == 0;
    final price = widget.event['price'] as int? ?? 0;

    return Container(
      height: sheetHeight,
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
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: gray400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge and status dot row
                  Row(
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(
                            widget.event['category']?.toString() ?? 'Default',
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.event['category']?.toString() ?? 'Event',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Status dot with label
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                widget.event['status']?.toString() ?? 'Upcoming',
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.event['status']?.toString() ?? 'Upcoming',
                            style: const TextStyle(
                              color: gray600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Event title
                  Text(
                    widget.event['title']?.toString() ?? 'Event Title',
                    style: const TextStyle(
                      color: darkNavy,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Info rows
                  _buildInfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date & Time',
                    value: widget.event['date']?.toString() ?? 'TBD',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Venue',
                    value: widget.event['venue']?.toString() ?? 'TBD',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.people_outline,
                    label: 'Available Seats',
                    value: _getAvailableSeats(),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.person_outline,
                    label: 'Organizer',
                    value: 'College Department',
                  ),
                  const SizedBox(height: 20),
                  // Divider
                  Divider(
                    color: gray400.withOpacity(0.3),
                    thickness: 1,
                  ),
                  const SizedBox(height: 16),
                  // About this event section
                  const Text(
                    'About this event',
                    style: TextStyle(
                      color: darkNavy,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event['description']?.toString() ??
                        'No description available',
                    style: const TextStyle(
                      color: gray400,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Fixed bottom section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: gray400.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Entry Fee',
                      style: TextStyle(
                        color: gray400,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isFree)
                      const Text(
                        'Free',
                        style: TextStyle(
                          color: greenSuccess,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        '₹$price',
                        style: const TextStyle(
                          color: darkNavy,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                // Register button with multiple states
                if (_isOngoing())
                  // Ongoing event - show closed button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: gray400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Closed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (_isAlreadyRegistered)
                  // Already registered - show disabled button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: gray400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Already Registered',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  // Show register button with loading state
                  Material(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _isRegistering ? null : _handleRegister,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                        child: _isRegistering
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Register Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build an info row with icon, label, and value
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon container
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: lightGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              icon,
              color: primaryBlue,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Label and value
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: gray400,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: darkNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
