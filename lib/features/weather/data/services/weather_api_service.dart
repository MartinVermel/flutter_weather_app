import 'package:dio/dio.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

/// WeatherApiService is a thin wrapper around Dio that handles all HTTP calls
/// to OpenWeatherMap. Using Dio (vs http) gives us interceptors, timeout
/// configuration, and structured error handling out of the box.
class WeatherApiService {
  late final Dio _dio;

  WeatherApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        queryParameters: {
          'appid': AppConstants.apiKey,
          'units': AppConstants.metricUnits,
        },
      ),
    );

    // Add logging interceptor in debug mode
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    );
  }

  /// Fetch current weather for [cityName].
  /// Throws [WeatherApiException] on failure.
  Future<WeatherModel> getCurrentWeather(String cityName) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        AppConstants.currentWeather,
        queryParameters: {'q': cityName},
      );
      return WeatherModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw WeatherApiException.fromDioError(e);
    }
  }

  /// Fetch current weather by geographic coordinates.
  Future<WeatherModel> getCurrentWeatherByCoords(
    double lat,
    double lon,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        AppConstants.currentWeather,
        queryParameters: {'lat': lat, 'lon': lon},
      );
      return WeatherModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw WeatherApiException.fromDioError(e);
    }
  }

  /// Fetch 5-day / 3-hour forecast for [cityName].
  Future<ForecastModel> getForecast(String cityName) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        AppConstants.forecast,
        queryParameters: {'q': cityName, 'cnt': 40},
      );
      return ForecastModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw WeatherApiException.fromDioError(e);
    }
  }

  /// Fetch forecast by geographic coordinates.
  Future<ForecastModel> getForecastByCoords(double lat, double lon) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        AppConstants.forecast,
        queryParameters: {'lat': lat, 'lon': lon, 'cnt': 40},
      );
      return ForecastModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw WeatherApiException.fromDioError(e);
    }
  }
}

/// Structured exception type so the UI can display user-friendly messages
/// without coupling to Dio internals.
class WeatherApiException implements Exception {
  final String message;
  final int? statusCode;

  const WeatherApiException({required this.message, this.statusCode});

  factory WeatherApiException.fromDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const WeatherApiException(
          message: 'Connection timed out. Please check your internet.',
        );
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 404) {
          return WeatherApiException(
            message: 'City not found. Please check the name.',
            statusCode: code,
          );
        }
        if (code == 401) {
          return WeatherApiException(
            message: 'Invalid API key. Please update AppConstants.apiKey.',
            statusCode: code,
          );
        }
        return WeatherApiException(
          message: 'Server error ($code). Please try again.',
          statusCode: code,
        );
      case DioExceptionType.cancel:
        return const WeatherApiException(message: 'Request was cancelled.');
      default:
        return const WeatherApiException(
          message: 'Network error. Please check your connection.',
        );
    }
  }

  @override
  String toString() => 'WeatherApiException: $message';
}

// Utility to suppress linter warning - in real code this would import dart:developer
void debugPrint(String message) {}
