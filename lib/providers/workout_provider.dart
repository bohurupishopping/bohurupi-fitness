import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout.dart';

class WorkoutProvider extends ChangeNotifier {
  List<Workout> _workouts = [];
  String _selectedDay = 'Back';
  Set<String> _completedWorkouts = {};

  List<Workout> get workouts => _workouts;
  String get selectedDay => _selectedDay;
  Set<String> get completedWorkouts => _completedWorkouts;
  List<Workout> get filteredWorkouts => _workouts.where((w) => w.day == _selectedDay).toList();

  Future<void> loadWorkouts() async {
    try {
      final String response = await rootBundle.loadString('json/workout_database.json');
      final List<dynamic> data = json.decode(response);
      _workouts = data.map((json) => Workout.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading workouts: $e');
    }
  }

  void setSelectedDay(String day) {
    _selectedDay = day;
    notifyListeners();
  }

  void toggleWorkoutCompletion(String workoutId) {
    if (_completedWorkouts.contains(workoutId)) {
      _completedWorkouts.remove(workoutId);
    } else {
      _completedWorkouts.add(workoutId);
    }
    notifyListeners();
  }

  bool isWorkoutCompleted(String workoutId) {
    return _completedWorkouts.contains(workoutId);
  }

  List<String> get uniqueDays {
    return _workouts
        .map((workout) => workout.day)
        .toSet()
        .toList();
  }
} 