import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../weather/data/models/weather_model.dart';
import '../../weather/data/repositories/weather_repository.dart';
import '../../weather/providers/weather_providers.dart';
import '../../../core/constants/app_constants.dart';

// ---------------------------------------------------------------------------
// Search history (in-memory, persists for app session)
// ---------------------------------------------------------------------------

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]);

  void addCity(String city) {
    if (state.contains(city)) {
      // Move to front
      state = [city, ...state.where((c) => c != city)];
    } else {
      state = [city, ...state].take(AppConstants.maxSearchHistory).toList();
    }
  }

  void removeCity(String city) {
    state = state.where((c) => c != city).toList();
  }

  void clear() => state = [];
}

final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>(
  (ref) => SearchHistoryNotifier(),
);

// ---------------------------------------------------------------------------
// City search — AsyncNotifier with debounce
// ---------------------------------------------------------------------------

/// SearchState holds the list of matching city weather results.
/// We model it as a list (OpenWeatherMap only returns one match per query,
/// but the architecture supports expansion to a geo-search endpoint).
class SearchNotifier extends AsyncNotifier<List<WeatherModel>> {
  @override
  Future<List<WeatherModel>> build() async => [];

  /// Called on every keystroke; debounce is handled in the UI layer.
  /// Uses AsyncValue.guard so any exception becomes AsyncError automatically.
  Future<void> search(String query) async {
    if (query.trim().length < 2) {
      state = const AsyncData([]);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(weatherRepositoryProvider);
      final weather = await repo.getCurrentWeather(query.trim());
      return [weather];
    });
  }

  void clear() {
    state = const AsyncData([]);
  }

  /// Select a city from results: update the weather provider and add to history.
  void selectCity(String cityName, WidgetRef ref) {
    ref.read(searchHistoryProvider.notifier).addCity(cityName);
    ref.read(weatherProvider.notifier).loadCity(cityName);
  }
}

final searchProvider =
    AsyncNotifierProvider<SearchNotifier, List<WeatherModel>>(
  SearchNotifier.new,
);
