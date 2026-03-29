import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

/// Service class for handling all Supabase database operations
/// related to events and event registrations in EventNexus app.
class EventService {
  // Get Supabase client instance
  static final _supabase = Supabase.instance.client;

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
    try {
      // Check if user is already registered for this event
      final existingRegistration = await _supabase
          .from('registrations')
          .select()
          .eq('user_id', userId)
          .eq('event_id', eventId);

      if (existingRegistration.isNotEmpty) {
        print('User already registered for this event');
        return false;
      }

      // Check if seats are still available
      final eventData = await _supabase
          .from('events')
          .select('seats_left')
          .eq('id', eventId)
          .single();

      final seatsLeft = (eventData['seats_left'] as num?)?.toInt() ?? 0;
      if (seatsLeft <= 0) {
        print('No seats available for this event');
        return false;
      }

      // Generate unique booking ID: EN-XXXXXX
      final bookingId = _generateBookingId();

      // Insert registration record
      await _supabase.from('registrations').insert({
        'booking_id': bookingId,
        'user_id': userId,
        'event_id': eventId,
        'user_email': userEmail,
        'user_name': userName,
      });

      // Decrease seats_left in events table using RPC function
      await _supabase.rpc('decrease_seats', params: {'event_id': eventId});

      print('Successfully registered for event with booking ID: $bookingId');
      return true;
    } catch (e) {
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
    final regsResponse = await _supabase
        .from('registrations')
        .select('*')
        .eq('user_id', userId);

    debugPrint('[EventService] Raw registrations count: ${(regsResponse as List).length}');

    if (regsResponse.isEmpty) {
      debugPrint('[EventService] No registrations found for user $userId');
      return [];
    }

    // Step 2: Fetch the event for each registration individually
    // (avoids issues with missing FK relationships for REST joins)
    final List<Map<String, dynamic>> result = [];
    for (final reg in regsResponse) {
      final eventId = reg['event_id']?.toString();
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

      return Set<String>.from(
        (response as List).map((r) => r['event_id'].toString()),
      );
    } catch (e) {
      print('Error fetching registered event IDs: $e');
      return {};
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
      final response = await _supabase
          .from('registrations')
          .select()
          .eq('user_id', userId)
          .eq('event_id', eventId);

      return response.isNotEmpty;
    } catch (e) {
      print('Error checking registration status: $e');
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
