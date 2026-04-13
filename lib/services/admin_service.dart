import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Admin service for reading event and registration data from Supabase.
///
/// NOTE: Write operations (create, update, delete) are marked as TODO
/// for teammate to connect to actual Supabase mutations.
class AdminService {
  static final _supabase = Supabase.instance.client;

  // ============================================================================
  // READ OPERATIONS (WORKING - Uses your existing Supabase tables)
  // ============================================================================

  /// Get total count of events in the database
  static Future<int> getTotalEventsCount() async {
    try {
      final response = await _supabase.from('events').select();
      debugPrint('[AdminService] Total events: ${response.length}');
      return response.length;
    } catch (e) {
      debugPrint('[AdminService] Error fetching events count: $e');
      return 0;
    }
  }

  /// Get total count of all registrations
  static Future<int> getTotalRegistrationsCount() async {
    try {
      final response = await _supabase.from('registrations').select();
      debugPrint('[AdminService] Total registrations: ${response.length}');
      return response.length;
    } catch (e) {
      debugPrint('[AdminService] Error fetching registrations count: $e');
      return 0;
    }
  }

  /// Get count of upcoming events
  static Future<int> getUpcomingEventsCount() async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .eq('status', 'Upcoming');
      debugPrint('[AdminService] Upcoming events: ${response.length}');
      return response.length;
    } catch (e) {
      debugPrint('[AdminService] Error fetching upcoming events: $e');
      return 0;
    }
  }

  /// Get count of ongoing events
  static Future<int> getOngoingEventsCount() async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .eq('status', 'Ongoing');
      debugPrint('[AdminService] Ongoing events: ${response.length}');
      return response.length;
    } catch (e) {
      debugPrint('[AdminService] Error fetching ongoing events: $e');
      return 0;
    }
  }

  /// Get all events ordered by created_at descending
  static Future<List<Map<String, dynamic>>> getAllEvents() async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .order('created_at', ascending: false);

      debugPrint('[AdminService] Fetched ${response.length} events');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[AdminService] Error fetching events: $e');
      return [];
    }
  }

  /// Get all registrations for a specific event
  static Future<List<Map<String, dynamic>>> getEventRegistrations(
    String eventId,
  ) async {
    try {
      final response = await _supabase
          .from('registrations')
          .select()
          .eq('event_id', eventId)
          .order('registered_at', ascending: false);

      debugPrint('[AdminService] Fetched ${response.length} registrations for event $eventId');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[AdminService] Error fetching event registrations: $e');
      return [];
    }
  }

  /// Get registrations with event details for a specific event
  static Future<Map<String, dynamic>?> getEventWithRegistrations(
    String eventId,
  ) async {
    try {
      // Fetch event details
      final event = await _supabase
          .from('events')
          .select()
          .eq('id', eventId)
          .maybeSingle();

      if (event == null) return null;

      // Fetch registrations
      final registrations = await getEventRegistrations(eventId);

      return {
        'event': event,
        'registrations': registrations,
      };
    } catch (e) {
      debugPrint('[AdminService] Error fetching event with registrations: $e');
      return null;
    }
  }

  /// Get category-wise event distribution
  static Future<Map<String, int>> getEventsByCategory() async {
    try {
      final events = await getAllEvents();
      final Map<String, int> categoryCount = {};

      for (final event in events) {
        final category = (event['category'] as String?)?.trim() ?? 'Uncategorized';
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }

      debugPrint('[AdminService] Events by category: $categoryCount');
      return categoryCount;
    } catch (e) {
      debugPrint('[AdminService] Error fetching category distribution: $e');
      return {};
    }
  }

  /// Get total seats and filled seats across all events
  static Future<Map<String, int>> getSeatsStats() async {
    try {
      final events = await getAllEvents();
      int totalSeats = 0;
      int filledSeats = 0;

      for (final event in events) {
        final total = (event['total_seats'] as num?)?.toInt() ?? 0;
        final left = (event['seats_left'] as num?)?.toInt() ?? 0;
        totalSeats += total;
        filledSeats += (total - left).clamp(0, total);
      }

      return {
        'total_seats': totalSeats,
        'filled_seats': filledSeats,
      };
    } catch (e) {
      debugPrint('[AdminService] Error fetching seats stats: $e');
      return {'total_seats': 0, 'filled_seats': 0};
    }
  }

  /// Get recent registrations (last 10)
  static Future<List<Map<String, dynamic>>> getRecentRegistrations() async {
    try {
      final response = await _supabase
          .from('registrations')
          .select()
          .order('registered_at', ascending: false)
          .limit(10);

      debugPrint('[AdminService] Fetched ${response.length} recent registrations');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[AdminService] Error fetching recent registrations: $e');
      return [];
    }
  }

  // ============================================================================
  // WRITE OPERATIONS (TODO: Teammate to connect to Supabase)
  // ============================================================================

  /// Create a new event
  ///
  /// TODO: Connect to Supabase insert
  static Future<bool> createEvent({
    required String title,
    required String description,
    required String category,
    required DateTime date,
    required String venue,
    required num price,
    required int totalSeats,
    required String imageUrl,
    String status = 'Upcoming',
  }) async {
    try {
      // TODO: Uncomment below when teammate provides write access
      /*
      final response = await _supabase.from('events').insert({
        'title': title.trim(),
        'description': description.trim(),
        'category': category.trim(),
        'date': date.toIso8601String(),
        'venue': venue.trim(),
        'price': price,
        'total_seats': totalSeats,
        'seats_left': totalSeats,
        'status': status,
        'image_url': imageUrl.trim(),
      });
      debugPrint('[AdminService] Event created: $title');
      return true;
      */

      // Mock success for UI demo
      debugPrint('[AdminService] TODO: createEvent - connect to Supabase');
      return false; // Returns false to show TODO dialog
    } catch (e) {
      debugPrint('[AdminService] Error creating event: $e');
      return false;
    }
  }

  /// Update an existing event
  ///
  /// TODO: Connect to Supabase update
  static Future<bool> updateEvent({
    required String eventId,
    required String title,
    required String description,
    required String category,
    required DateTime date,
    required String venue,
    required num price,
    required int totalSeats,
    required String imageUrl,
    String status = 'Upcoming',
  }) async {
    try {
      // TODO: Uncomment below when teammate provides write access
      /*
      final response = await _supabase
          .from('events')
          .update({
            'title': title.trim(),
            'description': description.trim(),
            'category': category.trim(),
            'date': date.toIso8601String(),
            'venue': venue.trim(),
            'price': price,
            'total_seats': totalSeats,
            'status': status,
            'image_url': imageUrl.trim(),
          })
          .eq('id', eventId);

      debugPrint('[AdminService] Event updated: $title');
      return true;
      */

      // Mock success for UI demo
      debugPrint('[AdminService] TODO: updateEvent - connect to Supabase');
      return false; // Returns false to show TODO dialog
    } catch (e) {
      debugPrint('[AdminService] Error updating event: $e');
      return false;
    }
  }

  /// Delete an event
  ///
  /// TODO: Connect to Supabase delete
  static Future<bool> deleteEvent(String eventId) async {
    try {
      // TODO: Uncomment below when teammate provides write access
      /*
      // First delete all registrations for this event
      await _supabase.from('registrations').delete().eq('event_id', eventId);

      // Then delete the event
      await _supabase.from('events').delete().eq('id', eventId);

      debugPrint('[AdminService] Event deleted: $eventId');
      return true;
      */

      // Mock success for UI demo
      debugPrint('[AdminService] TODO: deleteEvent - connect to Supabase');
      return false; // Returns false to show TODO dialog
    } catch (e) {
      debugPrint('[AdminService] Error deleting event: $e');
      return false;
    }
  }
}
