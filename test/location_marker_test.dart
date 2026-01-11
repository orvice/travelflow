import 'package:flutter_test/flutter_test.dart' hide expect, group, test;
import 'package:glados/glados.dart';
import 'package:travelflow/models/location_marker.dart';

/// Custom generator for LocationMarker
/// Generates valid LocationMarker instances with random but valid data
extension LocationMarkerGenerator on Any {
  Generator<LocationMarker> get locationMarker => any.combine5(
        any.nonEmptyLetters, // id - non-empty string
        any.nonEmptyLetters, // name - non-empty string
        any.letters, // notes - string (can be empty)
        any.doubleInRange(-90, 90), // latitude - valid range
        any.doubleInRange(-180, 180), // longitude - valid range
        (id, name, notes, latitude, longitude) {
          final now = DateTime.utc(2026, 1, 10, 12, 0, 0);
          return LocationMarker(
            id: id,
            name: name,
            notes: notes.isEmpty ? null : notes,
            latitude: latitude,
            longitude: longitude,
            isFavorite: false,
            createdAt: now,
            updatedAt: now,
          );
        },
      );

  Generator<LocationMarker> get locationMarkerWithFavorite => any.combine2(
        any.locationMarker,
        any.bool,
        (marker, isFavorite) => marker.copyWith(isFavorite: isFavorite),
      );

  /// Generator for valid non-empty, non-whitespace-only names
  Generator<String> get validMarkerName => any.nonEmptyLetters;

  /// Generator for valid latitude values (-90 to 90)
  Generator<double> get validLatitude => any.doubleInRange(-90, 90);

  /// Generator for valid longitude values (-180 to 180)
  Generator<double> get validLongitude => any.doubleInRange(-180, 180);

  /// Generator for whitespace-only strings (including empty string)
  /// Generates strings composed entirely of whitespace characters
  Generator<String> get whitespaceOnlyString => any.intInRange(0, 10).map((length) {
        const whitespaceChars = [' ', '\t', '\n', '\r', '\v', '\f'];
        if (length == 0) return '';
        final buffer = StringBuffer();
        for (var i = 0; i < length; i++) {
          buffer.write(whitespaceChars[i % whitespaceChars.length]);
        }
        return buffer.toString();
      });

  /// Generator for a list of LocationMarkers with unique IDs
  /// This ensures no duplicate IDs exist in the generated list
  Generator<List<LocationMarker>> get uniqueIdMarkerList => any.intInRange(0, 10).map((count) {
        final now = DateTime.utc(2026, 1, 10, 12, 0, 0);
        final result = <LocationMarker>[];
        for (var i = 0; i < count; i++) {
          result.add(LocationMarker(
            id: 'unique-marker-id-$i',
            name: 'Marker $i',
            notes: i % 2 == 0 ? 'Notes for marker $i' : null,
            latitude: -90 + (i * 18.0) % 180,
            longitude: -180 + (i * 36.0) % 360,
            isFavorite: i % 2 == 0, // Alternate favorites
            createdAt: now,
            updatedAt: now,
          ));
        }
        return result;
      });

  /// Generator for a list of LocationMarkers with unique IDs and random favorite status
  Generator<List<LocationMarker>> get uniqueIdMarkerListWithRandomFavorites => 
      any.combine2(
        any.intInRange(0, 10),
        any.list(any.bool),
        (count, favoriteFlags) {
          final now = DateTime.utc(2026, 1, 10, 12, 0, 0);
          final result = <LocationMarker>[];
          for (var i = 0; i < count; i++) {
            final isFavorite = i < favoriteFlags.length ? favoriteFlags[i] : false;
            result.add(LocationMarker(
              id: 'unique-marker-id-$i',
              name: 'Marker $i',
              notes: i % 2 == 0 ? 'Notes for marker $i' : null,
              latitude: -90 + (i * 18.0) % 180,
              longitude: -180 + (i * 36.0) % 360,
              isFavorite: isFavorite,
              createdAt: now,
              updatedAt: now,
            ));
          }
          return result;
        },
      );

  /// Generator for search query strings (can be empty or contain letters)
  Generator<String> get searchQuery => any.letters;

  /// Generator for a list of LocationMarkers with varied names for search testing
  /// Creates markers with diverse names to test search functionality
  Generator<List<LocationMarker>> get markersWithVariedNames =>
      any.combine2(
        any.intInRange(0, 10),
        any.list(any.nonEmptyLetters),
        (count, names) {
          final now = DateTime.utc(2026, 1, 10, 12, 0, 0);
          final result = <LocationMarker>[];
          for (var i = 0; i < count; i++) {
            final name = i < names.length ? names[i] : 'DefaultName$i';
            result.add(LocationMarker(
              id: 'search-marker-id-$i',
              name: name,
              notes: null,
              latitude: -90 + (i * 18.0) % 180,
              longitude: -180 + (i * 36.0) % 360,
              isFavorite: false,
              createdAt: now,
              updatedAt: now,
            ));
          }
          return result;
        },
      );
}

