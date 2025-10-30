class TravelPlan {
  final String destination;
  final int duration;
  final String overview;
  final List<DailyPlan> dailyPlan;
  final String transportation;
  final List<String> tips;

  TravelPlan({
    required this.destination,
    required this.duration,
    required this.overview,
    required this.dailyPlan,
    required this.transportation,
    required this.tips,
  });

  factory TravelPlan.fromJson(Map<String, dynamic> json) {
    return TravelPlan(
      destination: json['destination'] ?? '',
      duration: json['duration'] ?? 0,
      overview: json['overview'] ?? '',
      dailyPlan: (json['daily_plan'] as List<dynamic>?)
              ?.map((e) => DailyPlan.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      transportation: json['transportation'] ?? '',
      tips: (json['tips'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
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
      activities: (json['activities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      meals: (json['meals'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      accommodation: json['accommodation'] ?? '',
    );
  }
}

