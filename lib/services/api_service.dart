import 'package:dio/dio.dart';
import '../models/travel_plan.dart';
import '../services/theme_service.dart';

class ApiService {
  static const String baseUrl = 'https://api.lovec.at/v1/workflows';

  final Dio _dio = Dio();
  final ThemeService _themeService = ThemeService();

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json; charset=utf-8';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 230);
  }

  Future<TravelPlan> getTravelPlan({
    required int travelDays,
    required String departureCity,
    required String destinationCity,
  }) async {
    try {
      // 获取配置的语言
      final language = await _themeService.getApiLanguage();

      final response = await _dio.post(
        '/travelPlanFlow',
        data: {
          'data': {
            'travel_days': travelDays,
            'departure_city': departureCity,
            'destination_city': destinationCity,
            'language': language,
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return TravelPlan.fromJson(data['result']);
      } else {
        final responseBody = response.data.toString();
        throw Exception(
          'Failed to load travel plan: ${response.statusCode}, Body: $responseBody',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final responseBody = e.response?.data.toString() ?? 'No response body';
        throw Exception(
          'Failed to load travel plan: ${e.response?.statusCode}, Body: $responseBody',
        );
      } else {
        throw Exception('Error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
