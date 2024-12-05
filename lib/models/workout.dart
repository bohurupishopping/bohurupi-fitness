class Workout {
  final String id;
  final String day;
  final String exercise;
  final String image;
  final String instructions;
  final String tips;
  final int sets;
  final String repsRange;

  Workout({
    required this.id,
    required this.day,
    required this.exercise,
    required this.image,
    required this.instructions,
    required this.tips,
    required this.sets,
    required this.repsRange,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['ID'] as String,
      day: json['Day'] as String,
      exercise: json['Exercise'] as String,
      image: json['Image'] as String,
      instructions: json['Instructions'] as String,
      tips: json['Tips'] as String,
      sets: json['Sets'] as int,
      repsRange: json['Reps Range'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Day': day,
      'Exercise': exercise,
      'Image': image,
      'Instructions': instructions,
      'Tips': tips,
      'Sets': sets,
      'Reps Range': repsRange,
    };
  }
} 