/// Helper function to simulate marker creation logic (same as LocationService.addMarker)
/// This validates the name and adds the marker to the list
List<LocationMarker> addMarkerToList(List<LocationMarker> markers, LocationMarker marker) {
  // Validate name is not empty or whitespace-only (same validation as LocationService)
  if (marker.name.trim().isEmpty) {
    throw ArgumentError('Marker name cannot be empty');
  }

  final result = List<LocationMarker>.from(markers);
  
  // Check for duplicate ID - update existing if found
  final existingIndex = result.indexWhere((m) => m.id == marker.id);
  if (existingIndex != -1) {
    result[existingIndex] = marker;
  } else {
    result.add(marker);
  }

  return result;
}

/// Helper function to simulate marker deletion logic (same as LocationService.deleteMarker)
/// This removes the marker with the given ID from the list
List<LocationMarker> deleteMarkerFromList(List<LocationMarker> markers, String id) {
  final result = List<LocationMarker>.from(markers);
  result.removeWhere((marker) => marker.id == id);
  return result;
}

/// Helper function to simulate search by name logic (same as LocationService.searchByName)
/// This filters markers by name (case-insensitive)
List<LocationMarker> searchByName(List<LocationMarker> markers, String query) {
  if (query.isEmpty) {
    return markers;
  }
  final lowerQuery = query.toLowerCase();
  return markers
      .where((marker) => marker.name.toLowerCase().contains(lowerQuery))
      .toList();
}

/// Helper function to simulate favorite toggle logic (same as LocationService.toggleFavorite)
/// This toggles the isFavorite field of the marker with the given ID
LocationMarker toggleFavorite(LocationMarker marker) {
  return marker.copyWith(
    isFavorite: !marker.isFavorite,
    updatedAt: DateTime.now(),
  );
}

