import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeHeader extends StatelessWidget {
  final bool showSearch;
  final VoidCallback onSearchToggle;
  final AnimationController searchController;

  const HomeHeader({
    super.key,
    required this.showSearch,
    required this.onSearchToggle,
    required this.searchController,
  });

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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                        const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                        const Color(0xFF45B7D1).withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF4ECDC4).withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
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
                              const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                              const Color(0xFF45B7D1).withValues(alpha: 0.1),
                            ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        if (showSearch)
                          BoxShadow(
                            color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
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
                  ).animate()
                    .scale(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
