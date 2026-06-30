/// WeatherModel represents the current weather response from OpenWeatherMap.
/// Written manually without code generation to demonstrate fromJson patterns.
class WeatherModel {
  final int id;
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final int windDegree;
  final String description;
  final String iconCode;
  final String mainCondition; // "Clear", "Rain", "Clouds", etc.
  final int visibility;
  final int cloudiness;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime timestamp;

  const WeatherModel({
    required this.id,
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDegree,
    required this.description,
    required this.iconCode,
    required this.mainCondition,
    required this.visibility,
    required this.cloudiness,
    required this.sunrise,
    required this.sunset,
    required this.timestamp,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    final sys = json['sys'] as Map<String, dynamic>;
    final clouds = json['clouds'] as Map<String, dynamic>? ?? {};

    return WeatherModel(
      id: json['id'] as int,
      cityName: json['name'] as String,
      country: sys['country'] as String,
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      humidity: main['humidity'] as int,
      pressure: main['pressure'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      windDegree: (wind['deg'] as num? ?? 0).toInt(),
      description: weather['description'] as String,
      iconCode: weather['icon'] as String,
      mainCondition: weather['main'] as String,
      visibility: (json['visibility'] as num? ?? 10000).toInt(),
      cloudiness: (clouds['all'] as num? ?? 0).toInt(),
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        (sys['sunrise'] as int) * 1000,
      ),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        (sys['sunset'] as int) * 1000,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': cityName,
        'main': {
          'temp': temperature,
          'feels_like': feelsLike,
          'temp_min': tempMin,
          'temp_max': tempMax,
          'humidity': humidity,
          'pressure': pressure,
        },
        'wind': {'speed': windSpeed, 'deg': windDegree},
        'weather': [
          {
            'description': description,
            'icon': iconCode,
            'main': mainCondition,
          }
        ],
        'sys': {
          'country': country,
          'sunrise': sunrise.millisecondsSinceEpoch ~/ 1000,
          'sunset': sunset.millisecondsSinceEpoch ~/ 1000,
        },
        'dt': timestamp.millisecondsSinceEpoch ~/ 1000,
        'visibility': visibility,
        'clouds': {'all': cloudiness},
      };

  WeatherModel copyWith({
    double? temperature,
    double? feelsLike,
    double? tempMin,
    double? tempMax,
  }) =>
      WeatherModel(
        id: id,
        cityName: cityName,
        country: country,
        temperature: temperature ?? this.temperature,
        feelsLike: feelsLike ?? this.feelsLike,
        tempMin: tempMin ?? this.tempMin,
        tempMax: tempMax ?? this.tempMax,
        humidity: humidity,
        pressure: pressure,
        windSpeed: windSpeed,
        windDegree: windDegree,
        description: description,
        iconCode: iconCode,
        mainCondition: mainCondition,
        visibility: visibility,
        cloudiness: cloudiness,
        sunrise: sunrise,
        sunset: sunset,
        timestamp: timestamp,
      );

  String get iconUrl =>
      'https://openweathermap.org/img/wn/$iconCode@2x.png';

  bool get isDaytime {
    final now = DateTime.now();
    return now.isAfter(sunrise) && now.isBefore(sunset);
  }

  @override
  String toString() => 'WeatherModel($cityName, $temperature°C, $mainCondition)';
}
