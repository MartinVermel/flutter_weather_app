<div align="center">

<img src="https://raw.githubusercontent.com/devicons/devicon/master/icons/flutter/flutter-original.svg" alt="Flutter" width="80" />

# Flutter Weather App

**A production-quality weather dashboard built with Flutter**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-5AC8FA)](https://riverpod.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Real-time weather with animated icons, custom-painted gauges, and a city search — built to showcase clean architecture, reactive state management, and Flutter's animation APIs.

</div>

---

## Screenshots

<div align="center">

| Home — Sunny | Home — Rainy | City Search | Details |
|:---:|:---:|:---:|:---:|
| <img src="docs/screenshots/home_sunny.png" width="180" alt="Home Sunny" /> | <img src="docs/screenshots/home_rain.png" width="180" alt="Home Rainy" /> | <img src="docs/screenshots/search.png" width="180" alt="City Search" /> | <img src="docs/screenshots/details.png" width="180" alt="Details" /> |

> **Note:** Screenshots coming soon — run the app locally with your OpenWeatherMap API key to see it in action.

</div>

---

## Features

- 🌤 **Dynamic backgrounds** — gradient changes per weather condition (sunny → amber, rain → blue, storm → deep purple)
- 🌀 **Animated icons** — spinning sun, pulsing rain, drifting snow using `flutter_animate`
- 🌡 **Animated temperature counter** — smooth number roll on °C / °F toggle
- 🔍 **Debounced city search** — 500ms debounce, in-memory search history
- 📅 **5-day forecast** — horizontal scroll with staggered entry animations
- 🎨 **Arc gauges** — humidity, wind speed and pressure drawn with `CustomPainter`
- 🗺 **go_router navigation** — typed routes with custom `SlideTransition` page transitions

---

## Architecture

Feature-first folder structure with a clean data / domain / presentation split:

```
lib/
├── core/
│   ├── constants/        # API base URL, endpoint paths, placeholder key
│   ├── router/           # go_router setup + custom SlideTransition
│   └── theme/            # Material 3 ColorScheme + weather gradient palette
└── features/
    ├── weather/
    │   ├── data/
    │   │   ├── models/   # WeatherModel, ForecastModel (manual fromJson)
    │   │   ├── services/ # WeatherApiService (Dio)
    │   │   └── repositories/ # WeatherRepository (abstracts service)
    │   ├── providers/    # Riverpod AsyncNotifierProvider, settingsProvider
    │   └── presentation/
    │       ├── screens/  # HomeScreen, DetailsScreen
    │       └── widgets/  # AnimatedWeatherIcon, HourlyForecastCard, ...
    └── search/
        ├── providers/    # StateNotifierProvider for search history
        └── presentation/ # SearchScreen
```

**State flow:**
```
WeatherApiService  →  WeatherRepository  →  WeatherNotifier (AsyncNotifier)
                                                    ↓
                                             UI: .when(data, loading, error)
```

---

## Tech Stack

| Package | Version | Role |
|---|---|---|
| `flutter_riverpod` | ^2.5.1 | Reactive state management, DI |
| `flutter_animate` | ^4.5.0 | Declarative micro-animations |
| `go_router` | ^14.2.7 | Declarative navigation with typed params |
| `dio` | ^5.4.3 | HTTP client for OpenWeatherMap API |
| `cached_network_image` | ^3.3.1 | Disk + memory image caching |
| `google_fonts` | ^6.2.1 | Nunito font for UI |

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- A free [OpenWeatherMap API key](https://openweathermap.org/api) (takes ~1 minute to register)

### Installation

```bash
git clone https://github.com/MartinVermel/flutter_weather_app.git
cd flutter_weather_app
flutter pub get
```

### Configuration

Open `lib/core/constants/api_constants.dart` and replace the placeholder key:

```dart
class ApiConstants {
  static const String apiKey = 'YOUR_API_KEY'; // ← replace this
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
}
```

### Run

```bash
flutter run
```

---

## Key Implementation Notes

### `AnimatedWeatherIcon` — stateless condition-driven animation
Instead of a `StatefulWidget` per animation type, `flutter_animate`'s `.animate()` extension wraps any child widget. The `onPlay: (c) => c.repeat()` callback registers on the internal `AnimationController` before it starts — no manual `TickerProvider` or `dispose()` needed.

### `_ArcGaugePainter` — `CustomPainter` with `shouldRepaint`
An `AnimationController` drives a `Tween<double>` from `0.0` to the target value. `CustomPainter` converts the current value to a `canvas.drawArc()` sweep angle. The `shouldRepaint` override ensures the painter only re-runs when the animation actually ticks — skipping it on unrelated rebuilds.

### `WeatherNotifier` — `AsyncValue.guard()` + `Future.wait()`
`AsyncValue.guard()` wraps any async call and auto-converts thrown exceptions into `AsyncError` — zero try/catch boilerplate. `Future.wait([getCurrentWeather(), getForecast()])` fires both API calls in parallel, halving total load time.

---

## Project Structure Decisions

- **Why feature-first over layer-first?** Each feature can be extracted or deleted without touching other features. `weather/` and `search/` are independent vertical slices.
- **Why Riverpod over Provider/BLoC?** `AsyncNotifierProvider` gives compile-safe, code-gen-free async state with built-in loading/error/data states. The DI chain (`service → repository → notifier`) is explicit and testable.
- **Why manual `fromJson` instead of `freezed`?** Keeps the project dependency-light and makes the JSON mapping visible. `freezed` is worth adding once the model shape stabilizes.

---

## License

MIT © [Martin Vermel](https://github.com/MartinVermel)
