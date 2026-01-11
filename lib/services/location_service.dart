import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/location_marker.dart';

class LocationService {
  static const String _fileName = 'location_markers.json';
  static LocationService? _instance;

  factory LocationService() {
    _instance ??= LocationService._internal();
    return _instance!;
  }

  LocationService._internal();

  Future<File> _getMarkersFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  /// Load all markers from local storage
  Future<List<LocationMarker>> _loadMarkers() async {
    try {
      final file = await _getMarkersFile();
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => LocationMarker.fromJson(json)).toList();
    } catch (e) {
      print('Error loading markers: $e');
      return [];
    }
  }

  /// Save all markers to local storage
  Future<void> _saveMarkers(List<LocationMarker> markers) async {
    try {
      final file = await _getMarkersFile();
      final jsonList = markers.map((marker) => marker.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Error saving markers: $e');
    }
  }


  /// Get all markers from storage
  /// Requirements: 5.4
  Future<List<LocationMarker>> getAllMarkers() async {
    return await _loadMarkers();
  }

  /// Get all favorite markers
  /// Requirements: 4.2
  Future<List<LocationMarker>> getFavorites() async {
    final markers = await _loadMarkers();
    return markers.where((marker) => marker.isFavorite).toList();
  }

  /// Get a specific marker by ID
  Future<LocationMarker?> getMarkerById(String id) async {
    try {
      final markers = await _loadMarkers();
      return markers.firstWhere((marker) => marker.id == id);
    } catch (e) {
      print('Marker not found with id: $id');
      return null;
    }
  }

  /// Add a new marker
  /// Requirements: 1.2, 5.1
  Future<void> addMarker(LocationMarker marker) async {
    // Validate name is not empty or whitespace-only
    if (marker.name.trim().isEmpty) {
      throw ArgumentError('Marker name cannot be empty');
    }

    final markers = await _loadMarkers();

    // Check for duplicate ID - update existing if found
    final existingIndex = markers.indexWhere((m) => m.id == marker.id);
    if (existingIndex != -1) {
      markers[existingIndex] = marker;
    } else {
      markers.add(marker);
    }

    await _saveMarkers(markers);
  }

  /// Update an existing marker
  /// Requirements: 2.3, 5.2
  Future<void> updateMarker(LocationMarker marker) async {
    // Validate name is not empty or whitespace-only
    if (marker.name.trim().isEmpty) {
      throw ArgumentError('Marker name cannot be empty');
    }

    final markers = await _loadMarkers();
    final index = markers.indexWhere((m) => m.id == marker.id);

    if (index != -1) {
      markers[index] = marker;
      await _saveMarkers(markers);
    } else {
      print('Warning: Marker not found for update with id: ${marker.id}');
    }
  }

  /// Delete a marker by ID
  /// Requirements: 2.4, 5.3
  Future<void> deleteMarker(String id) async {
    final markers = await _loadMarkers();
    markers.removeWhere((marker) => marker.id == id);
    await _saveMarkers(markers);
  }

  /// Toggle favorite status of a marker
  /// Requirements: 3.1, 3.3, 5.5
  Future<void> toggleFavorite(String id) async {
    final markers = await _loadMarkers();
    final index = markers.indexWhere((m) => m.id == id);

    if (index != -1) {
      final marker = markers[index];
      markers[index] = marker.copyWith(
        isFavorite: !marker.isFavorite,
        updatedAt: DateTime.now(),
      );
      await _saveMarkers(markers);
    } else {
      print('Warning: Marker not found for toggle favorite with id: $id');
    }
  }

  /// Search markers by name (case-insensitive)
  /// Requirements: 6.1, 6.2
  List<LocationMarker> searchByName(List<LocationMarker> markers, String query) {
    if (query.isEmpty) {
      return markers;
    }
    final lowerQuery = query.toLowerCase();
    return markers
        .where((marker) => marker.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
