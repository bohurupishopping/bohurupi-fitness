import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../providers/workout_provider.dart';
import '../widgets/category_list.dart';
import '../widgets/workout_list.dart';
import '../services/cache_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _categoryScrollController = ScrollController();

  CacheManager? _cacheManager;

  @override
  void initState() {
    super.initState();
    _initializeCache();
  }

  Future<void> _initializeCache() async {
    _cacheManager = CacheService.instance.workoutImageCache;
    if (mounted) {
      setState(() {});
      _precacheImages();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  // Precache images for better performance
  Future<void> _precacheImages() async {
    if (_cacheManager == null) return;
    final workoutProvider = Provider.of<WorkoutProvider>(
      context,
      listen: false,
    );
    for (final workout in workoutProvider.workouts) {
      await _cacheManager!.getSingleFile(workout.image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Categories list
            SliverToBoxAdapter(
              child: CategoryList(
                scrollController: _categoryScrollController,
                cacheManager: _cacheManager,
              ),
            ),

            // Workout list
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 16),
              sliver: WorkoutList(cacheManager: _cacheManager),
            ),
          ],
        ),
      ),
    );
  }
}
