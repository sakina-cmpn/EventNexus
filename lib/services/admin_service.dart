import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Admin service for reading event and registration data from Supabase.
///
class AdminService {
  static final _supabase = Supabase.instance.client;
  static String? _lastErrorMessage;

  static String? get lastErrorMessage => _lastErrorMessage;

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
  // WRITE OPERATIONS
  // ============================================================================

  /// Create a new event
  ///
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
    _lastErrorMessage = null;
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _lastErrorMessage = 'You must be signed in to create events.';
        return false;
      }
      final userMeta = user.userMetadata ?? const <String, dynamic>{};
      final organizerEmail =
          (user.email ??
                  userMeta['name'] ??
                  userMeta['full_name'] ??
                  userMeta['display_name'] ??
                  'Admin')
              .toString()
              .trim();
      final organizerUid = user.id.toString().trim();

      final titleValue = title.trim();
      final descriptionValue = description.trim();
      final categoryValue = category.trim();
      final venueValue = venue.trim();
      final imageUrlValue = imageUrl.trim();
      final nowIso = DateTime.now().toIso8601String();

      final payloadVariants = <Map<String, dynamic>>[
        // Preferred schema used by this app.
        {
          'title': titleValue,
          'description': descriptionValue,
          'category': categoryValue,
          'date': date.toIso8601String(),
          'venue': venueValue,
          'price': price,
          'total_seats': totalSeats,
          'seats_left': totalSeats,
          'status': status,
          'image_url': imageUrlValue.isEmpty ? null : imageUrlValue,
          'organizer': organizerEmail,
        },
        // Preferred schema with explicit created_at.
        {
          'title': titleValue,
          'description': descriptionValue,
          'category': categoryValue,
          'date': date.toIso8601String(),
          'venue': venueValue,
          'price': price,
          'total_seats': totalSeats,
          'seats_left': totalSeats,
          'status': status,
          'image_url': imageUrlValue.isEmpty ? null : imageUrlValue,
          'organizer': organizerEmail,
          'created_at': nowIso,
        },
        // Same schema using auth uid as organizer (some RLS policies use auth.uid()).
        {
          'title': titleValue,
          'description': descriptionValue,
          'category': categoryValue,
          'date': date.toIso8601String(),
          'venue': venueValue,
          'price': price,
          'total_seats': totalSeats,
          'seats_left': totalSeats,
          'status': status,
          'image_url': imageUrlValue.isEmpty ? null : imageUrlValue,
          'organizer': organizerUid,
        },
        // uid organizer with explicit created_at.
        {
          'title': titleValue,
          'description': descriptionValue,
          'category': categoryValue,
          'date': date.toIso8601String(),
          'venue': venueValue,
          'price': price,
          'total_seats': totalSeats,
          'seats_left': totalSeats,
          'status': status,
          'image_url': imageUrlValue.isEmpty ? null : imageUrlValue,
          'organizer': organizerUid,
          'created_at': nowIso,
        },
        // Same schema without organizer (if that column is absent).
        {
          'title': titleValue,
          'description': descriptionValue,
          'category': categoryValue,
          'date': date.toIso8601String(),
          'venue': venueValue,
          'price': price,
          'total_seats': totalSeats,
          'seats_left': totalSeats,
          'status': status,
          'image_url': imageUrlValue.isEmpty ? null : imageUrlValue,
        },
        // Same schema without organizer with explicit created_at.
        {
          'title': titleValue,
          'description': descriptionValue,
          'category': categoryValue,
          'date': date.toIso8601String(),
          'venue': venueValue,
          'price': price,
          'total_seats': totalSeats,
          'seats_left': totalSeats,
          'status': status,
          'image_url': imageUrlValue.isEmpty ? null : imageUrlValue,
          'created_at': nowIso,
        },
      ];

      Object? lastInsertError;
      for (final payload in payloadVariants) {
        try {
          await _supabase.from('events').insert(payload).select().single();
          debugPrint('[AdminService] Event created: $title');
          return true;
        } catch (e) {
          lastInsertError = e;
          debugPrint('[AdminService] createEvent insert variant failed: $e');
        }
      }

      if (lastInsertError is PostgrestException &&
          (lastInsertError as PostgrestException).code == '42501') {
        _lastErrorMessage =
            'Permission denied by database policy (RLS). Ensure your admin account is authenticated and allowed to insert into events.';
      } else {
        _lastErrorMessage = lastInsertError?.toString();
      }
      return false;
    } catch (e) {
      debugPrint('[AdminService] Error creating event: $e');
      _lastErrorMessage = e.toString();
      return false;
    }
  }

  /// Update an existing event
  ///
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
    _lastErrorMessage = null;
    try {
      if (eventId.trim().isEmpty) {
        _lastErrorMessage = 'Missing event id';
        return false;
      }

      final existing = await _supabase
          .from('events')
          .select('total_seats, seats_left')
          .eq('id', eventId)
          .single();

      final oldTotal = (existing['total_seats'] as num?)?.toInt() ?? 0;
      final oldSeatsLeft = (existing['seats_left'] as num?)?.toInt() ?? 0;
      final bookedSeats = (oldTotal - oldSeatsLeft).clamp(0, oldTotal).toInt();
      final newSeatsLeft = (totalSeats - bookedSeats).clamp(0, totalSeats).toInt();

      final titleValue = title.trim();
      final descriptionValue = description.trim();
      final categoryValue = category.trim();
      final venueValue = venue.trim();
      final imageUrlValue = imageUrl.trim();

      final payloadVariants = <Map<String, dynamic>>[
        {
          'title': titleValue,
          'description': descriptionValue,
          'category': categoryValue,
          'date': date.toIso8601String(),
          'venue': venueValue,
          'price': price,
          'total_seats': totalSeats,
          'seats_left': newSeatsLeft,
          'status': status,
          'image_url': imageUrlValue.isEmpty ? null : imageUrlValue,
        },
      ];

      Object? lastUpdateError;
      for (final payload in payloadVariants) {
        try {
          await _supabase
              .from('events')
              .update(payload)
              .eq('id', eventId)
              .select()
              .single();
          debugPrint('[AdminService] Event updated: $title');
          return true;
        } catch (e) {
          lastUpdateError = e;
          debugPrint('[AdminService] updateEvent variant failed: $e');
        }
      }

      _lastErrorMessage = lastUpdateError?.toString();
      return false;
    } catch (e) {
      debugPrint('[AdminService] Error updating event: $e');
      _lastErrorMessage = e.toString();
      return false;
    }
  }

  /// Delete an event
  ///
  static Future<bool> deleteEvent(String eventId) async {
    try {
      // First delete all registrations for this event
      await _supabase.from('registrations').delete().eq('event_id', eventId);

      // Then delete the event
      await _supabase.from('events').delete().eq('id', eventId);

      debugPrint('[AdminService] Event deleted: $eventId');
      return true;
    } catch (e) {
      debugPrint('[AdminService] Error deleting event: $e');
      return false;
    }
  }
}
