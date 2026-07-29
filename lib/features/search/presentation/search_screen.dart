import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../providers/search_provider.dart';

/// SearchScreen demonstrates a debounced search pattern with Riverpod.
///
/// The debounce is implemented with a plain Timer (not a package) to show
/// how to manage side effects in ConsumerStatefulWidget. The 500ms delay
/// prevents an API call on every keystroke.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Cancel any pending search
    _debounceTimer?.cancel();

    final query = _controller.text;
    if (query.isEmpty) {
      ref.read(searchProvider.notifier).clear();
      return;
    }

    // Schedule search after debounce period
    _debounceTimer = Timer(AppConstants.searchDebounce, () {
      ref.read(searchProvider.notifier).search(query);
    });
  }

  void _selectCity(String cityName) {
    ref.read(searchProvider.notifier).selectCity(cityName, ref);
    Navigator.of(context)
      ..pop()         // close search
      ..popAndPushNamed(AppRouter.home); // navigate home with new city
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(searchProvider);
    final history = ref.watch(searchHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          cursorColor: Colors.white70,
          decoration: InputDecoration(
            hintText: 'Search city...',
            hintStyle: const TextStyle(color: Colors.white38),
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchProvider.notifier).clear();
                    },
                  )
                : null,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Colors.white12, height: 1),

          // Search results
          searchAsync.when(
            data: (results) {
              if (results.isNotEmpty) {
                return _buildResults(results);
              }
              // Fall through to history when no results yet
              return const SizedBox.shrink();
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white54,
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (error, _) => _buildErrorTile(error.toString()),
          ),

          // Search history (shown when no active search)
          if (_controller.text.isEmpty && history.isNotEmpty)
            _buildSearchHistory(history),
        ],
      ),
    );
  }

  Widget _buildResults(List results) {
    return Column(
      children: results.asMap().entries.map((e) {
        final weather = e.value;
        return ListTile(
          leading: const Icon(Icons.location_on_rounded, color: Colors.blue),
          title: Text(
            '${weather.cityName}, ${weather.country}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${weather.temperature.round()}° · ${weather.description}',
            style: const TextStyle(color: Colors.white54),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.white38),
          onTap: () => _selectCity(weather.cityName),
        )
            .animate()
            .fadeIn(delay: (e.key * 80).ms)
            .slideX(begin: 0.2, end: 0);
      }).toList(),
    );
  }

  Widget _buildSearchHistory(List<String> history) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'RECENT SEARCHES',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(searchHistoryProvider.notifier).clear(),
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (_, i) => ListTile(
                leading: const Icon(Icons.history, color: Colors.white38),
                title: Text(
                  history[i],
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white24, size: 18),
                  onPressed: () =>
                      ref.read(searchHistoryProvider.notifier).removeCity(history[i]),
                ),
                onTap: () => _selectCity(history[i]),
              )
                  .animate()
                  .fadeIn(delay: (i * 50).ms)
                  .slideX(begin: -0.1, end: 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorTile(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
