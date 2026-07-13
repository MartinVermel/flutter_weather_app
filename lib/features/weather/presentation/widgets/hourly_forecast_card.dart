import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/models/forecast_model.dart';

class HourlyForecastCard extends StatelessWidget {
  final ForecastItem item;
  final bool isFirst;

  const HourlyForecastCard({
    super.key,
    required this.item,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      margin: EdgeInsets.only(left: isFirst ? 0 : 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.shortTime,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          CachedNetworkImage(
            imageUrl: item.iconUrl,
            width: 36,
            height: 36,
            errorWidget: (_, __, ___) => const Icon(
              Icons.wb_cloudy_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${item.temperature.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (item.precipitationProbability > 0.1) ...[
            const SizedBox(height: 4),
            Text(
              '${(item.precipitationProbability * 100).round()}%',
              style: const TextStyle(
                color: Color(0xFF90CAF9),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