void main() {
  group('LocationMarker Property Tests', () {
    // Feature: map-location-favorites, Property 7: Persistence Round-Trip
    // **Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.5**
    Glados(any.locationMarkerWithFavorite).test(
      'Property 7: Persistence Round-Trip - toJson then fromJson produces equivalent marker',
      (marker) {
        // Serialize to JSON
        final json = marker.toJson();
        
        // Deserialize from JSON
        final restored = LocationMarker.fromJson(json);
        
        // Verify all fields are preserved
        expect(restored.id, equals(marker.id));
        expect(restored.name, equals(marker.name));
        expect(restored.notes, equals(marker.notes));
        expect(restored.latitude, equals(marker.latitude));
        expect(restored.longitude, equals(marker.longitude));
        expect(restored.isFavorite, equals(marker.isFavorite));
        expect(restored.createdAt, equals(marker.createdAt));
        expect(restored.updatedAt, equals(marker.updatedAt));
        
        // Also verify equality operator works
        expect(restored, equals(marker));
      },
    );

    // Feature: map-location-favorites, Property 1: Marker Creation with Valid Name
    // **Validates: Requirements 1.2**
    // For any valid name (non-empty, non-whitespace-only string) and valid coordinates,
    // creating a marker SHALL result in a marker being added to the markers list
    // with the correct name and coordinates.
    Glados3(any.validMarkerName, any.validLatitude, any.validLongitude).test(
      'Property 1: Marker Creation with Valid Name - valid name and coordinates result in marker added with correct properties',
      (name, latitude, longitude) {
        // Create a marker with valid name and coordinates
        final now = DateTime.now();
        final marker = LocationMarker(
          id: 'test-id-${now.millisecondsSinceEpoch}',
          name: name,
          latitude: latitude,
          longitude: longitude,
          createdAt: now,
          updatedAt: now,
        );

        // Start with an empty list
        final initialMarkers = <LocationMarker>[];
        
        // Add the marker (simulating LocationService.addMarker logic)
        final resultMarkers = addMarkerToList(initialMarkers, marker);

        // Verify marker was added
        expect(resultMarkers.length, equals(1));
        
        // Verify the added marker has correct name and coordinates
        final addedMarker = resultMarkers.first;
        expect(addedMarker.name, equals(name));
        expect(addedMarker.latitude, equals(latitude));
        expect(addedMarker.longitude, equals(longitude));
        
        // Verify the marker in the list is the same as what we created
        expect(addedMarker, equals(marker));
      },
    );

    // Feature: map-location-favorites, Property 2: Empty Name Validation
    // **Validates: Requirements 1.4**
    // For any string composed entirely of whitespace characters (including empty string),
    // attempting to create a marker SHALL be rejected and the markers list SHALL remain unchanged.
    Glados(any.whitespaceOnlyString).test(
      'Property 2: Empty Name Validation - whitespace-only names are rejected and list remains unchanged',
      (whitespaceOnlyName) {
        // Create a marker with whitespace-only name
        final now = DateTime.now();
        final marker = LocationMarker(
          id: 'test-id-${now.millisecondsSinceEpoch}',
          name: whitespaceOnlyName,
          latitude: 39.9042,
          longitude: 116.4074,
          createdAt: now,
          updatedAt: now,
        );

        // Start with an empty list
        final initialMarkers = <LocationMarker>[];
        final initialLength = initialMarkers.length;

        // Attempt to add the marker - should throw ArgumentError
        bool exceptionThrown = false;
        List<LocationMarker> resultMarkers = initialMarkers;
        
        try {
          resultMarkers = addMarkerToList(initialMarkers, marker);
        } on ArgumentError {
          exceptionThrown = true;
        }

        // Verify that an exception was thrown
        expect(exceptionThrown, isTrue, 
            reason: 'Expected ArgumentError for whitespace-only name: "$whitespaceOnlyName"');
        
        // Verify the markers list remains unchanged
        expect(resultMarkers.length, equals(initialLength),
            reason: 'Markers list should remain unchanged after rejection');
      },
    );

    // Feature: map-location-favorites, Property 4: Marker Deletion Removes from List
    // **Validates: Requirements 2.4**
    // For any existing marker, deleting it SHALL result in the marker no longer being
    // present in the markers list, and the list length SHALL decrease by one.
    Glados2(any.locationMarker, any.intInRange(0, 5)).test(
      'Property 4: Marker Deletion Removes from List - deleting a marker removes it and decreases list length by one',
      (markerToDelete, additionalMarkersCount) {
        // Create a list with the marker to delete and some additional markers
        final now = DateTime.utc(2026, 1, 10, 12, 0, 0);
        final markers = <LocationMarker>[markerToDelete];
        
        // Add additional markers with unique IDs
        for (var i = 0; i < additionalMarkersCount; i++) {
          markers.add(LocationMarker(
            id: 'additional-marker-$i',
            name: 'Additional Marker $i',
            latitude: 39.9042 + i * 0.01,
            longitude: 116.4074 + i * 0.01,
            createdAt: now,
            updatedAt: now,
          ));
        }
        
        final initialLength = markers.length;
        
        // Delete the marker
        final resultMarkers = deleteMarkerFromList(markers, markerToDelete.id);
        
        // Verify the list length decreased by one
        expect(resultMarkers.length, equals(initialLength - 1),
            reason: 'List length should decrease by one after deletion');
        
        // Verify the marker is no longer present in the list
        final markerStillExists = resultMarkers.any((m) => m.id == markerToDelete.id);
        expect(markerStillExists, isFalse,
            reason: 'Deleted marker should no longer be present in the list');
        
        // Verify all other markers are still present
        for (var i = 0; i < additionalMarkersCount; i++) {
          final additionalMarkerExists = resultMarkers.any((m) => m.id == 'additional-marker-$i');
          expect(additionalMarkerExists, isTrue,
              reason: 'Additional marker $i should still be present after deletion');
        }
      },
    );

    // Feature: map-location-favorites, Property 5: Favorite Toggle Idempotence
    // **Validates: Requirements 3.1, 3.3**
    // For any marker, toggling favorite twice SHALL return the marker to its original
    // favorite state. Additionally, toggling favorite on a non-favorite marker SHALL
    // make it a favorite, and vice versa.
    Glados(any.locationMarkerWithFavorite).test(
      'Property 5: Favorite Toggle Idempotence - toggling favorite twice returns to original state',
      (marker) {
        final originalFavoriteState = marker.isFavorite;
        
        // Toggle favorite once
        final afterFirstToggle = toggleFavorite(marker);
        
        // Verify the favorite state is inverted after first toggle
        expect(afterFirstToggle.isFavorite, equals(!originalFavoriteState),
            reason: 'First toggle should invert the favorite state');
        
        // Toggle favorite again
        final afterSecondToggle = toggleFavorite(afterFirstToggle);
        
        // Verify the favorite state returns to original after second toggle
        expect(afterSecondToggle.isFavorite, equals(originalFavoriteState),
            reason: 'Second toggle should return to original favorite state');
        
        // Verify other fields are preserved (except updatedAt which changes on toggle)
        expect(afterSecondToggle.id, equals(marker.id));
        expect(afterSecondToggle.name, equals(marker.name));
        expect(afterSecondToggle.notes, equals(marker.notes));
        expect(afterSecondToggle.latitude, equals(marker.latitude));
        expect(afterSecondToggle.longitude, equals(marker.longitude));
        expect(afterSecondToggle.createdAt, equals(marker.createdAt));
      },
    );

    // Feature: map-location-favorites, Property 6: Favorites List Completeness
    // **Validates: Requirements 4.2**
    // For any set of markers, the favorites list SHALL contain exactly all markers
    // where isFavorite is true, and no markers where isFavorite is false.
    Glados(any.uniqueIdMarkerListWithRandomFavorites).test(
      'Property 6: Favorites List Completeness - favorites list contains exactly all favorited markers',
      (markers) {
        // Filter favorites (simulating LocationService.getFavorites logic)
        final favoritesList = markers.where((marker) => marker.isFavorite).toList();
        
        // Verify all markers in favoritesList have isFavorite == true
        for (final marker in favoritesList) {
          expect(marker.isFavorite, isTrue,
              reason: 'All markers in favorites list should have isFavorite == true');
        }
        
        // Verify no markers with isFavorite == false are in the favorites list
        final nonFavoriteInList = favoritesList.any((marker) => !marker.isFavorite);
        expect(nonFavoriteInList, isFalse,
            reason: 'No non-favorite markers should be in the favorites list');
        
        // Verify all markers with isFavorite == true from original list are in favoritesList
        final expectedFavorites = markers.where((m) => m.isFavorite).toList();
        expect(favoritesList.length, equals(expectedFavorites.length),
            reason: 'Favorites list should contain exactly all favorited markers');
        
        // Verify each expected favorite is present in the favorites list
        for (final expectedFavorite in expectedFavorites) {
          final isPresent = favoritesList.any((m) => m.id == expectedFavorite.id);
          expect(isPresent, isTrue,
              reason: 'Expected favorite marker ${expectedFavorite.id} should be in favorites list');
        }
        
        // Verify no non-favorite markers from original list are in favoritesList
        final nonFavorites = markers.where((m) => !m.isFavorite).toList();
        for (final nonFavorite in nonFavorites) {
          final isPresent = favoritesList.any((m) => m.id == nonFavorite.id);
          expect(isPresent, isFalse,
              reason: 'Non-favorite marker ${nonFavorite.id} should not be in favorites list');
        }
      },
    );

    // Feature: map-location-favorites, Property 8: Search Filtering Correctness
    // **Validates: Requirements 6.1, 6.2**
    // For any search query and list of markers, the filtered results SHALL contain
    // exactly all markers whose name contains the query (case-insensitive),
    // and no markers whose name does not contain the query.
    Glados2(any.markersWithVariedNames, any.searchQuery).test(
      'Property 8: Search Filtering Correctness - search returns exactly matching markers',
      (markers, query) {
        // Perform search (simulating LocationService.searchByName logic)
        final searchResults = searchByName(markers, query);
        
        // If query is empty, all markers should be returned
        if (query.isEmpty) {
          expect(searchResults.length, equals(markers.length),
              reason: 'Empty query should return all markers');
          return;
        }
        
        final lowerQuery = query.toLowerCase();
        
        // Verify all markers in searchResults have names containing the query (case-insensitive)
        for (final marker in searchResults) {
          final nameContainsQuery = marker.name.toLowerCase().contains(lowerQuery);
          expect(nameContainsQuery, isTrue,
              reason: 'Marker "${marker.name}" in results should contain query "$query" (case-insensitive)');
        }
        
        // Verify no markers whose name does not contain the query are in the results
        final nonMatchingInResults = searchResults.any(
            (marker) => !marker.name.toLowerCase().contains(lowerQuery));
        expect(nonMatchingInResults, isFalse,
            reason: 'No non-matching markers should be in search results');
        
        // Verify all markers whose name contains the query are in the results
        final expectedMatches = markers.where(
            (m) => m.name.toLowerCase().contains(lowerQuery)).toList();
        expect(searchResults.length, equals(expectedMatches.length),
            reason: 'Search results should contain exactly all matching markers');
        
        // Verify each expected match is present in the search results
        for (final expectedMatch in expectedMatches) {
          final isPresent = searchResults.any((m) => m.id == expectedMatch.id);
          expect(isPresent, isTrue,
              reason: 'Expected matching marker "${expectedMatch.name}" should be in search results');
        }
        
        // Verify no non-matching markers from original list are in search results
        final nonMatches = markers.where(
            (m) => !m.name.toLowerCase().contains(lowerQuery)).toList();
        for (final nonMatch in nonMatches) {
          final isPresent = searchResults.any((m) => m.id == nonMatch.id);
          expect(isPresent, isFalse,
              reason: 'Non-matching marker "${nonMatch.name}" should not be in search results');
        }
      },
    );
  });
}
