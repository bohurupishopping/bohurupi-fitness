import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import 'dart:ui';
import '../widgets/workout_chat_modal.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailsScreen({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> _isExpandedNotifier = ValueNotifier<bool>(false);
  late AnimationController _animationController;
  late Animation<double> _headerScaleAnimation;
  double _startX = 0.0;
  double _currentX = 0.0;
  static const double _swipeThreshold = 50.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Container(
        height: size.height,
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
            // Main content
            GestureDetector(
              onHorizontalDragStart: (details) {
                setState(() {
                  _startX = details.globalPosition.dx;
                });
              },
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _currentX = details.globalPosition.dx;
                });
              },
              onHorizontalDragEnd: (details) {
                final delta = _currentX - _startX;
                final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
                final workouts = workoutProvider.workouts;
                final currentIndex = workouts.indexWhere((w) => w.id == widget.workout.id);

                if (delta.abs() > _swipeThreshold) {
                  if (delta > 0 && currentIndex > 0) {
                    // Swipe right - go to previous workout
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            WorkoutDetailsScreen(workout: workouts[currentIndex - 1]),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-1.0, 0.0),
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
                  } else if (delta < 0 && currentIndex < workouts.length - 1) {
                    // Swipe left - go to next workout
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            WorkoutDetailsScreen(workout: workouts[currentIndex + 1]),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
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
                }
              },
              child: _buildMainContent(context),
            ),
            
            // New header with back button
            SafeArea(
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
                    // Back button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
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
                    ),
                    const SizedBox(width: 16),
                    // Title
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workout Details',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3142),
                            ),
                          ),
                          Text(
                            'Day ${widget.workout.day}',
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF2D3142).withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add Ask AI button
                    Material(
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
                                workoutName: widget.workout.exercise,
                                workout: widget.workout,
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
                    ),
                  ],
                ),
              ),
            ).animate().slideY(
              begin: -1,
              duration: 400.ms,
              curve: Curves.easeOutQuart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageHeight = size.height * 0.35;
    final contentPadding = size.height * 0.015;
    final topPadding = MediaQuery.of(context).padding.top + 60;

    return GestureDetector(
      onHorizontalDragStart: (details) {
        setState(() {
          _startX = details.globalPosition.dx;
        });
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          _currentX = details.globalPosition.dx;
        });
      },
      onHorizontalDragEnd: (details) {
        final delta = _currentX - _startX;
        final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
        final workouts = workoutProvider.workouts;
        final currentIndex = workouts.indexWhere((w) => w.id == widget.workout.id);

        if (delta.abs() > _swipeThreshold) {
          if (delta > 0 && currentIndex > 0) {
            // Swipe right - go to previous workout
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    WorkoutDetailsScreen(workout: workouts[currentIndex - 1]),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-1.0, 0.0),
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
          } else if (delta < 0 && currentIndex < workouts.length - 1) {
            // Swipe left - go to next workout
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    WorkoutDetailsScreen(workout: workouts[currentIndex + 1]),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
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
        }
      },
      child: Container(
        height: size.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top padding for header
                SliverToBoxAdapter(
                  child: SizedBox(height: topPadding),
                ),
                // Image section
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: imageHeight,
                    child: _buildMainImage(context),
                  ),
                ),
                // Instructions and next workouts
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, size.height * 0.08),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildInstructionsCard(context),
                      SizedBox(height: contentPadding),
                      _buildNextWorkouts(context),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainImage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              return _FullScreenImageView(
                imageUrl: widget.workout.image,
                heroTag: 'workout_image_fullscreen_${widget.workout.id}',
              );
            },
          ),
        );
      },
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
              tag: 'workout_image_fullscreen_${widget.workout.id}',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                    bottom: Radius.circular(32),
                  ),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(widget.workout.image),
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
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return _FullScreenImageView(
                            imageUrl: widget.workout.image,
                            heroTag: 'workout_image_fullscreen_${widget.workout.id}',
                          );
                        },
                      ),
                    );
                  },
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
              ).animate().scale(delay: 800.ms),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms);
  }

  Widget _buildCompactTitleStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isExpandedNotifier,
      builder: (context, isExpanded, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4ECDC4).withOpacity(0.9),
                    const Color(0xFF45B7D1).withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.workout.exercise,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.1,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Day ${widget.workout.day}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCompactTitleStat(
                          icon: Icons.fitness_center,
                          value: '${widget.workout.sets}',
                          label: 'Sets',
                        ),
                        const SizedBox(width: 6),
                        _buildCompactTitleStat(
                          icon: Icons.repeat,
                          value: widget.workout.repsRange,
                          label: 'Reps',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Instructions header
            Row(
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
                    _isExpandedNotifier.value = !isExpanded;
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
            ),
            const SizedBox(height: 8),
            AnimatedCrossFade(
              firstChild: Text(
                widget.workout.instructions,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF2D3142).withOpacity(0.7),
                      height: 1.3,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(
                widget.workout.instructions,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF2D3142).withOpacity(0.7),
                      height: 1.3,
                    ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
            if (widget.workout.tips.isNotEmpty) ...[
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Container(
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
                        widget.workout.tips,
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
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNextWorkouts(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final workouts = workoutProvider.workouts;
    final currentIndex = workouts.indexWhere((w) => w.id == widget.workout.id);
    
    // Get previous and next workouts
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
          _buildWorkoutNavigationItem(
            context,
            workout: previousWorkout,
            label: 'Previous',
            icon: Icons.arrow_back_ios,
            delay: 200,
          ),
        if (nextWorkout != null)
          _buildWorkoutNavigationItem(
            context,
            workout: nextWorkout,
            label: 'Next',
            icon: Icons.arrow_forward_ios,
            delay: 400,
          ),
      ],
    );
  }

  Widget _buildWorkoutNavigationItem(
    BuildContext context, {
    required Workout workout,
    required String label,
    required IconData icon,
    required int delay,
  }) {
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

class _FullScreenImageView extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const _FullScreenImageView({
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final size = MediaQuery.of(context).size;
    final screenAspectRatio = size.width / size.height;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image with pinch to zoom
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Hero(
                      tag: heroTag,
                      child: Container(
                        width: size.width,
                        height: size.width, // Make it square 1:1 aspect ratio
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
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Close button with improved visibility
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
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
                  // Image dimensions indicator
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