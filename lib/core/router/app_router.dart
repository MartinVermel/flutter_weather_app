import 'package:flutter/material.dart';

import '../../features/weather/data/models/weather_model.dart';
import '../../features/weather/presentation/screens/home_screen.dart';
import '../../features/weather/presentation/screens/details_screen.dart';
import '../../features/search/presentation/search_screen.dart';

class AppRouter {
  AppRouter._();

  static const String home = '/';
  static const String search = '/search';
  static const String details = '/details';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case search:
        return MaterialPageRoute(
          builder: (_) => const SearchScreen(),
        );

      case details:
        // The details screen receives a WeatherModel as argument
        final weather = settings.arguments as WeatherModel;
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              DetailsScreen(weather: weather),
          // Custom slide-from-bottom transition
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;
            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
    }
  }
}
