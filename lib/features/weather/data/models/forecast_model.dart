/// ForecastModel wraps the 5-day / 3-hour forecast data from OpenWeatherMap.
/// The API returns a list of up to 40 items; we group them by day client-side.
class ForecastItem {
  final DateTime dateTime;
  final double temperature;
  final double tempMin;
  final double tempMax;
  final double feelsLike;
  final int humidity;
  final String description;
  final String iconCode;
  final String mainCondition;
  final double windSpeed;
  final double precipitationProbability; // 0.0 - 1.0

  const ForecastItem({
    required this.dateTime,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.feelsLike,
    required this.humidity,
    required this.description,
    required this.iconCode,
    required this.mainCondition,
    required this.windSpeed,
    required this.precipitationProbability,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;

    return ForecastItem(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
      temperature: (main['temp'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      humidity: main['humidity'] as int,
      description: weather['description'] as String,
      iconCode: weather['icon'] as String,
      mainCondition: weather['main'] as String,
      windSpeed: (wind['speed'] as num).toDouble(),
      precipitationProbability: (json['pop'] as num? ?? 0).toDouble(),
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';

  String get shortTime {
    final h = dateTime.hour.toString().padLeft(2, '0');
    return '$h:00';
  }
}

class ForecastModel {
  final String cityName;
  final String country;
  final List<ForecastItem> items;

  const ForecastModel({
    required this.cityName,
    required this.country,
    required this.items,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final city = json['city'] as Map<String, dynamic>;
    final list = (json['list'] as List)
        .map((item) => ForecastItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return ForecastModel(
      cityName: city['name'] as String,
      country: (city['country'] as String? ?? ''),
      items: list,
    );
  }

  /// Groups forecast items by calendar day, returning up to 5 days.
  /// Takes the min/max across all items for that day.
  List<DailyForecast> get dailyForecasts {
    final Map<String, List<ForecastItem>> grouped = {};

    for (final item in items) {
      final key =
          '${item.dateTime.year}-${item.dateTime.month}-${item.dateTime.day}';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return grouped.entries.take(5).map((entry) {
      final dayItems = entry.value;
      final temps = dayItems.map((i) => i.temperature).toList();
      return DailyForecast(
        date: dayItems.first.dateTime,
        tempMin: temps.reduce((a, b) => a < b ? a : b),
        tempMax: temps.reduce((a, b) => a > b ? a : b),
        representativeItem: dayItems[dayItems.length ~/ 2],
      );
    }).toList();
  }

  /// Returns the next 8 hourly items (24h view).
  List<ForecastItem> get hourlyForecast => items.take(8).toList();
}

class DailyForecast {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final ForecastItem representativeItem;

  const DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.representativeItem,
  });

  String get dayName {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
