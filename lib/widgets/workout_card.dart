import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import '../services/cache_service.dart';

class WorkoutCard extends StatelessWidget {
  static const Duration _animationDuration = Duration(milliseconds: 200);
  
  final Workout workout;
  final VoidCallback onTap;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<WorkoutProvider, bool>(
      selector: (_, provider) => provider.isWorkoutCompleted(workout.id),
      builder: (context, isCompleted, _) {
        return Hero(
          tag: 'workout_card_${workout.id}',
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ImageSection(
                        workout: workout,
                        isCompleted: isCompleted,
                      ),
                      _DetailsSection(workout: workout),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ).animate()
          .fadeIn(duration: _animationDuration)
          .slideY(begin: 0.1, end: 0, duration: _animationDuration);
      },
    );
  }
}

class _ImageSection extends StatelessWidget {
  final Workout workout;
  final bool isCompleted;

  const _ImageSection({
    required this.workout,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: 'workout_image_${workout.id}',
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: CachedNetworkImage(
              imageUrl: workout.image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 100),
              fadeOutDuration: const Duration(milliseconds: 100),
              placeholderFadeInDuration: const Duration(milliseconds: 100),
              placeholder: (context, url) => Container(
                color: AppTheme.backgroundColor,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppTheme.backgroundColor,
                child: const Icon(Icons.error),
              ),
              cacheManager: CacheService.instance.workoutImageCache,
              useOldImageOnUrlChange: true,
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: _StatusBadge(isCompleted: isCompleted),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isCompleted;
  
  const _StatusBadge({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted ? AppTheme.successColor : AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.timer,
            size: 16,
            color: isCompleted ? Colors.white : AppTheme.subtitleColor,
          ),
          const SizedBox(width: 4),
          Text(
            isCompleted ? 'Completed' : 'Todo',
            style: TextStyle(
              color: isCompleted ? Colors.white : AppTheme.subtitleColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final Workout workout;

  const _DetailsSection({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workout.exercise,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoChip(icon: Icons.fitness_center, label: '${workout.sets} sets'),
              const SizedBox(width: 8),
              _InfoChip(icon: Icons.repeat, label: workout.repsRange),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
