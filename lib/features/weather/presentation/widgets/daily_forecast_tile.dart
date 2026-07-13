import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/models/forecast_model.dart';

class DailyForecastTile extends StatelessWidget {
  final DailyForecast day;

  const DailyForecastTile({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              day.dayName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CachedNetworkImage(
            imageUrl: day.representativeItem.iconUrl,
            width: 32,
            height: 32,
            errorWidget: (_, __, ___) => const Icon(
              Icons.wb_cloudy_rounded,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Text(
            '${day.tempMin.round()}°',
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(width: 8),
          _TempBar(min: day.tempMin, max: day.tempMax),
          const SizedBox(width: 8),
          Text(
            '${day.tempMax.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// A small gradient bar visualising the temperature range for a day.
class _TempBar extends StatelessWidget {
  final double min;
  final double max;

  const _TempBar({required this.min, required this.max});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFFFF7043)],
        ),
      ),
    );
  }
}
