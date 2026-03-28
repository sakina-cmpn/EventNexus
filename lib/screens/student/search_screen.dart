import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Color palette
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkNavy = Color(0xFF1a1a2e);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color greenSuccess = Color(0xFF22c55e);
  static const Color purpleCategory = Color(0xFF8B5CF6);
  static const Color orangeCategory = Color(0xFFF97316);
  static const Color greenCategory = Color(0xFF10B981);
  static const Color grayCategory = Color(0xFF6B7280);

  // State variables
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Workshops',
    'Hackathons',
    'Cultural',
    'Sports',
  ];

  final List<Map<String, dynamic>> _dummyEvents = [
    {
      'title': 'Tech Workshop',
      'description': 'CS Seminar',
      'category': 'Workshop',
      'status': 'Upcoming',
      'date': '12 Feb, 2PM',
      'venue': 'Auditorium A',
      'price': 50,
      'seats': '50/100',
    },
    {
      'title': 'Cultural Fest',
      'description': 'Dance Competition',
      'category': 'Cultural',
      'status': 'Upcoming',
      'date': '15 Feb, 6PM',
      'venue': 'Main Hall',
      'price': 0,
      'seats': '120/200',
    },
    {
      'title': 'Sports Day',
      'description': 'Football Match',
      'category': 'Sports',
      'status': 'Ongoing',
      'date': '20 Feb, 4PM',
      'venue': 'Sports Ground',
      'price': 0,
      'seats': '75/200',
    },
    {
      'title': 'Hackathon 2025',
      'description': '24hr Coding Challenge',
      'category': 'Hackathon',
      'status': 'Upcoming',
      'date': '18 Feb, 9AM',
      'venue': 'Tech Block',
      'price': 100,
      'seats': '30/50',
    },
    {
      'title': 'Music Night',
      'description': 'Annual Cultural Show',
      'category': 'Cultural',
      'status': 'Upcoming',
      'date': '22 Feb, 7PM',
      'venue': 'Open Air Theatre',
      'price': 0,
      'seats': '200/300',
    },
    {
      'title': 'AI Workshop',
      'description': 'Machine Learning Basics',
      'category': 'Workshop',
      'status': 'Upcoming',
      'date': '25 Feb, 11AM',
      'venue': 'Lab 3',
      'price': 75,
      'seats': '20/40',
    },
    {
      'title': 'Cricket Match',
      'description': 'Inter Department Tournament',
      'category': 'Sports',
      'status': 'Ongoing',
      'date': '28 Feb, 10AM',
      'venue': 'Ground B',
      'price': 0,
      'seats': '50/100',
    },
    {
      'title': 'Web Dev Bootcamp',
      'description': 'Full Stack Development',
      'category': 'Hackathon',
      'status': 'Upcoming',
      'date': '5 Mar, 10AM',
      'venue': 'Computer Lab',
      'price': 200,
      'seats': '15/30',
    },
  ];

  /// Get filtered events based on search and category
  List<Map<String, dynamic>> get _filteredEvents {
    return _dummyEvents.where((event) {
      // Check category filter
      bool categoryMatch = _selectedCategory == 'All';
      if (!categoryMatch) {
        final eventCategory = event['category'].toString().toLowerCase();
        final selectedCategory = _selectedCategory.toLowerCase();
        categoryMatch = eventCategory == selectedCategory ||
            '${eventCategory}s' == selectedCategory ||
            eventCategory == '${selectedCategory.replaceAll('s', '')}';
      }

      // Check search query
      bool searchMatch = _searchQuery.isEmpty;
      if (!searchMatch) {
        final query = _searchQuery.toLowerCase();
        final title = event['title'].toString().toLowerCase();
        final description = event['description'].toString().toLowerCase();
        searchMatch = title.contains(query) || description.contains(query);
      }

      return categoryMatch && searchMatch;
    }).toList();
  }

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

  /// Get status dot color
  Color _getStatusColor(String status) {
    return status.toLowerCase() == 'ongoing' ? primaryBlue : greenSuccess;
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Search Events',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkNavy,
                ),
              ),
              const SizedBox(height: 16),
              // Search field
              _buildSearchField(),
              const SizedBox(height: 16),
              // Category filter
              _buildCategoryFilter(),
              const SizedBox(height: 20),
              // Events list
              Expanded(
                child: _filteredEvents.isEmpty
                    ? _buildEmptyState()
                    : _buildEventsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build search text field
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() => _searchQuery = value);
      },
      decoration: InputDecoration(
        hintText: 'Search by event name...',
        hintStyle: const TextStyle(
          color: gray400,
          fontSize: 14,
        ),
        prefixIcon: const Icon(
          Icons.search_outlined,
          color: gray400,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, color: gray400),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: primaryBlue,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  /// Build category filter chips
  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = category);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryBlue : Colors.white,
                  border: isSelected
                      ? null
                      : Border.all(
                          color: gray400,
                          width: 1,
                        ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : gray600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No events found',
        style: TextStyle(
          fontSize: 16,
          color: gray400,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Build events list
  Widget _buildEventsList() {
    return ListView.separated(
      itemCount: _filteredEvents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  /// Build event card
  Widget _buildEventCard(Map<String, dynamic> event) {
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
          // Title and category badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Expanded(
                child: Text(
                  event['title']?.toString() ?? 'Event',
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
                    event['category']?.toString() ?? 'Default',
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  event['category']?.toString() ?? 'Event',
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
          // Date and venue row
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: gray400,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  event['date']?.toString() ?? 'TBD',
                  style: const TextStyle(
                    fontSize: 12,
                    color: gray400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.location_on_outlined,
                size: 12,
                color: gray400,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  event['venue']?.toString() ?? 'TBD',
                  style: const TextStyle(
                    fontSize: 12,
                    color: gray400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Status and details button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status dot and text
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        event['status']?.toString() ?? 'Upcoming',
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    event['status']?.toString() ?? 'Upcoming',
                    style: const TextStyle(
                      fontSize: 12,
                      color: gray600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Details button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'View details for ${event['title']}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryBlue,
                      ),
                    ),
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
