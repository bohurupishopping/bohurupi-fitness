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

  const WorkoutCard({super.key, required this.workout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Selector<WorkoutProvider, bool>(
      selector: (_, provider) => provider.isWorkoutCompleted(workout.id),
      builder: (context, isCompleted, _) {
        return Hero(
              tag: 'workout_card_${workout.id}',
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: AppTheme.cardColor,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(24),
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
            )
            .animate()
            .fadeIn(duration: _animationDuration)
            .slideY(begin: 0.1, end: 0, duration: _animationDuration);
      },
    );
  }
}

class _ImageSection extends StatelessWidget {
  final Workout workout;
  final bool isCompleted;

  const _ImageSection({required this.workout, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: 'workout_image_${workout.id}',
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: CachedNetworkImage(
              imageUrl: workout.image,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 100),
              fadeOutDuration: const Duration(milliseconds: 100),
              placeholderFadeInDuration: const Duration(milliseconds: 100),
              placeholder: (context, url) => Container(
                color: AppTheme.backgroundColor,
                child: const Center(child: CircularProgressIndicator()),
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
          top: 16,
          right: 16,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.successColor
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? Colors.transparent
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.timer_rounded,
            size: 16,
            color: isCompleted ? Colors.white : AppTheme.subtitleColor,
          ),
          const SizedBox(width: 6),
          Text(
            isCompleted ? 'Completed' : 'Todo',
            style: TextStyle(
              color: isCompleted ? Colors.white : AppTheme.subtitleColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workout.exercise,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(
                icon: Icons.fitness_center_rounded,
                label: '${workout.sets} sets',
              ),
              const SizedBox(width: 12),
              _InfoChip(icon: Icons.repeat_rounded, label: workout.repsRange),
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

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
