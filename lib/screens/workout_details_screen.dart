import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import 'dart:ui';
import '../widgets/workout_chat_modal.dart';
import '../services/cache_service.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailsScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> with SingleTickerProviderStateMixin {
  static const Duration _animationDuration = Duration(milliseconds: 200);
  static const double _swipeThreshold = 50.0;
  
  final ValueNotifier<bool> _isExpandedNotifier = ValueNotifier<bool>(false);
  late final AnimationController _animationController;
  late final Animation<double> _headerScaleAnimation;
  
  double _startX = 0.0;
  double _currentX = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    _headerScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _isExpandedNotifier.dispose();
    super.dispose();
  }

  void _handleSwipe(BuildContext context, double delta) {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    final workouts = workoutProvider.workouts;
    final currentIndex = workouts.indexWhere((w) => w.id == widget.workout.id);

    if (delta.abs() > _swipeThreshold) {
      if (delta > 0 && currentIndex > 0) {
        _navigateToWorkout(context, workouts[currentIndex - 1], true);
      } else if (delta < 0 && currentIndex < workouts.length - 1) {
        _navigateToWorkout(context, workouts[currentIndex + 1], false);
      }
    }
  }

  void _navigateToWorkout(BuildContext context, Workout workout, bool isPrevious) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
          WorkoutDetailsScreen(workout: workout),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(isPrevious ? -1.0 : 1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF4ECDC4).withOpacity(0.1),
              const Color(0xFF45B7D1).withOpacity(0.1),
            ],
          ),
        ),
        child: Stack(
          children: [
            _MainContent(
              workout: widget.workout,
              isExpandedNotifier: _isExpandedNotifier,
              onSwipeStart: (details) {
                setState(() => _startX = details.globalPosition.dx);
              },
              onSwipeUpdate: (details) {
                setState(() => _currentX = details.globalPosition.dx);
              },
              onSwipeEnd: (details) {
                _handleSwipe(context, _currentX - _startX);
              },
            ),
            _Header(workout: widget.workout),
          ],
        ),
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  final Workout workout;
  final ValueNotifier<bool> isExpandedNotifier;
  final Function(DragStartDetails) onSwipeStart;
  final Function(DragUpdateDetails) onSwipeUpdate;
  final Function(DragEndDetails) onSwipeEnd;

  const _MainContent({
    required this.workout,
    required this.isExpandedNotifier,
    required this.onSwipeStart,
    required this.onSwipeUpdate,
    required this.onSwipeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: onSwipeStart,
      onHorizontalDragUpdate: onSwipeUpdate,
      onHorizontalDragEnd: onSwipeEnd,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.top + 60),
          ),
          SliverToBoxAdapter(
            child: _WorkoutImage(workout: workout),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _WorkoutInstructions(
                  workout: workout,
                  isExpandedNotifier: isExpandedNotifier,
                ),
                const SizedBox(height: 16),
                _NextWorkouts(workout: workout),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutImage extends StatelessWidget {
  final Workout workout;

  const _WorkoutImage({required this.workout});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context),
      child: Container(
        width: double.infinity,
        height: 350,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(32),
            bottom: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Hero(
              tag: 'workout_image_fullscreen_${workout.id}',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                    bottom: Radius.circular(32),
                  ),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      workout.image,
                      cacheManager: CacheService.instance.workoutImageCache,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                      bottom: Radius.circular(32),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showFullScreenImage(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.fullscreen,
                      color: Color(0xFF2D3142),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  void _showFullScreenImage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenImageView(
            imageUrl: workout.image,
            heroTag: 'workout_image_fullscreen_${workout.id}',
          );
        },
      ),
    );
  }
}

class _WorkoutInstructions extends StatelessWidget {
  final Workout workout;
  final ValueNotifier<bool> isExpandedNotifier;

