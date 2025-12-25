import 'package:dio/dio.dart';
import '../models/travel_plan.dart';

class ApiService {
  static const String baseUrl = 'https://api.lovec.at/v1/workflows';

  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json; charset=utf-8';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<TravelPlan> getTravelPlan({
    required int travelDays,
    required String departureCity,
    required String destinationCity,
  }) async {
    try {
      final response = await _dio.post(
        '/travelPlanFlow',
        data: {
          'data': {
            'travel_days': travelDays,
            'departure_city': departureCity,
            'destination_city': destinationCity,
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return TravelPlan.fromJson(data['result']);
      } else {
        final responseBody = response.data.toString();
        print('Response status: ${response.statusCode}');
        print('Response body: $responseBody');
        throw Exception(
          'Failed to load travel plan: ${response.statusCode}, Body: $responseBody',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final responseBody = e.response?.data.toString() ?? 'No response body';
        print('Response status: ${e.response?.statusCode}');
        print('Response body: $responseBody');
        throw Exception(
          'Failed to load travel plan: ${e.response?.statusCode}, Body: $responseBody',
        );
      } else {
        print('Dio error: ${e.message}');
        throw Exception('Error: ${e.message}');
      }
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('Error: $e');
    }
  }
}
