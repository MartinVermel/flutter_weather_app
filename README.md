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
- 🗺 **Named routes** — `onGenerateRoute` with a custom `SlideTransition` page transition

---

## Architecture

Feature-first folder structure with a clean data / domain / presentation split:

```
lib/
├── core/
│   ├── constants/        # API base URL, endpoint paths, placeholder key
│   ├── router/           # Named routes (onGenerateRoute) + custom SlideTransition
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
    │       └── widgets/  # AnimatedWeatherIcon, HourlyForecastCard, DailyForecastTile
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

Pass the key at build/run time, no file edit needed:

```bash
flutter run --dart-define=OPENWEATHER_API_KEY=your_key
```

It is read in `lib/core/constants/app_constants.dart` via `String.fromEnvironment`.

### Run

```bash
flutter run --dart-define=OPENWEATHER_API_KEY=your_key
```

---

## Docker

The app ships as a Flutter **web** build served by nginx, using a multi-stage `Dockerfile` (Flutter SDK build stage, then a ~100 MB nginx:alpine runtime image).

```bash
OPENWEATHER_API_KEY=your_key docker compose up --build
```
Open http://localhost:8101 (each project uses its own port so they can run side by side; override with `HOST_PORT=9000 docker compose up --build`).

Or without Compose:

```bash
docker build --build-arg OPENWEATHER_API_KEY=your_key -t flutter_weather_app .
docker run -p 8101:80 flutter_weather_app
```

`OPENWEATHER_API_KEY` is passed to `flutter build web --dart-define` at build time. Without it the app builds with a placeholder and the weather calls will fail. Note that any key compiled into a client-side bundle is visible to users, so use a restricted/free-tier key.

| File | Purpose |
|---|---|
| `Dockerfile` | Stage 1 builds `flutter build web --release`, stage 2 copies the output into nginx |
| `nginx.conf` | SPA fallback to `index.html`, gzip, long-lived cache for assets, no-cache for the bootstrap files |
| `docker-compose.yml` | One-command run on port 8101 |
| `.dockerignore` | Keeps `.git`, `build/` and `.dart_tool/` out of the build context |

Docker serves the web target only. For Android/iOS builds use `flutter run` as above.

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
