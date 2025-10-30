import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/travel_plan.dart';

class ApiService {
  static const String baseUrl = 'https://api.lovec.at/v1/workflows';

  Future<TravelPlan> getTravelPlan({
    required int travelDays,
    required String departureCity,
    required String destinationCity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/travelPlanFlow'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'data': {
            'travel_days': travelDays,
            'departure_city': departureCity,
            'destination_city': destinationCity,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return TravelPlan.fromJson(data['result']);
      } else {
        throw Exception('Failed to load travel plan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

