import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/weather_model.dart';
import '../data/models/forecast_model.dart';
import '../data/repositories/weather_repository.dart';
import '../data/services/weather_api_service.dart';

// ---------------------------------------------------------------------------
// Infrastructure providers (single instances, shared across the app)
// ---------------------------------------------------------------------------

final weatherApiServiceProvider = Provider<WeatherApiService>(
  (ref) => WeatherApiService(),
);

final weatherRepositoryProvider = Provider<IWeatherRepository>(
  (ref) => WeatherRepository(
    apiService: ref.watch(weatherApiServiceProvider),
  ),
);

// ---------------------------------------------------------------------------
// Settings
// ---------------------------------------------------------------------------

final useMetricProvider = StateProvider<bool>((ref) => true);

// ---------------------------------------------------------------------------
// WeatherState — the shape of data the HomeScreen needs
// ---------------------------------------------------------------------------

class WeatherState {
  final WeatherModel? weather;
  final ForecastModel? forecast;
  final String? lastCity;

  const WeatherState({this.weather, this.forecast, this.lastCity});

  WeatherState copyWith({
    WeatherModel? weather,
    ForecastModel? forecast,
    String? lastCity,
  }) =>
      WeatherState(
        weather: weather ?? this.weather,
        forecast: forecast ?? this.forecast,
        lastCity: lastCity ?? this.lastCity,
      );
}

// ---------------------------------------------------------------------------
// WeatherNotifier — AsyncNotifier drives loading + error states automatically
// ---------------------------------------------------------------------------

/// AsyncNotifier<WeatherState> exposes an AsyncValue<WeatherState> to the UI.
/// The UI pattern-matches on loading/error/data without manual flag management:
///   ref.watch(weatherProvider).when(
///     data: (s) => ...,
///     loading: () => CircularProgressIndicator(),
///     error: (e, _) => Text(e.toString()),
///   );
class WeatherNotifier extends AsyncNotifier<WeatherState> {
  @override
  Future<WeatherState> build() async {
    // Initial state — load London as default
    return _loadWeather('London');
  }

  Future<WeatherState> _loadWeather(String city) async {
    final repo = ref.read(weatherRepositoryProvider);
    final results = await Future.wait([
      repo.getCurrentWeather(city),
      repo.getForecast(city),
    ]);
    return WeatherState(
      weather: results[0] as WeatherModel,
      forecast: results[1] as ForecastModel,
      lastCity: city,
    );
  }

  Future<void> loadCity(String cityName) async {
    // Set loading state while keeping the previous data visible (AsyncLoading
    // with previousData prevents a full blank screen on refresh)
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadWeather(cityName));
  }

  Future<void> loadByCoords(double lat, double lon) async {
    state = const AsyncLoading();
    final repo = ref.read(weatherRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final results = await Future.wait([
        repo.getCurrentWeatherByCoords(lat, lon),
        repo.getForecastByCoords(lat, lon),
      ]);
      return WeatherState(
        weather: results[0] as WeatherModel,
        forecast: results[1] as ForecastModel,
        lastCity: (results[0] as WeatherModel).cityName,
      );
    });
  }

  void toggleUnit() {
    // Recompute temperatures (°C ↔ °F) without a network call
    final useMetric = ref.read(useMetricProvider);
    ref.read(useMetricProvider.notifier).state = !useMetric;
  }
}

final weatherProvider =
    AsyncNotifierProvider<WeatherNotifier, WeatherState>(WeatherNotifier.new);
