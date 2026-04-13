import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';
import 'event_registrations_screen.dart';
import 'create_event_screen.dart';

class ManageEventsScreen extends StatefulWidget {
  final bool showRegistrationsOnly;

  const ManageEventsScreen({
    Key? key,
    this.showRegistrationsOnly = false,
  }) : super(key: key);

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkNavy = Color(0xFF1a1a2e);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color greenSuccess = Color(0xFF22c55e);
  static const Color orangeAccent = Color(0xFFF97316);
  static const Color redError = Color(0xFFef4444);

  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All'];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    try {
      final events = await AdminService.getAllEvents();
      final categories = events
          .map((e) => e['category']?.toString() ?? 'Uncategorized')
          .toSet();

      if (mounted) {
        setState(() {
          _events = events;
          _categories.addAll(categories.where((c) => !_categories.contains(c)));
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[ManageEvents] Error loading events: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredEvents {
    if (_selectedCategory == 'All') return _events;
    return _events
        .where((e) => e['category']?.toString() == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        title: const Text(
          'Manage Events',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
            color: Colors.white,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryBlue,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.event), text: 'Events'),
            Tab(icon: Icon(Icons.people), text: 'Registrations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventsList(),
          _buildAllRegistrationsView(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateEventScreen()),
        ),
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.add),
        label: const Text('New Event'),
      ),
    );
  }

  Widget _buildEventsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryBlue),
      );
    }

    return Column(
      children: [
        // Category filter chips
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;

              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) =>
                    setState(() => _selectedCategory = category),
                backgroundColor: Colors.white,
                selectedColor: primaryBlue.withOpacity(0.15),
                checkmarkColor: primaryBlue,
                labelStyle: TextStyle(
                  color: isSelected ? primaryBlue : gray600,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? primaryBlue : Colors.grey.shade300,
                  ),
                ),
              );
            },
          ),
        ),
        // Events list
        Expanded(
          child: _filteredEvents.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredEvents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final event = _filteredEvents[index];
                    return _buildEventCard(event);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: gray400.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No events found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: gray600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + New Event to create one',
            style: TextStyle(
              fontSize: 13,
              color: gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final title = event['title']?.toString() ?? 'Untitled Event';
    final category = event['category']?.toString() ?? 'Uncategorized';
    final dateStr = event['date']?.toString() ?? '';
    final venue = event['venue']?.toString() ?? 'TBA';
    final price = (event['price'] as num?)?.toInt() ?? 0;
    final totalSeats = (event['total_seats'] as num?)?.toInt() ?? 0;
    final seatsLeft = (event['seats_left'] as num?)?.toInt() ?? 0;
    final status = event['status']?.toString() ?? 'Upcoming';
    final imageUrl = event['image_url']?.toString() ?? '';

    DateTime? dateTime;
    try {
      dateTime = DateTime.parse(dateStr);
    } catch (_) {}

    final filledSeats = totalSeats - seatsLeft;
    final occupancyPercent = totalSeats > 0
        ? ((filledSeats / totalSeats) * 100).toInt()
        : 0;

    Color statusColor;
    IconData statusIcon;
    switch (status.toLowerCase()) {
      case 'ongoing':
        statusColor = orangeAccent;
        statusIcon = Icons.play_circle;
        break;
      case 'completed':
        statusColor = gray400;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = greenSuccess;
        statusIcon = Icons.event_available;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event image
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          // Event details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkNavy,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Date and venue
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: gray400),
                    const SizedBox(width: 6),
                    Text(
                      dateTime != null
                          ? DateFormat('MMM dd, yyyy • h:mm a').format(dateTime)
                          : 'Date TBA',
                      style: const TextStyle(
                        fontSize: 12,
                        color: gray600,
                      ),
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
                        style: const TextStyle(
                          fontSize: 12,
                          color: gray600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Price and seats
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: price == 0
                            ? greenSuccess.withOpacity(0.1)
                            : orangeAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            size: 14,
                            color: price == 0 ? greenSuccess : orangeAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            price == 0 ? 'FREE' : '₹$price',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: price == 0 ? greenSuccess : orangeAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_seat,
                              size: 14, color: primaryBlue),
                          const SizedBox(width: 4),
                          Text(
                            '$filledSeats/$totalSeats',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Occupancy indicator
                    SizedBox(
                      width: 60,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$occupancyPercent%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: darkNavy,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'filled',
                            style: const TextStyle(
                              fontSize: 9,
                              color: gray400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: occupancyPercent / 100,
                    backgroundColor: gray400.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      occupancyPercent >= 90
                          ? redError
                          : occupancyPercent >= 50
                              ? orangeAccent
                              : greenSuccess,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 14),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventRegistrationsScreen(
                              eventId: event['id']?.toString() ?? '',
                              eventTitle: title,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.people_outline, size: 18),
                        label: const Text('View Regs'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryBlue,
                          side: const BorderSide(color: primaryBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () => _showEditDialog(event),
                      icon: const Icon(Icons.edit_outlined, color: primaryBlue),
                      style: IconButton.styleFrom(
                        backgroundColor: primaryBlue.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: const Size(44, 44),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showDeleteConfirm(event),
                      icon: const Icon(Icons.delete_outline, color: redError),
                      style: IconButton.styleFrom(
                        backgroundColor: redError.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: const Size(44, 44),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue.withOpacity(0.3), primaryBlue.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.event, size: 50, color: Colors.white54),
    );
  }

  void _showEditDialog(Map<String, dynamic> event) {
    // TODO: Navigate to edit screen (teammate to implement)
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Event'),
        content: const Text(
          'Edit event form UI to be connected to Supabase by teammate.\n\n'
          'For now, this is a demo dialog.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(Map<String, dynamic> event) {
    final title = event['title']?.toString() ?? 'this event';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: redError, size: 28),
            const SizedBox(width: 12),
            const Text('Delete Event?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$title"?\n\n'
          'This will also delete all registrations for this event.\n\n'
          'Note: Delete functionality requires Supabase write access.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Connect to AdminService.deleteEvent()
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'TODO: Connect delete to Supabase (teammate task)',
                  ),
                  backgroundColor: orangeAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: redError,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildAllRegistrationsView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: AdminService.getAllEvents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No events with registrations'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final event = snapshot.data![index];
            final title = event['title']?.toString() ?? 'Untitled';
            final eventId = event['id']?.toString() ?? '';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.event, color: primaryBlue),
                ),
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Tap to view registrations'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventRegistrationsScreen(
                      eventId: eventId,
                      eventTitle: title,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
