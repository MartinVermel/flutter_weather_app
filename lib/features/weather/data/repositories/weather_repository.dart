import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/weather_api_service.dart';

/// WeatherRepository sits between the providers (Riverpod) and the API service.
/// This separation makes the providers easy to test (swap in a fake repo) and
/// keeps business logic out of the network layer.
abstract class IWeatherRepository {
  Future<WeatherModel> getCurrentWeather(String cityName);
  Future<WeatherModel> getCurrentWeatherByCoords(double lat, double lon);
  Future<ForecastModel> getForecast(String cityName);
  Future<ForecastModel> getForecastByCoords(double lat, double lon);
}

class WeatherRepository implements IWeatherRepository {
  final WeatherApiService _apiService;

  const WeatherRepository({required WeatherApiService apiService})
      : _apiService = apiService;

  @override
  Future<WeatherModel> getCurrentWeather(String cityName) =>
      _apiService.getCurrentWeather(cityName);

  @override
  Future<WeatherModel> getCurrentWeatherByCoords(double lat, double lon) =>
      _apiService.getCurrentWeatherByCoords(lat, lon);

  @override
  Future<ForecastModel> getForecast(String cityName) =>
      _apiService.getForecast(cityName);

  @override
  Future<ForecastModel> getForecastByCoords(double lat, double lon) =>
      _apiService.getForecastByCoords(lat, lon);
}
