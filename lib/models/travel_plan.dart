class TravelPlan {
  final String id;
  final String destination;
  final int duration;
  final String overview;
  final List<DailyPlan> dailyPlan;
  final String transportation;
  final List<String> tips;
  final DateTime timestamp;

  TravelPlan({
    required this.id,
    required this.destination,
    required this.duration,
    required this.overview,
    required this.dailyPlan,
    required this.transportation,
    required this.tips,
    required this.timestamp,
  });

  factory TravelPlan.fromJson(Map<String, dynamic> json) {
    return TravelPlan(
      id: json['id'] ?? '',
      destination: json['destination'] ?? '',
      duration: json['duration'] ?? 0,
      overview: json['overview'] ?? '',
      dailyPlan:
          (json['daily_plan'] as List<dynamic>?)
              ?.map((e) => DailyPlan.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      transportation: json['transportation'] ?? '',
      tips:
          (json['tips'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination': destination,
      'duration': duration,
      'overview': overview,
      'daily_plan': dailyPlan.map((e) => e.toJson()).toList(),
      'transportation': transportation,
      'tips': tips,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class DailyPlan {
  final int day;
  final List<String> activities;
  final List<String> meals;
  final String accommodation;

  DailyPlan({
    required this.day,
    required this.activities,
    required this.meals,
    required this.accommodation,
  });

  factory DailyPlan.fromJson(Map<String, dynamic> json) {
    return DailyPlan(
      day: json['day'] ?? 0,
      activities:
          (json['activities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      meals:
          (json['meals'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      accommodation: json['accommodation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'activities': activities,
      'meals': meals,
      'accommodation': accommodation,
    };
  }
}
