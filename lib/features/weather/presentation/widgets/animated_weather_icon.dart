import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// AnimatedWeatherIcon applies different flutter_animate effects depending
/// on the weather condition, making each weather type feel alive:
/// - Clear/Sun → continuous rotation (spinning sun)
/// - Rain/Drizzle → vertical shake (falling rain feel)
/// - Thunderstorm → rapid shake (lightning jolt)
/// - Snow → slow oscillation (drifting snow)
/// - Clouds → gentle fade pulse (moving clouds)
class AnimatedWeatherIcon extends StatelessWidget {
  final String iconUrl;
  final String condition;
  final double size;

  const AnimatedWeatherIcon({
    super.key,
    required this.iconUrl,
    required this.condition,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    final icon = CachedNetworkImage(
      imageUrl: iconUrl,
      width: size,
      height: size,
      placeholder: (_, __) => SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white54,
        ),
      ),
      errorWidget: (_, __, ___) => Icon(
        Icons.wb_sunny_rounded,
        size: size,
        color: Colors.white,
      ),
    );

    return _applyAnimation(icon, condition.toLowerCase());
  }

  Widget _applyAnimation(Widget child, String condition) {
    if (condition.contains('clear') || condition.contains('sun')) {
      // Continuous slow rotation for a sunny day
      return child
          .animate(onPlay: (c) => c.repeat())
          .rotate(
            duration: 8.seconds,
            curve: Curves.linear,
          );
    }

    if (condition.contains('rain') || condition.contains('drizzle')) {
      // Repeating vertical shake to mimic falling rain
      return child
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: 6,
            duration: 600.ms,
            curve: Curves.easeInOut,
          );
    }

    if (condition.contains('thunderstorm')) {
      // Rapid shake for the jolt of thunder
      return child
          .animate(onPlay: (c) => c.repeat())
          .shake(hz: 4, duration: 400.ms)
          .then(delay: 1200.ms);
    }

    if (condition.contains('snow')) {
      // Gentle sway left-right for drifting snow
      return child
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveX(
            begin: -4,
            end: 4,
            duration: 2.seconds,
            curve: Curves.easeInOut,
          );
    }

    // Clouds: soft fade pulse
    return child
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: 1500.ms, curve: Curves.easeInOut)
        .then()
        .fadeOut(duration: 1500.ms, curve: Curves.easeInOut);
  }
}
