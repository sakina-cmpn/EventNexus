import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

/// Service class for handling all Supabase database operations
/// related to events and event registrations in EventNexus app.
class EventService {
  // Get Supabase client instance
  static final _supabase = Supabase.instance.client;
  static String? _lastErrorMessage;

  static String? get lastErrorMessage => _lastErrorMessage;

  /// Fetch all events from the events table
  ///
  /// Returns a list of all events ordered by created_at in descending order.
  /// Returns an empty list if any error occurs.
  static Future<List<Map<String, dynamic>>> getAllEvents() async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  /// Register a user for an event
  ///
  /// Checks if the user is already registered, generates a booking ID,
  /// inserts the registration, and decreases the available seats.
  ///
  /// Parameters:
  ///   - eventId: ID of the event
  ///   - userId: ID of the user registering
  ///   - userEmail: Email of the user
  ///   - userName: Name of the user
  ///
  /// Returns true if registration is successful, false otherwise.
  static Future<bool> registerForEvent({
    required String eventId,
    required String userId,
    required String userEmail,
    required String userName,
  }) async {
    _lastErrorMessage = null;
    try {
      if (eventId.trim().isEmpty || userId.trim().isEmpty) {
        _lastErrorMessage = 'Missing event or user identifier.';
        return false;
      }

      // Check if user is already registered for this event
      List<dynamic> existingRegistration;
      try {
        existingRegistration = await _supabase
            .from('registrations')
            .select('id')
            .eq('user_id', userId)
            .eq('event_id', eventId)
            .limit(1);
      } catch (_) {
        existingRegistration = await _supabase
            .from('registrations')
            .select('id')
            .eq('userId', userId)
            .eq('eventId', eventId)
            .limit(1);
      }

      if (existingRegistration.isNotEmpty) {
        _lastErrorMessage = 'Already registered for this event.';
        print('User already registered for this event');
        return false;
      }

      // Check if seats are still available
      int? seatsLeft;
      try {
        final eventData = await _supabase
            .from('events')
            .select('seats_left, seatsLeft')
            .eq('id', eventId)
            .single();
        seatsLeft =
            (eventData['seats_left'] as num?)?.toInt() ??
            (eventData['seatsLeft'] as num?)?.toInt();
      } catch (_) {
        // If seats column is missing in schema, skip this pre-check.
      }

      if (seatsLeft != null && seatsLeft <= 0) {
        _lastErrorMessage = 'No seats available for this event.';
        print('No seats available for this event');
        return false;
      }

      // Generate unique booking ID: EN-XXXXXX
      final bookingId = _generateBookingId();

      final emailValue = userEmail.trim();
      final nameValue = userName.trim();
      final nowIso = DateTime.now().toIso8601String();

      final payloadVariants = <Map<String, dynamic>>[
        {
          'booking_id': bookingId,
          'user_id': userId,
          'event_id': eventId,
          'user_email': emailValue,
          'user_name': nameValue,
          'registered_at': nowIso,
          'status': 'confirmed',
        },
        {
          'booking_id': bookingId,
          'user_id': userId,
          'event_id': eventId,
          'user_email': emailValue,
          'user_name': nameValue,
        },
        {
          'bookingId': bookingId,
          'userId': userId,
          'eventId': eventId,
          'userEmail': emailValue,
          'userName': nameValue,
          'registeredAt': nowIso,
          'status': 'confirmed',
        },
        {
          'booking_id': bookingId,
          'user_id': userId,
          'event_id': eventId,
          'user_email': emailValue,
          'user_name': nameValue,
          'created_at': nowIso,
        },
      ];

      Object? lastInsertError;
      var inserted = false;
      for (final payload in payloadVariants) {
        try {
          await _supabase.from('registrations').insert(payload).select().single();
          inserted = true;
          break;
        } catch (e) {
          lastInsertError = e;
          print('Registration insert variant failed: $e');
        }
      }

      if (!inserted) {
        _lastErrorMessage = lastInsertError?.toString() ?? 'Failed to save registration.';
        return false;
      }

      // Try to decrease seats, but keep registration successful even if seat
      // update fails (registration row is already stored).
      try {
        await _supabase.rpc('decrease_seats', params: {'event_id': eventId});
      } catch (rpcError) {
        print('decrease_seats RPC failed: $rpcError');
        if (seatsLeft != null && seatsLeft > 0) {
          try {
            try {
              await _supabase
                  .from('events')
                  .update({'seats_left': seatsLeft - 1})
                  .eq('id', eventId);
            } catch (_) {
              await _supabase
                  .from('events')
                  .update({'seatsLeft': seatsLeft - 1})
                  .eq('id', eventId);
            }
          } catch (directUpdateError) {
            print('Fallback seats_left update failed: $directUpdateError');
          }
        }
      }

      print('Successfully registered for event with booking ID: $bookingId');
      return true;
    } catch (e) {
      _lastErrorMessage = e.toString();
      print('Error registering for event: $e');
      return false;
    }
  }

