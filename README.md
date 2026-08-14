# Flutter Weather App

A production-quality weather dashboard built with Flutter, showcasing clean architecture, reactive state management with Riverpod, REST API integration, and micro-animations.

## Features

- **Real-time weather data** via OpenWeatherMap API (current conditions + 5-day forecast)
- **Dynamic gradient backgrounds** that change per weather condition (sunny = orange, rain = blue, storm = deep purple)
- **Animated weather icons** using `flutter_animate`: spinning sun, shaking rain, drifting snow
- **Animated temperature counter** — smooth number roll animation on unit switch (°C / °F)
- **City search with debounce** — 500ms debounce to avoid flooding the API, in-memory search history
- **5-day / hourly forecast** with horizontal scroll and staggered entry animations
- **Details screen** with custom-painted circular arc gauges for humidity, wind speed, and pressure
- **Custom page transitions** — DetailsScreen slides up from bottom via `SlideTransition`

## Architecture

Feature-first with a clean data/domain/presentation split:

```
lib/
├── core/
│   ├── constants/     # API base URL, keys, durations
│   ├── router/        # Named route generation + custom transitions
│   └── theme/         # Material 3 theme + weather gradient palette
└── features/
    ├── weather/
    │   ├── data/
    │   │   ├── models/        # WeatherModel, ForecastModel (manual fromJson)
    │   │   ├── services/      # WeatherApiService (Dio)
    │   │   └── repositories/  # IWeatherRepository interface + impl
    │   ├── providers/         # Riverpod: WeatherNotifier, useMetricProvider
    │   └── presentation/
    │       ├── screens/       # HomeScreen, DetailsScreen
    │       └── widgets/       # AnimatedWeatherIcon, HourlyForecastCard, ...
    └── search/
        ├── providers/         # SearchNotifier (AsyncNotifier), SearchHistoryNotifier
        └── presentation/      # SearchScreen
```

## State Management — Riverpod

| Provider | Type | Purpose |
|---|---|---|
| `weatherProvider` | `AsyncNotifierProvider<WeatherNotifier, WeatherState>` | Current weather + forecast; auto loading/error states |
| `searchProvider` | `AsyncNotifierProvider<SearchNotifier, List<WeatherModel>>` | City search results |
| `searchHistoryProvider` | `StateNotifierProvider<SearchHistoryNotifier, List<String>>` | In-memory LRU search history |
| `useMetricProvider` | `StateProvider<bool>` | °C / °F toggle |

The UI pattern-matches on `AsyncValue`:
```dart
ref.watch(weatherProvider).when(
  data: (state) => _buildWeatherScreen(state),
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text(e.toString()),
);
```

## Key Technical Highlights

### CustomPainter Gauges (`_ArcGaugePainter`)
The humidity/wind/pressure gauges in DetailsScreen are drawn with `CustomPainter.canvas.drawArc()`. The arc starts at 135° (7 o'clock) and sweeps 270°, leaving a gap at the bottom. The filled portion is animated from 0 to `progress` via `AnimationController` + `CurvedAnimation`.

### Animated Temperature Counter
`_AnimatedTemperature` uses `SingleTickerProviderStateMixin` and an `AnimatedBuilder` to interpolate between the previous and new temperature values, creating a "counting" effect when the user toggles °C/°F.

### Debounced Search
Rather than adding a debounce package, the search is debounced with a plain `dart:async Timer` managed in `ConsumerStatefulWidget.initState/dispose`. This demonstrates lifecycle-aware side effect management.

### flutter_animate Chaining
```dart
child
  .animate(onPlay: (c) => c.repeat())
  .rotate(duration: 8.seconds, curve: Curves.linear)  // sun spin

child
  .animate(onPlay: (c) => c.repeat(reverse: true))
  .moveY(begin: 0, end: 6, duration: 600.ms)  // rain drop
```

## Setup

1. Clone the repository
2. Get your free API key at [openweathermap.org](https://openweathermap.org/api)
3. Replace `YOUR_API_KEY` in `lib/core/constants/app_constants.dart`
4. Run `flutter pub get`
5. Run `flutter run`

## Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | Reactive state management |
| `dio` | HTTP client with interceptors |
| `flutter_animate` | Declarative micro-animations |
| `google_fonts` | Nunito typography |
| `cached_network_image` | Weather icon caching |
| `geolocator` | Device location (future feature) |
| `permission_handler` | Location permissions |

## Screenshots

_Add screenshots here after running the app_

## License

MIT
