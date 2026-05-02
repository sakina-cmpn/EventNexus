import 'package:flutter/material.dart';
import 'package:eventnexus/services/event_service.dart';
import 'package:eventnexus/services/auth_service.dart';
import 'package:eventnexus/screens/student/event_detail_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredEvents = [];
  List<Map<String, dynamic>> _allEvents = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  final Set<String> _registeredEventIds = {};

  final List<String> categories = [
    'All',
    'Workshops',
    'Hackathons',
    'Cultural',
    'Sports',
    'Seminar',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
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
          _allEvents = events;
          _filteredEvents = events;
          _registeredEventIds
            ..clear()
            ..addAll(registeredIds);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading events: $e')),
        );
      }
    }
  }

  void _filterEvents() {
    final searchTerm = _searchController.text.toLowerCase();
    setState(() {
      _filteredEvents = _allEvents.where((event) {
        final matchesSearch =
            event['title'].toString().toLowerCase().contains(searchTerm);
        final matchesCategory =
            _selectedCategory == 'All' || event['category'] == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _showEventDetails(Map<String, dynamic> event) {
    final eventId = event['id']?.toString() ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventDetailSheet(
        event: event,
        onRegistrationSuccess: () {
          if (mounted) {
            setState(() => _registeredEventIds.add(eventId));
          }
        },
      ),
    );
  }

  Color _getCategoryColor(String? category) {
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
        return const Color(0xFF2563EB);
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.event, size: 40, color: Color(0xFF2563EB)),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Search Events',
          style: TextStyle(
            color: Color(0xFF1a1a2e),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _filterEvents(),
                decoration: InputDecoration(
                  hintText: 'Search by event title...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedCategory = category);
                        _filterEvents();
                      },
                      selectedColor: const Color(0xFF2563EB),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF1a1a2e),
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE0E0E0),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
                  : _filteredEvents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_note, size: 64,
                                  color: const Color(0xFF2563EB).withOpacity(0.3)),
                              const SizedBox(height: 16),
                              const Text('No events found',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF666666),
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredEvents.length,
                          itemBuilder: (context, index) =>
                              _buildEventCard(_filteredEvents[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final categoryColor = _getCategoryColor(event['category']);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: event['image_url'] != null &&
                          event['image_url'].toString().isNotEmpty
                      ? Image.network(event['image_url'],
                          width: 80, height: 80, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImagePlaceholder())
                      : _buildImagePlaceholder(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'] ?? 'Unknown Event',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1a1a2e)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event['category'] ?? 'Other',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: categoryColor),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 12, color: Color(0xFF999999)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event['date'] ?? 'N/A',
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF666666)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_registeredEventIds.contains(event['id']?.toString() ?? ''))
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFdcfce7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Color(0xFF16a34a)),
                    SizedBox(width: 6),
                    Text(
                      'Registered',
                      style: TextStyle(
                        color: Color(0xFF16a34a),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showEventDetails(event),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  child: const Text('View Details',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