  /// Fetch all registrations for a specific user
  ///
  /// Joins registrations table with events table to return complete
  /// registration data including event details.
  ///
  /// Parameters:
  ///   - userId: ID of the user
  ///
  /// Returns a list of registrations with event details, or empty list on error.
  static Future<List<Map<String, dynamic>>> getUserRegistrations(
    String userId,
  ) async {
    debugPrint('[EventService] Fetching registrations for user: $userId');

    // Step 1: Fetch registrations for this user (simple query, no join)
    List<dynamic> regsResponse;
    try {
      regsResponse = await _supabase
          .from('registrations')
          .select('*')
          .eq('user_id', userId);
    } catch (_) {
      regsResponse = await _supabase
          .from('registrations')
          .select('*')
          .eq('userId', userId);
    }

    debugPrint('[EventService] Raw registrations count: ${(regsResponse as List).length}');

    if (regsResponse.isEmpty) {
      debugPrint('[EventService] No registrations found for user $userId');
      return [];
    }

    // Step 2: Fetch the event for each registration individually
    // (avoids issues with missing FK relationships for REST joins)
    final List<Map<String, dynamic>> result = [];
    for (final reg in regsResponse) {
      final eventId = reg['event_id']?.toString() ?? reg['eventId']?.toString();
      if (eventId == null) continue;
      try {
        final eventResponse = await _supabase
            .from('events')
            .select('*')
            .eq('id', eventId)
            .maybeSingle();
        result.add({
          ...Map<String, dynamic>.from(reg),
          'events': eventResponse,
        });
      } catch (e) {
        debugPrint('[EventService] Error fetching event $eventId: $e');
        result.add({...Map<String, dynamic>.from(reg), 'events': null});
      }
    }

    debugPrint('[EventService] getUserRegistrations returning ${result.length} items');
    return result;
  }

  /// Fetch all event IDs that a user is registered for.
  ///
  /// Used to seed the registration state on screen load so previously
  /// registered events display the correct UI state immediately.
  ///
  /// Returns a [Set<String>] of event IDs, or an empty set on error.
  static Future<Set<String>> getRegisteredEventIds(String userId) async {
    try {
      final response = await _supabase
          .from('registrations')
          .select('event_id')
          .eq('user_id', userId);

      return Set<String>.from((response as List).map((r) => r['event_id'].toString()));
    } catch (e) {
      try {
        final response = await _supabase
            .from('registrations')
            .select('eventId')
            .eq('userId', userId);
        return Set<String>.from(
          (response as List).map((r) => r['eventId'].toString()),
        );
      } catch (e2) {
        print('Error fetching registered event IDs: $e | fallback: $e2');
        return {};
      }
    }
  }

  /// Check if a user is registered for a specific event
  ///
  /// Parameters:
  ///   - eventId: ID of the event
  ///   - userId: ID of the user
  ///
  /// Returns true if the user is registered, false otherwise.
  static Future<bool> isUserRegistered({
    required String eventId,
    required String userId,
  }) async {
    try {
      try {
        final response = await _supabase
            .from('registrations')
            .select('id')
            .eq('user_id', userId)
            .eq('event_id', eventId)
            .limit(1);
        return response.isNotEmpty;
      } catch (_) {
        final response = await _supabase
            .from('registrations')
            .select('id')
            .eq('userId', userId)
            .eq('eventId', eventId)
            .limit(1);
        return response.isNotEmpty;
      }
    } catch (e) {
      print('Error checking registration status: $e');
      return false;
    }
  }

  /// Cancel (revoke) a user's registration for an event.
  ///
  /// Deletes the registration row and restores the seat count on the event.
  ///
  /// Parameters:
  ///   - bookingId: The booking_id string (e.g. "EN-XXXXXX")
  ///   - eventId: ID of the event (used to restore seats_left)
  ///
  /// Returns true if cancellation succeeded, false otherwise.
  static Future<bool> cancelRegistration({
    required String bookingId,
    required String eventId,
  }) async {
    try {
      // Delete the registration row
      await _supabase
          .from('registrations')
          .delete()
          .eq('booking_id', bookingId);

      // Restore seat count — read current value then increment
      try {
        final eventData = await _supabase
            .from('events')
            .select('seats_left')
            .eq('id', eventId)
            .single();
        final currentSeats = (eventData['seats_left'] as num?)?.toInt() ?? 0;
        await _supabase
            .from('events')
            .update({'seats_left': currentSeats + 1})
            .eq('id', eventId);
      } catch (seatError) {
        // Registration already deleted — seat restore failure is non-fatal
        print('Could not restore seat count after cancellation: $seatError');
      }

      return true;
    } catch (e) {
      print('Error cancelling registration: $e');
      return false;
    }
  }

  /// Generate a random booking ID in format: EN-XXXXXX
  ///
  /// Where X is a random uppercase alphanumeric character.
  static String _generateBookingId() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final randomPart =
        List.generate(6, (_) => characters[random.nextInt(characters.length)])
            .join();
    return 'EN-$randomPart';
  }
}
