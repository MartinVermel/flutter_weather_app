import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/weather_model.dart';

/// DetailsScreen showcases two advanced Flutter techniques:
/// 1. CustomPainter for drawing circular arc gauges (wind, humidity, pressure)
/// 2. The screen itself arrives via a SlideTransition (defined in AppRouter)
class DetailsScreen extends StatelessWidget {
  final WeatherModel weather;

  const DetailsScreen({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          '${weather.cityName} Details',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: city + condition
            _buildHeader(context),
            const SizedBox(height: 32),

            // Gauges section
            _SectionTitle(title: 'Atmospheric Data'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _GaugeWidget(
                  label: 'Humidity',
                  value: weather.humidity.toDouble(),
                  maxValue: 100,
                  unit: '%',
                  color: const Color(0xFF42A5F5),
                ).animate().fadeIn(delay: 300.ms).scale(
                      begin: const Offset(0.7, 0.7),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
                _GaugeWidget(
                  label: 'Wind',
                  value: weather.windSpeed,
                  maxValue: 30,
                  unit: 'm/s',
                  color: const Color(0xFF66BB6A),
                ).animate().fadeIn(delay: 450.ms).scale(
                      begin: const Offset(0.7, 0.7),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
                _GaugeWidget(
                  label: 'Pressure',
                  value: weather.pressure.toDouble() - 950,
                  maxValue: 100,
                  unit: 'hPa',
                  displayValue: weather.pressure.toDouble(),
                  color: const Color(0xFFAB47BC),
                ).animate().fadeIn(delay: 600.ms).scale(
                      begin: const Offset(0.7, 0.7),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
              ],
            ),

            const SizedBox(height: 32),

            // Additional info
            _SectionTitle(title: 'More Information'),
            const SizedBox(height: 12),
            _buildInfoGrid(),

            const SizedBox(height: 32),

            // Sun times
            _SectionTitle(title: 'Sunrise & Sunset'),
            const SizedBox(height: 12),
            _SunTimesCard(weather: weather)
                .animate()
                .fadeIn(delay: 700.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            weather.cityName,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            weather.country,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${weather.temperature.round()}°C',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.mainCondition,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    weather.description,
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildInfoGrid() {
    final items = [
      _InfoItem(
        icon: Icons.thermostat_rounded,
        label: 'Feels Like',
        value: '${weather.feelsLike.round()}°C',
      ),
      _InfoItem(
        icon: Icons.arrow_downward_rounded,
        label: 'Min Temp',
        value: '${weather.tempMin.round()}°C',
      ),
      _InfoItem(
        icon: Icons.arrow_upward_rounded,
        label: 'Max Temp',
        value: '${weather.tempMax.round()}°C',
      ),
      _InfoItem(
        icon: Icons.cloud_rounded,
        label: 'Cloud Cover',
        value: '${weather.cloudiness}%',
      ),
      _InfoItem(
        icon: Icons.visibility_rounded,
        label: 'Visibility',
        value: '${(weather.visibility / 1000).round()} km',
      ),
      _InfoItem(
        icon: Icons.explore_rounded,
        label: 'Wind Dir',
        value: _degreesToCardinal(weather.windDegree),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _InfoCard(item: items[i])
          .animate()
          .fadeIn(delay: (400 + i * 60).ms)
          .slideY(begin: 0.2, end: 0),
    );
  }

  String _degreesToCardinal(int deg) {
    const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return dirs[((deg + 22) ~/ 45) % 8];
  }
}

// ---------------------------------------------------------------------------
// GaugeWidget — the centrepiece CustomPainter component
// ---------------------------------------------------------------------------

class _GaugeWidget extends StatefulWidget {
  final String label;
  final double value;
  final double maxValue;
  final String unit;
  final double? displayValue;
  final Color color;

  const _GaugeWidget({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.unit,
    required this.color,
    this.displayValue,
  });

  @override
  State<_GaugeWidget> createState() => _GaugeWidgetState();
}

class _GaugeWidgetState extends State<_GaugeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0,
      end: (widget.value / widget.maxValue).clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final display = widget.displayValue ?? widget.value;

    return Column(
      children: [
        SizedBox(
          width: 90,
          height: 90,
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (_, __) => CustomPaint(
              painter: _ArcGaugePainter(
                progress: _progressAnimation.value,
                color: widget.color,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      display.round().toString(),
                      style: TextStyle(
                        color: widget.color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    Text(
                      widget.unit,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// _ArcGaugePainter draws a circular track with a filled arc representing
/// [progress] (0.0 to 1.0). We use canvas.drawArc() with the following
/// parameters:
///   - rect: bounding box, inset by strokeWidth/2 to avoid clipping
///   - startAngle: math.pi * 0.75 (bottom-left, 7 o'clock position)
///   - sweepAngle: 270° of arc (leaves a gap at the bottom)
///   - useCenter: false → stroke arc, not a pie slice
class _ArcGaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  const _ArcGaugePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  static const double _strokeWidth = 7.0;
  static const double _startAngle = math.pi * 0.75;  // 135°
  static const double _fullSweep = math.pi * 1.5;    // 270°

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - _strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    canvas.drawArc(
      rect,
      _startAngle,
      _fullSweep,
      false,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Filled progress arc
    if (progress > 0) {
      canvas.drawArc(
        rect,
        _startAngle,
        _fullSweep * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcGaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      );
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem({required this.icon, required this.label, required this.value});
}

class _InfoCard extends StatelessWidget {
  final _InfoItem item;
  const _InfoCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: Colors.white54, size: 20),
          const SizedBox(height: 4),
          Text(
            item.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            item.label,
            style: const TextStyle(color: Colors.white38, fontSize: 9),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SunTimesCard extends StatelessWidget {
  final WeatherModel weather;
  const _SunTimesCard({required this.weather});

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF8C00).withOpacity(0.2),
            const Color(0xFF1565C0).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.wb_twilight_rounded,
                    color: Color(0xFFFFB74D), size: 32),
                const SizedBox(height: 8),
                Text(
                  _formatTime(weather.sunrise),
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Sunrise',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: Colors.white12,
          ),
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.nights_stay_rounded,
                    color: Color(0xFF42A5F5), size: 32),
                const SizedBox(height: 8),
                Text(
                  _formatTime(weather.sunset),
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Sunset',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
