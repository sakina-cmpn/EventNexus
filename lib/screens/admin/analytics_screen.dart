import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkNavy = Color(0xFF1a1a2e);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color greenSuccess = Color(0xFF22c55e);
  static const Color orangeAccent = Color(0xFFF97316);
  static const Color purpleAccent = Color(0xFF8B5CF6);

  bool _isLoading = true;
  Map<String, int> _categoryData = {};
  Map<String, int> _eventsByStatus = {};
  List<Map<String, dynamic>> _events = [];
  int _totalRevenue = 0;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        AdminService.getEventsByCategory(),
        AdminService.getAllEvents(),
      ]);

      final categoryData = results[0] as Map<String, int>;
      final events = results[1] as List<Map<String, dynamic>>;

      // Calculate revenue from paid events
      int totalRevenue = 0;
      Map<String, int> statusCount = {};

      for (final event in events) {
        final price = (event['price'] as num?)?.toInt() ?? 0;
        final totalSeats = (event['total_seats'] as num?)?.toInt() ?? 0;
        final seatsLeft = (event['seats_left'] as num?)?.toInt() ?? 0;
        final status = (event['status']?.toString() ?? 'Upcoming');

        if (price > 0) {
          totalRevenue += price * (totalSeats - seatsLeft);
        }

        statusCount[status] = (statusCount[status] ?? 0) + 1;
      }

      if (mounted) {
        setState(() {
          _categoryData = categoryData;
          _events = events;
          _eventsByStatus = statusCount;
          _totalRevenue = totalRevenue;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[Analytics] Error loading data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bar_chart, color: primaryBlue, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Analytics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            color: Colors.white,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryBlue),
            )
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              color: primaryBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildRevenueCard(),
                    _buildStatusBreakdown(),
                    _buildCategoryChart(),
                    _buildEventsList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRevenueCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.attach_money, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Revenue',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'From paid event registrations',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '₹$_totalRevenue',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      'Lifetime earnings',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart, color: primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'Events by Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _statusItem('Upcoming', greenSuccess)),
              const SizedBox(width: 12),
              Expanded(child: _statusItem('Ongoing', orangeAccent)),
              const SizedBox(width: 12),
              Expanded(child: _statusItem('Completed', gray400)),
            ],
          ),
          const SizedBox(height: 16),
          // Visual bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: _buildStatusBar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusItem(String status, Color color) {
    final count = _eventsByStatus[status] ?? 0;
    final total = _events.length;
    final percent = total > 0 ? ((count / total) * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$percent%',
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    final upcoming = _eventsByStatus['Upcoming'] ?? 0;
    final ongoing = _eventsByStatus['Ongoing'] ?? 0;
    final completed = _eventsByStatus['Completed'] ?? 0;
    final total = upcoming + ongoing + completed;

    if (total == 0) {
      return Container(color: gray400.withOpacity(0.2));
    }

    return Row(
      children: [
        if (upcoming > 0)
          Expanded(
            flex: upcoming,
            child: Container(color: greenSuccess),
          ),
        if (ongoing > 0)
          Expanded(
            flex: ongoing,
            child: Container(color: orangeAccent),
          ),
        if (completed > 0)
          Expanded(
            flex: completed,
            child: Container(color: gray400),
          ),
      ],
    );
  }

  Widget _buildCategoryChart() {
    if (_categoryData.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxCount = _categoryData.values.isEmpty
        ? 1
        : _categoryData.values.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.category, color: primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'Events by Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ..._categoryData.entries.map((entry) {
            final percent = maxCount > 0 ? ((entry.value / maxCount) * 100).toInt() : 0;
            final color = _getCategoryColor(entry.key);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: darkNavy,
                        ),
                      ),
                      Text(
                        '${entry.value} events',
                        style: TextStyle(
                          fontSize: 12,
                          color: gray400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 10,
                      child: Stack(
                        children: [
                          Container(
                            color: color.withOpacity(0.15),
                          ),
                          FractionallySizedBox(
                            widthFactor: percent / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [color, color.withOpacity(0.7)],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'workshops':
        return primaryBlue;
      case 'hackathons':
        return orangeAccent;
      case 'cultural':
        return purpleAccent;
      case 'sports':
        return greenSuccess;
      default:
        return primaryBlue;
    }
  }

  Widget _buildEventsList() {
    final sortedEvents = List<Map<String, dynamic>>.from(_events)
      ..sort((a, b) {
        final aTotal = (a['total_seats'] as num?)?.toInt() ?? 0;
        final aLeft = (a['seats_left'] as num?)?.toInt() ?? 0;
        final bTotal = (b['total_seats'] as num?)?.toInt() ?? 0;
        final bLeft = (b['seats_left'] as num?)?.toInt() ?? 0;
        final aRegs = aTotal - aLeft;
        final bRegs = bTotal - bLeft;
        return bRegs.compareTo(aRegs);
      });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.leaderboard, color: primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'Most Popular Events',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sortedEvents.take(5).map((event) {
            final title = event['title']?.toString() ?? 'Untitled';
            final totalSeats = (event['total_seats'] as num?)?.toInt() ?? 0;
            final seatsLeft = (event['seats_left'] as num?)?.toInt() ?? 0;
            final filled = totalSeats - seatsLeft;
            final percent = totalSeats > 0 ? ((filled / totalSeats) * 100).toInt() : 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(
                    '#${sortedEvents.indexOf(event) + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: darkNavy,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.event_seat, size: 12, color: gray400),
                            const SizedBox(width: 4),
                            Text(
                              '$filled/$totalSeats registered',
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: percent >= 80
                          ? orangeAccent.withOpacity(0.1)
                          : greenSuccess.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: percent >= 80 ? orangeAccent : greenSuccess,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
