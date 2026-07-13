import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/weather_model.dart';
import '../../providers/weather_providers.dart';
import '../widgets/animated_weather_icon.dart';
import '../widgets/hourly_forecast_card.dart';
import '../widgets/daily_forecast_tile.dart';

/// HomeScreen is a ConsumerWidget — it rebuilds when weatherProvider changes.
/// The gradient background is derived from the current weather condition,
/// making the UI respond visually to data, not just display it.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    final useMetric = ref.watch(useMetricProvider);

    return weatherAsync.when(
      loading: () => _buildLoadingScreen(),
      error: (error, _) => _buildErrorScreen(error.toString(), ref),
      data: (state) => _buildWeatherScreen(context, ref, state, useMetric),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Loading weather...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, color: Colors.white54, size: 64),
              const SizedBox(height: 16),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(weatherProvider.notifier).loadCity('London'),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherScreen(
    BuildContext context,
    WidgetRef ref,
    WeatherState state,
    bool useMetric,
  ) {
    final weather = state.weather!;
    final forecast = state.forecast;
    final gradientColors =
        AppTheme.getGradientForCondition(weather.mainCondition);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          '${weather.cityName}, ${weather.country}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Unit toggle button
          TextButton(
            onPressed: () =>
                ref.read(weatherProvider.notifier).toggleUnit(),
            child: Text(
              useMetric ? '°C' : '°F',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, AppRouter.search),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Animated weather icon
                AnimatedWeatherIcon(
                  iconUrl: weather.iconUrl,
                  condition: weather.mainCondition,
                  size: 120,
                ).animate().fadeIn(duration: 600.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),

                const SizedBox(height: 8),

                // Large temperature display with animated counter
                _AnimatedTemperature(
                  temperature: useMetric
                      ? weather.temperature
                      : _toFahrenheit(weather.temperature),
                  unit: useMetric ? '°C' : '°F',
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                // Weather description
                Text(
                  weather.description.toUpperCase(),
                  style: GoogleFonts.nunito(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 8),

                // Feels like
                Text(
                  'Feels like ${useMetric ? weather.feelsLike.round() : _toFahrenheit(weather.feelsLike).round()}°',
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 24),

                // Quick stats row
                _QuickStatsRow(weather: weather)
                    .animate()
                    .fadeIn(delay: 500.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 24),

                // Hourly forecast
                if (forecast != null) ...[
                  _SectionHeader(
                    icon: Icons.access_time_rounded,
                    title: 'Hourly Forecast',
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: forecast.hourlyForecast.length,
                      itemBuilder: (_, i) => HourlyForecastCard(
                        item: forecast.hourlyForecast[i],
                        isFirst: i == 0,
                      )
                          .animate()
                          .fadeIn(delay: (600 + i * 60).ms)
                          .slideX(begin: 0.3, end: 0),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    icon: Icons.calendar_today_rounded,
                    title: '5-Day Forecast',
                  ).animate().fadeIn(delay: 700.ms),
                  const SizedBox(height: 8),
                  ...forecast.dailyForecasts
                      .asMap()
                      .entries
                      .map(
                        (e) => DailyForecastTile(day: e.value)
                            .animate()
                            .fadeIn(delay: (700 + e.key * 80).ms)
                            .slideX(begin: -0.2, end: 0),
                      ),
                ],

                const SizedBox(height: 24),

                // See details button
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRouter.details,
                    arguments: weather,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Full Details'),
                ).animate().fadeIn(delay: 900.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _toFahrenheit(double celsius) => celsius * 9 / 5 + 32;
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _AnimatedTemperature extends StatefulWidget {
  final double temperature;
  final String unit;

  const _AnimatedTemperature({required this.temperature, required this.unit});

  @override
  State<_AnimatedTemperature> createState() => _AnimatedTemperatureState();
}

class _AnimatedTemperatureState extends State<_AnimatedTemperature>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousTemp = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.temperature)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedTemperature oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.temperature != widget.temperature) {
      _previousTemp = oldWidget.temperature;
      _animation = Tween<double>(begin: _previousTemp, end: widget.temperature)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOut),
          );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: _animation.value.round().toString(),
              style: GoogleFonts.nunito(
                fontSize: 96,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1,
              ),
            ),
            TextSpan(
              text: widget.unit,
              style: GoogleFonts.nunito(
                fontSize: 36,
                fontWeight: FontWeight.w300,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  final WeatherModel weather;

  const _QuickStatsRow({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatChip(
          icon: Icons.water_drop_rounded,
          value: '${weather.humidity}%',
          label: 'Humidity',
        ),
        _StatChip(
          icon: Icons.air_rounded,
          value: '${weather.windSpeed.round()} m/s',
          label: 'Wind',
        ),
        _StatChip(
          icon: Icons.visibility_rounded,
          value: '${(weather.visibility / 1000).round()} km',
          label: 'Visibility',
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
