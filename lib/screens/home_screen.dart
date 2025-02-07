import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  static const Duration _animationDuration = Duration(milliseconds: 300);
  
  late final AnimationController _searchController;
  final _scrollController = ScrollController();
  final _categoryScrollController = ScrollController();
  
  CacheManager? _cacheManager;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _searchController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    _initializeCache();
  }

  Future<void> _initializeCache() async {
    _cacheManager = await CacheService.instance.workoutImageCache;
    if (mounted) {
      setState(() {});
      _precacheImages();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  // Precache images for better performance
  Future<void> _precacheImages() async {
    if (_cacheManager == null) return;
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    for (final workout in workoutProvider.workouts) {
      await _cacheManager!.getSingleFile(workout.image);
    }
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (_showSearch) {
        _searchController.forward();
      } else {
        _searchController.reverse();
      }
    });
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
            // Header with profile and search
            SliverPersistentHeader(
              floating: true,
              delegate: HomeHeaderDelegate(
                showSearch: _showSearch,
                onSearchToggle: _toggleSearch,
                searchController: _searchController,
              ),
            ),

            // Search bar if enabled
            if (_showSearch)
              const SliverToBoxAdapter(
                child: SearchBarWidget(),
              ),

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
              sliver: WorkoutList(
                cacheManager: _cacheManager,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extracted Widgets

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.synchronized(
      child: SlideAnimation(
        verticalOffset: -50.0,
        child: FadeInAnimation(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search workout',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Persistent header delegate for better performance
class HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool showSearch;
  final VoidCallback onSearchToggle;
  final AnimationController searchController;

  const HomeHeaderDelegate({
    required this.showSearch,
    required this.onSearchToggle,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return HomeHeader(
      showSearch: showSearch,
      onSearchToggle: onSearchToggle,
      searchController: searchController,
    );
  }

  @override
  double get maxExtent => 80.0;

  @override
  double get minExtent => 80.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

class HomeHeader extends StatelessWidget {
  final bool showSearch;
  final VoidCallback onSearchToggle;
  final AnimationController searchController;

  const HomeHeader({
    Key? key,
    required this.showSearch,
    required this.onSearchToggle,
    required this.searchController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimationConfiguration.synchronized(
        child: SlideAnimation(
          verticalOffset: 50.0,
          child: FadeInAnimation(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF4ECDC4).withOpacity(0.1),
                              const Color(0xFF45B7D1).withOpacity(0.1),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFF4ECDC4).withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF4ECDC4),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'FitUser',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3142),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onSearchToggle,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: showSearch 
                                ? [
                                    const Color(0xFF4ECDC4),
                                    const Color(0xFF45B7D1),
                                  ]
                                : [
                                    const Color(0xFF4ECDC4).withOpacity(0.1),
                                    const Color(0xFF45B7D1).withOpacity(0.1),
                                  ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              if (showSearch)
                                BoxShadow(
                                  color: const Color(0xFF4ECDC4).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Icon(
                            Icons.search,
                            color: showSearch 
                              ? Colors.white 
                              : const Color(0xFF4ECDC4),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 