  const _WorkoutInstructions({
    required this.workout,
    required this.isExpandedNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isExpandedNotifier,
      builder: (context, isExpanded, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitle(context, isExpanded),
            const SizedBox(height: 8),
            _buildInstructions(context, isExpanded),
            if (workout.tips.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildTips(context, isExpanded),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTitle(BuildContext context, bool isExpanded) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF4ECDC4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Color(0xFF4ECDC4),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Instructions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                color: const Color(0xFF2D3142),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            isExpandedNotifier.value = !isExpanded;
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            foregroundColor: const Color(0xFF4ECDC4),
          ),
          child: Text(
            isExpanded ? 'Show Less' : 'Show More',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions(BuildContext context, bool isExpanded) {
    return AnimatedCrossFade(
      firstChild: Text(
        workout.instructions,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF2D3142).withOpacity(0.7),
          height: 1.3,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      secondChild: Text(
        workout.instructions,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF2D3142).withOpacity(0.7),
          height: 1.3,
        ),
      ),
      crossFadeState: isExpanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildTips(BuildContext context, bool isExpanded) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B6B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: Color(0xFFFF6B6B),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              workout.tips,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF2D3142),
                height: 1.3,
              ),
              maxLines: isExpanded ? null : 2,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextWorkouts extends StatelessWidget {
  final Workout workout;

  const _NextWorkouts({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, _) {
        final workouts = provider.workouts;
        final currentIndex = workouts.indexWhere((w) => w.id == workout.id);
    final previousWorkout = currentIndex > 0 ? workouts[currentIndex - 1] : null;
    final nextWorkout = currentIndex < workouts.length - 1 ? workouts[currentIndex + 1] : null;

    if (previousWorkout == null && nextWorkout == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF45B7D1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF45B7D1).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.sync,
                color: Color(0xFF45B7D1),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Other Workouts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    color: const Color(0xFF2D3142),
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (previousWorkout != null)
              _WorkoutNavigationItem(
            workout: previousWorkout,
            label: 'Previous',
            icon: Icons.arrow_back_ios,
            delay: 200,
          ),
        if (nextWorkout != null)
              _WorkoutNavigationItem(
            workout: nextWorkout,
            label: 'Next',
            icon: Icons.arrow_forward_ios,
            delay: 400,
          ),
      ],
    );
      },
    );
  }
}

class _WorkoutNavigationItem extends StatelessWidget {
  final Workout workout;
  final String label;
  final IconData icon;
  final int delay;

  const _WorkoutNavigationItem({
    required this.workout,
    required this.label,
    required this.icon,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  WorkoutDetailsScreen(workout: workout),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF45B7D1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF45B7D1).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF45B7D1).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: workout.image,
                    fit: BoxFit.cover,
                    cacheManager: CacheService.instance.workoutImageCache,
                    useOldImageOnUrlChange: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF45B7D1).withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workout.exercise,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3142),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${workout.sets} sets • ${workout.repsRange}',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF2D3142).withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                icon,
                size: 16,
                color: const Color(0xFF2D3142).withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 400.ms, delay: delay.ms)
        .slideX(begin: label == 'Previous' ? -0.2 : 0.2, end: 0);
  }
}

class _Header extends StatelessWidget {
  final Workout workout;

  const _Header({required this.workout});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
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
        child: Row(
          children: [
            _BackButton(onPressed: () => Navigator.pop(context)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Workout Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  Text(
                    'Day ${workout.day}',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF2D3142).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            _AskAIButton(workout: workout),
          ],
        ),
      ).animate().slideY(
        begin: -1,
        duration: 400.ms,
        curve: Curves.easeOutQuart,
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF4ECDC4).withOpacity(0.1),
                const Color(0xFF45B7D1).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF2D3142),
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _AskAIButton extends StatelessWidget {
  final Workout workout;

  const _AskAIButton({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: WorkoutChatModal(
                workoutName: workout.exercise,
                workout: workout,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4ECDC4),
                Color(0xFF45B7D1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4ECDC4).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 14,
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .scaleXY(
                  duration: 2.seconds,
                  begin: 0.9,
                  end: 1.1,
                  curve: Curves.easeInOut,
                )
                .then()
                .scaleXY(
                  duration: 2.seconds,
                  begin: 1.1,
                  end: 0.9,
                  curve: Curves.easeInOut,
                ),
              const SizedBox(width: 4),
              const Text(
                'Ask AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullScreenImageView extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const _FullScreenImageView({
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Hero(
                  tag: heroTag,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.black12,
                      child: const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                    cacheManager: CacheService.instance.workoutImageCache,
                    useOldImageOnUrlChange: true,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '1080 × 1080',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
} 