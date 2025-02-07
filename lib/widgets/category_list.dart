import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../providers/workout_provider.dart';

class CategoryList extends StatelessWidget {
  final ScrollController scrollController;
  final CacheManager? cacheManager;

  const CategoryList({
    super.key,
    required this.scrollController,
    required this.cacheManager,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'icon': Icons.fitness_center,
        'color': const Color(0xFF4ECDC4),
        'name': 'Back'
      },
      {
        'icon': Icons.sports_gymnastics,
        'color': const Color(0xFFFF6B6B),
        'name': 'Chest'
      },
      {
        'icon': Icons.sports_handball,
        'color': const Color(0xFF45B7D1),
        'name': 'Biceps'
      },
      {
        'icon': Icons.accessibility_new,
        'color': const Color(0xFFFFA06B),
        'name': 'Shoulder'
      },
      {
        'icon': Icons.directions_run,
        'color': const Color(0xFF9B51E0),
        'name': 'Leg'
      },
      {
        'icon': Icons.fitness_center,
        'color': const Color(0xFF2D3142),
        'name': 'Abs'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: Consumer<WorkoutProvider>(
            builder: (context, provider, child) {
              return AnimationConfiguration.synchronized(
                child: SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: ListView.builder(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.uniqueDays.length,
                      itemBuilder: (context, index) {
                        final day = provider.uniqueDays[index];
                        final isSelected = day == provider.selectedDay;
                        final category = categories[index % categories.length];
                        
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                child: GestureDetector(
                                  onTap: () => provider.setSelectedDay(day),
                                  child: TweenAnimationBuilder(
                                    duration: const Duration(milliseconds: 300),
                                    tween: Tween<double>(
                                      begin: isSelected ? 0.95 : 1.0,
                                      end: isSelected ? 1.0 : 0.95,
                                    ),
                                    builder: (context, double scale, child) {
                                      return Transform.scale(
                                        scale: scale,
                                        child: Container(
                                          width: 85,
                                          decoration: BoxDecoration(
                                            color: isSelected ? category['color'] as Color : Colors.white,
                                            borderRadius: BorderRadius.circular(24),
                                            boxShadow: [
                                              BoxShadow(
                                                color: (category['color'] as Color).withOpacity(0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: isSelected 
                                                    ? Colors.white.withOpacity(0.2)
                                                    : (category['color'] as Color).withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  category['icon'] as IconData,
                                                  color: isSelected 
                                                    ? Colors.white
                                                    : category['color'] as Color,
                                                  size: 22,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                day,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: isSelected ? Colors.white : const Color(0xFF2D3142),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 