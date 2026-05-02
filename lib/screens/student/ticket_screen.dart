import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TicketScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const TicketScreen({super.key, required this.booking});

  static const Color _darkNavy = Color(0xFF1a1a2e);
  static const Color _bgColor = Color(0xFFF0F4FF);

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'workshops':
        return const Color(0xFF2563EB);
      case 'hackathons':
        return const Color(0xFF10B981);
      case 'cultural':
        return const Color(0xFF8B5CF6);
      case 'sports':
        return const Color(0xFFF97316);
      case 'seminar':
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatEventDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final dayName = days[dt.weekday - 1];
      final rawHour = dt.hour;
      final hour = rawHour > 12
          ? rawHour - 12
          : (rawHour == 0 ? 12 : rawHour);
      final period = rawHour >= 12 ? 'PM' : 'AM';
      return '$dayName, ${months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}  •  $hour:${dt.minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return raw;
    }
  }

  String _formatRegisteredAt(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  •  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = (booking['events'] as Map<String, dynamic>?) ?? {};
    final title = event['title']?.toString() ?? 'Event';
    final category = event['category']?.toString() ?? 'Other';
    final rawDate = event['date']?.toString() ?? '';
    final venue = event['venue']?.toString() ?? 'TBD';
    final organizer = event['organizer']?.toString() ?? 'EventNexus';
    final price = (event['price'] as num?)?.toInt() ?? 0;
    final isFree = price == 0;
    final bookingId = booking['booking_id']?.toString() ?? 'N/A';
    final registeredAt = booking['created_at']?.toString() ?? '';

    final categoryColor = _getCategoryColor(category);
    final dateDisplay =
        rawDate.isNotEmpty ? _formatEventDate(rawDate) : 'Date TBD';
    final registeredDisplay =
        registeredAt.isNotEmpty ? _formatRegisteredAt(registeredAt) : '';

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _darkNavy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Ticket',
          style: TextStyle(
            color: _darkNavy,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: _darkNavy, size: 20),
            tooltip: 'Copy Booking ID',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: bookingId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Booking ID copied!'),
                  backgroundColor: const Color(0xFF16a34a),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              _buildTicket(
                title: title,
                category: category,
                categoryColor: categoryColor,
                dateDisplay: dateDisplay,
                venue: venue,
                organizer: organizer,
                price: price,
                isFree: isFree,
                bookingId: bookingId,
                registeredDisplay: registeredDisplay,
              ),
              const SizedBox(height: 24),
              // Share hint
              Text(
                'Show this ticket at the event entrance',
                style: TextStyle(
                  color: _darkNavy.withOpacity(0.45),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicket({
    required String title,
    required String category,
    required Color categoryColor,
    required String dateDisplay,
    required String venue,
    required String organizer,
    required int price,
    required bool isFree,
    required String bookingId,
    required String registeredDisplay,
  }) {
    const double notchRadius = 18.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // ── TOP DARK SECTION ───────────────────────────────────
            _buildTopSection(
              title: title,
              category: category,
              categoryColor: categoryColor,
              dateDisplay: dateDisplay,
              venue: venue,
              organizer: organizer,
              price: price,
              isFree: isFree,
            ),
            // ── PERFORATED TEAR LINE ───────────────────────────────
            _buildTearLine(notchRadius: notchRadius),
            // ── BOTTOM STUB ────────────────────────────────────────
            _buildBottomStub(
              bookingId: bookingId,
              registeredDisplay: registeredDisplay,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection({
    required String title,
    required String category,
    required Color categoryColor,
    required String dateDisplay,
    required String venue,
    required String organizer,
    required int price,
    required bool isFree,
  }) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1a1a2e),
      child: Stack(
        children: [
          // Dot texture overlay
          Positioned.fill(
            child: CustomPaint(painter: _DotPatternPainter()),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand + category row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.event_rounded,
                              color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'EventNexus',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: categoryColor.withOpacity(0.55), width: 1),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: categoryColor == const Color(0xFF2563EB)
                              ? const Color(0xFF93C5FD)
                              : categoryColor.withOpacity(0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Event title
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 22),

                // Separator
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.1),
                ),

                const SizedBox(height: 20),

                // Info rows
                _infoRow(Icons.calendar_today_rounded, dateDisplay),
                const SizedBox(height: 14),
                _infoRow(Icons.location_on_rounded, venue),
                const SizedBox(height: 14),
                _infoRow(Icons.person_rounded, 'Organised by $organizer'),

                const SizedBox(height: 24),

                // Entry fee strip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.1), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ENTRY FEE',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        isFree ? 'FREE' : 'Rs $price',
                        style: TextStyle(
                          color: isFree
                              ? const Color(0xFF4ADE80)
                              : Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
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
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white38, size: 15),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTearLine({required double notchRadius}) {
    return SizedBox(
      height: notchRadius * 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // White strip
          Positioned.fill(
            child: Container(color: Colors.white),
          ),
          // Dashed line centered vertically
          Positioned(
            left: notchRadius,
            right: notchRadius,
            top: notchRadius - 0.75,
            child: CustomPaint(
              painter: _DashedLinePainter(),
              child: const SizedBox(height: 1.5),
            ),
          ),
          // Left semicircle notch (positioned so center aligns with left edge)
          Positioned(
            left: -notchRadius,
            top: 0,
            child: Container(
              width: notchRadius * 2,
              height: notchRadius * 2,
              decoration: const BoxDecoration(
                color: _bgColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Right semicircle notch
          Positioned(
            right: -notchRadius,
            top: 0,
            child: Container(
              width: notchRadius * 2,
              height: notchRadius * 2,
              decoration: const BoxDecoration(
                color: _bgColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStub({
    required String bookingId,
    required String registeredDisplay,
  }) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Confirmed badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Color(0xFF16a34a), size: 14),
                SizedBox(width: 5),
                Text(
                  'BOOKING CONFIRMED',
                  style: TextStyle(
                    color: Color(0xFF16a34a),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: ID + registered date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BOOKING ID',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 10,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      bookingId,
                      style: const TextStyle(
                        color: Color(0xFF1a1a2e),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.8,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (registeredDisplay.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'REGISTERED ON',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 10,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        registeredDisplay,
                        style: const TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Right: QR placeholder
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color(0xFFE5E7EB), width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFFAFAFA),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  size: 54,
                  color: Color(0xFF1a1a2e),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Custom Painters ───────────────────────────────────────────────────────────

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    const spacing = 22.0;
    const radius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPatternPainter old) => false;
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 7.0;
    const dashSpace = 5.0;
    double startX = 0;
    final y = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(
          Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => false;
}
