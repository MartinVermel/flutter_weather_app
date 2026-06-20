class AppConstants {
  AppConstants._();

  // OpenWeatherMap API
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String apiKey = 'YOUR_API_KEY'; // Replace with your key
  static const String iconBaseUrl = 'https://openweathermap.org/img/wn';

  // Endpoints
  static const String currentWeather = '/weather';
  static const String forecast = '/forecast';

  // Units
  static const String metricUnits = 'metric';
  static const String imperialUnits = 'imperial';

  // Duration
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration animationFast = Duration(milliseconds: 300);
  static const Duration animationMedium = Duration(milliseconds: 600);
  static const Duration animationSlow = Duration(milliseconds: 1200);

  // Max search history entries
  static const int maxSearchHistory = 10;
}
